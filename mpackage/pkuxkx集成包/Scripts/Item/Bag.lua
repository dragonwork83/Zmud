--
-- Bag.lua
--
--[[
--]]
cty_cur = 0
cbw_cur = 0
hxd_cur = 0
dhd_cur = 0

Bag = Bag or {}

-- ---------------------------------------------------------------
-- 获取每一种货币的具体数值的实现
-- ---------------------------------------------------------------
function Bag.GetCurrencySingleItem(str, CNname, ENname)
    Bag[CNname] = Bag[CNname] or {}
    Bag[CNname].id = ENname
    Bag[CNname].cnt = 1
    if string.contain(str, "×") then
        local st = string.split(str, "×")
        Bag[CNname].cnt = tonumber(st[2])
    end
end
-- ---------------------------------------------------------------
-- 获取每一种货币的具体数值
-- ---------------------------------------------------------------
function Bag.GetCurrencyAmout(str)
    if string.contain(str, "黄金") then
        Bag.GetCurrencySingleItem(str, "黄金", "gold")
    end
    if string.contain(str, "白银") then
        Bag.GetCurrencySingleItem(str, "白银", "silver")
    end
    if string.contain(str, "铜板") then
        Bag.GetCurrencySingleItem(str, "铜板", "coin")
    end
end
-- ---------------------------------------------------------------
-- 清空身上包裹的物件数量
-- ---------------------------------------------------------------
function Bag.Empty()
    for k, v in pairs(Bag) do
        if type(v) == "table" then
            Bag[k] = nil
        end
    end
end
-- ---------------------------------------------------------------
-- 检查包裹里是否含有某件东西
-- ---------------------------------------------------------------
function Bag.Has(p_item)
    if p_item == nil then
        return false
    end
    if Bag[p_item] and type(Bag[p_item]) then
        return true
    end
end
-- ---------------------------------------------------------------
-- 检查捡到的护具
-- ---------------------------------------------------------------
function Bag.ArmorCheck()
    common.warning(" ArmorCheck 待实现!~ ")
end
-- ---------------------------------------------------------------
-- 存钱触发集合
-- ---------------------------------------------------------------
local function _SaveMoneyTrigger()
    Bag.Bank = Bag.Bank or {}
    Bag.Bank.cmd = Bag.Bank.cmd or nil
    AddTrigger("钱庄存钱","存钱Busy","^钱眼开说道：「哟，抱歉啊，我这儿正忙着呢……您请稍候。」",function() tempTimer(1.5, [[Bag.SaveMoneyHandle()]]) end)
    AddTrigger("钱庄存钱","存钱完成","^系统回馈：钱庄存钱 = 完成",function() tempTimer(1.5, function() KillTriggerGroup("钱庄存钱") job.prepare() end)end)
    AddTrigger("钱庄存钱","存钱成功","^你拿出(.*)?，存进了银号。",[[exe("i;response 钱庄存钱 继续")]])
    AddTrigger("钱庄存钱","存钱继续","^系统回馈：钱庄存钱 = 继续",function() tempTimer(1.5, [[Bag.SaveMoneyHandle()]]) end)
end
-- ---------------------------------------------------------------
-- 检查是否需要存钱
-- ---------------------------------------------------------------
function Bag.NeedDepositMoney()
    if (Bag["黄金"] and Bag["黄金"].cnt > 8) or (Bag["白银"] and Bag["白银"].cnt > 1200) or (Bag["铜板"] and Bag["铜板"].cnt > 1500)  then
        return true
    else
        return false
    end
end
-- ---------------------------------------------------------------
-- 存钱处理handle
-- ---------------------------------------------------------------
function Bag.SaveMoneyHandle()
    Bag.Bank = Bag.Bank or {}
    Bag.Bank.cmd = nil
    if Bag["黄金"] and Bag["黄金"].cnt > 8 then
        Bag.Bank.cmd = "cun "..Bag["黄金"].cnt.." gold"
    elseif Bag["白银"] and Bag["白银"].cnt > 100 then
        Bag.Bank.cmd = "cun "..(tonumber(Bag["白银"].cnt) - 100).." silver"
    elseif Bag["铜板"] and Bag["铜板"].cnt > 1500 then
        Bag.Bank.cmd = "cun 1500 coin"
    end
    if Bag.Bank.cmd == nil then
        Bag.Bank.cmd = "response 钱庄存钱 完成"
    end
    send(Bag.Bank.cmd)
end
-- ---------------------------------------------------------------
-- 钱庄存钱
-- ---------------------------------------------------------------
function Bag.SaveMoney()
    pkuxkx.gps.gotodoExtend("扬州","扬州钱庄", function()
        -- step 1. 打开存钱触发器
        _SaveMoneyTrigger()
        -- step 2. 尝试存钱
        Bag.SaveMoneyHandle()
    end)
end
-- ---------------------------------------------------------------
-- 根据字符串 转换为 物品item项
-- ---------------------------------------------------------------
function ParseItem(str)
    if string.find(str, "%(") == nil then
        return
    end
    local names = string.split(str, "(")
    if table.len(names) > 1 then
        -- 物品中文ID
        if Bag[names[1]] == nil then
            Bag[names[1]] = {}
        end
        -- 物品英文ID
        if names[2] ~= nil then
            local tsi = string.split(names[2], ")")
            if table.len(tsi) > 0 then
                Bag[names[1]].id = tsi[1]
            end
        end
        -- 判断物品数量是否多个 即判断符号(×)
        if string.find(str, "×") ~= nil then
            local tsp = string.split(names[2], "×")
            if table.len(tsp) > 1 then
                Bag[names[1]].cnt = tonumber(tsp[2])
            end
        end
        if Bag[names[1]].cnt == nil then
            Bag[names[1]].cnt = 1
        end
    end
end

-- ---------------------------------------------------------------
-- 检查身上的绳子是否足够, 用于进华山山洞
-- ---------------------------------------------------------------
function CheckRope(func)
    delete_all_timers()
    if not Bag["绳子"] then
        print("绳子不够")
        exe("s;s;tell rope 交货")
        tempTimer(
            2,
            function()
                exe("get sheng zi;i;n;n;")
                return func()
            end
        )
    else
        print("绳子够了")
        return func()
    end
end

-- ---------------------------------------------------------------
-- 重置/刷新包裹里的所有物品以及数量 (包含金银数)
-- ---------------------------------------------------------------
function RefreshBags(func)
    ResetBags()
    DeleteTriggerGroup("Yaobags")
    AddTrigger("Yaobags", "Yaobags1", "^(> )*(\\D*)(锭|两|张)(白银|黄金|壹仟两银票)\\(", "checkBagsMoney")
    -- AddTrigger("Yaobags", "Yaobags2", '^(> )*你把 "action" 设定为 "检查药品" 成功完成。$', "checkYaoBagsOver")
    -- RefreshBagsItems([[exe("i;alias action 检查药品")]])
    DeleteTriggerGroup("bags")
    AddTrigger("bags", "bags1", "^(> )*你身上携带物品的别称如下", "checkBagsStart")
    tmp.bags = func
    exe("i;id;alias action 刷新包裹")
end

function checkYaoBags(func)
    RefreshBags(func)
end
function checkYaoBagsOver()
    -- checkBY()
    DeleteTriggerGroup("Yaobags")
    if tmp.yaobags ~= nil then
        return tmp.yaobags()
    end
end

-- ----------------------------------------------------------
-- 根据物品英文名(fullid),获取物品中文名, 仅限身上Bag里的物品
-- ----------------------------------------------------------
function GetItemChineseInBagByFullID(tFullID)
    local CN_name = ""
    for p in pairs(Bag) do
        if Bag[p].fullid == tFullID then
            CN_name = tostring(p)
        end
    end
    return CN_name
end
function checkBags_Trigger()
    AddTrigger("bags", "bags2", "^\\d*:(\\D*) = (\\D*)$", "checkBagsId")
    AddTrigger("bags", "bags3", "^(> )*你目前已经拥有了(\\D*)件私有装备：(\\D*)。$", "checkBagsU")
    AddTrigger("bags", "bags4", "^(> )*(\\D*)(锭|两|张)(白银|黄金|壹仟两银票)\\(", "checkBagsMoney")
    AddTrigger("bags", "bags5", '^(> )*你把 "action" 设定为 "检查包裹" 成功完成。$', "checkBagsOver")
    AddTrigger("bags", "bags6", '^(> )*你把 "action" 设定为 "刷新包裹" 成功完成。$', "checkBagsOver")
    AddTrigger("bags", "bags7", "^(> )*(\\D*)枚飞镖\\(", "checkBagsDart")
    AddTrigger("bags", "bags8", "^(> )*你身上带着(\\D*)件东西\\(负重\\s*(\\d*)\\.\\d*\\%\\)：", "checkBagsW")
end
function checkBags(func)
    ResetBags()
    DeleteTriggerGroup("bags")
    AddTrigger("bags", "bags1", "^(> )*你身上携带物品的别称如下", "checkBagsStart")
    tmp.bags = func
    weaponUsave = {}
    exe("id")
    checkWield()
    exe("uweapon;alias action 检查包裹")
end
-- function checkBagsletter()
--     lostletter = 1
-- end
function checkBagsStart()
    checkBags_Trigger()
end
function checkBagsId()
    local l_name = utf8.trim(matches[2])
    local l_id = matches[3]
    local l_set = {}
    local l_cnt = 0
    if not Bag[l_name] then
        Bag[l_name] = {}
    end
    Bag[l_name].id = {}
    if string.find(l_id, ",") then
        l_set = string.split(l_id, ",")
        l_id = l_set[1]
        for k, v in ipairs(l_set) do
            Bag[l_name].id[utf8.trim(v)] = true
            if string.len(utf8.trim(v)) > l_cnt then
                Bag[l_name].fullid = utf8.trim(v)
                l_cnt = string.len(utf8.trim(v))
            end
        end
    else
        Bag[l_name].id[utf8.trim(l_id)] = true
        -- table.insert(Bag[l_name].id,1,Trim(l_id))
        Bag[l_name].fullid = utf8.trim(l_id)
    end
    if Bag[l_name].id["armor"] then
        Bag[l_name].kind = "armor"
    end
    if Bag[l_name].id["dao"] or Bag[l_name].id["blade"] then
        Bag[l_name].kind = "blade"
    end
    if Bag[l_name].id["jian"] or Bag[l_name].id["sword"] then
        Bag[l_name].kind = "sword"
    end
    if Bag[l_name].id["xiao"] then
        Bag[l_name].kind = "xiao"
    end
    if Bag[l_name].id["gun"] or Bag[l_name].id["club"] then
        Bag[l_name].kind = "club"
    end
    if Bag[l_name].id["stick"] or Bag[l_name].id["zhubang"] or Bag[l_name].id["bang"] then
        Bag[l_name].kind = "stick"
    end
    if Bag[l_name].id["bi"] or Bag[l_name].id["brush"] then
        Bag[l_name].kind = "brush"
    end
    if Bag[l_name].id["qiang"] or Bag[l_name].id["spear"] then
        Bag[l_name].kind = "spear"
    end
    if Bag[l_name].id["chui"] or Bag[l_name].id["hammer"] then
        Bag[l_name].kind = "hammer"
    end
    if Bag[l_name].id["gangzhang"] or Bag[l_name].id["staff"] or Bag[l_name].id["zhang"] or Bag[l_name].id["jiang"] then
        Bag[l_name].kind = "staff"
    end
    if Bag[l_name].id["bian"] or Bag[l_name].id["whip"] then
        Bag[l_name].kind = "whip"
    end
    if Bag[l_name].id["hook"] then
        Bag[l_name].kind = "hook"
    end
    if Bag[l_name].id["fu"] or Bag[l_name].id["axe"] then
        Bag[l_name].kind = "axe"
    end
    if Bag[l_name].id["bishou"] or Bag[l_name].id["dagger"] then
        Bag[l_name].kind = "dagger"
    end
    if weaponThrowing[l_name] then
        Bag[l_name].kind = "throwing"
    end
    if (utf8.find(l_name, "残篇") or utf8.find(l_name, "精要")) and not itemSave[l_name] then
        exe("read book")
        exe("drop " .. Bag[l_name].fullid)
    end
    if drugReward[l_name] and (not drugPoison[l_name] and not drugBuy[l_name]) then
        exe("eat " .. Bag[l_name].fullid)
    end
    bags[l_name] = utf8.trim(l_id)
    if Bag[l_name].cnt then
        Bag[l_name].cnt = Bag[l_name].cnt + 1
    else
        Bag[l_name].cnt = 1
    end
end
function checkBagsU()
    local t = utf8.trim(matches[4])
    local s = string.split(t, ",")
    for p, q in pairs(s) do
        if string.find(q, "⊕") then
            q = string.sub(q, 3, -1)
        end
        -- 加入精血判断,若精血小于2000, 很可能修不了武器,造成一直尝试修武器的死循环
        if hp.jingxue > 2000 then
            weaponUsave[q] = true
        end
    end
end
function checkBagsMoney()
    local l_cnt = trans(utf8.trim(matches[3]))
    local l_name = utf8.trim(matches[5])
    if Bag[l_name] then
        Bag[l_name].cnt = l_cnt
    -- print(l_name .. " : " .. tostring(l_cnt))
    end
end
function checkBagsW()
    local t = tonumber(matches[4])
    if t ~= nil and Bag["ENCB"] ~= nil then
        Bag["ENCB"].value = t
    end
end
function checkBagsDart()
    local l_name = "枚飞镖"
    Bag[l_name] = {}
    Bag[l_name].id = {}
    Bag[l_name].cnt = 0
    local l_cnt = trans(utf8.trim(matches[3]))
    Bag[l_name].cnt = l_cnt
end
function checkBagsOver()
    -- checkBY()
    DeleteTriggerGroup("Yaobags")
    DeleteTriggerGroup("bags")
    if Bag["大碗茶"] then
        exe("drop cha")
    end
    if Bag["棉花种子"] then
        exe("drop " .. Bag["棉花种子"].fullid)
    end
    if Bag["棉花"] then
        exe("drop " .. Bag["棉花"].fullid)
    end
    if Bag["青铜"] then
        exe("drop " .. Bag["青铜"].fullid)
    end
    if Bag["生铁"] then
        exe("drop " .. Bag["生铁"].fullid)
    end
    if Bag["粗绳子"] and Bag["粗绳子"].cnt > 2 then
        exe("drop cu shengzi 2")
    end
    if Bag["木剑"] and Bag["木剑"].cnt > 1 then
        exe("drop mu jian 2")
    end
    if Bag["水蜜桃"] then
        exe("drop mi tao")
    end
    if tmp.bags ~= nil then
        if type(tmp.bags) == "string" then
            local fun = _G[tmp.bags]
            if fun then
                fun()
            end
         -- body
        else
            tmp.bags()
        end
    end
    -- GUI界面显示刷新
    GUIShow_Bag()
end


function checkHmGive()
    if Bag["韦兰之锤"] then
        exe("give " .. Bag["韦兰之锤"].fullid .. " to zhujian shi")
    end
    Bag["韦兰之锤"] = nil
    return checkPrepare()
end
function check_gold()
    tmp.cnt = 0
    return go(check_gold_yz, "扬州城", "天阁斋")
end
function check_gold_yz()
    if not location.id["钱缝"] then
        return go(check_gold_dali, "大理城", "大理钱庄")
    else
        return check_gold_count()
    end
end
function check_gold_dali()
    if not location.id["严掌柜"] then
        return go(check_gold_xy, "襄阳城", "宝龙斋")
    else
        return check_gold_count()
    end
end
function check_gold_xy()
    if not location.id["钱善人"] then
        return go(check_gold_cd, "成都城", "墨玉斋")
    else
        return check_gold_count()
    end
end
function check_gold_cd()
    if not location.id["王掌柜"] then
        return go(check_gold_yz, "扬州城", "天阁斋")
    else
        return check_gold_count()
    end
end
function check_gold_count()
    if Bag["壹仟两银票"] and Bag["壹仟两银票"].cnt > 10 then
        exe("score;chazhang")
        if score.goldlmt and score.gold and (score.goldlmt - score.gold) > 50 then
            return check_cash_cun()
        end
    end
    if Bag and Bag["白银"] and Bag["白银"].cnt and Bag["白银"].cnt > 500 then
        return check_silver_qu()
    end
    if
        (Bag and Bag["黄金"] and Bag["黄金"].cnt and Bag["黄金"].cnt < count.gold_max and score.gold > count.gold_max) or
            (Bag and Bag["黄金"] and Bag["黄金"].cnt and Bag["黄金"].cnt > count.gold_max * 4)
     then
        -- SJConfig.DebugShow('Bag["黄金"].cnt : ' .. tostring(Bag["黄金"].cnt))
        return check_gold_qu()
    end

    check_gold_over()
end
function check_cash_cun()
    bank_trigger()
    if Bag["壹仟两银票"] then
        local l_cnt
        if score.goldlmt and score.gold and (score.goldlmt - score.gold) < Bag["壹仟两银票"].cnt * 10 then
            l_cnt = math.modf((score.goldlmt - score.gold) / 10) - 1
        else
            l_cnt = Bag["壹仟两银票"].cnt
        end
        if l_cnt > 0 then
            exe("cun " .. l_cnt .. " cash")
        end
    end
    checkBags()
    return checkWait(check_gold_check, 3)
end
function check_silver_qu()
    bank_trigger()
    local l_cnt = Bag["白银"].cnt - 100
    exe("cun " .. l_cnt .. " silver")
    exe("qu 50 silver")
end
function bank_trigger()
    -- 你从银号里取出
    -- 你拿出十锭黄金，存进了银号。
    -- 严掌柜说道：哟，抱歉啊，我这儿正忙着呢……您请稍候。
    DeleteTriggerGroup("bankmovement")
    AddTrigger("bankmovement", "moneyqu1", "^(> )*你从银号里取出", "bankafter")
    AddTrigger("bankmovement", "moneycun1", "^(> )*你拿出(.*?)，存进了银号", "bankafter")
    AddTrigger("bankmovement", "moneybusy", "^(> )*(.*?)说道：(“)*哟，抱歉啊，我这儿正忙着呢", "bankafter")
end
function bankafter()
    checkBags()
    tempTimer(
        0.5,
        function()
            checkWait(check_gold_check, 1)
        end
    )
end
function check_gold_qu()
    bank_trigger()
    local l_cnt = Bag["黄金"].cnt - count.gold_max * 2
    if l_cnt > 0 then
        exe("cun " .. l_cnt .. " gold")
    end
    if Bag["黄金"].cnt < count.gold_max then
        exe("qu " .. count.gold_max .. " gold")
    end
end
function check_gold_check()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 5 then
        return check_heal()
    end
    return check_gold_count()
end
function check_gold_over()
    DeleteTriggerGroup("bankmovement")
    return check_busy(checkPrepare, 1)
end

function checkZqd()
    tmp.cnt = 0
    return go(checkZqdBuy, randomElement(drugBuy["正气丹"]))
end
function checkZqdBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 30 then
        return checkZqdOver()
    else
        exe("buy zhengqi dan")
        checkBags()
        return check_bei(checkZqdi)
    end
end
function checkZqdi()
    if Bag["黄金"] and Bag["黄金"].cnt > 4 and (not Bag["正气丹"] or Bag["正气丹"].cnt < 4) then
        return checkWait(checkZqdBuy, 1)
    else
        return checkZqdOver()
    end
end
function checkZqdOver()
    checkBags()
    return check_bei(checkPrepare, 1)
end

function checkXqw()
    tmp.cnt = 0
    return go(checkXqwBuy, randomElement(drugBuy["邪气丸"]))
end
function checkXqwBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 30 then
        return checkXqwOver()
    else
        exe("buy xieqi wan")
        checkBags()
        return check_bei(checkXqwi)
    end
end
function checkXqwi()
    if Bag["黄金"] and Bag["黄金"].cnt > 4 and (not Bag["邪气丸"] or Bag["邪气丸"].cnt < 4) then
        return checkWait(checkXqwBuy, 1)
    else
        return checkXqwOver()
    end
end
function checkXqwOver()
    checkBags()
    return check_bei(checkPrepare, 1)
end
-- ---------------------------------------------------------------
-- 检查内力药是否足够
-- ---------------------------------------------------------------
function checkNxw()
    tmp.cnt = 0
    if score.gold and score.gold > 100 and (Bag["川贝内息丸"] == nil or Bag["川贝内息丸"].cnt < count.cbw_max) then
        return go(checkNxwBuy, randomElement(drugBuy["川贝内息丸"]))
    else
        return checkNxwOver()
    end
end
function checkNxwBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 30 then
        return checkNxwOver()
    else
        -- RefreshBags(checkNxwi)
        if (Bag["川贝内息丸"] == nil or Bag["川贝内息丸"].cnt < count.cbw_max) then
            exe("buy " .. drug.neili)
        end
        check_busy(RefreshBags, 0.5, checkNxwi)
    end
end
function checkNxwi()
    if (Bag["川贝内息丸"] == nil or (Bag["川贝内息丸"].cnt < count.cbw_max)) and Bag["黄金"] and Bag["黄金"].cnt > 4 then
        return checkWait(checkNxwBuy, 1)
    else
        return checkNxwOver()
    end
end

function checkNxwOver()
    return check_bei(checkPrepare, 1)
end

function checkHxd()
    tmp.cnt = 0
    if score.gold and score.gold > 100 and (Bag["蝉蜕金疮药"] == nil or Bag["蝉蜕金疮药"].cnt < 1) then
        return go(checkHxdBuy, randomElement(drugBuy["蝉蜕金疮药"]))
    else
        return checkNxwOver()
    end
end
function checkHxdBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 30 then
        return checkNxwOver()
    else
        if score.gold and score.gold > 100 and (Bag["蝉蜕金疮药"] == nil or Bag["蝉蜕金疮药"].cnt < count.cty_max) then
            exe("buy " .. drug.heal)
        end
        checkYaoBags(check_bei(checkHxdBag))
    end
end
function checkHxdBag()
    if cty_cur < count.cty_max and Bag["黄金"] and Bag["黄金"].cnt > 4 then
        return checkWait(checkHxdBuy, 1)
    else
        return checkNxwOver()
    end
end

function checkLjd()
    tmp.cnt = 0
    if score.gold and score.gold > 100 and hxd_cur < count.hxd_max then
        return go(checkLjdBuy, randomElement(drugBuy["活血疗精丹"]))
    else
        return checkNxwOver()
    end
end
function checkLjdBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 30 then
        return checkNxwOver()
    else
        exe("buy " .. drug.jingxue)
        checkYaoBags(check_bei(checkLjdBag))
    end
end
function checkLjdBag()
    if hxd_cur < count.hxd_max and Bag["黄金"] and Bag["黄金"].cnt > 4 then
        return checkWait(checkLjdBuy, 1)
    else
        return checkNxwOver()
    end
end
function bagDhd()
    if Bag["大还丹"] or Bag["大还丹(盒)"] or Bag["大还丹(超大)"] then
        return true
    else
        return false
    end
end
function checkdhd()
    tmp.cnt = 0
    if score.tb and score.tb > 100 and (Bag["大还丹"] == nil or Bag["大还丹"].cnt < 1) then
        return go(checkdhdBuy, randomElement(drugBuy["大还丹"]))
    else
        return checkNxwOver()
    end
end
function checkdhdBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 30 then
        return checkNxwOver()
    else
        exe("duihuan dahuan dan;score")
        checkYaoBags(check_halt(checkdhdBag))
    end
end
function checkdhdBag()
    if (Bag["大还丹"] == nil or Bag["大还丹"].cnt < count.dhd_max) and score.tb and score.tb > 100 then
        return checkWait(checkdhdBuy, 1)
    else
        return checkNxwOver()
    end
end
function checkFire()
    if not Bag["火折"] then
        return go(checkFireBuy, randomElement(drugBuy["火折"]))
    else
        return checkFireOver()
    end
end
function checkFireBuy()
    exe("buy fire")
    checkBags()
    return checkFireOver()
end
function checkFireOver()
    exe("drop fire 2")
    return check_busy(checkPrepare, 1)
end

function checkYu(p_yu)
    tmp.yu = p_yu
    return go(checkYuCun, "扬州城", "杂货铺")
end
function checkYuCun()
    exe("cun " .. Bag[tmp.yu].fullid)
    return check_bei(checkYuOver)
end
function checkYuOver()
    exe("cun yu;drop yu")
    checkBags()
    return check_busy(checkPrepare, 1)
end

function checkSell(p_sell)
    tmp.sell = p_sell
    return go(checkSellDo, "扬州城", "当铺")
end
function checkSellDo()
    if Bag[tmp.sell] then
        exe("sell " .. Bag[tmp.sell].fullid)
    end
    return check_bei(checkSellOver)
end
function checkSellOver()
    if Bag[tmp.sell] then
        exe("sell " .. Bag[tmp.sell].fullid)
        exe("drop " .. Bag[tmp.sell].fullid)
    end
    checkBags()
    return check_busy(checkPrepare, 1)
end

function check_item()
    if score.party and score.party == "峨嵋派" and not Bag["腰带"] then
        return check_item_go()
    elseif score.party == "少林派" and not Bag["护腰"] and not Bag["护腕"] then
        return go(checkSengxie, "嵩山少林", "防具库")
    else
        return check_item_over()
    end
end
function checkSengxie()
    exe("ask chanshi about 僧鞋")
    return check_bei(checkHuyao)
end
function checkHuyao()
    exe("ask chanshi about 护腰")
    return check_bei(checkHuwan)
end
function checkHuwan()
    exe("ask chanshi about 护腕")
    return check_bei(check_item_over)
end
function check_item_go()
    go(check_item_belt, "峨嵋山", "储物间")
end
function check_item_belt()
    exe("ask shitai about 皮腰带")
    check_bei(check_item_over)
end
function check_item_over()
    exe("drop shoes 2")
    exe("remove all")
    exe("wear all")
    flag.item = true
    return checkPrepare()
end
