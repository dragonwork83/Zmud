--
-- murong_puren.lua
--
--[[
    慕容系列任务一:  慕容仆人任务
--]]
murong = {
	new = function()
		local l = {}
		setmetatable(l, {__index = murong})
		return l
	end
}

-- ---------------------------------------------------------------
-- 慕容任务入口
-- ---------------------------------------------------------------
function murong:start()
	AddTrigger(
		"慕容家贼",
		"慕容家贼接到任务1",
		"仆人叹道：家贼难防，有人偷走了少爷的信件，据传曾在『(.*)』附近出现，你去把它找回来吧！",
		"murong:taskactivate"
	)	
	AddTrigger(
		"慕容家贼",
		"慕容家贼接到任务2",
		"能为慕容世家出力，真是太好了。」仆人叹道：家贼难防，有人偷走了少爷的信件，据传曾在『(.*)』附近出现，你去把它找回来吧！",
		"murong:taskactivate"
	)
	AddTrigger("慕容家贼", "接到图片任务地址", "^仆人叹道：家贼难防，有人偷走了少爷的信件，据传曾在以下地点附近出现，你去把它找回来吧！", [[RemoveObserver("murongAskJobOb")]])
	AddTrigger("慕容家贼", "任务完成奖励", "^由于你成功的找回慕容复写给江湖豪杰的信件，被奖励：", "murong:finish")
	AddTrigger(
		"慕容家贼",
		"家贼死了",
		"^慕容世家家贼死了。$",
		function()
			fight.finish()
			NewObserver("murongGetAllFromCorpseOb", "get gold;get all from corpse", 6)
		end
	)
	AddTrigger(
		"慕容家贼",
		"仆人busy",
		"^仆人忙着呢，等会吧。$",
		function()
			tempTimer(1, [[send("give xin to pu ren")]])
		end
	)
	AddTrigger(
		"慕容家贼",
		"这里不准战斗",
		"^(这里不准战斗。|这里禁止战斗。)",
		function()
			send("ask " .. string.lower(score.id) .. "'s murong jiazei about fight")
			EnableTrigger("慕容家贼", "离开安全区")
		end
	)
	AddTrigger("慕容家贼", "战斗完成", "^你从慕容世家家贼的尸体身上搜出一封信件。", "murong:gobackandsubmit")
	AddTrigger(
		"慕容家贼",
		"离开安全区",
		"(慕容世家家贼往(.*)离开。|慕容世家家贼往(.*)落荒而逃了。)",
		function()
			send("yun powerup")
			tempTimer(1, [[fight.kill("jiazei")]])
			DisableTrigger("慕容家贼", "离开安全区")
		end
	)
	DisableTrigger("慕容家贼", "离开安全区")
	AddTrigger(
		"慕容家贼",
		"放弃任务完成",
		"^由于你没有找回慕容复丢失的信件，被扣除：",
		function()
			tempTimer(1, [[murong:finish()]])
		end
	)
	AddTrigger(
		"慕容家贼",
		"放弃任务",
		"^仆人一脚踢向你的屁股，留下一个清楚的鞋印，好爽！",
		function()
			RemoveObserver("murongAskJobOb")
			send("ask pu ren about fail")
		end
	)
	AddTrigger("慕容家贼", "你找不到 corpse", "^你找不到 corpse 这样东西。", [[RemoveObserver("murongGetAllFromCorpseOb")]])
	AddAlias("jc","^jc (.*)",[[murong:taskhandle(matches[2])]])
	AddAlias("refind","^refind$","murong:refind")
	murong:taketask()
end
-- ---------------------------------------------------------------
-- 去接任务
-- ---------------------------------------------------------------
function murong:taketask()
	pkuxkx.gps.gotodoExtend(
		"苏州",
		"茶馆",
		function()
			NewObserver("murongAskJobOb", "ask pu ren about job")
		end
	)
end
-- ---------------------------------------------------------------
-- 任务触发
-- ---------------------------------------------------------------
function murong:taskactivate()
	RemoveObserver("murongAskJobOb")
	local address = pkuxkx.gps.FixAddress(matches[2])
	murong:taskhandle(address)
end
-- ---------------------------------------------------------------
-- 去目的地查找target
-- ---------------------------------------------------------------
function murong:find(city, roomname)
	-- 初始化搜寻条件,避免上次的搜寻条件影响本次查询
    pkuxkx.seek.Init()
    pkuxkx.seek.session.foundoutEvent = function()
        cecho("<green>\n找到在 " .. pkuxkx.seek.session.NPCLocation .. " 的 " .. pkuxkx.seek.session.NPCName)
		if string.find(pkuxkx.seek.session.NPCId, string.lower(score.id)) then
			fight.kill(pkuxkx.seek.session.NPCId)
		end
    end
    pkuxkx.seek.session.failSeekEvent = function()
			add_log("【慕容仆人】: 任务失败,找不到NPC, 地址: " .. city .. roomname .. "\n")
			cecho("\n<purple>慕容仆人任务失败: 找不到 " .. pkuxkx.seek.session.NPCName.."\n")
			-- murong:cancel()
    end
	pkuxkx.seek.LookFor(quest.target, city, roomname, 5)
end
-- ---------------------------------------------------------------
-- 重新查找
-- ---------------------------------------------------------------
function murong:refind()
	murong:taskhandle(quest.location)
end
-- ---------------------------------------------------------------
-- 开始
-- ---------------------------------------------------------------
function murong:taskhandle(location)
	RemoveObserver("murongAskJobOb")
	quest.name = "慕容家贼任务"
	quest.status = "开始寻找家贼"
	quest.location = location
	quest.target = score.name .. "发现的 慕容世家家贼"
	quest.desc = ""
	quest.note = ""
	-- GUI 显示
	quest:update()

	-- 修正特殊地点
	quest.location = pkuxkx.gps.FixAddress(quest.location)
	local city, roomname = MapHelp.getAddress(quest.location)
	if city then
		cecho("\n<green>可以前往area:" .. city .. " | room:" .. roomname.."\n")
		send("yun powerup")
		murong:find(city, roomname)
	else
		add_log("【慕容仆人】: 任务失败,找不到NPC, 地址: " .. quest.location .. "\n")
		cecho("\n<purple>慕容仆人任务失败: 找不到 " .. pkuxkx.seek.session.NPCName.."\n")
		murong:cancel()
	end
end
-- ---------------------------------------------------------------
-- 杀死家贼后, 从尸体上获取到信件触发
-- ---------------------------------------------------------------
function murong:gobackandsubmit()
	RemoveObserver("murongGetAllFromCorpseOb")
	fight.finish()
	check_halt(
		function()
			pkuxkx.gps.gotodoExtend(
				"苏州",
				"茶馆",
				function()
					exe("hp;give xin to pu ren")
				end
			)
		end
	)
end
-- ---------------------------------------------------------------
-- 任务失败, 取消任务
-- ---------------------------------------------------------------
function murong:cancel()
	check_halt(
		function()
			pkuxkx.gps.gotodoExtend(
				"苏州",
				"茶馆",
				function()
					RemoveObserver("murongAskJobOb")
					send("ask pu ren about fail")
				end
			)
		end
	)
end
-- ---------------------------------------------------------------
-- 任务完成, 获得奖励触发
-- ---------------------------------------------------------------
function murong:finish()
	KillTriggerGroup("慕容家贼")
	exe("hp;i")
	job.prepare(
		function()
			job.tasking(murong)
		end
	)
end
