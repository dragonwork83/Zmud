function check_poison()
    prepare_neili_stop()
    poison_dazuo()
    condition = {}
    exe("cond")
    return check_busy(preparePoison)
end
function preparePoison()
    EnableTrigger("hp", "hp19")
    if (not condition.poison or condition.poison == 0) then
        return check_halt(check_heal_over)
    end
    return dazuoPoison()
end
function dazuoPoison()
    condition.poison = 0
    exe("hp;yun qi;yun regenerate;yun jingli;cond")
    exe("dazuo " .. hp.dazuo)
end
function poison_dazuo()
    DeleteTriggerGroup("poison")
    AddTrigger(
        "poison",
        "poison1",
        "^(> )*(过了片刻，你感觉自己已经将玄天无极神功|你将寒冰真气按周天之势搬运了一周|你只觉真力运转顺畅，周身气力充沛|你将纯阳神通功运行完毕|你只觉神元归一，全身精力弥漫|你将内息走了个一个周天|你将内息游走全身，但觉全身舒畅|你将真气逼入体内，将全身聚集的蓝色气息|你将紫气在体内运行了一个周天|你运功完毕，站了起来|你一个周天行将下来，精神抖擞的站了起来|你分开双手，黑气慢慢沉下|你将内息走满一个周天，只感到全身通泰|你真气在体内运行了一个周天，冷热真气收于丹田|你真气在体内运行了一个周天，缓缓收气于丹田|你双眼微闭，缓缓将天地精华之气吸入体内|你慢慢收气，归入丹田，睁开眼睛|你将内息又运了一个小周天，缓缓导入丹田|你感觉毒素越转越快，就快要脱离你的控制了！|你将周身内息贯通经脉，缓缓睁开眼睛，站了起来|你呼翕九阳，抱一含元，缓缓睁开双眼|你吸气入丹田，真气运转渐缓，慢慢收功|你将真气在体内沿脉络运行了一圈，缓缓纳入丹田|你将内息在体内运行十二周天，返回丹田|你将内息走了个小周天，流回丹田，收功站了起来|过了片刻，你已与这大自然融合在一起，精神抖擞的站了起|你感到自己和天地融为一体，全身清爽如浴春风，忍不住舒畅的呻吟了一声，缓缓睁开了眼睛)",
        "poisondazuo_desc"
    )
    AddTrigger("poison", "poison2", "^(> )*你现在精不够，无法控制内息的流动！", "checkDebug")
end
function poisondazuo_desc()
    if condition.poison and condition.poison == 0 then
        DeleteTriggerGroup("poison")
        exe("yun regenerate;yun qi;yun jingli")
        return check_bei(check_food)
    end
    return poisonLianxi()
end
function poisonLianxi()
    lianxi()
    tempTimer(
        2,
        function()
            return check_busy(preparePoison)
        end
    )
end
