Weapon = {}
weaponPrepare = {}
weaponUsave = {}
itemWield = {}
weaponStore = {
    ["箫"] = "city/yueqidian",
    ["木剑"] = "xiangyang/mujiangpu",
    ["长剑"] = "zhiye/bingqipu1",
    ["铁笔"] = "zhiye/bingqipu1",
    ["钢刀"] = "zhiye/bingqipu1",
    ["流星锤"] = "zhiye/bingqipu1",
    ["铁棍"] = "zhiye/bingqipu1",
    ["钢杖"] = "zhiye/bingqipu1",
    ["长鞭"] = "zhiye/bingqipu1",
    ["竹棒"] = "zhiye/bingqipu1",
    ["钢斧"] = "zhiye/bingqipu1",
    ["匕首"] = "zhiye/bingqipu1",
    ["单钩"] = "zhiye/bingqipu1",
    ["石子"] = "zhiye/bingqipu1",
    ["飞镖"] = "zhiye/bingqipu1",
    ["梅花针"] = "zhiye/bingqipu1",
    ["手裏剑"] = "zhiye/bingqipu1",
    ["银蛇剑"] = "xiangyang/bingqipu",
    ["碎雪刀"] = "xiangyang/bingqipu",
    ["寒玉钩"] = "xiangyang/bingqipu",
    ["仿制玉竹棒"] = "xiangyang/bingqipu",
    ["天蛇杖"] = "xiangyang/bingqipu",
    ["玉箫"] = "xiangyang/bingqipu",
    ["新人护腕"] = "xiangyang/mujiangpu"
}
weaponStoreId = {
    ["箫"] = "xiao",
    ["木剑"] = "mu jian",
    ["长剑"] = "changjian",
    ["铁笔"] = "tie bi",
    ["钢刀"] = "blade",
    ["流星锤"] = "liuxing chui",
    ["铁棍"] = "tiegun",
    ["钢杖"] = "gangzhang",
    ["长鞭"] = "changbian",
    ["竹棒"] = "zhubang",
    ["钢斧"] = "gang fu",
    ["匕首"] = "bishou",
    ["单钩"] = "hook",
    ["石子"] = "shizi",
    ["飞镖"] = "dart",
    ["梅花针"] = "meihua zhen",
    ["手裏剑"] = "shuriken",
    ["银蛇剑"] = "yinshe sword",
    ["碎雪刀"] = "xue sui",
    ["寒玉钩"] = "hanyu gou",
    ["仿制玉竹棒"] = "zhu bang",
    ["天蛇杖"] = "tianshe zhang",
    ["玉箫"] = "yu xiao",
    ["新人护腕"] = "hu wan"
}
weaponFunc = {
    ["松纹古剑"] = "if score.master and score.master=='张三丰' then return true else return false end"
}
weaponFuncName = {["松纹古剑"] = "weaponGetSwj"}
weaponThrowing = {
    ["梅花针"] = true,
    ["手裏剑"] = true,
    ["飞镖"] = true,
    ["铜钱"] = true,
    ["石子"] = true,
    ["甩箭"] = true,
    ["神龙镖"] = true,
    ["飞蝗石"] = true
}
armorKind = {["armor"] = true}
weaponKind = {
    ["ren"] = "cut",
    ["blade"] = "cut",
    ["sword"] = "cut",
    ["stick"] = true,
    ["club"] = true,
    ["hammer"] = true,
    ["whip"] = true,
    ["axe"] = "cut",
    ["staff"] = true,
    ["brush"] = true,
    ["dagger"] = "cut",
    ["hook"] = "cut",
    ["spear"] = true,
    ["throwing"] = true,
    ["xiao"] = true,
    ["fork"] = true,
    ["dart"] = true
}
unarmedKind = {
    ["cuff"] = true,
    ["strike"] = true,
    ["finger"] = true,
    ["claw"] = true,
    ["hand"] = true,
    ["leg"] = true
}

-- ---------------------------------------------------------------
-- 装备所有武器
-- ---------------------------------------------------------------
function Weapon.wield()
    local cmds = ""
    if Role.settings.weapon and string.len(Role.settings.weapon) > 0 then
        if string.contain(Role.settings.weapon,"|") then
            local tabs = string.split(Role.settings.weapon,"|")
            for i=1,#tabs do
                if string.len(tabs[i]) > 0 then
                    cmds = cmds.."wield "..tabs[i]..";"
                end
            end
        else
            cmds = "wield "..Role.settings.weapon..";"
        end
        exe(cmds)
    end
end
-- ---------------------------------------------------------------
-- 卸下所有武器
-- ---------------------------------------------------------------
function Weapon.unwield()
    local cmds = ""
    if Role.settings.weapon and string.len(Role.settings.weapon) > 0 then
        if string.contain(Role.settings.weapon,"|") then
            local tabs = string.split(Role.settings.weapon,"|")
            for i=1,#tabs do
                if string.len(tabs[i]) > 0 then
                    cmds = cmds.."unwield "..tabs[i]..";"
                end
            end
        else
            cmds = "unwield "..Role.settings.weapon..";"
        end
        exe(cmds)
    end
end
-- ---------------------------------------------------------------
-- 装备回内力武器, 前提是在之前的命令已经执行过 i 命令, 获得身上最新的装备着的武器信息
-- ---------------------------------------------------------------
function Weapon.RecoverNeili(force)
    -- 在紫檀站中并无回内武器
end

function weaponInBag(p_kind)
    for p in pairs(Bag) do
        if Bag[p].kind and Bag[p].kind == p_kind then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------
-- 重置,并重新检查包含里所有装备中的装备
-- ---------------------------------------------------------------

function checkWield()
    itemWield = {}
    exe("i")
end

function checkWieldCatch()
    itemWield = itemWield or {}
    local l_item = matches[2]
    for p in pairs(weaponThrowing) do
        if string.find(l_item, p) then
            l_item = p
        end
    end
    itemWield[l_item] = true
end



function weaponWWalk()
    Weapon.wield()
    return walk_wait()
end

function weaponUnWalk()
    Weapon.unwield()
    return walk_wait()
end

function weaponWieldCut()
    if Bag["木剑"] then
        exe("wield " .. Bag["木剑"].fullid)
    else
        for p in pairs(Bag) do
            if Bag[p].kind and weaponKind[Bag[p].kind] and weaponKind[Bag[p].kind] == "cut" then
                if not (Bag[p].kind == "xiao" and weaponUsave[p]) then
                    for q in pairs(Bag) do
                        if Bag[q].kind == "xiao" and weaponUsave[q] then
                            exe("unwield " .. Bag[q].fullid)
                        end
                    end
                    exe("wield " .. Bag[p].fullid)
                end
            end
        end
    end
    checkWield()
end
function weaponUcheck()
    DeleteTriggerGroup("weapon")
    AddTrigger("weapon", "weapon1", '^(> )*你把 "action" 设定为 "checkUweapon" 成功完成。', "weaponUdone")
    AddTrigger(
        "weapon",
        "weapon2",
        "^(> )*这是一(柄)由\\D*(青铜|生铁|软铁|绿石|流花石|软银|金铁|玄铁|万年神铁|万年寒冰铁)制成，重\\D*的(\\D*)。$",
        "weaponUtmp"
    )
    AddTrigger("weapon", "weapon3", "^(> )*看起来(需要修理|已经使用过一段时间|马上就要坏)了。", "weaponUneed")
    AddTrigger("weapon", "weapon4", "^(> )*看起来没有什么损坏。", "weaponUwell")
    weaponUcannt = weaponUcannt or {}
    tmp.uweapon = nil
    for p in pairs(weaponUsave) do
        if Bag[p] and Bag[p].kind and weaponKind[Bag[p].kind] and not weaponUcannt[p] then
            exe("l " .. Bag[p].fullid)
        end
    end
    exe("alias action checkUweapon")
end
function weaponUtmp()
    if weaponUsave[matches[5]] and Bag[matches[5]] then
        tmp.uweapon = matches[5]
    end
end
function weaponUneed()
    if tmp.uweapon and weaponUsave[tmp.uweapon] then
        weaponUsave[tmp.uweapon] = "repair"
    end
end
function weaponUwell()
    if tmp.uweapon and weaponUsave[tmp.uweapon] then
        weaponUsave[tmp.uweapon] = true
    end
end
function weaponUdone()
    KillTriggerGroup("weapon")
    for p in pairs(weaponUsave) do
        if weaponUsave[p] and type(weaponUsave[p]) == "string" and weaponUsave[p] == "repair" then
            dis_all()
            return weaponRepair(p)
        end
    end
    return check_bei(weaponRepairOver)
end
function weaponRepair(p_weapon)
    tmp.uweapon = p_weapon
    if not Bag["铁锤"] then
        cntr1 = countR(3)
        return go(weaponRepairQu, "扬州城", "杂货铺")
    end
    return weaponRepairGo()
end
function weaponRepairQu()
    exe("qu tiechui;i")
    checkBags()
    return check_bei(weaponRepairQuCheck, 1)
end
function weaponRepairQuCheck()
    if cntr1() > 0 and not Bag["铁锤"] then
        return weaponRepairQu()
    end
    if Bag["铁锤"] then
        return weaponRepairGo()
    else
        return weaponRepairFind()
    end
end
-- ---------------------------------------------------------------
-- 从采矿师傅 那里找铁锤
-- ---------------------------------------------------------------

function Weapon.GetTiechui()
    weaponRepairFind()
end

function weaponRepairFind()
    DeleteTriggerGroup("weaponFind")
    cntr1 = countR(20)
    job.name = "买铁锤"
    return go(weaponRepairFact, "扬州城", "打铁铺")
end
function weaponRepairFact()
    DeleteTriggerGroup("weaponFind")
    AddTrigger("weaponFind", "weaponFind1", "^(> )*\\s*采矿师傅\\(Caikuang shifu\\)", "weaponRepairFollow")
    AddTrigger("weaponFind", "weaponFind2", "^(> )*这里没有 caikuang shifu", "weaponRepairGoon")
    AddTrigger("weaponFind", "weaponFind3", "^(> )*你决定跟随\\D*一起行动。", "weaponRepairBuy")
    AddTrigger("weaponFind", "weaponFind4", "^(> )*你已经这样做了。", "weaponRepairBuy")
    exe("look")
    return find()
end
function weaponRepairFollow()
    flag.find = 1
    exe("follow caikuang shifu")
end
function weaponRepairGoon()
    flag.wait = 0
    flag.find = 0
    return walk_wait()
end
function weaponRepairBuy()
    DeleteTriggerGroup("weaponFind")
    exe("buy tie chui")
    locate()
    checkBags()
    return checkWait(weaponRepairItem, 0.5)
end
function weaponRepairItem()
    if cntr1() > 0 and not Bag["铁锤"] then
        return weaponRepairBuy()
    end
    if not Bag["铁锤"] then
        return weaponRepairGoCun()
    end
    return weaponRepairGo()
end
function weaponRepairGo()
    return go(weaponRepairDo, "扬州城", "兵器铺")
end

function weaponRepairDo()
    DeleteTriggerGroup("repair")
    AddTrigger("repair", "repair1", "^(> )*你开始仔细的维修(\\D*)，不时用铁锤敲敲打打", "")
    AddTrigger("repair", "repair2", "^(> )*你仔细的维修(\\D*)，总算大致恢复了它的原貌。$", "weaponRepairGoCun")
    AddTrigger("repair", "repair3", "^(> )*这件兵器完好无损，无需修理。$", "weaponRepairGoCun")
    AddTrigger("repair", "repair4", "^(> )*对于这种武器，您了解不多，无法修理！$", "weaponRepairCannt")
    AddTrigger("repair", "repair5", "^(> )*你带的零钱不够了！你需要", "weaponRepairGold")
    AddTrigger("repair", "repair6", "^(> )*你的精神状态不佳$", "weaponRepairCannt")
    Weapon.unwield()
    exe("wield tie chui")
    exe("repair " .. Bag[tmp.uweapon].fullid)
    AddTimer("repair", 150, "weaponRepairGoCun")
end

function weaponRepairCannt()
    weaponUcannt = weaponUcannt or {}
    return weaponRepairGoCun()
end

function weaponRepairGold()
    KillTriggerGroup("repair")
    KillTimer("repair")
    exe("n;w;w;w;n;n;n;w;qu 50 gold;e;s;s;s;e;e;e;s")
    return checkWait(weaponRepairDo, 2)
end

function weaponRepairOver()
    DeleteTriggerGroup("weapon")
    KillTriggerGroup("repair")
    DeleteTimer("repair")
    return armorUcheck()
end

function weaponRepairGoCun()
    KillTriggerGroup("repair")
    DeleteTimer("repair")
    cntr2 = countR(3)
    exe("unwield tie chui")
    return go(weaponRepairCun, "扬州城", "杂货铺")
end

function weaponRepairCun()
    if not Bag["铁锤"] then
        return check_heal()
    end
    if cntr2() > 0 and Bag["铁锤"] then
        Weapon.unwield()
        exe("cun tie chui;i")
        checkBags()
        return check_halt(weaponRepairCun, 1)
    end
    return weaponRepairOver()
end

function weaponGetSwj()
    return go(swjAsk, "武当山", "后山小院")
end

function swjAsk()
    if location.room ~= "后山小院" or not location.id["张三丰"] then
        return weaponGetSwj()
    end
    exe("ask zhang sanfeng about 下山")
    tempTimer(
        3,
        function()
            exe("ask zhang sanfeng about 教诲")
            checkBags()
            return check_bei(swjOver)
        end
    )
end

function armorUdone()
    for p in pairs(weaponUsave) do
        if weaponUsave[p] and type(weaponUsave[p]) == "string" and weaponUsave[p] == "repair" then
            dis_all()
            return armorRepair(p)
        end
    end
    return check_bei(armorRepairOver)
end
function armorUtmp()
    if weaponUsave[matches[4]] and Bag[matches[4]] then
        tmp.uarmor = matches[4]
    end
end
function armorUwell()
    if tmp.uarmor and weaponUsave[tmp.uarmor] then
        weaponUsave[tmp.uarmor] = true
    end
end
function armorUcheck()
    DeleteTriggerGroup("armor")
    AddTrigger("armor", "armor1", '^(> )*你把 "action" 设定为 "checkUarmor" 成功完成。', "armorUdone")
    AddTrigger("armor", "armor2", "^(> )*这是由\\D*(棉花|亚麻|大麻|苎麻|蚕丝|木棉花|玉蚕丝|冰蚕丝|天蚕丝|龙茧蚕丝)制成，重\\D*的(\\D*)。$", "armorUtmp")
    AddTrigger("armor", "armor3", "^(> )*看起来(需要修理|已经使用过一段时间|马上就要坏)了。", "armorUneed")
    AddTrigger("armor", "armor4", "^(> )*看起来没有什么损坏。", "armorUwell")
    armorUcannt = armorUcannt or {}
    tmp.uarmor = nil
    for p in pairs(weaponUsave) do
        if Bag[p] and Bag[p].kind and armorKind[Bag[p].kind] and not armorUcannt[p] then
            exe("l " .. Bag[p].fullid)
        end
    end
    exe("alias action checkUarmor")
end
function armorUneed()
    if tmp.uarmor and weaponUsave[tmp.uarmor] then
        weaponUsave[tmp.uarmor] = "repair"
    end
end

function armorRepairGold()
    KillTriggerGroup("repair")
    KillTimer("repair")
    exe("e;s;s;s;w;qu 50 gold;e;n;n;n;w")
    return checkWait(armorRepairDo, 2)
end

function armorRepairDo()
    DeleteTriggerGroup("repair")
    AddTrigger("repair", "repair1", "^(> )*你开始仔细的修补(\\D*)，不时用剪刀来回裁剪缝纫着", "")
    AddTrigger("repair", "repair2", "^(> )*你仔细的修补(\\D*)，总算大致恢复了它的原貌。$", "armorRepairGoCun")
    AddTrigger("repair", "repair3", "^(> )*这件防具完好无损，无需修补。$", "armorRepairGoCun")
    AddTrigger("repair", "repair4", "^(> )*对于这种防具，您了解不多，无法修补！$", "armorRepairCannt")
    AddTrigger("repair", "repair5", "^(> )*你带的零钱不够了！你需要", "armorRepairGold")
    AddTrigger("repair", "repair6", "^(> )*你现在精神状态不佳，还是等会再修补吧。$", "armorRepairCannt")
    exe("unwield sanqing sword;unwield xuanyuan axe;unwield xuanyuan axe;unwield fengyun whip;unwield qiankun sword")
    exe("wield jian dao")
    exe("repair " .. Bag[tmp.uarmor].fullid)
    AddTimer("repair", 150, "armorRepairGoCun")
end
function armorRepairQu()
    exe("qu jian dao")
    checkBags()
    return check_bei(armorRepairQuCheck, 1)
end
function armorRepairQuCheck()
    if cntr1() > 0 and not Bag["剪刀"] then
        return armorRepairQu()
    end
    if Bag["剪刀"] then
        return armorRepairGo()
    else
        return armorRepairFind()
    end
end
function armorRepairFollow()
    flag.find = 1
    exe("follow yangcan popo")
end
function armorRepairFind()
    DeleteTriggerGroup("armorFind")
    cntr1 = countR(20)
    job.name = "买剪刀"
    return go(armorRepairFact, "changan/northjie2")
end
function armorRepairFact()
    DeleteTriggerGroup("armorFind")
    AddTrigger("armorFind", "armorFind1", "^(> )*\\s*养蚕婆婆\\(Yangcan popo\\)", "armorRepairFollow")
    AddTrigger("armorFind", "armorFind2", "^(> )*这里没有 yangcan popo", "armorRepairGoon")
    AddTrigger("armorFind", "armorFind3", "^(> )*你决定跟随\\D*一起行动。", "armorRepairBuy")
    AddTrigger("armorFind", "armorFind4", "^(> )*你已经这样做了。", "armorRepairBuy")
    exe("look")
    return find()
end
function armorRepairBuy()
    DeleteTriggerGroup("armorFind")
    exe("buy jian dao")
    locate()
    checkBags()
    return checkWait(armorRepairItem, 0.5)
end
function armorRepairItem()
    if cntr1() > 0 and not Bag["剪刀"] then
        return armorRepairBuy()
    end
    if not Bag["剪刀"] then
        return armorRepairGoCun()
    end
    return armorRepairGo()
end
function armorRepairGo()
    return go(armorRepairDo, "长安城", "裁缝铺")
end
function armorRepairGoon()
    flag.wait = 0
    flag.find = 0
    return walk_wait()
end
function armorRepair(p_armor)
    tmp.uarmor = p_armor
    if not Bag["剪刀"] then
        cntr1 = countR(3)
        return go(armorRepairQu, "扬州城", "杂货铺")
    end
    return armorRepairGo()
end
function armorRepairCannt()
    armorUcannt = armorUcannt or {}
    return armorRepairGoCun()
end
function armorRepairGoCun()
    KillTriggerGroup("repair")
    KillTimer("repair")
    cntr2 = countR(3)
    exe("unwield jian dao")
    return go(armorRepairCun, "扬州城", "杂货铺")
end
function armorRepairCun()
    exe("unwield jian dao")
    if not Bag["剪刀"] then
        return check_heal()
    end
    if cntr2() > 0 and Bag["剪刀"] then
        exe("cun jian dao;i")
        checkBags()
        return check_halt(armorRepairCun, 1)
    end
    return armorRepairOver()
end

function armorRepairOver()
    DeleteTriggerGroup("armor")
    KillTriggerGroup("repair")
    DeleteTimer("repair")
    return check_halt(job.Switch)
end

function checkHammer()
    return go(checkHmGive, "扬州城", "兵器铺")
end

function checkWeapon(p_weapon)
    tmp.cnt = 0
    tmp.weapon = p_weapon
    return go(checkWeaponBuy, weaponStore[p_weapon], "")
end
function checkWeaponBuy()
    tmp.cnt = tmp.cnt + 1
    if tmp.cnt > 10 then
        checkBags()
        return check_heal()
    else
        if tmp.weapon and weaponStoreId[tmp.weapon] then
            exe("list;buy " .. weaponStoreId[tmp.weapon])
            checkBags()
            return checkWait(checkWeaponI, 3)
        else
            return check_heal()
        end
    end
end
function checkWeaponI()
    if not Bag[tmp.weapon] then
        return checkWeaponBuy()
    else
        return checkWeaponOver()
    end
end
function checkWeaponOver()
    return checkPrepare()
end