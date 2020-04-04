tmp = {}
master = {}
perform = {}
lost_name = 0
needdolost = 0
flagFull = {}
condition = {}
weapon = {}
team = {}

function SJ.Init()
    -- setAlias()
    KillAllTemporaryTrigger()
    KillAllTemporaryTimer()
    disWait()
    hp_trigger()
    fight.install()
    fight_prepare()
    -- idle()
    -- 初始化任务系统
    job.Init()
    -- 激活 消息过滤
    gag.Activate()
    -- 后续执行采用divider方式, divider的格式为","
    send("set divider ,")
    exe("set hpbrief long;set area_detail 1;halt;score;cha;hp;i;jifa all;jiali 1;")
end

function SJ.Main()
    SJ.Init()
    -- 检查配置文件, 若配置文件不完整, 则提示完善配置文件
    if countTab(job.zuhe) < 2 then
        cecho("\n<red>配置文件不完善,请先配置完整!~")
        return
    -- else
        -- return check_bei(hp_dazuo_count)
    end
end
-- ---------------------------------------------------------------
-- 开始执行
-- ---------------------------------------------------------------
function SJ.Start()
    return check_bei(check_food)
end

function disAll()
    DisableAllTemporaryTrigger()
    KillAllTemporaryTrigger()
    KillAllTemporaryTimer()
    KillAllTemporaryAlias()
    disWait()
    disableTrigger("任务准备")
    -- 走路 partial
    disableTrigger("单步行走")
    disableTrigger("坐船")
    disableTrigger("坐车")
    -- 新版行走
    pkuxkx.gps.stop()
    -- send("set brief 3")
    -- 任务 partial
    fight.install()
    -- fight_prepare()
    gag.Activate()

    enableTrigger("hp")
    enableTrigger("score")
end
function dis_all()
    DisableAllTemporaryTrigger()
    KillAllTemporaryTimer()
    KillAllTemporaryAlias()
    disWait()
    disableTrigger("任务准备")
    fight.install()
    -- fight_prepare()
    -- idle()
    gag.Activate()

    EnableTriggerGroup("chat", true)
    EnableTriggerGroup("hp", true)
    EnableTriggerGroup("score", true)
    EnableTriggerGroup("count", true)
    EnableTriggerGroup("fight", true)
    EnableTriggerGroup("job_exp", true)

    flag.find = 1
    -- idle()
end
-- ---------------------------------------------------------------
-- disable all halt/wait/busy
-- ---------------------------------------------------------------
function disWait()
    disableTrigger("checkwait")
    KillTimer("waitimer")

    disableTrigger("check_bei")
    DeleteTimer("bei")

    disableTrigger("check_halt")
    disableTimer("check_halt")

    disableTrigger("check_busy")
    DeleteTimer("busy")
end
-- ---------------------------------------------------------------
-- check_bei
-- ---------------------------------------------------------------
function check_bei(func, waitSec, args)
    disWait()
    enableTrigger("check_bei")
    beihook = func
    beihook_args = args
    send("bei bei bei")
    bei_timer(waitSec)
end
function bei_timer(waitSec)
    waitSec = waitSec or 0.6
    AddTimer("bei", waitSec, [[send("bei bei bei")]])
end
function beiok()
    DeleteTimer("bei")
    disableTrigger("check_bei")
    if beihook == nil then
        beihook = test
    end
    if type(beihook) == "function" then
        if beihook_args then
            beihook(beihook_args)
        else
            beihook()
        end
    else
        common.debug("异常: beihook 的类型为: " .. type(beihook))
    end
end
-- ---------------------------------------------------------------
-- check_halt
-- ---------------------------------------------------------------
function check_halt(func)
    disWait()
    enableTrigger("check_halt")
    halthook = func
    halt_timer()
end
function halterror()
    haltbusy = haltbusy or 0
    haltbusy = haltbusy + 1
    if haltbusy > 30 then
        haltbusy = 0
        locate()
    end
    if location.room == "洗象池边" then
        disableTimer("check_halt")
        tempTimer(
            5,
            function()
                haltok()
            end
        )
    end
end
function halt_timer()
    enableTimer("check_halt")
end
function haltok()
    haltbusy = 0
    disableTrigger("check_halt")
    disableTimer("check_halt")
    if halthook == nil then
        halthook = test
    end
    if type(halthook) == "table" then
        if type(halthook.func) == "function" then
            if halthook.arg4 ~= nil then
                return halthook.func(halthook.arg1, halthook.arg2, halthook.arg3, halthook.arg4)
            elseif halthook.arg3 ~= nil then
                return halthook.func(halthook.arg1, halthook.arg2, halthook.arg3)
            elseif halthook.arg2 ~= nil then
                return halthook.func(halthook.arg1, halthook.arg2)
            else
                return halthook.func(halthook.arg1)
            end
        end
    else
        return halthook()
    end
end
-- ---------------------------------------------------------------
-- check_busy
-- ---------------------------------------------------------------
function check_busy(func, waitSec, args)
    disWait()
    enableTrigger("check_busy")
    busyhook = func
    busyhook_args = args
    exe("jifa jifa jifa")
    jifa_timer(waitSec)
end
function jifa_timer(waitSec)
    waitSec = waitSec or 0.4
    AddTimer("jifa", waitSec, [[exe("jifa jifa jifa")]])
end
function busyok()
    disableTrigger("check_busy")
    KillTimer("jifa")
    if busyhook == nil then
        busyhook = test
    end
    if type(busyhook) == "function" then
        if busyhook_args then
            busyhook(busyhook_args)
        else
            busyhook()
        end
    else
        SJConfig.DebugShow("异常: busyhook 的类型为: " .. type(beihook))
    end
end
-- ---------------------------------------------------------------
-- checkWait
-- ---------------------------------------------------------------
function checkWait(func, sec)
    disWait()
    enableTrigger("checkwait")
    waithook = func
    if sec == nil then
        sec = 5
    end
    AddTimer("waitimer", sec, "wait_timer_set")
end
function wait_timer_set()
    send("alias action 等待一下")
end
function checkWaitOk()
    disableTrigger("checkwait")
    KillTimer("waitimer")
    if waithook == nil then
        waithook = test
    end
    if type(waithook) == "string" or type(waithook) == "number" then
        print("waithook 赋值异常: 当前类型为 - " .. type(waithook) .. ", 当前值为 - " .. waithook)
        return test()
    end
    if type(waithook) == "function" then
        return waithook()
    end
end
-- ---------------------------------------------------------------
-- checkNext
-- ---------------------------------------------------------------
nexthook = test
function checkNext(func)
    disWait()
    -- DeleteTriggerGroup("checknext")
    -- AddTrigger("checknext", "checknext1", '^(> )*你把 "action" 设定为 "继续前进" 成功完成。$', "checkNextOk")
    enableTrigger("checknext")
    nexthook = func
    next_timer_set()
    AddTimer("nextimer", 0.5, "next_timer_set")
end
function next_timer_set()
    exe("alias action 继续前进")
end
function checkNextOk()
    -- KillTriggerGroup("checknext")
    disableTrigger("checknext")
    KillTimer("nextimer")
    if nexthook == nil then
        nexthook = test
    end
    return nexthook()
end

-- ---------------------------------------------------------------
-- 从打坐开始, 检查任务
-- ---------------------------------------------------------------
function hp_dazuo_trigger()
    DeleteTriggerGroup("dz_count")
    AddTrigger("dz_count", "dz_count1", "^>*\\s*卧室不能打坐，会影响别人休息。", "hp_dz_where")
    AddTrigger("dz_count", "dz_count2", "^>*\\s*你无法静下心来修炼。", "hp_dz_where")
    AddTrigger("dz_count", "dz_count3", "^>*\\s*(这里不准战斗，也不准打坐。|这里可不是让你提高内力的地方。)", "hp_dz_where")
    AddTrigger("dz_count", "dz_count4", "^(> )*你现在手脚戴着镣铐，不能做出正确的姿势来打坐", "hp_dz_liaokao")
    AddTrigger("dz_count", "dz_count5", "^(> )*(你正要有所动作|你无法静下心来修炼|你还是专心拱猪吧)", "hp_dz_where")
    AddTrigger("dz_count", "dz_count6", "^(> )*你现在精不够，无法控制内息的流动！", "hp_dazuo_lackofjing")
end
function hp_dazuo_count()
    hp_dazuo_trigger()
    if perform.force and skills[perform.force] then
        exe("jifa force " .. perform.force)
    else
        for p in pairs(skills) do
            if skillEnable[p] == "force" then
                exe("jifa force " .. p)
                exe("cha")
            end
        end
    end
    if skills["linji-zhuang"] and skills["linji-zhuang"].lvl > 149 then
        exe("yun yinyang")
    end
    exe("yun recover;hp")
    hp.dazuo = 10
    return check_bei(hp_dazuo_act)
end
function hp_dazuo_lackofjing()
    DeleteTriggerGroup("dz_count")
    DeleteTimer("dazuo_count")
    return checkWait(check_heal, 0.5)
end
function hp_dazuo_act()
    tmp.qixue = hp.qixue
    exe("yun regenerate;dazuo " .. hp.qixue)
    tmp.i = 0
    return AddTimer("dazuo_count", 1.5, "hp_dazuo_timer")
end
function hp_dazuo_timer()
    tmp.i = tmp.i + 1
    if tmp.i > 30 then
        return SJ.Main()
    end
    exe("hp;yun regenerate;yun recover;dazuo " .. hp.qixue)
    return checkWait(hp_dz_count, 0.5)
end
function hp_dz_count()
    KillTriggerGroup("dz_count")
    local l_times = 1
    if hp.qixue < tmp.qixue then
        if hp.qixue_max > 1000 then
            l_times = math.modf(math.modf(hp.qixue_max / 5) / (tmp.qixue - hp.qixue)) + 1
        end
        hp.dazuo = l_times * (tmp.qixue - hp.qixue) + 150
        if hp.dazuo < 10 then
            hp.dazuo = 10
        end
        SJConfig.DebugShow("\n最佳打坐值为: " .. hp.dazuo)
        DeleteTriggerGroup("dz_count")
        DeleteTimer("dazuo_count")
        exe("halt")
        -- if kdummy == 1 and hp.exp > 2000000 then
        --     opendummy()
        -- end
        return check_bei(SJ.Start)
    end
end
function hp_dz_where()
    KillTriggerGroup("dz_count")
    DeleteTimer("dazuo_count")
    locate()
    check_bei(hp_dz_go)
end
function hp_dz_go()
    hp_dazuo_trigger()
    exe(location.dir)
    hp_dazuo_act()
end
function hp_dz_liaokao()
    dis_all()
    return tiaoshui()
end

function hp_trigger()
    DeleteTriggerGroup("hp")
    -- AddTrigger("hp",'hp1', "^·精血·\\s*(\\d*)\\s*\\/\\s*(\\d*)\\s*\\(\\s*(\\d*)\\%\\)\\s*·精力·\\s*(\\d*)\\s*\\/\\s*(\\d*)\\((\\d*)\\)$", 'hp_jingxue_check')
    -- AddTrigger("hp",'hp2', "^·气血·\\s*(\\d*)\\s*\\/\\s*(\\d*)\\s*\\(\\s*(\\d*)\\%\\)\\s*·内力·\\s*(\\d*)\\s*\\/\\s*(\\s*\\d*)\\(\\+\\d*\\)$", 'hp_qixue_check')
    -- AddTrigger("hp",'hp3', "^·食物·\\s*(\\d*)\\.\\d*\\%\\s*·潜能·\\s*(\\d*)\\s*\\/\\s*(\\d*)$", 'hp_pot_check')
    -- AddTrigger("hp",'hp4', "^·饮水·\\s*(\\d*)\\.\\d*\\%\\s*·经验·\\s*(.*)\\s*\\(", 'hp_exp_check')
    AddTrigger(
        "hp",
        "hp7",
        "^(□)*\\s*(\\D*)\\s*\\((\\D*)(\\-)*(\\D*)\\)\\s*\\-\\s*\\D*\\s*(\\d*)\\/\\s*(\\d*)$",
        "check_skills"
    )
    AddTrigger("hp", "hp8", "^>*\\s*你至少需要(\\D*)点的气来打坐！", "hp_dazuo_check")
    AddTrigger("hp", "hp9", "^│(\\D*)任务\\s*│\\s*(\\d*) 次\\s*│ ", "checkJobtimes")
    AddTrigger("hp", "hp10", "^□(\\D*)\\(\\D*\\)$", "checkWieldCatch")
    AddTrigger("hp", "hp11", "^(> )*你最近刚完成了(\\D*)任务。$", "checkJoblast")
    -- AddTrigger("hp",'hp13', "^(> )*你还在巡城呢，仔细完成你的任务吧。", 'checkQuit')
    AddTrigger("hp", "hp14", "^\\D*被一阵风卷走了。$", "checkRefresh")
    AddTrigger("hp", "hp15", "^(> )*一个月又过去", "checkMonth")
    -- AddTrigger("hp",'hp17', "^(> )*你(渴得眼冒金星，全身无力|饿得头昏眼花，直冒冷汗)", 'checkQuit')
    -- AddTrigger("hp",'hp18', "^(> )*(你舔了舔干裂的嘴唇，看来是很久没有喝水了|突然一阵“咕咕”声传来，原来是你的肚子在叫了)", 'checkfood')
    AddTrigger("hp", "hp19", "^(> )*(忽然一阵刺骨的奇寒袭来，你中的星宿掌毒发作了|忽然一股寒气犹似冰箭，循着手臂，迅速无伦的射入胸膛，你中的寒毒发作了)", "checkDebug")
    AddTrigger(
        "hp",
        "hp20",
        "^(> )*你(服下一颗活血疗精丹，顿时感觉精血不再流失|服下一颗内息丸，顿时觉得内力充沛了不少|服下一颗川贝内息丸，顿时感觉内力充沛|服下一颗黄芪内息丹，顿时感觉空虚的丹田充盈了不少|敷上一副蝉蜕金疮药，顿时感觉伤势好了不少|吃下一颗大还丹顿时伤势痊愈气血充盈)。",
        "hpEatOver"
    )
    AddTrigger("hp", "hp21", "^(> )*你必须先用 enable 选择你要用的特殊内功。", "jifaOver")
    AddTrigger("hp", "hp22", "^(> )*(\\D*)目前学过(\\D*)种技能：", "show_skills")
    -- AddTrigger('hp23', "^(> )*你的背囊里有：", 'show_beinang')
    AddTrigger("hp", "hp24", "^(> )*你眼中一亮看到\\D*的身边掉落一(件|副|双|袭|顶|个|条|对)(\\D*)(手套|靴|甲胄|腰带|披风|彩衣|头盔)。", "fqyyArmorGet")
    AddTrigger("hp", "hp25", "^(> )*你捡起一(件|副|双|袭|顶|个|条|对)(\\D*)(手套|靴|甲胄|腰带|披风|彩衣|头盔)。", "Bag.ArmorCheck")
    AddTrigger("hp", "hp26", "^(> )*(\\D*)客官已经付了银子，怎(么|麽)不住店就走了呢(\\D*)$", "kedian_sleep")
end

function jifaOver()
    exe("jifa all")
end

function checkMonth()
    flag.month = 1
end

function checkDebug()
    messageShow("您中毒了!")
    vippoison = 1
    exe("i;hp")
    if job.name == "songmoya" then
        job.name = "poison"
        return check_halt(fangqiypt)
    end
    if hxd_cur > 0 then
        AddTimer("eatdan", 3, "hpEat")
    else
        dis_all()
        return check_halt(check_xue)
    end
end
function hp_dazuo_check()
    hp.dazuo = trans(matches[2])
    exe("dazuo " .. hp.dazuo)
end

function hpEat()
    exe("eat huoxue dan")
end

function hpEatOver()
    local l = matches[3]
    if string.find(l, "敷上一副蝉蜕金疮药，顿时感觉伤势好了不少") then
        cty_cur = cty_cur - 1
    end
    if string.find(l, "服下一颗川贝内息丸，顿时感觉内力充沛") then
        cbw_cur = cbw_cur - 1
    end
    if string.find(l, "服下一颗活血疗精丹，顿时感觉精血不再流失") then
        DeleteTimer("eatdan")
        hxd_cur = hxd_cur - 1
    end
    if string.find(l, "吃下一颗大还丹顿时伤势痊愈气血充盈") then
        messageShow("吃大还丹了！")
        dhd_cur = dhd_cur - 1
    end
end
function checkQuit()
    dis_all()
    check_halt(BQuit)
end
function BQuit()
    exe("quit")
end
-- ---------------------------------------------------------------
-- checkfood
-- ---------------------------------------------------------------
function checkfood()
    if job.name == "songmoya" then
        return
    else
        dis_all()
        return check_halt(check_food)
    end
end

function check_food(Force2Full)
    Force2Full = Force2Full or false
    beiUnarmed()
    dis_all()
    if mydummy == true then
        return dummyfind()
    end
    exe("nick 全面检查状态;remove all;wear all;score;hp;unset no_kill_ap;yield no")
    quest.name = "全面检查状态"
    quest.status = ""
    quest.target = ""
    quest.location = ""
    quest.note = ""
    quest.update()
    check_bei(check_heal)
end

-- ---------------------------------------------------------------
-- 检查是否需要去学习(学习,领悟等)
-- ---------------------------------------------------------------
function NeedStudy()
    local need = false

    -- 领悟 partial
    if GetVariable("lingwuskills") then
        local l_skillsLingwu = {}
        l_skillsLingwu = string.split(GetVariable("lingwuskills"), "|")
        for p in pairs(skills) do
            for k, q in ipairs(l_skillsLingwu) do
                if skills[p].lvl < score.level - 1 and skills[p].lvl >= 300 and p == q then
                    need = true
                end
            end
        end
    end

    -- literate
    if score.gold and score.gold > 100 and (not skills["literate"] or skills["literate"].lvl < score.level - 2) then
        need = true
    end

    -- learn
    if GetVariable("xuexiskills") then
        local l_xuexiskills = {}
        l_xuexiskills = string.split(GetVariable("xuexiskills"), "|")
        for p in pairs(skills) do
            for k, q in ipairs(l_xuexiskills) do
                if skills[p].lvl < score.level - 1 and skills[p].lvl < 300 and p == q then
                    need = true
                end
            end
        end
    end

    return need
end

-- ---------------------------------------------------------------
-- 自动存潜能
-- ---------------------------------------------------------------
function DepositPot()
    go(DepositPot_Act,"襄阳","潜能银行")
    quest.name = "存入潜能"
    quest.location = "潜能银行"
    quest.update()
end
function DepositPot_Act()
    -- 你从银行里取出四点潜能。
    DeleteTriggerGroup("qn_Bank")
    AddTrigger("qn_Bank", "qn_Bank1", "^(> )*你拿出(.*)潜能，存进了银行。", "DepositPot_After_Handle")
    AddTrigger("qn_Bank", "qn_Bank2", "^(> )*你没有这么多潜能。", "DepositPot_Fail_Handle")
    check_busy(DepositPot_act)
end
function DepositPot_act()
    exe("qn_cun "..hp.pot)
end
function DepositPot_After_Handle()
    exe("hp")
    DeleteTriggerGroup("qn_Bank")
    job.Switch()
end
function DepositPot_Fail_Handle()
    DeleteTriggerGroup("qn_Bank")
    check_heal()
end
-- ---------------------------------------------------------------
-- 从潜能银行取潜能出来
-- ---------------------------------------------------------------
function FetchPot()
    if hp.pot > math.floor(hp.pot_max * 1.5) then
        return check_pot()
    end
    go(FetchPot_Act,"襄阳","潜能银行")
    quest.name = "取出潜能"
    quest.location = "潜能银行"
    quest.update()
end
function FetchPot_Act()
    DeleteTriggerGroup("qn_Bank")
    AddTrigger("qn_Bank", "qn_Bank1", "^(> )*你从银行里取出(.*)潜能。", "FecthPot_After_Handle")
    AddTrigger("qn_Bank", "qn_Bank2", "^(> )*你存的潜能不够取。", "FetchPot_Fail_Handle")
    check_busy(FetchPot_act)
end
function FetchPot_act()
    exe("qn_qu "..math.floor(hp.pot_max * 1.5))
end
function FecthPot_After_Handle()
    exe("hp")
    check_pot()
end
function FetchPot_Fail_Handle()
    DeleteTriggerGroup("qn_Bank")
    zhunbeineili(check_food, true)
end
-- ---------------------------------------------------------------
-- 如何使用pot的 handle
-- ---------------------------------------------------------------
function check_pot(p_cmd)
    -- local l_skill
    -- if perform.skill then
    --     l_skill = skillEnable[perform.skill]
    -- end

    -- 删除取潜能的触发器
    DeleteTriggerGroup("qn_Bank")

    -- 判断 领悟
    flag.lingwu = 0
    if tmp.xskill and skills[tmp.xskill] and skillEnable[tmp.xskill] and skills[skillEnable[tmp.xskill]] then
        local p = tmp.xskill
        local q = skillEnable[p]
        if skills[q].lvl < hp.pot_max - 100 and skills[q].lvl <= skills[p].lvl and skills[q].lvl < hp.pot_max - 100 then
            flag.lingwu = 1
        end
    end
    if GetVariable("lingwuskills") then
        local l_skillsLingwu = {}
        l_skillsLingwu = string.split(GetVariable("lingwuskills"), "|")
        for p in pairs(skills) do
            for k, q in ipairs(l_skillsLingwu) do
                if
                    skillEnable[p] == q and skills[q].lvl < hp.pot_max - 10 and skills[q].lvl <= skills[p].lvl and
                        skills[q].lvl >= 300
                 then
                    flag.lingwu = 1
                end
            end
        end
    end
    if flag.lingwu == 1 then
        return checklingwu()
    end

    -- 普通百姓
    if score.party == "普通百姓" then
        if
            hp.pot >= l_pot and score.gold and skills["literate"] and score.gold > 3000 and
                skills["literate"].lvl < hp.pot_max - 100
         then
            return literate()
        end
        if hp.pot >= l_pot and skills["parry"].lvl < hp.pot_max - 100 and skills["parry"].lvl >= 101 then
            flag.lingwu = 1
        end
        if flag.lingwu == 1 then
            return checklingwu()
        end
        if skills["force"].lvl > 50 then
            if skills["force"].lvl < 101 then
                return huxi()
            end
            if skills["force"].lvl == 101 then
                exe("fangqi force 1;y;y;y")
                return huxi()
            end
            if skills["shenzhao-jing"] and skills["shenzhao-jing"].lvl < 200 then
                return learnSzj()
            end
        end
    end

    -- 门派弟子
    if score.party ~= "普通百姓" then
        -- 判断是否达到学习要求
        if GetVariable("Autoxuexi") and GetVariable("Autoxuexi") == true then
            if score.gold and skills["literate"] and score.gold > 100 and skills["literate"].lvl < hp.pot_max - 100 then
                return literate()
            end

            -- 学习 判断
            -- for p in pairs(skills) do
            --     local q = qrySkillEnable(p)
            --     if q and q["force"] and perform.force and p == perform.force and skills[p].lvl < 100 and hp.pot >= l_pot then
            --         if skills[p].mstlvl and skills[p].mstlvl <= skills[p].lvl then
            --         else
            --             return checkxue()
            --         end
            --     end
            -- end
            if GetVariable("xuexiskills") then
                local l_xuexiskills = {}
                l_xuexiskills = string.split(GetVariable("xuexiskills"), "|")
                for p in pairs(skills) do
                    for k, q in ipairs(l_xuexiskills) do
                        if skills[p].lvl < score.level - 1 and skills[p].lvl < 300 and p == q then
                            return xuexi()
                        end
                    end
                end
            end

            if perform.skill and skills[perform.skill] and skills[perform.skill].lvl < 300 then
                return checkxue()
            end

            if flag.type and flag.type ~= "lingwu" and flag.xuexi == 1 then
                return checkxue()
            end

            if flag.xuexi == 1 then
                return checkxue()
            end

            -- 无相截指 partial
            if skills["wuxiang-zhi"] then
                if not flag.wxjz then
                    flag.wxjz = 0
                end
                if
                    flag.wxjz == 0 and skills["finger"].lvl > skills["wuxiang-zhi"].lvl and
                        skills["wuxiang-zhi"].lvl < hp.pot_max - 100
                 then
                    return wxjzFofa()
                end
            end
        end
    end

    return job.Switch()
end

function checkRefresh()
    job.time["refresh"] = os.time() % 900
end

function idle()
    hp.expBak = hp.expBak or -1
    if hp.exp and hp.exp ~= hp.expBak then
        hp.expBak = hp.exp
        cntrI = countR(20)
    end
    flag.idle = 0
    return AddTimer("idle", 30, "idle_set")
end
function idle_set()
    if job.name == "ptbx" then
        return exe("praise ptbx")
    end
    if job.name == "husong" then
        exe("aq")
        print("正在护送任务中")
        return
    end
    if job.name == "refine" then
        exe("admire2")
        print("正在提练矿石中")
        return
    end
    if flag.idle then
        print(flag.idle)
        -- 更新idle时间至状态栏
        quest.update()
    end
    exe("poem")
    if not flag.idle or type(flag.idle) ~= "number" then
        flag.idle = 0
    end
    flag.idle = tonumber(flag.idle) + 1
    if flag.idle < 8 then
        return
    end
    local idle_max = 10
    -- if hp.exp < 2000000 then
    --     idle_max = 24
    -- end
    if tonumber(flag.idle) < idle_max then
        DeleteTimer("walkWait10")
        DeleteTimer("walkWait9")
        if dest.area == nil then
            return
        end
        if dest.area == "铁掌山" then
            locate()
            if location.room ~= job.room then
                return walk_wait()
            else
                if job.name == "wudang" then
                    return wudangFindAct()
                end
                if job.name == "huashan" then
                    return huashanFindAct()
                end
                if job.name == "xueshan" then
                    return xueshan_find_act()
                end
                if job.name == "songxin" or job.name == "songxin2" then
                    return songxin_find_go()
                end
            end
        end
        chats_log("ROBOT 可能已发呆" .. tonumber(flag.idle) / 2 .. "分钟!", "deepskyblue")
        return
    end

    scrLog()
    dis_all()
    job.statistics.IdleTime = job.statistics.IdleTime + 1
    if location.area == nil then
        location.area = "不知道区域"
    end
    if location.room == nil then
        location.room = "不知道哪里"
    end
    chats_locate(
        "定位系统：发呆" .. (tonumber(flag.idle) / 2) .. "分钟后，于【" .. location.area  .. location.room .. "】重新启动系统！",
        "red"
    )
    reconnect()
end

-- ---------------------------------------------------------------
-- 客栈被小二busy触发处理..
-- ---------------------------------------------------------------
function kedian_sleep()
    -- 路径合并了！适用所有客栈！
    exe("up;n;enter;sleep")
    checkWait(locate, 3)
    walk_wait()
end
-- ---------------------------------------------------------------
-- 运特殊内功, 通常在学习/领悟等开始前使用
-- ---------------------------------------------------------------
function yunAddInt()
    if perform.force and perform.force == "linji-zhuang" then
        exe("yun zhixin")
    end
    if perform.force and perform.force == "bihai-chaosheng" then
        exe("yun qimen")
    end
    if perform.force and perform.force == "yunu-xinjing" then
        exe("yun xinjing")
    end
end

function test()
    SJConfig.DebugShow("到达目的地！")
    -- return fight_prepare()
end

-- ---------------------------------------------------------------
-- 任务必须物品基本检查 (只作基本检查, 如药品只检查是否达到基本的量, 如任务惩罚期,需作全面检查, 以full所有东西)
-- ---------------------------------------------------------------
function checkPrepare()
    DeleteTriggerGroup("poison")
    drugPrepare = drugPrepare or {}

    if hp.exp < 150000 then
        return checkPrepareOver()
    end

    if Bag["镣铐"] then
        return tiaoshui()
    end

    if Bag and Bag["白银"] and Bag["白银"].cnt and Bag["白银"].cnt > 500 then
        return check_gold()
    end
    if
        (Bag and Bag["黄金"] and Bag["黄金"].cnt and Bag["黄金"].cnt < count.gold_max and score.gold > count.gold_max) or
            (Bag and Bag["黄金"] and Bag["黄金"].cnt and Bag["黄金"].cnt > count.gold_max * 4)
     then
        quest.status = "检查黄金"
        quest.update()
        return check_gold()
    end

    if score.gold and score.gold > 100 and drugPrepare["川贝内息丸"] and (Bag["川贝内息丸"] == nil or Bag["川贝内息丸"].cnt < 2) then
        quest.status = "检查 川贝内息丸"
        quest.update()
        return checkNxw()
    end

    if not Bag["火折"] and drugPrepare["火折"] then
        return checkFire()
    end
    if score.gold and score.gold > 100 and hxd_cur < 3 and drugPrepare["活血疗精丹"] then
        return checkLjd()
    end

    weaponPrepare = string.split(GetVariable("WeaponPrepare"), "|")
    for k, p in pairs(weaponPrepare) do
        if weaponStore[p] and not Bag[p] and Bag["黄金"].cnt > 3 then
            return checkWeapon(p)
        end
        if weaponFunc[p] and not Bag[p] then
            return _G[weaponFuncName[p]]()
        end
        if weaponPrepare["飞镖"] and Bag["枚飞镖"].cnt < 100 then
            return checkWeapon("飞镖")
        end
    end
    local l_cut = false
    local bagItemCount = 0
    local itemNameList = ""
    for k, v in pairs(Bag) do
        bagItemCount = bagItemCount + 1
        -- itemNameList=itemNameList ..'|' .. k
    end
    if (bagItemCount > 0) then
        for p in pairs(Bag) do
            if weaponKind[Bag[p].kind] and weaponKind[Bag[p].kind] == "cut" then
                l_cut = true
                break
            end
        end
    else
        l_cut = true
    end

    exe("wear all")
    return checkPrepareOver()
end

function checkPrepareOver()
    -- 检查 准备完毕, 可进行下一步动作
    -- 暂时没有其它需要作的, 直接进行下一个任务 (可补充)
    return job.Switch()
end

function check_xuexi()
    if MidHsDay[location.time] and score.master == "风清扬" and
            (skills["dugu-jiujian"] == nil or skills["dugu-jiujian"].lvl < 220)
     then
        return job.Switch()
    end
    if needxuexi == 0 then
        return job.Switch()
    else
        return check_pot()
    end
end
