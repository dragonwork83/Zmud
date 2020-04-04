sour = { area = '襄阳城', room = '当铺' }
dest = { area = '襄阳城', room = '当铺' }


-- ---------------------------------------------------------------
-- locate_finish 用于标记是否当前定位已完成,并且记录下一个动作要作什么, 如为 0 ,则无下一个动作,正常执行下面, 如为 ~= 0, 则被赋值为函数名
-- 如 locate_finish='hsssl_goon'  后续判断时可继续执行_G[locate_finish](), 即 = hsssl_goon()
-- ---------------------------------------------------------------

locate_finish = 0

-- ---------------------------------------------------------------
-- 将获取到的exit出口字符串 转换为 table数组并返回
-- ---------------------------------------------------------------
function exit_set(exit)
    local l_set = {}
    local l_exit = utf8.trim(exit)
    for w in string.gmatch(l_exit, "(%a+)") do
        table.insert(l_set, w)
    end

    return l_set
end
-- ---------------------------------------------------------------
-- 开始定位初始化
-- ---------------------------------------------------------------
function locate_Init()
    enableTrigger("locate")
    enableTrigger("look locate")
    enableTrigger("locate_unknown")
    exit.locl = {}
    init_location()
    location.area = "不知道哪里"
    location.dir = "east"
end
-- ---------------------------------------------------------------
-- 发送定位指令
-- ---------------------------------------------------------------
function locate_cmd()
    -- enableTrigger("locate5")
    -- exe('alias action 正在定位')
    locate_Init()
    exe("id here;set look;l;time")
end
-- ---------------------------------------------------------------
-- 开始重新准确定位当前位置
-- ---------------------------------------------------------------
function locate()
    locate_cmd()
    AddTimer("locateWait", 0.3, "locate_cmd")
end
-- ---------------------------------------------------------------
-- 发送快速定位指令
-- ---------------------------------------------------------------
function fastLocate_cmd()
    -- enableTrigger("locate5")
    -- exe('alias action 正在定位')
    locate_Init()
    exe("set look;l")
end
-- ---------------------------------------------------------------
-- 开始快速定位
-- ---------------------------------------------------------------
function fastLocate()
    fastLocate_cmd()
    AddTimer("fastlocateWait", 0.3, "fastLocate_cmd")
end
-- ---------------------------------------------------------------
-- 根据 where(襄阳城当铺) 定位当前的 area和room
-- ---------------------------------------------------------------
function locateroom(where)
    local l_dest = { }
    where = utf8.trim(where)
    if string.find(where, "/") then
        local l_path = Mushmap:getPath("xiangyang/dangpu", where)
        if l_path then
            return where
        end
    else
        l_dest.room, l_dest.area = MapHelp.getAddr(utf8.trim(where))
    end
    if l_dest.area then
        local l_rooms = MapHelp.getRooms(l_dest.room, l_dest.area)
        for k, v in pairs(l_rooms) do
            local l_path = Mushmap:getPath("xiangyang/dangpu", v)
            if l_path then
                return l_dest.area, l_dest.room
            end
        end
    end
    for p in pairs(Mushmap.rooms) do
        if Mushmap.rooms[p].objs then
            for k in pairs(Mushmap.rooms[p].objs) do
                if k == where then
                    local l_path = Mushmap:getPath("xiangyang/dangpu", p)
                    if l_path then
                        return p
                    end
                end
            end
        end
    end
    return false
end

-- ---------------------------------------------------------------
-- 创建链表
-- ---------------------------------------------------------------
List = {}
function List.new(val)
    return {pnext = nil, index = val}
end
-- ---------------------------------------------------------------
-- 添加一个节点
-- ---------------------------------------------------------------
function List.addNode(nodeParent, nodeChild)
    nodeChild.pnext = nodeParent.pnext
    nodeParent.pnext = nodeChild
    return nodeChild
end

-- ---------------------------------------------------------------
-- 搜索 准备工作
-- ---------------------------------------------------------------
function searchPre()
    road.rooms = {}
    -- print(road.id)
    local p_room = Mushmap.rooms[road.id].name
    local p_dest = MapHelp.getLookCity(road.id)
    local l_distance = 6
    if job.name and (job.name == "clb" or job.name == "tdh" or job.name == "tmonk") and flag.times == 1 then
        l_distance = 2
    end
    if job.name and job.name == "xueshan" and flag.times == 1 then
        l_distance = 4
    end
    if job.name and job.name == "wudang" then
        l_distance = wd_distance
    --messageShow('武当任务：        没找到人，继续搜索，范围【'.. l_distance ..'】！')
    end
    if job.name and job.name == "huashan" then
        if job.room == "碎石路" or job.room == "侧廊" then
            l_distance = 1
        else
            l_distance = 3
        end
    --messageShow('华山任务：        没找到人，继续搜索，范围【'.. l_distance ..'】！')
    end
    if p_dest == nil then
        p_dest = Mushmap.rooms[road.id].outdoor
    end
    local rooms = MapHelp.getAroundRooms(p_room, p_dest, l_distance, "all")
    roomsnum = countTab(rooms)
    -- 构造邻接表，用于递归搜索
    -- 插入起始road.id
    starttime = os.clock()
    -- 测试计算时间
    newrooms = {}
    for id in pairs(rooms) do
        table.insert(newrooms, id)
    end

    myrt = {}

    for _, roomid in pairs(newrooms) do
        -- 插入房间链表
        roomV = List.new(roomid)
        local node = roomV
        for k, v in pairs(newrooms) do
            -- 所有的房间id
            for route, link_way in pairs(Mushmap.rooms[roomid].ways) do
                -- 当前id的出口
                local routeLength = Mushmap.rooms[roomid]:length(route)
                -- 获取路径方向是否可达，返回false标示此路不通，那么这个方向的路就不插入出口链表
                -- print("k="..k.."|link_way="..link_way.."|v="..v)
                if routeLength then
                    --- by fqyy 20170429 加入room.lengths的数值判断
                    if routeLength == 1 or routeLength > 1 and flag.times > 1 then
                        if v == link_way then
                            node = List.addNode(node, List.new(k))
                        -- 插入节点生成第一个房间的出口链表
                        end
                    end
                end
            end
        end
        table.insert(myrt, roomV)
    end
    visited = {}

    for i = 1, countTab(newrooms) do
        visited[i] = false
        -- 初始化所有节点未曾访问
    end

    if not visited[1] then
        FastDFS(myrt, 1)
    -- 计算起点的连通图
    end
    for i = 1, countTab(newrooms) do
        if visited[i] == false then
            -- 未曾访问的节点测试一下跟第一个起点的连通性，如果能联通，则递归这个节点
            local path, len = Mushmap:getPath(myrt[1].index, myrt[i].index)
            if path then
                FastDFS(myrt, i)
            -- 继续遍历指定的myrt[i]这个节点
            -- messageShow("发现通路，遍历下一个节点！通路长度="..len,"red")
            end
        end
    end
    -- wd_distance = wd_distance + 2    异常, 需重写该部分代码
    -- messageShow("【"..job.name.."】深度优先计算结束，遍历【"..roomsnum.."】个房间，用时【"..os.clock()-starttime.."】秒","SandyBrown")
end
-- ---------------------------------------------------------------
-- 搜索
-- ---------------------------------------------------------------
function search()
    tmp.find = true
    if flag.find == 1 then
        return
    end
    searchPre()
    cntr1 = countR(15)
    exe("look;halt")
    -- 搜索时间控制
    findTime=os.time()
    tmpsearch = 3
    return check_halt(searchStart, 1)
end
function searchStart()
    if flag.find == 1 then
        return
    end
    if flag.wait == 1 then
        return
    end
    if findTime<=os.time() - 3*60 then
       messageShow('搜寻时间超过上限,放弃寻找')
       return find_nobody()
    end
    if table.getn(road.rooms) == 0 then
        return find_nobody()
    end
    local path, length = Mushmap:getPath(road.id, road.rooms[1])
    -- print("path+length"..path.."|"..length)
    road.id = road.rooms[1]
    table.remove(road.rooms, 1)

    if type(path) ~= "string" then
        return searchStart()
    end

    if string.find(path, "#") or job.name ~= "huashan" then
        -- print("path:"..path)
        return searchFunc(path)
    else
        -- print("alias:"..string.sub(string.gsub(path, "halt;", ""),1,-2))
        exe(string.sub(string.gsub(path, "halt;", ""), 1, -2))
        _, tmpnum = string.gsub(path, ";", " ")
        tmpsearch = tmpsearch + tmpnum
        -- print("n="..tmpsearch)
        if tmpsearch > road.steps then
            -- return walk_wait()
            tmpsearch = 3
            -- print("apath:"..path)
            tempTimer(0.2,
                function()
                    searchStart()
                end
            )
        else
            tmpsearch = tmpsearch + 1
            return searchStart()
        end
    end
end
function searchFunc(path)
    if flag.find == 1 then
        return
    end
    if flag.wait == 1 then
        return
    end
    road.pathset = road.pathset or {}
    if path then
        road.pathset = string.split(path, ";")
        for i = 1, table.getn(road.pathset) do
            for p = 1, table.getn(road.pathset) do
                if isNil(road.pathset[p]) or road.pathset[p] == "halt" then
                    table.remove(road.pathset, p)
                    break
                end
            end
        end
    end
    if table.getn(road.pathset) == 0 then
        return searchStart()
    end
    -- for i=1,table.getn(road.pathset) do
    if string.find(road.pathset[1], "#") then
        local _, _, func, params = string.find(road.pathset[1], "^#(%a%w*)%s*(.-)$")
        if func then
            table.remove(road.pathset, 1)
            return _G[func](params)
        else
            exe(road.pathset[1])
            table.remove(road.pathset, 1)
            return walk_wait()
        end
    else
        exe(road.pathset[1])
        table.remove(road.pathset, 1)
        return walk_wait()
    end
    -- end
    -- return searchWait()
end
function searchWait()
    send("alias action 正在搜寻中")
end

function searchNpc(city, npc)
    if city then
        tmp.rooms = MapHelp.getCityRooms(city)
    end
    if npc then
        tmp.npc = npc
    end
    tmp.rooms = tmp.rooms or { }
    tmp.sour = tmp.sour or "city/dangpu"
    while countTab(tmp.rooms) > 0 do
        local l_sour = "city/dangpu"
        if tmp.sour ~= "city/dangpu" then
            l_sour = tmp.sour
        end
        local l_dest, l_distance = MapHelp.getNearRoom(l_sour, tmp.rooms)
        if l_dest then
            tmp.rooms = delElement(tmp.rooms, l_dest)
            local l_path = Mushmap:getPath(l_sour, l_dest)
            if l_path then
                tmp.sour = l_dest
                return go(searchNpcLocate, l_dest, '', l_sour)
            end
        else
            tmp.rooms = { }
        end
    end
    printTab(tmp.objs)
end
function searchNpcLocate()
    locate()
    return check_halt(searchNpcAdd, 1)
end
function searchNpcAdd()
    tmp.objs = tmp.objs or { }
    for p, q in pairs(location.id) do
        if tmp.npc and p == tmp.npc then
            exe('follow ' .. q)
            return disAll()
        end
        if ItemGet[p] or weaponStore[p] or weaponThrowing[p] or drugBuy[p] or drugPoison[p] or itemSave[p] then
            location.id[p] = nil
        end
        if string.find(p, "镖车") or string.find(p, "种子") or string.find(p, "残篇") or string.find(p, "精要") or string.find(p, "武将") or string.find(p, "官兵") or string.find(p, "削断的") or string.find(p, "传记") or string.find(p, "镖师") or string.find(p, "白银") or string.find(p, "火焰") or string.find(p, "设定环境变量") or string.find(p, "男尸") or string.find(p, "女尸") or string.find(p, "尸体") or string.find(p, "断掉的") or string.find(p, "粉碎的") or string.find(p, "首级") or string.find(p, "骷髅") or string.find(p, "骸骨") then
            location.id[p] = nil
        end
        if p == score.name or MudUser[p] then
            location.id[p] = nil
        end
        if location.item[p]["cloth"] or location.item[p]["shoes"] or location.item[p]["shoe"] or location.item[p]["blade"] or location.item[p]["sword"] then
            location.id[p] = nil
        end
        if Mushmap.rooms[tmp.sour] and Mushmap.rooms[tmp.sour].objs and type(Mushmap.rooms[tmp.sour].objs) == "table" then
            for k in pairs(Mushmap.rooms[tmp.sour].objs) do
                if p == k then
                    location.id[p] = nil
                end
            end
        end
    end
    if countTab(location.id) > 0 then
        for p, q in pairs(location.id) do
            tmp.objs[tmp.sour] = tmp.objs[tmp.sour] or { }
            tmp.objs[tmp.sour].objs = tmp.objs[tmp.sour].objs or { }
            tmp.objs[tmp.sour].objs[p] = q
        end
    end
    return searchNpc()
end

-- ---------------------------------------------------------------
-- ---------------------------------------------------------------
-- 搜索  -- end
-- ---------------------------------------------------------------
-- ---------------------------------------------------------------
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- Del Element
-- ---------------------------------------------------------------
function delElement(set, dir)
    local l_cnt = 0
    for i = 1, table.getn(set) do
        if set[i] == dir then
            l_cnt = i
            break
        end
    end
    table.remove(set, l_cnt)
    return set
end

function del_element(set, element)
    for i = 1, table.getn(element) do
        set = delElement(set, element[i])
    end
    return set
end

function del_string(string, sub)
    local l_s, l_e
    for i = 1, utf8.len(string) do
        l_s, l_e = string.find(string, sub)
        if l_s == nil then
            break
        end
        string = string.sub(string, 1, l_s - 1) .. string.sub(string, l_e + 1, utf8.len(string))
    end
    return string
end
-- ---------------------------------------------------------------
-- 走路间隔 - 防flood
-- ---------------------------------------------------------------
function walk_wait()
    enableTrigger("walk")
    if tmp.find then
        if type(cntr1) == "function" and cntr1() > 0 then
            AddTimer("walkWait", 0.1, [[send('alias action 正在赶路中')]])
        else
            cntr1 = countR(15)
        end
    else
        AddTimer("walkWait", 0.1, [[send('alias action 正在赶路中')]])
    end
end
-- ---------------------------------------------------------------
-- 疑似 走路间隔 - 防flood
-- ---------------------------------------------------------------
function walkBusy()
    return check_halt(walk_wait)
end
-- ---------------------------------------------------------------
-- 继续走下一段路
-- ---------------------------------------------------------------
function walk_goon()
    disableTrigger("walk")
    if walkWait ~= nil then
        KillTimer(walkWait)
    end
    if tmp.find then
        return searchFunc()
    end
    AddTimer('roadWait', road.wait, 'path_start')
end
-- ---------------------------------------------------------------
-- DFS
-- ---------------------------------------------------------------
function FastDFS(myrt, i)
    visited[i] = true
    -- 设置下标为I的顶点为已访问
    -- SJConfig.DebugShow("myrt["..i.."]="..myrt[i].index)  --输出顶点信息
    table.insert(road.rooms, myrt[i].index)
    local p = myrt[i].pnext
    -- 下一个边表结点
    if p == nil then return end
    while p ~= nil do

        if (not visited[p.index]) then
            -- 如果是未访问的则递归
            visited[p.index] = true
            FastDFS(myrt, p.index)
        end
        p = p.pnext
    end
end
function dfs(from)
    for i = 1, countTab(tmp.to) do
        if not tmp.to then
            break
        end
        local l_dest, l_p = MapHelp.getNearRoom(from, tmp.to)
        if l_dest then
            local l_check = true
            for v in pairs(road.rooms) do
                if v == l_dest then
                    l_check = false
                end
            end
            if l_check then
                local path, len = Mushmap:getPath(from, l_dest)
                if path then
                    table.insert(road.rooms, l_dest)
                    table.remove(tmp.to, l_p)
                    dfs(l_dest)
                end
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 原版Mush的goto 去往某个地方的主函数
-- ---------------------------------------------------------------
function SJ.goto(where)
    dis_all()
    local l_dest = { }
    sour.id = nil
    dest.id = nil
    tmp.goto = true
    where = utf8.trim(where)

    l_dest.area, l_dest.room = locateroom(where)

    if l_dest.area then
        return go(test, l_dest.area, l_dest.room)
    else
        return cecho("<red>找不到或无法到达此(地点|人物)：" .. where)
    end

end
-- ---------------------------------------------------------------
-- 原Mush go函数的预设置
-- ---------------------------------------------------------------
function go_setting(job, area, room, sId)
    tmp.goto = nil
    sour.id = sId
    dest.id = nil
    if area ~= nil then
        dest.area = area
    end
    if room ~= nil then
        dest.room = room
    end
    if string.find(dest.area, "/") then
        dest.id = dest.area
        dest.room = Mushmap.rooms[dest.id].name
    end
    if job == nil then
        job = test
    end
    flag.find = 0
    flag.wait = 0
    road.act = job
    road.i = 0
    flag.dw = 1
    tmp.find = nil
end
-- ---------------------------------------------------------------
-- 原Mush的go函数
-- ---------------------------------------------------------------
function go(job, area, room, sId)
    -- quest.status = "正在赶路中"
    -- if area ~= nil and room ~= nil then
    --     quest.location = area .. room
    -- end
    -- quest.update()
    go_setting(job, area, room, sId)
    -- if sour.id ~= nil then
    --   return check_busy(path_consider)
    -- else
    -- ain
    return check_halt(go_locate)
    -- end
end
-- ----------------------------------------------------------
-- 设定当前位置, 达到简化版Locate()的效果. (复杂地型不可用, 因缺少room_relation等参数)
-- ----------------------------------------------------------
function go_direct_pre(localarea, localroom, sID)
    sour.id = sID
    location.area = localarea
    location.room = localroom
    location.room_relation = ""
    location.where = location.area .. location.room
    road.id = nil
end
-- ----------------------------------------------------------
-- 在确定当前位置的前提下, 不需要Locate直接查找路径前往, 含checkwait功能
-- 注意 若有带sID参数,则需要sID(当前房间英文名),与localroom的中文名相匹配, 否则会造成错误
-- 如 localroom = "解脱坡" 则当有sID时,需必须为相对应的 "emei/jietuopo"
-- 通常sID用于某房间名有多个同名的情况下的唯一值鉴别, 如 "书房",中文同名很多,英文名可用于唯一值鉴别
-- 注意 此为非安全方法, 使用时应避免在迷宫,树林等地使用, 复杂地型请使用安全方法 go()
-- ----------------------------------------------------------
function go_direct(job, localarea, localroom, destarea, destroom, sID)
    -- quest.status = "正在赶路中"
    -- if area ~= nil and room ~= nil then
    --     quest.location = area .. room
    -- end
    -- quest.update()
    go_direct_pre(localarea, localroom, sID)
    go_setting(job, destarea, destroom, sId)
    check_busy(path_consider)
end
-- ----------------------------------------------------------
-- 功能同go_direct, 不含检查busy功能
-- ----------------------------------------------------------
function go_direct_pure(job, localarea, localroom, destarea, destroom, sID)
    -- quest.status = "正在赶路中"
    -- if area ~= nil and room ~= nil then
    --     quest.location = area .. room
    -- end
    -- quest.update()
    go_direct_pre(localarea, localroom, sID)
    go_setting(job, destarea, destroom, sId)
    path_consider()
end

function go_locate()
    -- check_cjn()
    locate()
    checkWait(path_consider, 0.3)
end

function goContinue()
    return go(road.act)
end
-- ---------------------------------------------------------------
-- 开始行走 go
-- ---------------------------------------------------------------
function go_confirm()
    locate_finish = 0
    -- checkWield()
    sour.id = nil
    if flag.go == nil then flag.go = 0 end
    flag.go = flag.go + 1
    if flag.go > 3 then flag.go = 0 end
    if location.room == dest.room or flag.go == 0 then
        if location.room == dest.room then
            chats_locate('定位系统：从【' .. sour.area .. sour.room .. '】出发，到达目的地【' .. dest.area .. dest.room .. '】！', 'seagreen')
        else
            chats_locate('定位系统：从【' .. sour.area .. sour.room .. '】出发，未达目的地【' .. dest.area .. dest.room .. '】，终点为【' .. location.area .. location.room .. '】！', 'cyan')
        end
        flag.go = 0
        if type(road.act) == "function" then
            return road.act()
        end
    else
        return go(road.act)
    end
end

-- ---------------------------------------------------------------
-- 找不到人handler
-- ---------------------------------------------------------------
function find_nobody()
    if string.find(job.name, 'songxin') then
        chats_log('定位系统：未能在【' .. job.area .. '】找到【' .. job.target .. '】！', 'songxinFindFail')
    end
    if job.name == 'wudang' then
        chats_log('定位系统：未能在【' .. job.area .. job.room .. '】找到【' .. job.target .. '】！', 'wudangFindFail')
        -- if flag.times>2 then return wudangFindFail() end
    end
    if job.name == 'clb' then
        chats_log('定位系统：未能在【' .. job.area .. job.room .. '】找到【' .. job.target .. '】！', 'clbFindFail')
    end
    if job.name == 'husong' then
        chats_log('定位系统：未能在【' .. job.area .. job.room .. '】找到【' .. job.target .. '】！', 'husongFindFail')
    end
    if job.name == 'xueshan' then
        chats_log('定位系统：未能在【' .. job.area .. job.room .. '】找到【' .. job.target .. '】！', 'xueshanFindFail')
    end
    if job.name == 'tdh' then
        chats_log('定位系统：未能在【' .. job.area .. job.room .. '】找到【' .. job.target .. '】！', 'tdhFindFail')
    end
    if job.name == 'huashan' then
        chats_log('定位系统：未能在【' .. dest.area .. dest.room .. '】找到【' .. job.target .. '】！', 'huashanFindFail')
    end
    if job.name == "Dummyjob" then
        chats_log('定位系统：未能在【' .. job.area .. job.room .. '】找到【' .. job.target4 .. '】！')
        return dummyover()
    end

    flag.times = flag.times + 1
    if flag.times > 3 or string.find(job.where,"后山小院") or (string.find(job.where,"武当") and string.find(job.where,"院门")) then
        jobFindFail = jobFindFail or { }
        if job.name and jobFindFail[job.name] then
            local p = jobFindFail[job.name]
            return _G[p]()
        end
    else
        jobFindAgain = jobFindAgain or { }
        if job.name and jobFindAgain[job.name] then
            local p = jobFindAgain[job.name]
            return _G[p]()
        end
    end

    return go(check_heal, '大理城', '药铺')
end

-- ---------------------------------------------------------------
-- 作用未知,  待观察
-- ---------------------------------------------------------------
function thread_resume(thread)
    if type(thread) == 'thread' then
        coroutine.resume(thread)
    end
end