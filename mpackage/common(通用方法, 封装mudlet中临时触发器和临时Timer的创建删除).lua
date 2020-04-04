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
function exe(cmd)
    -- if SocketConnection.Status == false then
    --     return reconnect()
    -- end
    if cmd == nil then
        cmd = "look"
    end
    if string.contain(cmd,";") then
        local cmds = string.split(cmd, ";")
        for i = 1, #cmds do
            send(cmds[i])
        end
    else
        send(cmd)
    end
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
-- Lua获取系统时间, 返回标准日期格式
-- ---------------------------------------------------------------

function common.date()
    return os.date("%Y-%m-%d", os.time())
end

-- ---------------------------------------------------------------
-- Lua获取系统时间, 返回标准时间标式
-- ---------------------------------------------------------------

function common.time()
    return os.date("%Y-%m-%d %H:%M:%S", os.time())
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
    return os.time({year = y, month = m, day = d, hour = H, min = M, sec = S})
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
        os.date("*t", os.time({year = n_short_time.year, month = n_short_time.month + 1, day = 0})).day,
        12,
        0
    }
    n_long_time.hour = n_long_time.hour - (n_long_time.isdst and 1 or 0) + (n_short_time.isdst and 1 or 0)
    -- handle dst
    for i, v in ipairs({"sec", "min", "hour", "day", "month", "year"}) do
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
    string.gsub(
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
    if utf8.match(str, character) == nil then
        return false
    else
        return true 
    end
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
-- 计算 table中的集合数
-- ---------------------------------------------------------------

function countTab(tab)
    return common.table_leng(tab)
end

-- ----------------------------------------------------------
-- 自定义实现 lua 合并两个table
-- ----------------------------------------------------------

function common.MergeTables(...)
    local tabs = {...}
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
-- 随机获取table数组表中的一条集合, 不适用于key/value集合
-- ---------------------------------------------------------------

function chats_locate(info, color)
    -- 原 Mush 输出到聊天频道, 用于输出定位
end



TempTriggerList = {}
TempTimerList = {}

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
-- 描述: 自定义KillTriggerGroup函数, 用于删除mudlet的tempTrigger or tempRegexTrigger 的整个group
-- ---------------------------------------------------------------
function KillTriggerGroup(group)
    if TempTriggerList[group] then
        for k, v in pairs(TempTriggerList[group]) do
            killTrigger(v)
        end
        table.remove(TempTriggerList[group])
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
                killTrigger(v)
                -- echo("\n killTrigger : " .. v)
                TempTriggerList[group][k] = nil
            end
        end
    end
end

-- ------------------------------------
-- 描述: 自定义AddTrigger函数
-- ------------------------------------
function AddTrigger(group, name, match, script)
    local temptriggerID = nil
    if existTrigger(group, name) then
        KillTrigger(group, name)
    end
    if not TempTriggerList[group] then
        TempTriggerList[group] = {}
    end
    temptriggerID = tempRegexTrigger(match, script .. [[()]])
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
-- 删除临时Timer, 并删除在临时集合(TempTimerList)中的记录
-- ---------------------------------------------------------------
function KillTimer(name)
    for k, v in pairs(TempTimerList) do
        if k == name then
            killTimer(v)
            TempTimerList[k] = nil
        end
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
    if string.contain(script, "send%(") or string.contain(script, "exe%(") or string.contain(script, "function") then
        temptimerID = tempTimer(time,script,true)
        -- permTimer(name, "书剑永恒", time, script)
    elseif not string.contain(script,"%[%[") then
        temptimerID = tempTimer(time, script..[[()]], true)
    else
        temptimerID = tempTimer(time, script, true)
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

function NewObserver(obname,ticktime,script)
    if not ExistObserver(obname) then
        -- 检测script是否为复合命令, 如为复合命令,即含有;的多个命令集合,则用send执行该指令集合, 若不含有;, 则为script方法名, 则执行方法
        if string.find(script, ";") then
            exe(script)
        else
            local fun =_G[script];
            if fun then
                fun()
            end
        end
        local ticktime = ticktime or 1
        AddTimer(obname, ticktime, script)
    end
end

-- ---------------------------------------------------------------
-- 新建一个监视器, 通过新建计时器的方式, 监视命令是否被正常执行, 通常该命令执行后续会触发方法将这个定时器关闭
-- args:
-- obname: 监视器名称
-- ticktime: 间隔时间
-- func: 需要执行的方法
-- ---------------------------------------------------------------

-- function NewObserverByFunc(obname, func, ticktime)
--     if not ExistObserver(obname) then
--         _G[func]()
--         local ticktime = ticktime or 2
--         create_timer_s(obname, ticktime, func)
--     end
-- end

-- ---------------------------------------------------------------
-- 移除监视器
-- ---------------------------------------------------------------

function RemoveObserver(obname)
    KillTimer(obname)
end

