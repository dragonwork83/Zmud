jobtimes = {}

jiangnan_area = "佛山镇|福州城|杭州城|嘉兴城|梅庄|姑苏慕容|燕子坞|曼佗罗山庄|宁波城|莆田少林|苏州城|牛家村|归云庄"
zhongyuan_area =
    "苗疆|长乐帮|成都城|扬州城|大理城|无量山|大理皇宫|大理王府|终南山|玉虚观|峨嵋山|襄阳郊外|黄河流域|萧府|华山|南阳城|嵩山|嵩山少林|大理城西|大理城南|大理城东|泰山|铁掌山|天龙寺|华山村|武当山|襄阳城|柳宗镇|大雪山|中原|成都郊外|大理城北|长安城"

dangerousNpc = {
    ["獒犬"] = true,
    ["藏獒"] = true,
    ["疯狗"] = true,
    ["头狼"] = true,
    ["野狼"] = true,
    ["毒蛇"] = true,
    ["马贼"] = true,
    ["老虎"] = true,
    ["玉峰"] = true,
    ["菜花蛇"] = true,
    ["竹叶青"] = true,
    ["梅超风"] = true,
    ["雪豹"] = true,
    ["野猪"] = true,
    ["怪蟒"] = true,
    ["巨蟒"] = true,
    ["毒蟒"] = true,
    ["恶犬"] = true,
    ["蜈蚣"] = true,
    ["折冲将军"] = true,
    ["平寇将军"] = true,
    ["征东将军"] = true,
    ["车骑将军"] = true,
    ["慧真尊者"] = true,
    ["出尘子"] = true,
    ["黑色毒蛇"] = true,
    ["厚土旗教众"] = true,
    ["巨木旗教众"] = true,
    ["锐金旗教众"] = true,
    ["烈火旗教众"] = true,
    ["洪水旗教众"] = true,
    ["黑衣帮众"] = true,
    ["灰衣帮众"] = true
}

-- ---------------------------------------------------------------
-- 接任务前准备                                                 --
-- ---------------------------------------------------------------
function job.prepare(script)
    if script then
        job.NextScript = script
    end
    quest.name = "任务准备"
    quest.target = ""
    quest.location = ""
    quest.desc = ""
    quest.note = ""
    quest:update()
    exe("exert regenerate;exert recover;response 任务准备 继续")
    enableTrigger("任务准备")
end
-- ---------------------------------------------------------------
-- 接任务前准备的处理事项                                                 --
-- ---------------------------------------------------------------
function job.prepareHandle()
    if hp.qixue_per < 94 then
        send("exert heal")
        tempTimer(
            1.5,
            function()
                exe("hpbrief;response 任务准备 继续")
            end
        )
        return
    end

    -- 包裹检查
    if Bag.NeedDepositMoney() then
        quest.desc = "钱庄存钱"
        return Bag.SaveMoney()
    end

    -- if hp.qixue < hp.qixue_max then
    -- exe("exert recover;hpbrief;response 任务准备 继续")
    -- return
    -- end

    if hp.neili < hp.neili_max then
        quest.desc = "内力准备"
        quest:update()
        if hp.exp > 500000 then
            return exe("exert recover;dazuo " .. tonumber(hp.qixue_max / 10))
        else
            return exe("exert recover;dz")
        end
    end

    disableTrigger("任务准备")
    -- 准备完成 继续执行下一步script
    job.NextScript = job.NextScript or function()
            print("无后续任务")
        end
    -- feed food
    pkuxkx.Feed()
    check_halt(job.NextScript)
end
-- ---------------------------------------------------------------
-- 任务分配运行
-- ---------------------------------------------------------------
function job.tasking(instant)
    instant.start()
end

-- ---------------------------------------------------------------
-- 准备内力 --
-- ---------------------------------------------------------------
function prepare_trigger()
    DeleteTriggerGroup("prepare_neili")
    -- ain dls nv id dazuo
    AddTrigger(
        "prepare_neili",
        "prepare_neili1",
        "^(> )*(过了片刻，你感觉自己已经将玄天无极神功|你将寒冰真气按周天之势搬运了一周|你只觉真力运转顺畅，周身气力充沛|你将纯阳神通功运行完毕|你只觉神元归一，全身精力弥漫|你将内息走了个一个周天|你将内息游走全身，但觉全身舒畅|你将真气逼入体内，将全身聚集的蓝色气息|你将紫气在体内运行了一个周天|你运功完毕，站了起来|你一个周天行将下来，精神抖擞的站了起来|你分开双手，黑气慢慢沉下|你将内息走满一个周天，只感到全身通泰|你真气在体内运行了一个周天，冷热真气收于丹田|你真气在体内运行了一个周天，缓缓收气于丹田|你双眼微闭，缓缓将天地精华之气吸入体内|你慢慢收气，归入丹田，睁开眼睛|你将内息又运了一个小周天，缓缓导入丹田|你感觉毒素越转越快，就快要脱离你的控制了！|你将周身内息贯通经脉，缓缓睁开眼睛，站了起来|你呼翕九阳，抱一含元，缓缓睁开双眼|你吸气入丹田，真气运转渐缓，慢慢收功|你将真气在体内沿脉络运行了一圈，缓缓纳入丹田|你将内息在体内运行十二周天，返回丹田|你将内息走了个小周天，流回丹田，收功站了起来|过了片刻，你已与这大自然融合在一起，精神抖擞的站了起|你感到自己和天地融为一体，全身清爽如浴春风，忍不住舒畅的呻吟了一声，缓缓睁开了眼睛)",
        "prepare_neili_b"
    )
    AddTrigger(
        "prepare_neili",
        "prepare_neili2",
        "^(> )*(你运起玄天无极神功，气聚丹田|你手捏剑诀，将寒冰真气|你盘膝而坐，运起八荒六合唯我独尊功|你运起纯阳神通功，片刻之间|你抉弃杂念盘膝坐定，手捏气诀|你盘膝坐下，默运天魔大法|你凝神静气，盘坐下来|你随意坐下，双手平放在双膝，默念口诀|你手捏绣花针，盘膝坐下，默运葵花神功|你坐下来运气用功，一股内息开始在体内流动|你慢慢盘膝而坐，双手摆于胸前|你五心向天，排除一切杂念，内息顺经脉缓缓流动|你盘膝坐下，双手合十置于头顶，潜运内力|你屏息静气，坐了下来，左手搭在右手之上|你盘膝坐下，垂目合什，默运枯荣禅功|你盘膝坐下，闭目合什，运起乾天一阳神功|你盘膝坐下，暗运内力，试图采取天地之精华|你轻轻的吸一口气，闭上眼睛，运起玉女心经|你盘腿坐下，双目微闭，双手掌心相向成虚握太极|你气运丹田，将体内毒素慢慢逼出，控制着它环绕你缓缓飘动|你盘膝而坐，双手垂于胸前成火焰状，深吸口气|你盘膝而坐，运使九阳，气向下沉|你随意坐下，双手平放在双膝，默念口诀|你随意一站，双手缓缓抬起，深吸一口气|你盘膝而坐，双目紧闭，深深吸一口气引入丹田|你席地而坐，五心向天，脸上红光时隐时现|你暗运临济十二庄，气聚丹田|你收敛心神闭目打坐，手搭气诀，调匀呼吸，感受天地之深邃，自然之精华，渐入无我境界)",
        "prepare_neili_t"
    )
    AddTrigger("prepare_neili", "prepare_neili3", "^(> )*卧室不能(吐纳|打坐)，会影响别人休息。", "prepare_neili_w")
    AddTrigger("prepare_neili", "prepare_neili4", "^(> )*(你正要有所动作|你无法静下心来修炼|你还是专心拱猪吧)", "prepare_neili_w")
    AddTrigger("prepare_neili", "prepare_neili5", "^(> )*这里不准战斗，也不准(吐纳|打坐)。", "prepare_neili_w")
    AddTrigger("prepare_neili", "prepare_neili6", "^(> )*这里可不是让你提高(内力|精力)的地方。", "prepare_neili_w")
    AddTrigger("prepare_neili", "prepare_neili7", "^(> )*你吐纳完毕，睁开双眼，站了起来。", "prepare_neili_b")
    AddTrigger("prepare_neili", "prepare_neili8", "^(> )*你闭上眼睛开始吐纳。", "prepare_neili_t")
    AddTrigger("prepare_neili", "prepare_neili9", "^(> )*你现在手脚戴着镣铐，不能做出正确的姿势来打坐", "prepare_neili_liaokao")
    AddTrigger("prepare_neili", "prepare_neili10", "^(> )*你身上没有包括任何特殊状态。", "prepare_neili_over")
end


function songxinKillFail()
    exe("yield no")
    return go(songxin_fangqi, "大理城", "驿站")
end
function wudangKillFail()
    exe("yield no")
    return go(wudangFangqi, "武当山", "三清殿")
end
function xueshanKillFail()
    exe("yield no")
    return go(xueshan_fangqi, "大雪山", "入幽口")
end
-- ---------------------------------------------------------------
-- 发 空手perform
-- ---------------------------------------------------------------
function noweaponpfm()
    local nhpfm = GetRoleConfig("NoWeaponPFM")
    if nhpfm then
        exe(nhpfm)
    end
end

function fightDrug()
    if Bag.Has(drug.neili) then
        exe("eat " .. drug.neili)
    end
end
-- ---------------------------------------------------------------
-- 战斗过程中自身状态的检查, 如内力不够吃内力药,受伤吃大还丹等
-- ---------------------------------------------------------------
function fightStatusCheck()
    if hp.qixue_per < 55 and Bag["大还丹"] then
        exe("fu dahuan dan")
    end
    if hp.qixue < hp.qixue_max * 0.7 then
        exe("yun qi")
    end
    if hp.jingxue < hp.jingxue_max * 0.5 then
        exe("yun regenerate")
    end
    if hp.neili < hp.neili_max * 0.5 and Bag["川贝内息丸"] then
        -- 内力小于50%，优先嗑川贝内息丸！
        exe("eat " .. drug.neili)
    end
    if (hp.neili < hp.neili_max * 0.35) and GetRoleConfig("Recover_neili") ~= "" then
        exe(GetRoleConfig("Recover_neili"))
    end
    if hp.jingli < hp.jingli_max * 0.5 or hp.jingli < 500 then
        exe("yun jingli")
    end
end

function fightXiqi()
    if not perform.xiqi then
        return
    end

    local l_jiali = max
    if job.killer and job.killer[matches[3]] then
        for p in pairs(skillEnable) do
            if skills[p] and skillEnable[p] == "force" and skills["force"] then
                l_jiali = math.modf(skills[p].lvl + skills["force"].lvl / 2) / 2
                l_jiali = math.modf(l_jiali)
                break
            end
        end
        if l_jiali > 200 then
            l_jiali = max
        end
        if skills["yinyun-ziqi"] and skills["yinyun-ziqi"].lvl < 300 then
        else
            exe("jiali max")
        end

        fightHpCheck()

        if type(job.killer[matches[3]]) == "string" then
            exe(perform.xiqi .. " " .. job.killer[matches[3]])
        else
            exe(perform.xiqi)
        end
    end
end


function performBusy(p_id, p_sec)
    if not p_id or type(p_id) ~= "string" then
        return
    end
    tmp.pfmid = p_id
    if p_sec and type(p_sec) == "number" then
        create_timer_s("performbusy", p_sec, "performAction")
    else
        return performAction()
    end
end
function performAction()
    local l_jiali
    if tmp.pfmid == nil then
        return
    end
    if not job.killer[tmp.pfmid] then
        tmp.pfmid = nil
        return
    end
    for p in pairs(skills) do
        if skillEnable[p] and skillEnable[p] == "force" and skills["force"] then
            l_jiali = math.modf(skills[p].lvl + skills["force"].lvl / 2) / 2
            l_jiali = math.modf(l_jiali)
            break
        end
    end
    if l_jiali > 200 then
        l_jiali = max
    end
    if skills["yinyun-ziqi"] and skills["yinyun-ziqi"].lvl < 300 then
    else
        exe("jiali max")
    end

    fightHpCheck()

    exe(perform.xiqi .. " " .. job.killer[tmp.pfmid])
    tmp.pfmid = nil
end

function fightDie()
    dieLog()
    dis_all()
    nobusy = 0
    messageShow("挂了！")
    if job.name == "songmoya" then
        smydie = smydie + 1
    end
    job.name = nil
    if hp.exp < 2000000 then
        AddTrigger("die", "die1", "^(> )*城隍庙", "xcquit")
    else
        AddTrigger("die", "die2", "^(> )*城隍庙", "SJ.Main")
    end
end
function xcquit()
    exe("quit")
    tempTimer(
        10,
        function()
            Disconnect()
            Connect()
        end
    )
end
function fight_hurt()
    local per = 100 - damage
    if per > 20 or (hp.qixue_per <= 70 and per > 10) then
        exe("yun qi")
    end
end
function fight_hp()
    exe("hp")
    checkWait(fightHpCheck, 0.2)
end

function fightHpCheck()
    -- if score.party and score.party=="峨嵋派" and hp.qixue_per<75 then
    --   exe('yun yinyang')
    -- end
    -- if score.party and score.party=="峨嵋派" and hp.qixue_per<40 then
    --   exe('yield yes;fu '..drug.heal..';yield no')
    -- end
    -- if score.party and score.party=="神龙教" and hp.qixue_per<50 then
    --   exe('yun wudi '.. score.id)
    -- end
    local cmds = ""
    if hp.qixue_per < 50 and cty_cur > 0 then
        exe("eat chantui yao")
    end
    if (hp.qixue / (hp.qixue_max / hp.qixue_per) < 35) and cty_cur > 0 then
        exe("eat chantui yao")
    end
    if hp.qixue < hp.qixue_max * 0.7 then
        exe("yun qi")
    end
    if hp.jingxue < hp.jingxue_max * 0.5 then
        exe("yun regenerate")
    end
    if hp.neili < hp.neili_max * 0.4 and cbw_cur > 0 then
        -- 内力小于40%，优先嗑川贝丸！
        exe("eat " .. drug.neili)
    end
    if hp.neili < 1000 and hp.neili_max > 3000 and hp.heqi > 480 and GetRoleConfig("Auto_hqgzc_10times") ~= "" then
        exe(GetRoleConfig("Recover_neili"))
    end
    if hp.jingli < hp.jingli_max * 0.5 or hp.jingli < 500 then
        exe("yun jingli")
    end
end

faintFunc = faintFunc or {}
function faint_handle()
    messageShow("被打晕了!")
end
function faint_check()
    fightHpCheck()
    job.killer = {}
    tmp = {}
    faintFunc = faintFunc or {}
    for k, v in pairs(faintFunc) do
        if job.name == k then
            return _G[v]()
        end
    end
    tempTimer(3, [[check_heal()]])
end

function killPfm(id, p_cmd)
    local l_cmd = "kill"
    if p_cmd and type(p_cmd) == "string" then
        l_cmd = p_cmd
    end
    if id then
        exe(l_cmd .. " " .. id)
    end
    tmp.pfm = 100
    tmp.busytest = 0
    exe("set wimpy 50")
end
-- ---------------------------------------------------------------
-- 预执行的 perform (提前执行的)
-- ---------------------------------------------------------------
function performPre()
    if GetVariable("perform_InAdvance") then
        perform.pre = GetVariable("perform_InAdvance")
    end

    local l_pfm = perform.pre
    if job.name == "gaibang" and perform.skill and perform.skill == "taiji-quan" then
        l_pfm = perform.xiqi
    end
    if job.name == "gblu" and road.wipe_id == "shiwei" and score.party == "丐帮" then
        l_pfm = string.gsub(l_pfm, "perform stick.zhuan", "perform stick.chuo shiwei")
    end
    if job.name == "gblu" and road.wipe_id == "wu shi" and score.party == "丐帮" then
        l_pfm = string.gsub(l_pfm, "perform stick.chuo", "perform stick.chuo wu shi")
    end
    if job.name == "gblu" and road.wipe_id == "wu shi" and score.party == "峨嵋派" then
        l_pfm = string.gsub(l_pfm, "perform stick.mie", "perform stick.mie wu shi")
    end
    if job.name == "zhuoshe" and score.party == "丐帮" then
        l_pfm = string.gsub(l_pfm, "perform stick.chuo", "perform stick.zhuan")
    end
    if score.party == "神龙教" and flag.wudi and flag.wudi == 0 then
        l_pfm = "yun wudi " .. score.id .. ";" .. l_pfm
    end
    if string.len(l_pfm) > 0 then
        exe(l_pfm)
    end
end
function pfmhuaxue()
    if not tmp.pfmid then
        DeleteTimer("performbusy")
    end
    if tmp.busytest then
        tmp.busytest = tmp.busytest + 1
    else
        tmp.busytest = 1
    end
    if tmp.busytest < 3 then
        exe("alias action pfmhuaxue")
    end
end
function performhuaxue()
    tmp.pfm = tmp.pfm - 1
    if tmp.pfm < 1 then
        DeleteTimer("perform")
        return
    end
    tmp.busytest = 0
    local l_pfm = perform.huaxue
    if not perform.huaxue then
        return
    end
    fightHpCheck()
    if job.name == "gblu" and road.wipe_id == "shiwei" and score.party == "丐帮" then
        if tmp.faint and tmp.faint > 0 then
            l_pfm = string.gsub(l_pfm, "perform stick.zhuan", "perform stick.zhuan shiwei " .. tmp.faint + 1)
        else
            l_pfm = string.gsub(l_pfm, "perform stick.zhuan", "perform stick.zhuan shiwei")
        end
    end
    if job.name == "gblu" and road.wipe_id == "wu shi" then
        if tmp.faint and tmp.faint > 0 then
            l_pfm = string.gsub(l_pfm, "perform stick.chan", "perform stick.chan wu shi " .. tmp.faint + 1)
            l_pfm = string.gsub(l_pfm, "perform stick.mie", "perform stick.mie wu shi " .. tmp.faint + 1)
        else
            l_pfm = string.gsub(l_pfm, "perform stick.chan", "perform stick.chan wu shi")
            l_pfm = string.gsub(l_pfm, "perform stick.mie", "perform stick.mie wu shi")
        end
    end
    if job.name == "zhuoshe" and score.party == "丐帮" then
        l_pfm = string.gsub(l_pfm, "perform stick.chan", "perform stick.zhuan")
    end
    if job.name == "songxin" then
        if job.killer[sxjob.killer1] == "faint" and type(job.killer[sxjob.killer2]) == "string" then
            l_pfm = string.gsub(l_pfm, "perform stick.zhuan", "perform stick.zhuan " .. job.killer[sxjob.killer2])
        elseif job.killer[sxjob.killer2] == "faint" and type(job.killer[sxjob.killer1]) == "string" then
            l_pfm = string.gsub(l_pfm, "perform stick.zhuan", "perform stick.zhuan " .. job.killer[sxjob.killer1])
        end
    end
    if skills["linji-zhuang"] and skills["linji-zhuang"].lvl > 150 and hp.qixue_per < 70 then
        l_pfm = "yun yinyang;" .. l_pfm
    end
    if score.party == "神龙教" and (hp.qixue_per < 40 or (flag.wudi and flag.wudi == 0)) then
        l_pfm = "yun wudi " .. score.id .. ";" .. l_pfm
    end
    exe(l_pfm)
    if score.party == "神龙教" and job.type and job.type == "zh" and job.name == "sldsm" and job.id then
        exe("zh " .. job.id .. ";no")
    end
end

function fight_prepare()
    if Bag[weapon.first] and weaponKind[skillEnable[perform.skill]] then
        exe("wield " .. Bag[weapon.first].fullid)
    elseif Bag[weapon.second] and weaponKind[skillEnable[perform.skill]] then
        exe("wield " .. Bag[weapon.second].fullid)
    end

    local l_pfm
    beiUnarmed()
    exe("set wimpy 50;jiali 1;yield no")
    if score.party == "桃花岛" then
        l_pfm = "perform dodge.wuzhuan " .. score.id
        exe(l_pfm)
    end

    if skills["yijin-jing"] and perform.force and perform.force == "yijin-jing" then
        exe("yun powerup")
    end
    if skills["lingbo-weibu"] then
        exe("enable dodge lingbo-weibu;perform dodge.luoshen " .. score.id)
    end

    if skills["xiantian-gong"] and perform.force and perform.force == "xiantian-gong" then
        exe("yun wuqi")
    end

    if skills["huagong-dafa"] and perform.force and perform.force == "huagong-dafa" then
        exe("yun huadu")
    end

    if skills["bahuang-gong"] and perform.force and perform.force == "bahuang-gong" then
        exe("yun duzun")
        exe("yun bahuang")
    end
    if skills["yunu-xinjing"] and perform.force and perform.force == "yunu-xinjing" then
        exe("yun xinjing")
    end
    if skills["hanbing-zhenqi"] and perform.force and perform.force == "hanbing-zhenqi" then
        exe("yun huti")
    end
end

function prepare_lianxi(func)
    prepare_trigger()
    flag.prepare = 1
    condition = {}
    return check_busy(prepareLianxi)
end
function prepareLianxi()
    if mydummy == true then
        DeleteTriggerGroup("prepare_neili")
        return dummyfind()
    end
    if
        score.party == "姑苏慕容" and need_dzxy == "yes" and hp.food > 50 and hp.water > 50 and
            (location.time == "戊" or location.time == "亥" or location.time == "子" or location.time == "丑")
     then
        messageShow("任务监控：是三段斗转星移，而且是晚上，可以去看星星领悟斗转星移了！", "white")
        return check_halt(checkdzxy)
    end
    flag.jixu = 1
    if hp.neili_max > hp.neili_limit - 10 then
        exe("unset 积蓄")
    else
        flag.jixu = 0
        exe("unset 积蓄")
    end

    if job.zuhe["gblu"] and not location.id["铜钱"] and hp.exp < 2000000 then
        exe("drop 1 coin")
    end

    prepare_neili_a()
end
function prepare_neili(func, p_cmd)
    local l_db
    tmp.db = p_cmd
    l_db = 1 / 2
    if tmp.db and type(tmp.db) == "number" and tmp.db < 2 then
        l_db = tmp.db
    end

    if hp.neili > hp.neili_max * l_db then
        return check_bei(job.prepare)
    end

    prepare_trigger()
    flag.jixu = 1
    exe("unset 积蓄")
    flag.prepare = 0
    exe("yun regenerate;yun jingli;hp")
    if job.zuhe["gblu"] and not location.id["铜钱"] then
        exe("drop 1 coin")
    end
    prepare_neili_a()
end
function prepare_neili_at()
    if job.zuhe["gblu"] and not location.id["铜钱"] then
        exe("drop 1 coin")
    end

    prepare_trigger()
    AddTimer("neili", 3, "prepare_neili_idle")
end
function prepare_neili_a()
    condition.busy = 0
    prepare_neili_idle()
    if hp.qixue_per < 50 and Bag.Has(drug.heal) then
        exe("eat chantui yao")
    end
    AddTimer("neili", 3, "prepare_neili_idle")
end
function prepare_neili_b()
    if mydummy == true then
        DeleteTriggerGroup("prepare_neili")
        return dummyfind()
    end
    if score.party == "普通百姓" and nobusy == 0 and hp.pot >= 60 then
        if skills["literate"] and score.gold > 1000 and skills["literate"].lvl < hp.pot_max - 100 then
            return check_halt(literate)
        elseif
            (skills["force"].lvl > 200 and skills["force"].lvl < hp.pot_max - 100) or
                (skills["dodge"].lvl > 101 and skills["dodge"].lvl < hp.pot_max - 100) or
                (skills["parry"].lvl > 101 and skills["parry"].lvl < hp.pot_max - 100)
         then
            return check_halt(lingwu)
        end
    end
    if score.party ~= "普通百姓" and nobusy == 0 and hp.pot >= 60 then
        if skills["literate"] and score.gold > 1000 and skills["literate"].lvl < hp.pot_max - 100 then
            return check_halt(literate)
        elseif
            (skills["dodge"].lvl < 450 and skills["dodge"].lvl < hp.pot_max - 100) or
                (skills["parry"].lvl < 450 and skills["parry"].lvl < hp.pot_max - 100) or
                (skills["force"].lvl < 450 and skills["force"].lvl < hp.pot_max - 100)
         then
            return check_halt(xuexi)
        elseif
            (skills["force"].lvl >= 450 and skills["force"].lvl < hp.pot_max - 100) or
                (skills["dodge"].lvl >= 450 and skills["dodge"].lvl < hp.pot_max - 100) or
                (skills["parry"].lvl >= 450 and skills["parry"].lvl < hp.pot_max - 100)
         then
            return check_halt(lingwu)
        end
    end
    exe("yun recover;hp")
    check_bei(prepare_neili_c)
end
function prepare_neili_c()
    local l_db = 1 / 2
    -- if score.party and score.party=='峨嵋派' then
    --   l_db=5/4
    -- end
    -- if perform.skill and perform.skill=="jieshou-jiushi" then
    --   l_db=7/4
    -- end
    if tmp.db and type(tmp.db) == "number" and tmp.db < 2 then
        l_db = tmp.db
    end

    -- if job.zuhe["wudang"] then l_db = 1 end

    if not flag.prepare or type(flag.prepare) ~= "number" then
        flag.prepare = 0
    end

    if flag.prepare > 4 then
        flag.prepare = 0
    end
    if (hp.neili > hp.neili_max * l_db or hp.jingli > hp.jingli_max) and flag.prepare == 0 then
        DeleteTriggerGroup("prepare_neili")
        DeleteTimer("neili")
        exe("yun regenerate;yun qi;yun jingli")
        check_bei(job.prepare)
    else
        prepare_neili_a()
    end
end
function prepare_neili_w()
    locate()
    check_bei(prepare_neili_g)
end
function prepare_neili_g()
    exe(location.dir)
end
function prepare_neili_t()
    DeleteTimer("neili")
    tmp.i = 1
end
function prepare_neili_idle()
    local l_cnt = 0
    local l_db = 3 / 2

    for p in pairs(skills) do
        if skillEnable[p] and skillEnable[p] == "force" then
            tmp.fskill = p
            break
        end
    end
    if perform.force then
        tmp.fskill = perform.force
    end

    if
        ((hp.neili_max > hp.neili_limit - 20 and score.party and score.party == "峨嵋派") or
            hp.neili_max >= hp.neili_limit - 5 or
            flag.jixu == 1 or
            skills[tmp.fskill].full == 0) and
            hp.neili > hp.neili_max * l_db
     then
        if hp.neili > hp.neili_max * 7 / 4 then
            l_cnt = l_cnt + math.modf((hp.neili - hp.neili_max * 7 / 4) / 10)
        end
        l_cnt = l_cnt + math.modf(hp.neili_max / 300)
        if l_cnt < 1 then
            l_cnt = 1
        end
        lianxi(l_cnt)
    end
    if score.gold and score.gold > 1000 and hp.neili < hp.neili_max * 0.5 then
        exe("eat " .. drug.neili)
    end
    exe("yun jingli;yun regenerate;yun qi")
    if
        hp.jingli_max < hp.jingli_limit - 500 and flag.lianxi == 1 and hp.neili > hp.neili_max * l_db and
            ((hp.neili_max > hp.neili_limit - 20 and score.party and score.party == "峨嵋派") or
                hp.neili_max >= hp.neili_limit - 5 or
                flag.jixu == 1)
     then
        exe("unset 积蓄;tuna " .. hp.jingxue / 2)
    else
        exe("unset 积蓄;dazuo " .. hp.dazuo)
    end
    exe("cond")
end
function prepare_neili_stop()
    DeleteTimer("neili")
    DeleteTimer("bei")
    DeleteTriggerGroup("prepare_neili")
    beihook = test
    busyhook = test
    KillTriggerGroup("check_bei")
    KillTriggerGroup("check_busy")
    exe("halt")
end
function prepare_neili_liaokao()
    dis_all()
    return tiaoshui()
end
function prepare_neili_over()
    condition.busy = 0
    check_halt(prepare_neili_guanbi)
end
function prepare_neili_guanbi()
    if not flag.prepare or type(flag.prepare) ~= "number" then
        flag.prepare = 0
    end
    if job.prepare and job.prepare ~= test and flag.prepare > 0 then
        flag.prepare = 0
    end
    if job.prepare == duHhe_start or job.prepare == duCjiang_start then
        flag.prepare = 0
    end
    if flag.prepare > 4 then
        flag.prepare = 0
    end
    DeleteTriggerGroup("prepare_neili")
    DeleteTimer("neili")
    exe("yun regenerate;yun qi;yun jingli")
    check_bei(job.prepare)
end
function job.find()
    if job.name == nil then
        return 0
    end
end
function job.flag()
    flag.find = 0
    flag.wait = 0
end

function job_exp_trigger()
    DeleteTriggerGroup("job_exp")
    AddTrigger("job_exp", "job_exp3", "^(> )*你静下心来，反复回想刚才的任务过程，不禁豁然开朗。。你额外地得到了(\\D*)点经验！", "jobExpExtra")
    AddTrigger("job_exp", "job_exp4", "^>*\\s*你觉得脑中豁然开朗，增加了(\\D*)点潜能和(\\D*)点经验！", "job_exp_gb")
    AddTrigger("job_exp", "job_exp5", "^(> )*恭喜你！你成功的完成了(\\D*)任务！你被奖励了", "jobExp")
    AddTrigger("job_exp", "job_exp6", "^>*\\s*好，任务完成了，你得到了(\\D*)点实战经验，(\\D*)点潜能", "job_exp_gblu")
    AddTrigger("job_exp", "job_exp7", "^>*\\s*你被奖励了(\\D*)点经验，(\\D*)点潜能，(\\D*)点负神！$", "job_exp_shenlong")
    AddTrigger("job_exp", "job_exp8", "^(> )*您被奖励了(\\D*)点经验，(\\D*)点潜能，您已经为长乐帮出力(\\D*)次。", "job_exp_clb")
    -- 您被奖励了一点经验，五十六点潜能，您已经为长乐帮出力一百二十四次。
    -- AddTrigger('job_exp8','^(> )*你被奖励了(\\D*)点经验，(\\D*)点潜能，(\\D*)两黄金','','hubiaoFinish')
    -- create_triggerex_lvl('job_exp9',"^(> )*【队伍】(\\D*)\\((\\D*)\\)：gblu start",'','gbluTeamStart',95)
    AddTrigger("job_exp", "job_exp10", "^(> )*好！任务完成，你被奖励了：(\\D*)点实战经验，(\\D*)点潜能。(\\D*)神。$", "job_exp_songxin")
    AddTrigger("job_exp", "job_exp11", "^(> )*你获得了(\\D*)点经验，(\\D*)点潜能！你的侠义正气增加了！$", "job_exp_wudang")
    AddTrigger("job_exp", "job_exp12", "^(> )*你获得了(\\D*)点经验，(\\D*)点潜能，(\\D*)点\\D*神。$", "job_exp_huashan")
    AddTrigger("job_exp", "job_exp13", "^(> )*你被奖励了(\\D*)点经验，(\\D*)点潜能！你感觉邪恶之气更胜从前！$", "job_exp_xueshan")
    AddTrigger("job_exp", "job_exp14", "^(> )*你被奖励了：(\\D*)点实战经验，(\\D*)点潜能，(\\D*)白银，(\\D*)神。$", "job_exp_xuncheng")
    -- 你获得了五百三十九点经验，一百五十六点潜能，你共为神龙教铲除了四个恶贼。
    AddTrigger("job_exp", "job_exp15", "^(> )*你获得了(\\D*)点经验，(\\D*)点潜能，你共为(\\D*)铲除了(\\D*)个恶贼。$", "job_exp_dummy")
    AddTrigger("job_exp", "job_exp16", "^(> )*恭喜你任务顺利完成，你获得了(\\D*)经验，(\\D*)点潜能的奖励。$", "job_exp_tdh")
    AddTrigger("job_exp", "job_exp17", "^(> )*(你擅离职守，任务失败。|你速度太慢，西夏武士已过颂摩崖，任务失败。)", "job_gblu_fail")
    AddTrigger("job_exp", "job_exp18", "^(> )*糟了！(\\D*)死亡，任务失败！", "jobtdhfail")
end
function jobtdhfail()
    messageShow("天地会任务：接头人死亡，任务失败！")
    tdh_triggerDel()
    return check_food()
end
function jobExp()
    AddTrigger("job_exp", "job_exp1", "^(> )*(\\D*)点潜能!$", "jobExppot")
    AddTrigger("job_exp", "job_exp2", "^(> )*(\\D*)点经验!$", "jobExpexp")
    hp.exp_name = tostring(matches[3])
end
function jobExpexp()
    hp.exp_exp = tostring(matches[3])
end
function jobExppot()
    KillTrigger("job_exp", "job_exp1")
    KillTrigger("job_exp", "job_exp2")
    hp.exp_pot = tostring(matches[3])
    if not isNil(hp.exp_name) and not isNil(hp.exp_exp) and not isNil(hp.exp_pot) then
        return messageShow(hp.exp_name .. "任务奖励: 经验:【" .. hp.exp_exp .. "】,潜能:【" .. hp.exp_pot .. "】", "darkorange")
    end
    hp.exp_name = nil
    hp.exp_exp = nil
    hp.exp_pot = nil
end

-- ---------------------------------------------------------------
-- 任务统计初始化
-- ---------------------------------------------------------------
function job.statistics_Init()
    if job.statistics.PreviousExp == 0 then
        print("init")
        job.statistics = {
            IdleTime = 0,
            DeathTime = 0,
            PreviousExp = hp.exp,
            PreviousPot = hp.pot,
            PreviousMoney = score.gold,
            StartTime = os.time(),
            -- 持续时间
            Duration = "",
            Times = 0,
            Success = 0,
            Failure = 0,
            Efficiency = 0,
            Category = Category or {}
        }
    end
end
-- ---------------------------------------------------------------
-- 任务统计至dashboard上
-- ---------------------------------------------------------------
function job.statistics_Update()
    job.statistics = job.statistics or {}
    if job.statistics.PreviousExp == nil or job.statistics.PreviousExp == 0 then
        job.statistics.PreviousExp = hp.exp
    end
    local l_exp = hp.exp
    local l_time = os.time() - job.statistics.StartTime
    local l_hour = math.modf(l_time / 3600)
    local l_min = math.modf((l_time - l_hour * 3600) / 60)
    local l_sec = l_time - l_hour * 3600 - l_min * 60
    local l_exp = hp.exp - job.statistics.PreviousExp
    local l_avg = math.modf(l_exp * 3600 / l_time)

    job.statistics.Duration = l_hour .. "小时" .. l_min .. "分" .. l_sec .. "秒"
    job.statistics.Efficiency = l_avg
    -- 任务GUI面板显示
    GUIShow_JobStatistics()
end
-- ---------------------------------------------------------------
-- 任务统计至messageShow窗口
-- ---------------------------------------------------------------
function job_exp_tongji(p_cmd)
    tongji = tongji or {}
    if tongji.exp == nil then
        tongji.exp = hp.exp
        tongji.time = os.time()
        tongji.hour = math.modf(os.time() / 900)
        messageShowT("任务奖励统计：统计开始", "orange")
        return
    end

    if not tongji.time or not tongji.hour then
        tongji.exp = nil
        return
    end
    if math.modf(os.time() / 900) <= tongji.hour and not p_cmd then
        return
    end

    tongji.hour = math.modf(os.time() / 900)

    local l_exp = hp.exp
    local l_time = os.time() - tongji.time
    local l_hour = math.modf(l_time / 3600)
    local l_min = math.modf((l_time - l_hour * 3600) / 60)
    local l_sec = l_time - l_hour * 3600 - l_min * 60
    local l_exp = hp.exp - tongji.exp
    local l_avg = math.modf(l_exp * 3600 / l_time)

    job.expAvg = l_avg

    if flag.log and flag.log == "yes" then
        SJConfig.DebugShow(
            "任务奖励统计：共运行【" ..
                l_hour .. "小时" .. l_min .. "分" .. l_sec .. "秒" .. "】，获得经验【" .. l_exp .. "】点，平均每小时【" .. l_avg .. "】点！",
            "orange"
        )
    else
        SJConfig.DebugShow(
            "white",
            "black",
            "任务奖励统计：共运行【" ..
                l_hour .. "小时" .. l_min .. "分" .. l_sec .. "秒" .. "】，获得经验【" .. l_exp .. "】点，平均每小时【" .. l_avg .. "】点！"
        )
    end
end
function jobExpTongji()
    return job_exp_tongji(1)
end

JobTriggerDel = JobTriggerDel or {}

function jobTriggerDel()
    huashan_triggerDel()
    songxin_triggerDel()
    gaibangTriggerDel()
    zhuosheTriggerDel()
    clbTriggerDel()
    -- SmyTriggerDel()
    sldsmTriggerDel()
    -- hubiaoTriggerDel()
    tmonkTriggerDel()
    -- husongTriggerDel()
    wudangTriggerDel()
    -- xueshan_triggerDel()
    -- tdh_triggerDel()
    JobTriggerDel = JobTriggerDel or {}
    for p, q in pairs(JobTriggerDel) do
        _G[q]()
    end
end
-- ---------------------------------------------------------------
-- 检查是否需要内力检查, Isforce判断是否强制执行打坐
-- ---------------------------------------------------------------
function zhunbeineili(func, Isforce)
    if func ~= nil then
        job.prepare = func
    else
        job.prepare = test
    end
    if hp.neili >= hp.neili_max * 0.8 and not Isforce then
        return check_bei(job.prepare)
    end

    DeleteTriggerGroup("zbneili")
    AddTrigger(
        "zbneili",
        "zbneili1",
        "^(> )*(过了片刻，你感觉自己已经将玄天无极神功|你将寒冰真气按周天之势搬运了一周|你只觉真力运转顺畅，周身气力充沛|你将纯阳神通功运行完毕|你只觉神元归一，全身精力弥漫|你将内息走了个一个周天|你将内息游走全身，但觉全身舒畅|你将真气逼入体内，将全身聚集的蓝色气息|你将紫气在体内运行了一个周天|你运功完毕，站了起来|你一个周天行将下来，精神抖擞的站了起来|你分开双手，黑气慢慢沉下|你将内息走满一个周天，只感到全身通泰|你真气在体内运行了一个周天，冷热真气收于丹田|你真气在体内运行了一个周天，缓缓收气于丹田|你双眼微闭，缓缓将天地精华之气吸入体内|你慢慢收气，归入丹田，睁开眼睛|你将内息又运了一个小周天，缓缓导入丹田|你感觉毒素越转越快，就快要脱离你的控制了！|你将周身内息贯通经脉，缓缓睁开眼睛，站了起来|你呼翕九阳，抱一含元，缓缓睁开双眼|你吸气入丹田，真气运转渐缓，慢慢收功|你将真气在体内沿脉络运行了一圈，缓缓纳入丹田|你将内息在体内运行十二周天，返回丹田|你将内息走了个小周天，流回丹田，收功站了起来|过了片刻，你已与这大自然融合在一起，精神抖擞的站了起|你感到自己和天地融为一体，全身清爽如浴春风，忍不住舒畅的呻吟了一声，缓缓睁开了眼睛)",
        "zhunbeineili_b"
    )
    AddTrigger("zbneili", "zbneili3", "^(> )*卧室不能(吐纳|打坐)，会影响别人休息。", "zbneili_w")
    AddTrigger("zbneili", "zbneili4", "^(> )*(你正要有所动作|你无法静下心来修炼|你还是专心拱猪吧)", "zbneili_w")
    AddTrigger("zbneili", "zbneili5", "^(> )*这里不准战斗，也不准(吐纳|打坐)。", "zbneili_w")
    AddTrigger("zbneili", "zbneili2", "^(> )*这里可不是让你提高(内力|精力)的地方。", "zbneili_w")
    exe("yun regenerate;yun jingli;yun recover;hp")
    zhunbeineili_a()
end
function zbneili_w()
    locate()
    check_bei(zbneili_g)
end
function zbneili_g()
    exe(location.dir)
    checkWait(zhunbeineili_a, 1)
end
function zhunbeineili_a()
    if hp.qixue_per < 50 and Bag.Has(drug.heal) then
        exe("eat chantui yao")
    end
    exe("dazuo " .. hp.dazuo)
end
function zhunbeineili_b()
    if mydummy == true then
        DeleteTriggerGroup("zbneili")
        return dummyfind()
    end
    exe("yun recover;hp")
    check_bei(zhunbeineili_c)
end
function zhunbeineili_c()
    if hp.neili >= hp.neili_max * 0.8 then
        DeleteTriggerGroup("zbneili")
        exe("yun regenerate;yun recover;yun jingli")
        check_bei(job.prepare)
    else
        zhunbeineili_a()
    end
end

function setJobwhere(p)
    job.where = p
end
-- ---------------------------------------------------------------
-- 发呆记录
-- ---------------------------------------------------------------
function scrLog()
    local filename = SJConfig.Directory .. "\\logs\\" .. score.id .. "发呆" .. os.date("%Y%m%d_%H时%M分%S秒") .. ".log"
    local file = io.open(filename, "w")
    local t = {}
    local lineAmount = 5000
    local lineContent = ""
    if getLineNumber() < 5000 then
        lineAmount = getLineNumber()
    end
    local tbs = getLines(getLineNumber() - lineAmount, getLineNumber())
    for i = 1, lineAmount do
        lineContent = tbs[i]
        table.insert(t, lineContent)
    end
    local s = table.concat(t, "\n") .. "\n"
    file:write(s)
    file:close()
end
-- ---------------------------------------------------------------
-- 死亡记录
-- ---------------------------------------------------------------
function dieLog()
    local filename = SJConfig.Directory .. "\\logs\\" .. score.id .. "死亡" .. os.date("%Y%m%d_%H时%M分%S秒") .. ".log"
    local file = io.open(filename, "w")
    local t = {}
    local lineAmount = 5000
    local lineContent = ""
    if getLineNumber() < 5000 then
        lineAmount = getLineNumber()
    end
    local tbs = getLines(getLineNumber() - lineAmount, getLineNumber())
    for i = 1, lineAmount do
        lineContent = tbs[i]
        table.insert(t, lineContent)
    end
    local s = table.concat(t, "\n") .. "\n"
    file:write(s)
    file:close()
end
-- ---------------------------------------------------------------
-- Job 系统初始化
-- ---------------------------------------------------------------
function job.Init()
    -- SJConfig.DebugShow("正在初始化Job ...")
    -- SJConfig.DebugShow("正在初始化Job Statistics...")
    job.statistics_Init()
    if job.zuhe == nil or table.len(job.zuhe) == 0 then
        job.zuhe = {}
        -- SJConfig.DebugShow("开始加载任务组合..")
        local joblist = string.split(GetVariable("Jobzuhe"), "|")
        for p in pairs(joblist) do
            if string.len(joblist[p]) > 0 and utf8.trim(joblist[p]) ~= "|" then
                if not job.zuhe[joblist[p]] then
                    job.zuhe[joblist[p]] = true
                end
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 任务统计 任务数自增1
-- ---------------------------------------------------------------
function job.statistics_JobTimePlus()
    job.statistics.Times = job.statistics.Times or 0
    job.statistics.Times = job.statistics.Times + 1
    job.statistics_Update()
end
-- ---------------------------------------------------------------
-- job切换
-- ---------------------------------------------------------------
-- function check_jobx()
--     if hp.neili_max > 15000 and (hp.neili > (hp.neili_max * 0.8)) then
--         lianxi()
--     end
--     if hp.pot > (hp.pot_max - 100) then
--         check_pot()
--     else
--         job.Switch()
--     end
-- end

function checkJoblast()
    local joblast = {
        ["武当锄奸"] = "wudang",
        ["大理送信"] = "songxin",
        ["强抢美女"] = "xueshan",
        ["惩恶扬善"] = "huashan",
        ["长乐帮"] = "clb",
        ["天地会"] = "tdh",
        ["嵩山并派"] = "songshan",
        ["丐帮任务"] = "gaibang",
        ["颂摩崖抗敌任务"] = "songmoya"
    }

    if joblast[matches[3]] then
        job.last = joblast[matches[3]]
    end
end

-- ---------------------------------------------------------------
-- job切换具体实现方法
-- ---------------------------------------------------------------
function job.Switch()
    -- ---------------------------------------------------------------
    -- 强制练习模式
    -- ---------------------------------------------------------------
    -- if GetRoleConfig("PracticeForce") == true then
    --     exe("yun regenerate;yun qi;yun jingli;")
    --     quest.desc = "强制练习模式"
    --     quest.update()
    --     return check_food()
    -- end

    -- ---------------------------------------------------------------
    -- 公共任务, 限次数
    -- ---------------------------------------------------------------

    -- ---------------------------------------------------------------
    -- 新手任务部分先判断
    -- ---------------------------------------------------------------
    -- if xcexp == 0 and hp.exp < 1000000 then
    --     print("巡城到1M")
    --     kdummy = 0
    --     return xunCheng()
    -- end
    -- if xcexp == 1 and hp.exp < 2000000 then
    --     print("巡城到2M")
    --     kdummy = 0
    --     return xunCheng()
    -- end
    if score.party == "桃花岛" and (hp.shen > 150000 or hp.shen < -150000) then
        return thdJiaohui()
    end
    -- ---------------------------------------------------------------
    -- 成长阶段任务
    -- ---------------------------------------------------------------
    -- 任务组计数, 用于节省每次任务结束的判断, 一些判断改为每个任务组(10次)进行一次检查
    job.group.times = job.group.times or 0
    job.group.times = job.group.times + 1

    for p in pairs(weaponUsave) do
        if Bag and not Bag[p] then
            job.zuhe["songmoya"] = nil
        end
    end
    if job.zuhe["zhuoshe"] and score.party ~= "丐帮" then
        job.zuhe["zhuoshe"] = nil
    end
    if job.zuhe["sldsm"] and score.party ~= "神龙教" then
        job.zuhe["sldsm"] = nil
    end
    if job.zuhe["songmoya"] and hp.exp < 5000000 then
        job.zuhe["songmoya"] = nil
    end
    if GetVariable(SMY_AllowDieNum) and tonumber(smydie) >= tonumber(GetVariable(SMY_AllowDieNum)) then
        job.zuhe["songmoya"] = nil
    end
    if job.zuhe["husong"] and (score.party ~= "少林派" or hp.exp < 2000000) then
        job.zuhe["husong"] = nil
    end
    if job.zuhe["songmoya"] and job.last ~= "songmoya" and mytime <= os.time() then
        return songmoya()
    end
    if
        job.zuhe["hubiao"] and job.last ~= "hubiao" and job.teamname and
            ((not condition.hubiao) or (condition.hubiao and condition.hubiao <= 0))
     then
        return hubiao()
    elseif job.zuhe["husong"] then
        return husong()
    end

    if job.zuhe["songxin2"] then
        job.zuhe["songxin2"] = nil
        job.zuhe["songxin"] = true
        flag.sx2 = true
    end
    if job.last and job.zuhe[job.last] then
        if type(job.zuhe[job.last]) == "number" then
            job.zuhe[job.last] = job.zuhe[job.last] + 1
        else
            job.zuhe[job.last] = 1
        end
    end
    if
        countTab(job.zuhe) > 2 and not skills["xixing-dafa"] and job.zuhe["huashan"] and job.zuhe["wudang"] 
     then
        local t_hs = jobtimes["华山岳不群惩恶扬善"]
        local t_wd = jobtimes["武当宋远桥杀恶贼"]
        local t_times = math.fmod((t_hs + t_wd), 50)
        if t_times > 48 then
            exe("pray pearl")
            if job.last ~= "huashan" then
                return huashan()
            else
                for p in pairs(job.zuhe) do
                    if p ~= "huashan" and p ~= "wudang" and p ~= "hubiao" and p ~= "husong" and p ~= "songmoya" then
                        return _G[p]()
                    end
                end
            end
        end
    end
    if
        score.party and score.party == "华山派" and countTab(job.zuhe) > 2 and not skills["dugu-jiujian"] and
            job.zuhe["huashan"] and
            job.zuhe["songxin"]
     then
        local t_hs, t_sx, t_gb

        if jobtimes["华山岳不群惩恶扬善"] then
            t_hs = jobtimes["华山岳不群惩恶扬善"]
        else
            t_hs = 0
        end
        if jobtimes["大理王府送信任务"] then
            t_sx = jobtimes["大理王府送信任务"]
        else
            t_sx = 0
        end
        if jobtimes["丐帮吴长老杀人任务"] then
            t_gb = jobtimes["丐帮吴长老杀人任务"]
        else
            t_gb = 0
        end
        local t_times = math.fmod((t_hs + t_sx + t_gb), 50)
        if t_times > 47 then
            exe("pray pearl")
            if job.last ~= "huashan" then
                return huashan()
            else
                for p in pairs(job.zuhe) do
                    if p ~= "huashan" and p ~= "songxin" and p ~= "hubiao" and p ~= "husong" and p ~= "songmoya" then
                        return _G[p]()
                    end
                end
            end
        end
    end

    if job.third and job.zuhe[job.third] and job.last ~= job.third then
        if job.second and job.last == job.second then
            if job.third == "wudang" and (not job.wdtime or job.wdtime <= os.time()) then
                return _G[job.third]()
            end
            if job.third ~= "wudang" and job.third ~= "songmoya" then
                return _G[job.third]()
            end
        end
    end
    if job.first and job.zuhe[job.first] and job.last ~= job.first then
        if job.first ~= "xueshan" and job.first ~= "wudang" and job.first ~= "songmoya" then
            return _G[job.first]()
        end
        if job.first == "xueshan" and ((not condition.xueshan) or (condition.xueshan and condition.xueshan <= 0)) then
            return _G[job.first]()
        end
        if job.first == "wudang" and (not job.wdtime or job.wdtime <= os.time()) then
            return _G[job.first]()
        end
        if job.first == "xueshan" and condition.xueshan and condition.busy and condition.busy >= condition.xueshan then
            return _G[job.first]()
        end
    end
    if job.second and job.zuhe[job.second] and job.last ~= job.second then
        if job.second ~= "xueshan" and job.second ~= "wudang" and job.second ~= "songmoya" then
            return _G[job.second]()
        end
        if job.second == "xueshan" and ((not condition.xueshan) or (condition.xueshan and condition.xueshan <= 0)) then
            return _G[job.second]()
        end
        if job.second == "wudang" and (not job.wdtime or job.wdtime <= os.time()) then
            return _G[job.second]()
        end
        if job.second == "xueshan" and condition.xueshan and condition.busy and condition.busy >= condition.xueshan then
            return _G[job.second]()
        end
    end

    for p in pairs(job.zuhe) do
        if job.last ~= p and job.first ~= p and job.second ~= p and p ~= "songmoya" then
            return _G[p]()
        end
    end

    for p in pairs(job.zuhe) do
        if job.last ~= p and p ~= "songmoya" then
            return _G[p]()
        end
    end
    if job.zuhe["xueshan"] and job.last ~= "xueshan" then
        return xueshan()
    end
    if job.zuhe["huashan"] and job.last ~= "huashan" then
        return huashan()
    end
    if job.zuhe["tmonk"] and job.last ~= "tmonk" then
        return tmonk()
    end
    if job.zuhe["wudang"] and job.last ~= "wudang" then
        return wudang()
    end
    if job.zuhe["songxin"] and job.last ~= "songxin" then
        return songxin()
    end
    if job.zuhe["gaibang"] and job.last ~= "gaibang" then
        return gaibang()
    end
    if job.zuhe["zhuoshe"] and job.last ~= "zhuoshe" then
        return zhuoshe()
    end
    if job.zuhe["sldsm"] and job.last ~= "sldsm" then
        return sldsm()
    end
    if job.zuhe["songshan"] and job.last ~= "songshan" then
        return songshan()
    end
    if job.last ~= "songxin" then
        return songxin()
    end
    if job.last ~= "xueshan" and hp.shen < 0 then
        return xueshan()
    end
    if job.last ~= "wudang" and hp.shen > 100000 then
        return wudang()
    end
    if job.last ~= "gaibang" and hp.exp < 2000000 and hp.shen > 0 then
        return gaibang()
    end
    if job.last ~= "songshan" and hp.shen < 0 and hp.exp < 2000000 then
        return songshan()
    end
end
