
pkuxkx = pkuxkx or {}
luasqlenv = luasql.sqlite3()
sqlconn = luasqlenv:connect(getMudletHomeDir().."/Database_pkuxkx.db")

-- ---------------------------------------------------------------
-- 绑定 sysDataSendRequest 事件, 用于发送cmd至服务端时的处理
-- ---------------------------------------------------------------
function pkuxkx.SendHandle(event,cmd)
	pkuxkx.cmd = pkuxkx.cmd or {}
	pkuxkx.cmd.lastcmd = cmd
	pkuxkx.cmd.lasttime = os.time()
end
-- ---------------------------------------------------------------
-- 从DB加载所有NPC集合,并放入pkuxkx.NPC中
-- ---------------------------------------------------------------
function pkuxkx.GetAllNPC()
	pkuxkx.NPC = {}
	pkuxkx.NPCbranch = {}
	local cursor = sqlconn:execute("select * from person ")
	row = cursor:fetch({}, "a")
	while row do
		-- print(string.format("Id: %s, Name: %s", row.id, row.name))
		table.insert(pkuxkx.NPC, row)
		if pkuxkx.NPCbranch[row.name] == nil then
            pkuxkx.NPCbranch[row.name] = {}
        end
        table.insert(pkuxkx.NPCbranch[row.name], row)
		row = cursor:fetch({}, "a")
	end
	cursor:close()
	return nil
end
-- ---------------------------------------------------------------
-- 查找固定NPC的位置
-- ---------------------------------------------------------------
function pkuxkx.GetFixNPC(npcname)
	local thisnpc = nil
	local roomid = nil
	if pkuxkx.NPC == nil then
		pkuxkx.GetAllNPC()
	end
	if pkuxkx.NPC then
		for i = 1, #pkuxkx.NPC do
			if pkuxkx.NPC[i].name == npcname then
				thisnpc = thisnpc or {}
				table.insert(thisnpc, pkuxkx.NPC[i])
			end
		end
	else
		cecho("<purple>加载NPC数据集合异常")
	end
	return thisnpc
end
-- ---------------------------------------------------------------
-- 获取当前房间所有物品/NPC的集合(含中文名和英文名)
-- ---------------------------------------------------------------
function pkuxkx.GetRoomItems(script)
	enableTrigger("获取当前房间ID集合")
	exe("id here;response idhere 结束")

	pkuxkx.currentroomitems = pkuxkx.currentroomitems or {}
	if script then
		pkuxkx.currentroomitems.afterhandle = script
	end
end
-- ---------------------------------------------------------------
-- full 吃喝
-- ---------------------------------------------------------------
function pkuxkx.Feed()
	local feedmove = GetRoleConfig("feed")
	if feedmove and string.len(feedmove) > 2 then
		exe(feedmove)
	end
end
-- ---------------------------------------------------------------
-- 空闲时/等待时, 可以作一些动作
-- ---------------------------------------------------------------
function pkuxkx.LeisureHandle()
	local move = GetRoleConfig("leisuredoing")
	if move and string.len(move) > 2 then
		exe(move)
	end
end
