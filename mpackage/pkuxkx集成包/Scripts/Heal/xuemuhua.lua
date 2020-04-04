function check_xue()
    DisableTrigger("hp", "hp19")
    tmp.xueSkills = {}
    tmp.xueCount = 1
    tmp.xueTimes = 0
    for p in pairs(skills) do
        if skills[p].lvl > 100 then
            table.insert(tmp.xueSkills, p)
        end
    end
    if hp.exp > 500000 then
        return go(check_xue_ask, "柳宗镇", "正厅")
    else
        return check_xue_fail()
    end
end
function check_xue_ask()
    DeleteTriggerGroup("ck_xue_ask")
    AddTrigger("ck_xue_ask", "ck_xue_ask1", "^(> )*你向薛慕华打听有关『疗伤』的消息。$", "check_xue_accept")
    AddTrigger("ck_xue_ask", "ck_xue_ask2", "^(> )*这里没有这个人", "check_xue_fail")

    DeleteTriggerGroup("ck_xue_teach")
    AddTrigger("ck_xue_teach", "ck_xue_teach1", "^(> )*薛神医的这个技能已经不能再进步了。$", "check_xue_next")

    DeleteTriggerGroup("ck_xue_busy")
    AddTrigger("ck_xue_busy", "ck_xue_busy1", "^(> )*您先歇口气再说话吧。$", "check_xue_busy")

    exe("ask xue muhua about 疗伤")
end
function check_xue_busy()
    return check_busy(check_xue_ok, 2)
end
function check_xue_ok()
    EnableTriggerGroup("ck_xue_accept", true)
    exe("ask xue muhua about 疗伤")
end
function check_xue_fail()
    EnableTriggerGroup("ck_xue_ask", false)
    EnableTriggerGroup("ck_xue_accept", false)
    EnableTriggerGroup("ck_xue_teach", false)
    return check_jingxue()
end
function check_xue_accept()
    DeleteTriggerGroup("ck_xue_ask")
    DeleteTriggerGroup("ck_xue_accept")
    AddTrigger("ck_xue_accept", "ck_xue_accept1", "^(> )*薛慕华「嘿嘿嘿」奸笑了几声。$", "check_xue_teach")
    AddTrigger("ck_xue_accept", "ck_xue_accept2", "^(> )*一柱香的工夫过去了，你觉得伤势已经基本痊愈了。", "check_xue_heal")
    AddTrigger("ck_xue_accept", "ck_xue_accept3", "^(> )*薛神医拿出一根银针轻轻捻入你受伤部位附近的穴道", "check_xue_wait")
    AddTrigger("ck_xue_accept", "ck_xue_accept4", "^(> )*薛慕华似乎不懂你的意思。$", "check_xue_heal")
    AddTrigger("ck_xue_accept", "ck_xue_accept5", "^(> )*薛慕华「啪」的一声倒在地上，挣扎着抽动了几下就死了", "check_xue_fail")
end
function check_xue_wait()
    EnableTrigger("ck_xue_accept1", false)
    EnableTrigger("ck_xue_accept3", false)
    EnableTrigger("ck_xue_accept4", false)
end
function check_xue_teach()
    DeleteTriggerGroup("ck_xue_accept")
    EnableTriggerGroup("ck_xue_teach", true)

    if tmpxueskill then
        for i = 1, 10 do
            exe("teach xue " .. tmpxueskill)
        end
    else
        for i = 1, 10 do
            exe("teach xue " .. tmp.xueSkills[tmp.xueCount])
        end
    end
    tempTimer(
        0.5,
        function()
            return check_busy(check_xue_ok)
        end
    )
end
function check_xue_next()
    EnableTriggerGroup("ck_xue_teach", false)
    if tmpxueskill then
        tmpxueskill = nil
        tmp.xueCount = 0
    end
    tmp.xueCount = tmp.xueCount + 1
    if tmp.xueCount > table.getn(tmp.xueSkills) then
        return check_jingxue()
    else
        return checkWait(check_xue_teach, 0.2)
    end
end
function check_xue_heal()
    DeleteTriggerGroup("ck_xue_ask")
    DeleteTriggerGroup("ck_xue_accept")
    DeleteTriggerGroup("ck_xue_teach")
    DeleteTriggerGroup("ck_xue_busy")
    return check_bei(check_poison)
end
