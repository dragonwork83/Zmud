--
-- study.lua
--
-- ----------------------------------------------------------
-- 含 学习 所有function 集合 (不含literate)
-- ----------------------------------------------------------
--
--[[

--]]
-- 最大学习次数
local learntime_max = 50
-- 最小学习次数
local learnTime_min = 10

function xuexiTrigger()
    DeleteTriggerGroup("xuexi")
    if score.master then
        AddTrigger("xuexi","xuexi1", "^(> )*你(\\D*)" .. score.master .. "(\\D*)指导", "xuexiAction")
    end
    AddTrigger("xuexi","xuexi2", "^(> )*你现在正忙着呢。", "xuexiAction")
    AddTrigger("xuexi","xuexi3", "^(> )*你今天太累了，结果什么也没有学到。", "xuexiSleep")
    AddTrigger("xuexi",
    "xuexi4",
    "^(> )*(六脉神剑|你不能再学习欢喜禅了|经脉学|你不能再学习|你的基本功火候未到|你不能再提高|你的太极拳火候太浅|兰花拂穴手乃黄岛主家传绝学|兰花拂穴手乃峨嵋派祖师郭襄秘学|你的悟性，无法|你的\\D*(级别|悟性|身法)不够|华山门下怎么容得|你一个大老爷们|你已经无法提高|你的基本棒法太差|你的邪气太重|你刚听一会儿|斗转星移只能通过领悟来提高|学就只能学的这里了|你是侠义正士|只有大奸大恶之人|你不能再修炼毒技|你不能再学习经脉学|经脉学只能靠研读|你的读书写字|本草术理只能通过研习医学|你的基本功火候未到|你屡犯僧家数戒|这项技能你只能通过读书学习或实战|这项技能你已经无法通过学习|这项技能你恐怕必须找别人学了|你必须去学堂学习读书写字|也许是缺乏实战经验|你的(大乘佛法|禅宗心法)修为不够|这项技能你的程度已经不输你师父)",
    "xuexiNext"
    )
    AddTrigger("xuexi","xuexi5", "^(> )*你没有这么多潜能来学习",  "xuexiFinish")
    AddTrigger("xuexi","xuexi6", "^(> )*你要向谁求教？", "xuexiFinish")
    AddTrigger("xuexi","xuexi7", "^(> )*你的「(\\D*)」进步了！", "xuexiLvlUp")
    AddTrigger("xuexi","xuexi8", "^(> )*你觉得对太极拳理还不够理解", "xueAskzhang")
    AddTrigger("xuexi","xuexi9", "^(> )*乾坤大挪移只能通过研习《乾坤大挪移心法》和领悟来提高", "taoJiaozhang")
    AddTrigger("xuexi",
    "xuexi10",
    "^(> )*(你手里有兵器|空了手才能练|空手方能练习|你必须先找|空手时无法练|你使用的武器不对|练\\D*空手|学\\D*空手|\\D*手里不能拿武器。)",
    "xueWeapon"
    )
end
-- ---------------------------------------------------------------
-- 异常, 需检查  
-- --TODO
-- ---------------------------------------------------------------
function checkxue()
    -- if xuefull == 0 then
    --     return xuexi()
    -- end
    -- if xxpot < hp.pot_max then
        return xuexi()
    -- end
    -- return job.Switch()
end

function xuexi()
    exe("nick 回门派学习;i;")
    quest.name = "回门派学习"
    quest.status = ""
    quest.target = ""
    quest.location = "回门派"
    quest.desc = ""
    quest.note = ""
    quest.update()
    messageShow("回门派学习")
    master = { }
    if hp.exp < 150000 then
        master.times = 10
    else
        -- ain usepot
        master.times = math.modf(hp.jingxue / 60)
        master.times = common.GetValueByRange(master.times, learnTime_min, learntime_max)
    end
    master.skills = { }
    master.skills = string.split(GetVariable("xuexiskills"), "|")
    flag.times = 1
    return check_halt(xuexiParty)
end

function xuexiParty()
    if score.master then
        master.area = locateroom(score.master)
        if master.area then
            return go(xuexiCheck, master.area, master.room)
        else
            ColourNote("white", "blue", "未找到师傅住址，请更新！")
            return xuexiFinish()
        end
    else
        return xuexiFinish()
    end
end

function xuexiCheck()
    checkWield()
    if location.id[score.master] then
        if score.party and score.party == "少林派" and score.master == "无名老僧" and skills["buddhism"] and
            skills["buddhism"].lvl == 200
        then
            exe("ask wuming about 佛法")
        end
        return check_bei(xuexiStart)
    else
        ColourNote("white", "blue", "师傅不在家！如果发现地址有错，请更新！")
        return xuexiFinish()
    end
end

function xuexiStart()
    xuexiTrigger()
    tmp.xuexi = 1

    if master.id and location.item and location.item[score.master] and not location.item[score.master][master.id] then
        master.id = nil
    end
    if not master.id and location.item and location.item[score.master] then
        master.id = location.item[score.master]
        for p in pairs(location.item[score.master]) do
            if not string.find(p, " ") then
                master.id = p
            end
        end
    end
    exe("bai " .. master.id)

    Weapon.unwield()

    if l_skill and weaponKind[l_skill] then
        if master.skills[tmp.xuexi] == "yuxiao-jian" then
            l_skill = "xiao"
        end
        for p in pairs(Bag) do
            if Bag[p].kind and Bag[p].kind == l_skill then
                exe("wield " .. Bag[p].fullid)
            end
        end
    end
    yunAddInt()
    return xuexiContinue()
end

function xuexiAction()
    KillTriggerGroup("xuexi")
    if hp.exp > 2000000 and hp.neili < 300 then
        prepare_neili(xuexiContinue)
    else
        check_bei(xuexiContinue)
    end
end

function xuexiContinue()
    flag.idle = nil
    xuefull = 0
    if hp.neili < 600 and cbw_cur > 0 then
        exe("eat chuanbei wan")
    end
    xuexiTrigger()
    tempTimer(0.4,
    function()
        exe("yun regenerate;xue " .. master.id .. " " .. master.skills[tmp.xuexi] .. " " .. master.times)
    end
    )
    SJConfig.DebugShow("学习点数:" .. master.times)
    exe("hp")
end

function taoJiaozhang()
    KillTriggerGroup("xuexi")
    print("问小张乾坤大挪移")
    tempTimer(1,
    function()
        exe("#5 taojiao qiankundanuoyi;yun jing")
    end
    )
    check_busy(xuexiContinue)
end

function xueAskzhang()
    KillTriggerGroup("xuexi")
    print("问老张太极拳理")
    tempTimer(1,
    function()
        exe("ask zhang about 太极拳理")
    end
    )
    check_busy(xuexiContinue)
end

function xueWeapon()
    KillTriggerGroup("xuexi")
    tmp.skill = master.skills[tmp.xuexi]
    if skills[tmp.skill] then
        if skills[tmp.skill].lvl >= 450 then
            skills[tmp.skill].mstlvl = 450
        else
            skills[tmp.skill].mstlvl = skills[tmp.skill].lvl
        end
    end
    local l_skill = skillEnable[master.skills[tmp.xuexi]]
    Weapon.unwield()
    if l_skill and weaponKind[l_skill] then
        for p in pairs(Bag) do
            if Bag[p].kind and Bag[p].kind == l_skill then
                exe("wield " .. Bag[p].fullid)
            end
        end
        checkWield()
    end
    return check_bei(xuexiContinue)
end

function xuexiNext()
    KillTriggerGroup("xuexi")
    tmp.skill = master.skills[tmp.xuexi]
    if skills[tmp.skill] then
        if skills[tmp.skill].lvl >= 450 then
            skills[tmp.skill].mstlvl = 450
        else
            skills[tmp.skill].mstlvl = skills[tmp.skill].lvl
        end
    end
    tmp.xuexi = tmp.xuexi + 1
    if tmp.xuexi > table.getn(master.skills) then
        xxpot = hp.pot_max
        xuefull = 1
        return xuexiFinish()
    end
    local l_skill = skillEnable[master.skills[tmp.xuexi]]
    Weapon.unwield()
    if l_skill and weaponKind[l_skill] then
        if master.skills[tmp.xuexi] == "yuxiao-jian" then
            l_skill = "xiao"
        end
        for p in pairs(Bag) do
            if Bag[p].kind and Bag[p].kind == l_skill then
                exe("wield " .. Bag[p].fullid)
            end
        end
        checkWield()
    end
    return check_bei(xuexiContinue)
end

function xuexiLvlUp(n, l, w)
    for p in pairs(skills) do
        if skills[p].name == matches[3] then
            skills[p].mstlvl = nil
            break
        end
    end
end

function xuexiSleep()
    KillTriggerGroup("xuexi")
    if score.party and score.party == "神龙教" then
        return go(xuexiSleepOver, "神龙岛", "卧室")
    end
    if score.party and score.party == "少林派" then
        return go(xuexiSleepOver, "shaolin/sengshe3", "")
    end
    if score.party and score.party == "桃花岛" then
        if score.master and score.master == "黄药师" then
            return go(xuexiSleepOver, "桃花岛", "客房")
        else
            return go(xuexiSleepOver, "归云庄", "客房")
        end
    end
    if score.master and score.master == "杨过" then
        return go(xuexiSleepOver, "gumu/jqg/wshi", "")
    end
    if score.master and score.master == "小龙女" then
        return go(xuexiSleepOver, "gumu/jqg/wshi", "")
    end
    if score.party and score.party == "武当派" and score.gender == "女" then
        return go(xuexiSleepOver, "武当山", "女休息室")
    end
    if score.party and score.party == "武当派" and score.gender == "男" then
        return go(xuexiSleepOver, "武当山", "男休息室")
    end
    if score.party and score.party == "天龙寺" then
        return go(xuexiSleepOver, "dali/wangfu/woshi2", "")
    end
    if score.party and score.party == "姑苏慕容" then
        return go(xuexiSleepOver, "姑苏慕容", "厢房")
    end
    if score.party and score.party == "星宿派" then
        return go(xxSleepcheck, "星宿海", "逍遥洞")
    end
    if score.party and score.party == "昆仑派" then
        return go(xuexiSleepOver, "昆仑山", "休息室")
    end
    if score.party and score.party == "华山派" and score.gender == "男" then
        return go(xuexiSleepOver, "华山", "男休息室")
    end
    if score.party and score.party == "华山派" and score.gender == "女" then
        return go(xuexiSleepOver, "华山", "女休息室")
    end
    if score.party and score.party == "铁掌帮" and score.gender == "男" then
        return go(xuexiSleepOver, "铁掌山", "男休息室")
    end
    if score.party and score.party == "铁掌帮" and score.gender == "女" then
        return go(xuexiSleepOver, "铁掌山", "女休息室")
    end
    if score.party and score.party == "嵩山派" and score.gender == "男" then
        return go(xuexiSleepOver, "songshan/nan-room", "")
    end
    if score.party and score.party == "嵩山派" and score.gender == "女" then
        return go(xuexiSleepOver, "songshan/nv-room", "")
    end
    if score.party and score.party == "灵鹫宫" then
        return go(xuexiSleepOver, "tianshan/kefang", "")
    end
    print("未找到当前门派对应的睡房, 请检查!")
    return xuexiFinish()
end

function xuexiSleepOver()
    exe("sleep")
    checkWait(xuexiParty, 3)
end

function xuexiFinish()
    messageShow("学习完毕！")
    flag.xuexi = 0
    DeleteTriggerGroup("xuexi")
    Weapon.unwield()
    exe("cha")
    dis_all()
    return check_busy(check_food)
end
