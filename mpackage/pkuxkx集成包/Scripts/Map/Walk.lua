-- ---------------------------------------------------------------
-- 该类主要单纯负责行走的部分
-- 用于独立出 普通行走, 和搜索行走中共用的walk行走的部分,以便共用
-- ---------------------------------------------------------------
pkuxkx = pkuxkx or {}
pkuxkx.gps = pkuxkx.gps or {}
pkuxkx.gps.walk = pkuxkx.gps.walk or {}
-- 行走路径path集合, 其中为diection的集合
pkuxkx.gps.walk.Path = pkuxkx.gps.walk.Path or {}
-- 当前行走至路径的第几步
pkuxkx.gps.walk.Step = pkuxkx.gps.walk.Step or 1
-- 是否允许行走(用于紧急停止行走等)
pkuxkx.gps.walk.allow = pkuxkx.gps.walk.allow or true
-- 行走错误时的重试次数
pkuxkx.gps.walk.errortimes = pkuxkx.gps.walk.errortimes or 0
-- 到达目的地后的执行事件
pkuxkx.gps.walk.arrivedEvent = pkuxkx.gps.walk.arrivedEvent or nil
-- 行走失败/错乱后, 执行的事件
pkuxkx.gps.walk.failEvent = pkuxkx.gps.walk.failEvent or nil
-- 行走失败/错乱后, 计数
pkuxkx.gps.walk.failtimes = pkuxkx.gps.walk.failtimes or 0

-- ---------------------------------------------------------------
-- 一段新行走的初始化
-- ---------------------------------------------------------------
function pkuxkx.gps.walk.Init(path, arrivedEvent, failEvent)
    pkuxkx.gps.walk.Path = path
    pkuxkx.gps.walk.Step = 1
    pkuxkx.gps.walk.allow = true
    pkuxkx.gps.walk.errortimes = 0
    pkuxkx.gps.walk.routecache = {}
    pkuxkx.gps.walk.passedrooms = {}
    pkuxkx.gps.walk.failtimes = 0
    pkuxkx.gps.walk.arrivedEvent = arrivedEvent
    pkuxkx.gps.walk.failEvent = failEvent
    enableTrigger("单步行走")
end
-- ---------------------------------------------------------------
-- 一段路径行走的具体执行
-- ---------------------------------------------------------------
function pkuxkx.gps.walk.Execute()
    if table.len(pkuxkx.gps.walk.Path) == 0 then
        return common.error("pkuxkx.gps.walk.Execute 执行时的Path异常, 为空或长度为0!")
    end
    if pkuxkx.gps.walk.allow == false then
        -- 紧急停止则不再继续行走
        common.debug(" -紧急停止则不再继续行走- ", 3)
        return
    end

    if pkuxkx.gps.walk.Step > 1 or (pkuxkx.gps.walk.Step == 1 and table.len(pkuxkx.gps.walk.routecache) > 0) then
        -- 非第一次的后续/继续行走(即执行了第一阶段的行走指令,但还未计算已行走的步数,所以在此情况下pkuxkx.gps.walk.Step还为原值,以下进行定位赋值)
        -- 定位当前走到第几步
        -- pkuxkx.gps.walk.passedrooms 上阶段已经走的
        -- pkuxkx.gps.walk.routecache 上阶段应该要走的
        if pkuxkx.gps.walk.passedrooms == nil or table.len(pkuxkx.gps.walk.passedrooms) == 0 then
            -- 说明还未接收到服务器的response, 或被未知原因block, 重新再走
            -- 继续常规走法, 往下即可
            pkuxkx.gps.walk.errortimes = pkuxkx.gps.walk.errortimes + 1
            -- 0.5秒后重新检查是否服务器已经回应
            if pkuxkx.gps.walk.errortimes > 20 then
                common.error("pkuxkx.gps.walk.errortimes异常: " .. pkuxkx.gps.walk.errortimes)
                return
            else
                return tempTimer(0.5, [[pkuxkx.gps.walk.Execute()]])
            end
        end

        if table.len(pkuxkx.gps.walk.passedrooms) >= table.len(pkuxkx.gps.walk.routecache) then
            -- 已经接收到服务器返回, 并且已经走动, 中间可能产生异常走动,或手动输入look等情况,造成房间数较多
            if pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.walk.routecache[#pkuxkx.gps.walk.routecache].room2) then
                -- 当前(最后)房间名字与路径中最后房间名字相同,则假定为已经到达理想位置
                pkuxkx.gps.walk.Step = pkuxkx.gps.walk.Step + #pkuxkx.gps.walk.routecache
            else
                common.debug("pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] : " .. pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms], 3)
                common.debug("pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.walk.routecache[#pkuxkx.gps.walk.routecache].room2) : " .. pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.walk.routecache[#pkuxkx.gps.walk.routecache].room2), 3)
                -- 说明行走中遇到异常情况
                common.warning("行走中遇到异常情况, 执行 pkuxkx.gps.walk.failEvent ")
                -- 执行失败后处理事件
                return pkuxkx.gps.walk.failHandle()
            end
        else
            -- 未走到预期位置(有可能服务器返回信息不全, 并不代表未走到预期位置)
            -- 判断最后的房间名称是否和预期房间名一致
            if pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.walk.routecache[#pkuxkx.gps.walk.routecache].room2) then
                pkuxkx.gps.walk.Step = pkuxkx.gps.walk.Step + #pkuxkx.gps.walk.routecache
            else
                pkuxkx.gps.walk.errortimes = pkuxkx.gps.walk.errortimes + 1
                -- 0.5秒后重新检查是否服务器已经回应
                if pkuxkx.gps.walk.errortimes > 20 then
                    common.warning("未走到预期位置, 执行 pkuxkx.gps.walk.failEvent")
                    -- 执行失败后处理事件
                    return pkuxkx.gps.walk.failHandle()
                else
                    return tempTimer(0.5, [[pkuxkx.gps.walk.Execute()]])
                end
            end
        end
    end

    -- 判断是否到达目的地(Ps. 因pkuxkx.gps.walk.Step的初始为1, 所以走完后会比pkuxkx.path.route的长度多1.)
    if pkuxkx.gps.walk.Step == #pkuxkx.gps.walk.Path + 1 and pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.walk.Path[#pkuxkx.gps.walk.Path].room2) then
        -- 执行到达目的地后续动作
        return pkuxkx.gps.walk.arrivedHandle()
    end

    -- ---------------------------------------------------------------
    -- 以上步骤获得了正确的pkuxkx.gps.walk.Step,
    -- 并已到达了预期的地点(如果不是第一步pkuxkx.gps.walk.Step=00), 可以进行下一步
    -- 开始进入下一步行走
    -- 1. 先判断下一步是否特殊地形行走部分
    if (pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step].special ~= nil and string.contain(pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step].special, "!")) or (pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step].go ~= nil and string.contain(pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step].go, "!")) then
        -- 设置单步特殊路径至pkuxkx.gps.walk.routecache里
        pkuxkx.gps.walk.routecache = {}
        pkuxkx.gps.walk.passedrooms = {}
        table.insert(pkuxkx.gps.walk.routecache, pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step])
        return pkuxkx.gps.specialStepHandle(pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step])
    end

    -- 2. 常规行走部分
    local singlesteplength = GetRoleConfig("WalkSteps")
    if singlesteplength == nil or singlesteplength == "" then
        -- 默认8步长
        singlesteplength = 8
    end
    local _preparedpaths = {}
    local IsSpecialStep = false
    local currentStepsNum = pkuxkx.gps.walk.Step
    while (table.len(_preparedpaths) < singlesteplength + 1) and ((currentStepsNum + table.len(_preparedpaths)) <= #pkuxkx.gps.walk.Path) and IsSpecialStep == false do
        local cmd = ""
        -- common.log("path.route index:" .. (currentStepsNum + table.len(_preparedpaths)))
        -- 先执行special, 再执行go里面的内容
        if pkuxkx.gps.walk.Path[currentStepsNum + table.len(_preparedpaths)].special ~= nil then
            cmd = cmd .. pkuxkx.gps.walk.Path[currentStepsNum + table.len(_preparedpaths)].special
        end
        if pkuxkx.gps.walk.Path[currentStepsNum + table.len(_preparedpaths)].go ~= nil then
            cmd = cmd .. pkuxkx.gps.walk.Path[currentStepsNum + table.len(_preparedpaths)].go
        end
        if string.contain(cmd, "!") then
            -- 退出循环,只执行前面一步
            IsSpecialStep = true
        else
            table.insert(_preparedpaths, pkuxkx.gps.walk.Path[currentStepsNum + table.len(_preparedpaths)])
        end
    end
    -- 重置pkuxkx.gps.walk.passedrooms, pkuxkx.gps.walk.routecache,进行下一阶段行走赋值
    pkuxkx.gps.walk.routecache = {}
    pkuxkx.gps.walk.passedrooms = {}
    if table.len(_preparedpaths) > 0 then
        -- 将得出的路径,加入到 正行走中的路径缓存
        for i = 1, #_preparedpaths do
            table.insert(pkuxkx.gps.walk.routecache, _preparedpaths[i])
        end
        -- 转换路径集合为cmd命令模式以送出
        local cmds = {}
        for i = 1, #_preparedpaths do
            if _preparedpaths[i].special ~= nil then
                table.insert(cmds, _preparedpaths[i].special)
            end
            if _preparedpaths[i].go ~= nil then
                table.insert(cmds, _preparedpaths[i].go)
            end
        end
        enableTrigger("单步行走")
        exe(table.concat(cmds, ";"))
        -- 0.5秒后检查是否到达了目标位置(也可能是路径中停下的位置), 以便 继续执行
        tempTimer(0.5, [[pkuxkx.gps.walk.Execute()]])
    end
end
-- ---------------------------------------------------------------
-- 用于特定路径走过后的检测,确定是否正确通过
-- ---------------------------------------------------------------
function pkuxkx.gps.walk.specialRecheck(direction)
    if pkuxkx.gps.current.RoomId == direction.room2 then
        -- 说明已经到达目标房间(已通过特殊路段)
        return pkuxkx.gps.walk.Execute()
    else
        -- if (pkuxkx.gps.current.RoomId == direction.room1) or (pkuxkx.gps.current.RoomName == pkuxkx.gps.GetRoomNameByID(direction.room1)) then
        pkuxkx.gps.walk.errortimes = pkuxkx.gps.walk.errortimes + 1
        if pkuxkx.gps.walk.errortimes > 30 then
            -- 位置异常, 只能使用go方法重新行走, 如果是seek的情况, 会中止seek
            -- 注意: 该情况会中止 seek
            ---- 中止seek  -------
            return pkuxkx.gps.go(pkuxkx.path.targetroom)
        else
            -- 在某些迷宫中,有可能房间号不一样,但房间名称是一样的, 所以多判断房间名称
            -- 未通过, 继续行走
            return pkuxkx.gps.specialStepHandle(direction)
        end
    end
end
-- ---------------------------------------------------------------
-- 到达目的地后事件
-- ---------------------------------------------------------------
function pkuxkx.gps.walk.arrivedHandle()
    if pkuxkx.gps.walk.arrivedEvent then
        pkuxkx.gps.walk.arrivedEvent()
    end
end
-- ---------------------------------------------------------------
-- 行走失败处理方法
-- ---------------------------------------------------------------
function pkuxkx.gps.walk.failHandle()
    pkuxkx.gps.walk.failtimes = pkuxkx.gps.walk.failtimes + 1
    if pkuxkx.gps.walk.failEvent then
        pkuxkx.gps.walk.failEvent()
    end
end