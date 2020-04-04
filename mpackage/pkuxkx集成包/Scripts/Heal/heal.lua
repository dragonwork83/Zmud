function check_heal()
    dis_all()
    tmp = { }
    jobTriggerDel()
    job.name = "heal"
    exe("nick 赶路中")
    if score.party and score.party == "神龙教" then
        exe("yun shougong " .. score.id)
    end
    if perform.force and skills[perform.force] then
        exe("jifa force " .. perform.force)
    end
    check_halt(check_jingxue_count)
end
function check_jingxue_count()
    checkBags()
    if hp.exp < 150000 then
        return checkWait(check_heal_over, 1)
    elseif (hp.exp > 150000 and hp.exp < 800000) then
        return go(check_heal_newbie, "扬州城", "药铺")
    elseif hp.jingxue_per < 96 or hp.qixue_per < 88 then
        return go(check_heal_normal, "大理城", "药铺")
    else
        return checkWait(check_jingxue, 0.1)
    end
end
function check_jingxue()
    -- if (hp.qixue_per < 98 and hp.qixue_per > 88) and cty_cur > 0 then
    --     exe("eat chantui yao;hp")
    --     return check_halt(check_jingxue, 0.1)
    -- else
        if score.party == "大轮寺" and hp.neili > 2000 then
            exe("yun juxue")
        elseif cty_cur == 0 then
            return checkHxd()
        end
        return check_halt(check_heal_over, 0.2)
    -- end
end
function check_heal_normal()
    if hp.qixue_per < 100 then
        exe("buy chantui yao;eat chantui yao;hp")
    end
    if hp.jingxue_per < 100 then
        exe("buy huoxue dan;eat huoxue dan;hp")
    end
    return check_halt(check_heal_over, 1)
end
function check_heal_newbie()
    if hp.qixue_per < 100 then
        exe("buy jinchuang yao;eat jinchuang yao;hp")
    end
    if hp.jingxue_per < 100 then
        exe("buy yangjing dan;eat yangjing dan")
    end
    return check_halt(check_heal_over, 1)
end
function check_heal_over()
    DeleteTriggerGroup("ck_xue_ask")
    DeleteTriggerGroup("ck_xue_accept")
    DeleteTriggerGroup("ck_xue_teach")
    return check_halt(checkPrepare)
end
