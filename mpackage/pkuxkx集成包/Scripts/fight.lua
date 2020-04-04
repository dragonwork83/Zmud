-----
-- fight.lua
--
-- ----------------------------------------------------------
-- 战斗相关
-- ----------------------------------------------------------
--
--[[
--]]
fight = fight or {}
fight.fighting = false
fight.time = {}
fight.time.b = os.time()
fight.time.e = os.time()
fight.time.over = os.time()
fight.time["refresh"] = 94

-- ---------------------------------------------------------------
-- 战斗提前准备                                                 --
-- ---------------------------------------------------------------
function fight.prepareInAdvance()
    if Role.settings.perform_InAdvance and string.len(Role.settings.perform_InAdvance) > 0 then
        exe(Role.settings.perform_InAdvance)
    end
end
-- ---------------------------------------------------------------
-- 战斗 下hit指令                                               --
-- ---------------------------------------------------------------
function fight.hit(npcname)
    fight.prepareInAdvance()
    exe("hit " .. npcname)
    fight.autopfm()
end
-- ---------------------------------------------------------------
-- 战斗 下kill指令                                              --
-- ---------------------------------------------------------------
function fight.kill(npcname)
    fight.prepareInAdvance()
    exe("killall " .. npcname)
    fight.autopfm()
end
-- ---------------------------------------------------------------
-- 战斗自动发pfm                                                --
-- ---------------------------------------------------------------
function fight.autopfm(cmd)
    if cmd then
        AddTimer("autopfm", 1, cmd)
    else
        if Role.settings.common_perform and string.len(Role.settings.common_perform) > 0 then
            AddTimer("autopfm", 1, Role.settings.common_perform)
        end
    end
end
-- ---------------------------------------------------------------
-- 战斗结束                                                --
-- ---------------------------------------------------------------
function fight.finish()
    fight.fighting = false
    KillTimer("autopfm")
end
-- ---------------------------------------------------------------
-- 战斗相关触发器
-- ---------------------------------------------------------------
function _fighttrigger()
    enableTrigger("fight")
end
-- ---------------------------------------------------------------
-- 战斗模块安装
-- ---------------------------------------------------------------
function fight.install()
    -- 添加战斗触发器
    _fighttrigger()
end
-- ---------------------------------------------------------------
-- 战斗过程中受伤状态检测
-- ---------------------------------------------------------------
-- function fight.statuscheck()
--     if matches[2] == "你" then
--         local l = matches[1]
--         -- print(l)
--         if string.find(l, "看起来气血充盈，并没有受伤") then
--             damage = 100
--             return fight_hurt()
--         end
--         if string.find(l, "似乎受了点轻伤，不过光从外表看不大出来") then
--             damage = 90
--             return fight_hurt()
--         end
--         if string.find(l, "看起来可能受了点轻伤") then
--             damage = 80
--             return fight_hurt()
--         end
--         if string.find(l, "受了几处伤，不过似乎并不碍事") then
--             damage = 70
--             return fight_hurt()
--         end
--         if string.find(l, "受伤不轻，看起来状况并不太好") then
--             damage = 60
--             return fight_hurt()
--         end
--         if string.find(l, "气息粗重，动作开始散乱，看来所受的伤着实不轻") then
--             damage = 50
--             return fight_hurt()
--         end
--         if string.find(l, "已经伤痕累累，正在勉力支撑着不倒下去") then
--             damage = 40
--             return fight_hurt()
--         end
--         if string.find(l, "受了相当重的伤，只怕会有生命危险") then
--             damage = 30
--             return fight_hurt()
--         end
--         if string.find(l, "伤重之下已经难以支撑，眼看就要倒在地上") then
--             damage = 20
--             return fight_hurt()
--         end
--         if string.find(l, "受伤过重，已经奄奄一息，命在旦夕了") then
--             damage = 10
--             return fight_hurt()
--         end
--         if string.find(l, "受伤过重，已经有如风中残烛，随时都可能断气") then
--             damage = 0
--             return fight_hurt()
--         end
--         if string.find(l, "看起来充满活力，一点也不累") then
--             damage = 99
--             return fight_hurt()
--         end
--         if string.find(l, "似乎有些疲惫，但是仍然十分有活力") then
--             damage = 88
--             return fight_hurt()
--         end
--         if string.find(l, "看起来可能有些累了") then
--             damage = 77
--             return fight_hurt()
--         end
--         if string.find(l, "动作似乎开始有点不太灵光，但是仍然有条不紊") then
--             damage = 66
--             return fight_hurt()
--         end
--         if string.find(l, "气喘嘘嘘，看起来状况并不太好") then
--             damage = 55
--             return fight_hurt()
--         end
--         if string.find(l, "似乎十分疲惫，看来需要好好休息了") then
--             damage = 44
--             return fight_hurt()
--         end
--         if string.find(l, "已经一副头重脚轻的模样，正在勉力支撑着不倒下去") then
--             damage = 33
--             return fight_hurt()
--         end
--         if string.find(l, "看起来已经力不从心了") then
--             damage = 22
--             return fight_hurt()
--         end
--         if string.find(l, "摇头晃脑、歪歪斜斜地站都站不稳，眼看就要倒在地上") then
--             damage = 11
--             return fight_hurt()
--         end
--         if string.find(l, "已经陷入半昏迷状态，随时都可能摔倒晕去") then
--             damage = 1
--             return fight_hurt()
--         end
--     end
-- end
