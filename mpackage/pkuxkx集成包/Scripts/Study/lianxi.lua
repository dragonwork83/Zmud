--
-- lianxi.lua
--
-- ----------------------------------------------------------
-- 含 练习 所有function 集合 (不含literate)
-- ----------------------------------------------------------
--
-- 基本练习次数
local lianxitime_max = 5

function lianxi()
    if GetRoleConfig("PracticeCMD") ~= nil then
        local pracmd = GetRoleConfig("PracticeCMD")
        if type(pracmd) == "table" then
            exe(common.RandomValueInTable(pracmd))
        else
            if string.len(pracmd) > 0 then
                exe(GetRoleConfig("PracticeCMD"))
            end
        end
    else
        intelligent_lianxi(5)
    end
end

function intelligent_lianxi(times, xskill)
    local weapontype
    flag.lianxi = 1
    local lianxi_times = lianxitime_max
    if times ~= nil then
        lianxi_times = times
    end
    tmp.xskill = xskill
    if perform.force then
        if not skills[perform.force] then
            perform.force = nil
        end
    end
    if not perform.force then
        tmp.lvl = 0
        for p in pairs(skills) do
            q = skillEnable[p]
            if q == "force" then
                if skills[p].lvl > tmp.lvl then
                    tmp.lvl = skills[p].lvl
                    perform.force = p
                end
            end
        end
    end
    if flag.lianxi == 1 then
        for p in pairs(skills) do
            q = skillEnable[p]
            if
                (not tmp.xskill or tmp.xskill == p) and q == "force" and hp.pot ~= nil and hp.pot > lianxi_times and
                    skills[p].full == 0 and
                    perform.force and
                    perform.force == p
             then
                lianxi_times = lianxi_times
                exe("lian " .. q .. " " .. lianxi_times)
                flag.lianxi = 0
                tmp.pskill = p
                exe("hp")
                break
            end
        end
    end
    if flag.lianxi == 1 then
        for p in pairs(skills) do
            q = skillEnable[p]
            if (not tmp.xskill or tmp.xskill == p) and q == "dodge" and skills[p].full == 0 then
                exe("bei none;jifa " .. q .. " " .. p)
                exe("lian " .. q .. " " .. lianxi_times)
                flag.lianxi = 0
                tmp.pskill = p
                break
            end
        end
    end
    if flag.lianxi == 1 then
        for p in pairs(skills) do
            q = skillEnable[p]
            if p == "yuxiao-jian" then
                weapontype = "xiao"
            else
                weapontype = q
            end
            if
                (not tmp.xskill or tmp.xskill == p) and q and p == perform.skill and skills[p].full == 0 and
                    ((weaponKind[weapontype] and weaponInBag(weapontype)) or unarmedKind[q])
             then
                exe("bei none;jifa " .. q .. " " .. p)
                Weapon.unwield()
                if weaponKind[q] then
                    exe("wield " .. q)
                    for k, v in pairs(Bag) do
                        if Bag[k].kind == weapontype then
                            exe("wield " .. Bag[k].fullid)
                        end
                    end
                end
                exe("i;lian " .. q .. " " .. lianxi_times)
                flag.lianxi = 0
                tmp.pskill = p
                break
            end
        end
    end
    if flag.lianxi == 1 then
        for p in pairs(skills) do
            q = skillEnable[p]
            if p == "yuxiao-jian" then
                weapontype = "xiao"
            else
                weapontype = q
            end
            if
                (not tmp.xskill or tmp.xskill == p) and q and q ~= "force" and skills[p].full == 0 and
                    ((weaponKind[weapontype] and weaponInBag(weapontype)) or unarmedKind[q])
             then
                exe("bei none;jifa " .. q .. " " .. p)
                Weapon.unwield()
                if weaponKind[q] then
                    exe("wield " .. q)
                    for k, v in pairs(Bag) do
                        if Bag[k].kind == weapontype then
                            exe("wield " .. Bag[k].fullid)
                        end
                    end
                end
                exe("i;lian " .. q .. " " .. lianxi_times)
                flag.lianxi = 0
                tmp.pskill = p
                break
            end
        end
    end
    beiUnarmed()
end

function beiUnarmed()
    local l_skill = beiUnarmedSkill()
    if l_skill and type(l_skill) == "string" and skillEnable[l_skill] then
        exe("bei none")
        exe("jifa " .. skillEnable[l_skill] .. " " .. l_skill)
        exe("bei " .. skillEnable[l_skill])
    end
    if skillHubei[l_skill] and skills[skillHubei[l_skill]] then
        l_skill = skillHubei[l_skill]
        exe("jifa " .. skillEnable[l_skill] .. " " .. l_skill)
        exe("bei " .. skillEnable[l_skill])
    end
end

function beiUnarmedSkill()
    local l_lvl = 0
    local l_skill
    if perform and perform.skill and skillEnable[perform.skill] and unarmedKind[skillEnable[perform.skill]] then
        -- exe('bei '.. skillEnable[perform.skill])
        return perform.skill
    end
    for p in pairs(flagFull) do
        if skills[p] and skillEnable[p] and unarmedKind[skillEnable[p]] then
            q = skillEnable[p]
            -- exe('bei none;jifa '..q..' '..p..';bei '..q)
            return p
        end
    end
    if score.party then
        if score.party == "峨嵋派" and skills["hand"] and skills["jieshou-jiushi"] then
            -- exe('bei none;jifa hand jieshou-jiushi;bei hand')
            return "jieshou-jiushi"
        end
        if score.party == "丐帮" and skills["strike"] and skills["xianglong-zhang"] then
            -- exe('bei none;jifa strike xianglong-zhang;bei strike')
            return "xianglong-zhang"
        end
    end
    for p in pairs(skills) do
        if skillEnable[p] then
            q = skillEnable[p]
            if unarmedKind[q] then
                if skills[p].lvl > l_lvl then
                    l_lvl = skills[p].lvl
                    l_skill = p
                -- exe('bei none;jifa '..q..' '..p..';bei '..q)
                end
            end
        end
    end
    return l_skill
end
