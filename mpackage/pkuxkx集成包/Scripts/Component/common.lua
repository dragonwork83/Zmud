--
-- common.lua
--
-- ----------------------------------------------------------
-- common functions
-- 通用function
-- ----------------------------------------------------------
--
--[[
--]]
-- ---------------------------------------------------------------
-- 自定义实现, 执行单个 含#的连续命令, 如 #15n 或者 #15(drop corpse)
-- ---------------------------------------------------------------
function exec_multi(cmd)
    if string.find(cmd, "#") and not string.find(cmd, ";") then
        if string.find(cmd, "%(") then
            local tstr = ""
            local _, _, time, c = string.find(cmd, "^#(%d+)%((.+)%)$")
            if time then
                for i = 1, time do
                    tstr = tstr .. c .. ";"
                end
            end
            return tstr
        else
            local tstr = ""
            local _, _, time, c = string.find(cmd, "^#(%d+)%s*(.+)$")
            if time then
                for i = 1, time do
                    tstr = tstr .. c .. ";"
                end
            end
            return tstr
        end
    end
end
-- ---------------------------------------------------------------
-- 自定义实现, 处理原mud以及mush常用的表达方式如 ( #15n 或者 #15(drop corpse))
-- ---------------------------------------------------------------
function exec(cmd)
    local cmds_str = ""
    if string.contain(cmd, ";") then
        local cmds = string.split(cmd, ";")
        for i = 1, #cmds do
            local c = ""
            if string.contain(cmds[i], "#") then
                c = exec_multi(cmds[i])
            else
                c = cmds[i]
            end
            if string.len(c) > 0 then
                if string.sub(c, -1) == ";" then
                    cmds_str = cmds_str .. c
                else
                    cmds_str = cmds_str .. c .. ";"
                end
            end
        end
    else
        cmds_str = exec_multi(cmd)
    end
    return cmds_str
end
-- ---------------------------------------------------------------
-- 通用执行cmd的方法,
-- 参数: analyse  为bool值, 默认为true, 当为false时, 即不解析cmd里的内容, 作为单个命令发出
-- 如: exe("alias pfm jifa all;wield yinshe sword;perform sword.fenglei", false)
-- 在此情况下, 因参数analyse为false, 即不会折分该命令,而作为一条命令发出
-- ---------------------------------------------------------------
function exe(cmd, analyse)
    -- if SocketConnection.Status == false then
    --     return reconnect()
    -- end
    if cmd == nil then
        cmd = "look"
    end
    -- 判断是否解析该命令
    if analyse ~= nil and analyse == false then
        return send(cmd)
    end
    if string.contain(cmd, "#") then
        cmd = exec(cmd)
    end
    if string.contain(cmd, ";") then
        -- 启用 北侠特有的divider命令
        cmd = "|" .. string.replace(cmd, ";", ",") .. "|"
    end
    send(cmd)
end

common = {}
-- ----------------------------------------------------------
-- Common.InstanceRun(执行的函数, 间隔的时间, 执行函数的参数);
-- 会立刻执行对应的函数,并且在间隔的时间内都不会再次执行;
-- 间隔的时间不填则默认2秒;
-- 执行函数无参数则不填,
-- 我的图片示例,
-- common.InstanceRun(common.Test);
-- ----------------------------------------------------------
common.tInstanceVoid = {}
common.InstanceRun = function(pVoid, nTime, vParam)
    local strKey = tostring(pVoid)
    if strKey == nil or strKey == "" then
        return false
    end
    if common.tInstanceVoid[strKey] ~= nil then
        return false
    end
    if nTime == nil then
        nTime = 2
    end
    common.tInstanceVoid[strKey] = 1
    pVoid(vParam)
    DoAfterSpecial(nTime, 'common.InstanceReset("' .. strKey .. '")', 12)
    return true
end
common.InstanceReset = function(strKey)
    if strKey == nil or strKey == "" then
        return
    end
    common.tInstanceVoid[strKey] = nil
end

-- ---------------------------------------------------------------
-- 针对被当作参数的事件/函数的执行处理
-- ---------------------------------------------------------------
function common.eventHandle(script)
    if type(script) == "function" then
        script()
    elseif _G[script] then
        local func = _G[script]
    elseif string.find(script, ";") or string.find(script, " ") then
        exe(script)
    else
        cecho("<red:gray> common.eventHandle 事件参数异常! 参数为: " .. script)
    end
end
-- ---------------------------------------------------------------
-- Lua获取系统时间, 返回标准日期格式
-- ---------------------------------------------------------------
function common.date()
    return os.date("%Y-%m-%d", os.time())
end
-- ---------------------------------------------------------------
-- Lua获取系统时间, 返回标准时间标式
-- ---------------------------------------------------------------
function common.time(short)
    short = short or false
    if short == true then
        return os.date("%H:%M:%S", os.time())
    else
        return os.date("%Y-%m-%d %H:%M:%S", os.time())
    end
end
-- ---------------------------------------------------------------
-- 时间字符串转为时间戳
-- ---------------------------------------------------------------
function common.string2time(timeString)
    if type(timeString) ~= "string" then
        error("string2time: timeString is not a string")
        return 0
    end
    local fun = string.gmatch(timeString, "%d+")
    local y = fun() or 0
    if y == 0 then
        error("timeString is a invalid time string")
        return 0
    end
    local m = fun() or 0
    if m == 0 then
        error("timeString is a invalid time string")
        return 0
    end
    local d = fun() or 0
    if d == 0 then
        error("timeString is a invalid time string")
        return 0
    end
    local H = fun() or 0
    if H == 0 then
        error("timeString is a invalid time string")
        return 0
    end
    local M = fun() or 0
    if M == 0 then
        error("timeString is a invalid time string")
        return 0
    end
    local S = fun() or 0
    if S == 0 then
        error("timeString is a invalid time string")
        return 0
    end
    return os.time({ year = y, month = m, day = d, hour = H, min = M, sec = S })
end
-- ---------------------------------------------------------------
-- 获取两个时间的间隔
-- ---------------------------------------------------------------
function common.timediff(long_time, short_time)
    local n_short_time, n_long_time, carry, diff = os.date("*t", short_time), os.date("*t", long_time), false, {}
    local colMax = {
        60,
        60,
        24,
        os.date("*t", os.time({ year = n_short_time.year, month = n_short_time.month + 1, day = 0 })).day,
        12,
        0
    }
    n_long_time.hour = n_long_time.hour - (n_long_time.isdst and 1 or 0) + (n_short_time.isdst and 1 or 0)
    -- handle dst
    for i, v in ipairs({ "sec", "min", "hour", "day", "month", "year" }) do
        diff[v] = n_long_time[v] - n_short_time[v] + (carry and -1 or 0)
        carry = diff[v] < 0
        if carry then
            diff[v] = diff[v] + colMax[i]
        end
    end
    return diff
end
-- ---------------------------------------------------------------
-- 获取最后一次服务器重启时间, for safety, 按每周四的8点计算
-- ---------------------------------------------------------------
function common.GetLastRebootTime()
    local weektime = os.date("%w", os.time())
    local day_gap = 0
    if tonumber(weektime) > 4 then
        day_gap = weektime - 4
    elseif tonumber(weektime) == 4 and tonumber(os.date("%H", os.time())) >= 8 then
        day_gap = 0
    else
        day_gap = weektime + 3
    end
    curH = tonumber(os.date("%H", os.time()))
    curM = tonumber(os.date("%M", os.time()))
    curS = tonumber(os.date("%S", os.time()))
    reboottime = (os.time() - day_gap * 24 * 3600 - curH * 3600 - curM * 60 - curS) + 8 * 3600
    return os.date("%Y-%m-%d %H:%M:%S", reboottime)
end
-- ----------------------------------------------------------
-- 自定义实现 lua split方法
-- ----------------------------------------------------------
function string.split(s, p)
    local rt = {}
    utf8.gsub(
    s,
    "[^" .. p .. "]+",
    function(w)
        table.insert(rt, w)
    end
    )
    return rt
end
-- ---------------------------------------------------------------
-- 自定义实现 string.contain方法
-- ---------------------------------------------------------------
function string.contain(str, character)
    -- print("\n 当前命令为: "..str)
    if not str or not character or utf8.match(str, character) == nil then
        return false
    else
        return true
    end
end
-- ---------------------------------------------------------------
-- 判断是否以 某字符串开始
-- ---------------------------------------------------------------
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
-- ---------------------------------------------------------------
-- 判断是否以 某字符串结束
-- ---------------------------------------------------------------
function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end
-- ----------------------------------------------------------
-- 自定义实现 lua string.isempty
-- ----------------------------------------------------------
function string.isempty(str)
    local isem = true
    if str ~= nil and utf8.len(str) > 0 then
        str = utf8.trim(str)
        if utf8.len(str) >= 1 then
            isem = false
        else
            isem = true
        end
    end
    return isem
end
-- ---------------------------------------------------------------
-- 自定义实现 lua string.append, 用于某些情况下替代 str..str1的字符串串接
-- ---------------------------------------------------------------
function string.append(cmds, str)
    return cmds .. str
end
-- ----------------------------------------------------------
-- 自定义实现 lua string.trim  (已弃用, 在mudlet中有自定义实现的string.trim, 重名,故弃用, 可用mudlet自带的utf8.trim)
-- ----------------------------------------------------------
-- function string.trim(s)
--     return (utf8.gsub(s, "^%s*(.-)%s*$", "%1"))
-- end
-- ----------------------------------------------------------
-- 自定义实现 lua string.replace
-- ---------------------------------------------------------
function string.replace(s, reg, target)
    return (s:gsub(reg, target))
end
-- ----------------------------------------------------------
-- 自定义实现 lua table 倒序排列
-- ----------------------------------------------------------
function common.reverseTable(tab)
    local tmp = {}
    for i = 1, #tab do
        local key = #tab
        tmp[i] = table.remove(tab)
    end
    return tmp
end
-- ----------------------------------------------------------
-- 自定义实现 lua 获取talbe长度
-- ----------------------------------------------------------
function common.table_leng(t)
    if t == nil then
        return 0
    end
    local leng = 0
    for k, v in pairs(t) do
        leng = leng + 1
    end
    return leng
end
-- ----------------------------------------------------------
-- 自定义实现 lua 获取talbe长度
-- ----------------------------------------------------------
function table.len(t)
    return common.table_leng(t)
end
-- ---------------------------------------------------------------
-- 自定义实现, 判断一个值是否在某一个集合里
-- ---------------------------------------------------------------
function table.contain(table, value)
    for k, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end
-- ---------------------------------------------------------------
-- 计算 table中的集合数
-- ---------------------------------------------------------------
function countTab(tab)
    return common.table_leng(tab)
end
-- ----------------------------------------------------------
-- 自定义实现 lua 合并两个table
-- ----------------------------------------------------------
function common.MergeTables(...)
    local tabs = { ... }
    if not tabs then
        return {}
    end
    local origin = tabs[1]
    for i = 2, #tabs do
        if origin then
            if tabs[i] then
                for k, v in pairs(tabs[i]) do
                    table.insert(origin, v)
                end
            end
        else
            origin = tabs[i]
        end
    end
    return origin
end
-- ----------------------------------------------------------
-- 根据最大值和最小值获得在该范围内的值,
-- return value
-- ----------------------------------------------------------
function common.GetValueByRange(num, min, max)
    if num > max then
        num = max
    end
    if num < min then
        num = min
    end
    return num
end
-- ---------------------------------------------------------------
-- 随机获取table数组表中的一条集合, 不适用于key/value集合
-- ---------------------------------------------------------------
function common.RandomValueInTable(Table)
    return Table[math.random(#Table)]
end
-- ---------------------------------------------------------------
-- 通用 debug
-- ---------------------------------------------------------------
function common.debug(msg, DebugLevel)
    DebugLevel = DebugLevel or 2
	if DebugLevel and type(DebugLevel) == "string" then
		DebugLevel = 2
    end
    if GetRoleConfig("DebugLevel") and GetRoleConfig("DebugLevel") >= DebugLevel then
        cecho("<white:MidnightBlue>\n[Debug]: " .. msg .. "\n")
    end
end
-- ---------------------------------------------------------------
-- 通用日志记录
-- ---------------------------------------------------------------
function common.log(msg)
    cecho("<green:black>\n[消息]: " .. msg .. "\n")
end
-- ---------------------------------------------------------------
-- 通用警告
-- ---------------------------------------------------------------
function common.warning(msg)
    cecho("<purple:gray>\n[警告]: " .. msg .. "\n")
end
-- ---------------------------------------------------------------
-- 通过错误记录
-- ---------------------------------------------------------------
function common.error(msg)
    cecho("<red:gray>\n[错误]: " .. msg .. "\n")
end
-- ---------------------------------------------------------------
-- 声音通告, 用于验证码,或晕倒,死亡之类
-- ---------------------------------------------------------------
function common.soundwarning()
    playSoundFile(SJConfig.Directory .. [[/warning_tone.mp3]])
end
-- ---------------------------------------------------------------
-- 随机获取table数组表中的一条集合, 不适用于key/value集合
-- ---------------------------------------------------------------
function chats_locate(info, color)
    -- 原 Mush 输出到聊天频道, 用于输出定位
    common.debug(info, 3)
end
-- ---------------------------------------------------------------
-- 检查是否存在该临时触发器
-- ---------------------------------------------------------------
function existTrigger(group, name)
    local IsExist = false
    if TempTriggerList[group] then
        for k, v in pairs(TempTriggerList[group]) do
            if k == name then
                IsExist = true
            end
        end
    end
    return IsExist
end
-- ---------------------------------------------------------------
-- 开启/关闭临时触发器 - 需要组名
-- ---------------------------------------------------------------
function EnableTrigger(group, name, IsOpen)
    if IsOpen == nil then
        IsOpen = true
    end
    if TempTriggerList[group] then
        for k, v in pairs(TempTriggerList[group]) do
            if k == name then
                if IsOpen == true then
                    enableTrigger(v)
                else
                    disableTrigger(v)
                end
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 关闭临时触发器 - 需要组名
-- ---------------------------------------------------------------
function DisableTrigger(group, name)
    if TempTriggerList[group] then
        for k, v in pairs(TempTriggerList[group]) do
            if k == name then
                disableTrigger(v)
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 为兼容Mush的开启和关闭临时触发器的通用方法
-- ---------------------------------------------------------------
function EnableTriggerGroup(group, IsOpen)
    if TempTriggerList[group] then
        for k, v in pairs(TempTriggerList[group]) do
            if IsOpen == true then
                enableTrigger(v)
            else
                disableTrigger(v)
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 关闭临时触发器的通用方法
-- ---------------------------------------------------------------
function DisableTriggerGroup(group)
    EnableTriggerGroup(group, false)
end
-- ---------------------------------------------------------------
-- 描述: 自定义KillTriggerGroup函数, 用于删除mudlet的tempTrigger or tempRegexTrigger 的整个group
-- ---------------------------------------------------------------
function KillTriggerGroup(group)
    if TempTriggerList[group] then
        for k, v in pairs(TempTriggerList[group]) do
            disableTrigger(v)
            killTrigger(v)
        end
        TempTriggerList[group] = nil
    end
end
-- ---------------------------------------------------------------
-- 继承自 KillTriggerGroup(group), 为兼容原mush写法
-- ---------------------------------------------------------------
function DeleteTriggerGroup(group)
    KillTriggerGroup(group)
end
-- ---------------------------------------------------------------
-- 描述: 自定义KillTrigger函数, 用于删除mudlet的tempTrigger or tempRegexTrigger
-- ---------------------------------------------------------------
function KillTrigger(group, name)
    if TempTriggerList[group] then
        local i = 0
        for k, v in pairs(TempTriggerList[group]) do
            i = i + 1
            -- echo("\n k : " .. k .. " , v : " .. v)
            if k == name then
                disableTrigger(v)
                killTrigger(v)
                -- echo("\n killTrigger : " .. v)
                TempTriggerList[group][k] = nil
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 继承自 KillTrigger(group,name), 为兼容原mush写法
-- ---------------------------------------------------------------
function DeleteTrigger(group, name)
    KillTrigger(group, name)
end
-- ---------------------------------------------------------------
-- 删除所有临时触发器
-- ---------------------------------------------------------------
function KillAllTemporaryTrigger()
    for k, v in pairs(TempTriggerList) do
        KillTriggerGroup(tostring(k))
    end
end
-- ---------------------------------------------------------------
-- 禁用所有临时触发器
-- ---------------------------------------------------------------
function DisableAllTemporaryTrigger()
    for k, v in pairs(TempTriggerList) do
        EnableTriggerGroup(tostring(k), false)
    end
end
-- ---------------------------------------------------------------
-- 判断一个触发器是否是被激活,或者处于非激活状态
-- ---------------------------------------------------------------
function IsActive(group, name)
    if TempTriggerList[group] then
        local i = 0
        for k, v in pairs(TempTriggerList[group]) do
            i = i + 1
            if k == name then
                if IsActive(v, "trigger") == 1 then
                    return true
                else
                    return false
                end
            end
        end
    end
    SJConfig.DebugShow("触发器 group: " .. group .. " | name: " .. name .. " 不存在或已删除!")
end
-- ------------------------------------
-- 描述: 自定义AddTrigger函数
-- ------------------------------------
function AddTrigger(group, name, match, script)
    if script == nil then
        SJConfig.DebugShow(
        "\nAddTrigger错误! 错误原因: script为nil! (Ex) group:" .. group .. " name:" .. name .. " match:" .. match
        )
    end
    local temptriggerID = nil
    if existTrigger(group, name) then
        KillTrigger(group, name)
    end
    if not TempTriggerList[group] then
        TempTriggerList[group] = {}
    end
    if type(script) == "function" or string.contain(script, "%(") or string.contain(script, "function") then
        temptriggerID = tempRegexTrigger(match, script)
    elseif string.find(script, ";") or string.find(script, " ") then
        temptriggerID = tempRegexTrigger(match, [[exe("]] .. script .. [[")]])
    else
        temptriggerID = tempRegexTrigger(match, script .. [[()]])
    end
    TempTriggerList[group][name] = temptriggerID
    return temptriggerID
end
-- ---------------------------------------------------------------
-- 检查是否存在该临时Timer
-- ---------------------------------------------------------------
function existTimer(name)
    local IsExist = false
    if TempTimerList then
        for k, v in pairs(TempTimerList) do
            if k == name then
                IsExist = true
            end
        end
    end
    return IsExist
end
-- ---------------------------------------------------------------
-- 开启/关闭临时Timer
-- ---------------------------------------------------------------
function EnableTimer(name, IsOpen)
    if IsOpen == nil then
        IsOpen = true
    end
    for k, v in pairs(TempTimerList) do
        if k == name then
            if IsOpen == true then
                enableTimer(v)
            else
                disableTimer(v)
            end
        end
    end
end
-- ---------------------------------------------------------------
-- 关闭临时Timer
-- ---------------------------------------------------------------
function DisableTimer(name)
    for k, v in pairs(TempTimerList) do
        if k == name then
            disableTimer(v)
        end
    end
end
-- ---------------------------------------------------------------
-- 删除临时Timer, 并删除在临时集合(TempTimerList)中的记录
-- ---------------------------------------------------------------
function KillTimer(name)
    for k, v in pairs(TempTimerList) do
        if k == name then
            disableTimer(v)
            killTimer(v)
            TempTimerList[k] = nil
        end
    end
end
-- ---------------------------------------------------------------
-- 删除所有临时Timer
-- ---------------------------------------------------------------
function KillAllTemporaryTimer()
    for k, v in pairs(TempTimerList) do
        KillTimer(tostring(k))
    end
end
-- ------------------------------------
-- 描述: 自定义AddTime函数 注意是正则表达式模式
-- ------------------------------------
function AddTimer(name, time, script)
    if existTimer(name) then
        KillTimer(name)
    end
    local temptimerID = ""
    if type(script) == "function" or string.contain(script, "%(") or string.contain(script, "function") then
        temptimerID = tempTimer(time, script, true)
    elseif string.find(script, ";") or string.find(script, " ") then
        temptimerID = tempTimer(time, [[exe("]] .. script .. [[")]], true)
    else
        temptimerID = tempTimer(time, script .. [[()]], true)
    end
    TempTimerList[name] = temptimerID
end
-- ---------------------------------------------------------------
-- 描述: 因在mudlet中无法删除permTimer, 所以重写DeleteTimer函数, 触发disableTimer功能
-- ---------------------------------------------------------------
function DeleteTimer(name)
    KillTimer(name)
    -- disableTimer(name)
end
-- ---------------------------------------------------------------
-- 判断一个Observer是否存在
-- ---------------------------------------------------------------
function ExistObserver(obname)
    return existTimer(obname)
end
-- ---------------------------------------------------------------
-- 新建一个监视器, 通过新建计时器的方式, 监视命令是否被正常执行, 通常该命令执行后续会触发方法将这个定时器关闭
-- args:
-- obname: 监视器名称
-- ticktime: 间隔时间
-- script: 需要执行的命令或函数名
-- ---------------------------------------------------------------
function NewObserver(obname, script, ticktime)
    if not ExistObserver(obname) then
        -- 检测script是否为复合命令, 如为复合命令,即含有;或 空格 的多个命令集合,则用send执行该指令集合, 若不含有;, 则为script方法名, 则执行方法
        if string.find(script, ";") or string.find(script, " ") then
            exe(script)
        else
            local fun = _G[script]
            if fun then
                fun()
            end
        end
        local ticktime = ticktime or 2
        AddTimer(obname, ticktime, script)
    end
end
-- ---------------------------------------------------------------
-- 移除监视器
-- ---------------------------------------------------------------
function RemoveObserver(obname)
    KillTimer(obname)
end
-- ---------------------------------------------------------------
-- 添加一个临时的alias
-- ---------------------------------------------------------------
function AddAlias(name, express, script)
    if existAlias(name) then
        KillAlias(name)
    end
    local tempaliasID = ""
    if type(script) == "function" or string.contain(script, "%(") or string.contain(script, "function") then
        tempaliasID = tempAlias(express, script)
    elseif string.find(script, ";") or string.find(script, " ") then
        tempaliasID = tempAlias(express, [[exe("]] .. script .. [[")]], true)
    else
        tempaliasID = tempAlias(express, script .. [[()]], true)
    end
    TempAliasList[name] = tempaliasID
end
-- ---------------------------------------------------------------
-- 判断是否存在名为name的别名
-- ---------------------------------------------------------------
function existAlias(name)
    local IsExist = false
    if TempAliasList then
        for k, v in pairs(TempAliasList) do
            if k == name then
                IsExist = true
            end
        end
    end
    return IsExist
end
-- ---------------------------------------------------------------
-- 删除一个别名Alias
-- ---------------------------------------------------------------
function KillAlias(name)
    for k, v in pairs(TempAliasList) do
        if k == name then
            killAlias(v)
            TempAliasList[k] = nil
        end
    end
end
-- ---------------------------------------------------------------
-- 删除所有临时别名
-- ---------------------------------------------------------------
function KillAllTemporaryAlias()
    for k, v in pairs(TempAliasList) do
        KillAlias(tostring(k))
    end
end
-- ---------------------------------------------------------------
-- 原MushClient使用, 现移植为兼容旧版
-- ---------------------------------------------------------------
function isNil(p_str)
    if p_str == nil then
        return true
    end
    if type(p_str) ~= "string" then
        return false
    else
        p_str = utf8.trim(p_str)
        if p_str == "" then
            return true
        else
            return false
        end
    end
end
function countR(p_number)
    local i = p_number or 10
    return function()
        i = i - 1
        return i
    end
end
function randomElement(p_set)
    local l_element

    if p_set and type(p_set) == "table" then
        local l_cnt = math.random(1, countTab(p_set))
        local l_i = 0
        for p, q in pairs(p_set) do
            l_element = q
            l_i = l_i + 1
            if l_i == l_cnt then
                return l_element
            end
        end
    else
        l_element = p_set
    end

    return l_element
end
-- ---------------------------------------------------------------
-- 获取用户配置文件设定, 现都统一为在用户配置文件中
-- ---------------------------------------------------------------
function GetRoleConfig(configname)
    for k, v in pairs(Role.settings) do
        if k == configname then
            return v
        end
    end
    return nil
end
-- ---------------------------------------------------------------
-- 获取变量值, 原Mush的内置方法, 为兼容实现
-- ---------------------------------------------------------------
function GetVariable(varname)
    return GetRoleConfig(varname)
end

-- 待用, 待检查
-- function addTrigger(packageName, triggerType, pattern, triggerName, func)
-- local package = ACS[packageName]
--
-- if not package.triggers then
-- package.triggers = {}
-- end
--
-- if package.triggers[triggerName] then
-- killTrigger(tostring(package.triggers[triggerName].trigger))
-- package.triggers[triggerName].trigger = nil
-- package.triggers[triggerName].handler = nil
-- end
--
-- package.triggers[triggerName] = {}
-- package.triggers[triggerName].handler = func
--
-- if triggerType == "exact" then
-- package.triggers[triggerName].trigger = tempExactMatchTrigger(pattern, [[
-- ACS[']] .. packageName .. [['].triggers[']] .. triggerName .. [['].handler()
-- ]])
-- end
-- end
--
-- function resetTriggers(package)
-- if not ACS[package] then return end
--
-- for _, trigger in pairs(ACS[package].triggers) do
-- killTrigger(trigger.trigger)
-- end
-- end
--
-- if ACS then resetTriggers("test") end
-- ACS = {}
-- ACS.test = {}
-- ACS.test.testFunction = function() echo("\nACS.test.testFunction() fired") end
--
-- addTrigger("test", "exact", "You have recovered balance on all limbs.", "balance trigger", function()
-- ACS.test.testFunction()
-- end)
--
-- addTrigger("test", "exact", "You have recovered balance on all limbs.", "balance trigger", function()
-- echo('repalcement trigger')
-- end)
