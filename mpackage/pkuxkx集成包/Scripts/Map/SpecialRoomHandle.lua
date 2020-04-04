-- ---------------------------------------------------------------
-- 本文件为一些特殊房间路径的处理及走法
-- ---------------------------------------------------------------
pkuxkx = pkuxkx or {}
pkuxkx.gps = pkuxkx.gps or {}
pkuxkx.gps.special = pkuxkx.gps.special or {}
-- 特殊路径行走暂存的cmd, 用于复杂地型或迷宫的重复行走
pkuxkx.gps.special.cmd = pkuxkx.gps.special.cmd or ""
-- 特殊路径/迷宫的出口房间名
pkuxkx.gps.special.ExitName = pkuxkx.gps.special.ExitName or ""

-- ---------------------------------------------------------------
-- 将 direction.special 和 direction.go 里的内容转化为command
-- ---------------------------------------------------------------
function pkuxkx.gps.special.convert2cmd(direction)
    local cmd = ""
    if direction.special ~= nil and direction.special:len() > 0 then
        cmd = direction.special .. ";"
    end
    if direction.go ~= nil and direction.go:len() > 0 then
        cmd = string.append(cmd, direction.go)
    end
    return cmd
end
-- ---------------------------------------------------------------
-- 有 !test 的路径处理, 通常需要后续检查是否已经通过
-- ---------------------------------------------------------------
function pkuxkx.gps.special.CheckThrough(direction)
    local cmd = pkuxkx.gps.special.convert2cmd(direction)
    local cmds = string.split(cmd, ";")
    local singlestep = ""
    local cmds_index = 1
    while cmds_index <= #cmds do
        singlestep = cmds[cmds_index]
        if string.contain(singlestep, "!") == true then
            break
        else
            exe(singlestep)
        end
        cmds_index = cmds_index + 1
    end
    -- 带 !号的特殊执行
    if cmds_index <= #cmds then
        singlestep = cmds[cmds_index]
        if string.contain(singlestep, "=") then
            -- 说明有特殊指令,执行完后进行行走检查
            singlestep = string.sub(singlestep, string.find(singlestep, "=") + 1, singlestep:len())
            singlestep = string.replace(singlestep, "&", ";")
            exe(singlestep)
        end
    end
    -- 剩余动作检查执行情况(正常情况下,不可能!test后没有后续执行动作,故不作数组超出下限的检查)
    local gothroughcmds = ""
    for i = cmds_index + 1, #cmds do
        gothroughcmds = gothroughcmds .. cmds[i] .. ";"
    end
    -- 开始尝试通过指令
    if cmds[cmds_index] == "!step" then
        tempTimer(1, function()
            pkuxkx.gps.special.CheckThroughHandle(gothroughcmds)
        end)
    else
        pkuxkx.gps.special.CheckThroughHandle(gothroughcmds)
    end
end
-- ---------------------------------------------------------------
-- 检查是否通过某个有可能被block的位置
-- ---------------------------------------------------------------
function pkuxkx.gps.special.CheckThroughHandle(gothroughcmds)
    enableTrigger("单步行走")
    if gothroughcmds then
        pkuxkx.gps.special.gothroughtcmds = gothroughcmds
        gothroughcmds = string.append(gothroughcmds, "response path 3")
        exe(gothroughcmds)
    else
        -- 判断是否已经通过该特殊地区
        if (pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] and pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.walk.Path[pkuxkx.gps.walk.Step].room2)) then
            return tempTimer(0.5, [[pkuxkx.gps.walk.Execute()]])
        end

        -- 从 cache里获取执行指令,重复执行
        gothroughcmds = pkuxkx.gps.special.gothroughtcmds
        gothroughcmds = string.append(gothroughcmds, "response path 3")
        tempTimer(0.5, function()
            exe(gothroughcmds)
        end)
    end
end
-- ---------------------------------------------------------------
-- 长时路径 处理方法, 先执行前置动作,后需等待路径到达时的触发,继续下一步
-- ---------------------------------------------------------------
function pkuxkx.gps.special.LongDistanceHandle(direction)
    enableTrigger("长时路径完成提示")
    local cmd = pkuxkx.gps.special.convert2cmd(direction)
    local cmds = string.split(cmd, ";")
    local singlestep = ""
    local cmds_index = 1
    while cmds_index <= #cmds do
        singlestep = cmds[cmds_index]
        if string.contain(singlestep, "!") == true then
            break
        else
            exe(singlestep)
        end
        cmds_index = cmds_index + 1
    end
    if cmds[cmds_index] ~= "!murong" then
        common.error("长时路径处理方法异常: " .. cmds[cmds_index])
    end
    -- 后续等待到达时的触发器触发,继续pkuxkx.gps.walk.Execute()
end
-- ---------------------------------------------------------------
-- 长时间等待到达,且到达不会有明显的提示触发,需不断尝试是否到达
-- ---------------------------------------------------------------
function pkuxkx.gps.special.WaitArrive(direction)
    local cmd = pkuxkx.gps.special.convert2cmd(direction)
    local cmds = string.split(cmd, ";")
    local singlestep = ""
    local cmds_index = 1
    while cmds_index <= #cmds do
        singlestep = cmds[cmds_index]
        if string.contain(singlestep, "!") == true then
            break
        else
            exe(singlestep)
        end
        cmds_index = cmds_index + 1
    end
    if cmds[cmds_index] ~= "!wait" then
        return common.error("等待到达路径处理方法异常: " .. cmds[cmds_index])
    end

    local arriveroomname = pkuxkx.gps.GetRoomNameByID(direction.room2)
    -- 开始长时检测是否到达
    pkuxkx.gps.special.StartWaitArrive(arriveroomname)
end
-- ---------------------------------------------------------------
-- 开始长时检测是否到达
-- ---------------------------------------------------------------
function pkuxkx.gps.special.StartWaitArrive(roomname)
    enableTrigger("单步行走")
    -- 重置 重试次数为0
    pkuxkx.gps.special.checktimes = 0
    -- 重置 pkuxkx.gps.walk.passedrooms 为空
    pkuxkx.gps.walk.passedrooms = {}
    -- 开始尝试是否到达
    pkuxkx.gps.special.CheckArriveHandle(roomname)
end
-- ---------------------------------------------------------------
-- 检测是否到达方法, 用于长时等待,且到达无任何触发提示的情况
-- ---------------------------------------------------------------
function pkuxkx.gps.special.CheckArriveHandle(roomname)
    -- 判断是否已经到达目标地区
    if table.len(pkuxkx.gps.walk.passedrooms) == 0 then
        -- 说明还未到达,继续下一个等待
        pkuxkx.gps.special.checktimes = pkuxkx.gps.special.checktimes + 1
        return tempTimer(0.5, function()
            pkuxkx.gps.special.CheckArriveHandle(roomname)
        end)
    else
        if pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] == roomname then
            -- 已到达目的地, 继续下一步行走
            pkuxkx.gps.walk.Execute()
        elseif string.contain(pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms], "船") == true or string.contain(pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms], "筏") == true or pkuxkx.gps.walk.passedrooms[#pkuxkx.gps.walk.passedrooms] == "接天桥" then
            -- 抓到上船后的位置,清除该位置,继续等待
            pkuxkx.gps.walk.passedrooms = {}
            return tempTimer(0.5, function()
                pkuxkx.gps.special.CheckArriveHandle(roomname)
            end)
        else
            -- 说明行走中遇到异常情况, 重新定位行走
            common.warning("当前位置异常,重新定位行走!")
            -- 中止行走
            pkuxkx.gps.stop()
            -- 强制重新定位,
            pkuxkx.gps.current.RoomId = 0
            -- 重新行走
            return pkuxkx.gps.go(pkuxkx.path.targetroom)
        end
    end
end
-- ---------------------------------------------------------------
-- 沙漠行走
-- ---------------------------------------------------------------
function pkuxkx.gps.special.Desert(direction)
    local cmd = pkuxkx.gps.special.convert2cmd(direction)
    local cmds = string.split(cmd, ";")
    local singlestep = ""
    local cmds_index = 1
    while cmds_index <= #cmds do
        singlestep = cmds[cmds_index]
        if string.contain(singlestep, "!") == true then
            if string.contain(singlestep, "!dw") then
                return pkuxkx.gps.special.ReLocate(direction)
            elseif string.contain(singlestep, "!drink") then
                for i = 1, 5 do
                    pkuxkx.Feed()
                end
            end
        else
            exe(singlestep)
        end
        cmds_index = cmds_index + 1
    end
    pkuxkx.gps.walk.Execute()
end
-- ---------------------------------------------------------------
-- 会busy路径处理
-- ---------------------------------------------------------------
function pkuxkx.gps.special.Busy(direction)
    local cmd = pkuxkx.gps.special.convert2cmd(direction)
    local cmds = string.split(cmd, ";")
    local singlestep = ""
    local cmds_index = 1
    while cmds_index <= #cmds do
        singlestep = cmds[cmds_index]
        if string.contain(singlestep, "!") == true then
            break
        else
            exe(singlestep)
        end
        cmds_index = cmds_index + 1
    end
    if cmds_index == #cmds then
        check_bei(function() pkuxkx.gps.walk.Execute() end)
    else
        singlestep = ""
        for i = cmds_index, #cmds do
            singlestep = singlestep .. cmds[i] .. ";"
        end
        check_bei(function()
            exe(singlestep)
            tempTimer(0.5, function()
                pkuxkx.gps.walk.Execute()
            end)
        end)
    end
end
-- ---------------------------------------------------------------
-- 需要重新定位继续行走的部分, 一般用于迷宫
-- ---------------------------------------------------------------
function pkuxkx.gps.special.ReLocate(direction)
    local cmd = pkuxkx.gps.special.convert2cmd(direction)
    cmd = string.replace(cmd, "!dw", "")
    -- 执行前置动作
    exe(cmd)
    -- 重新定位所到位置.继续行走
    -- 中止行走
    -- pkuxkx.gps.stop()
    -- -- 强制重新定位,
    -- pkuxkx.gps.current.RoomId = 0
    -- -- 重新行走
    -- pkuxkx.gps.go(pkuxkx.path.targetroom)
    pkuxkx.gps.afterLocationEvent = function()
        pkuxkx.gps.walk.specialRecheck(direction)
    end
    pkuxkx.gps.failLocationEvent = function()
        common.error("定位失败! 待完善地图以及定位失败的随机移动部分!~~~~~~~~")
    end
    pkuxkx.gps.Locate()
end
-- ---------------------------------------------------------------
-- 云海特殊走法
-- ---------------------------------------------------------------
function pkuxkx.gps.special.Yunhai(direction)
    -- 判断是 进云海 还是 出云海
    local targetroomname = pkuxkx.gps.GetRoomNameByID(pkuxkx.path.targetroom)
    if string.contain(targetroomname, "云海出口") or targetroomname == "峨嵋金顶" or targetroomname == "云台" then
        -- 说明是 进云海 方向
        pkuxkx.gps.current.RoomId = 3710
        -- 重新行走
        return pkuxkx.gps.go(pkuxkx.path.targetroom)
    else
        -- 说明是 出云海方向 ,需根据 RoomMap 判断
        -- 先检查 north方向
        pkuxkx.gps.current.RoomMap = ""
        exe("l north")
        tempTimer(0.5, function()
            pkuxkx.gps.special.Yunhai_CheckNorth()
        end)
    end
end
-- ---------------------------------------------------------------
-- 检查北边房间是否是 出云海 房间
-- ---------------------------------------------------------------
function pkuxkx.gps.special.Yunhai_CheckNorth()
    if pkuxkx.gps.current.RoomMap and pkuxkx.gps.current.RoomMap:len() > 2 then
        -- 说明已经获得地图
        if string.contain(pkuxkx.gps.current.RoomMap, "云海入口") then
            -- 说明north临近的一步就是云海入口
            exe("north")
            tempTimer(0.5, function()
                -- 准备出云海,继续最后一步
                pkuxkx.gps.special.LastStepOutYunhai()
            end)
        else
            -- 说明不在北边, 检查南边
            pkuxkx.gps.current.RoomMap = ""
            exe("l south")
            tempTimer(0.5, function()
                pkuxkx.gps.special.Yunhai_CheckSouth()
            end)
        end
    else
        -- 说明还未获得地图, 重复执行
        exe("l north")
        tempTimer(0.5, function()
            pkuxkx.gps.special.Yunhai_CheckNorth()
        end)
    end
end
-- ---------------------------------------------------------------
-- 检查南边房间是否是 出云海 房间
-- ---------------------------------------------------------------
function pkuxkx.gps.special.Yunhai_CheckSouth()
    if pkuxkx.gps.current.RoomMap and pkuxkx.gps.current.RoomMap:len() > 2 then
        -- 说明已经获得地图
        if string.contain(pkuxkx.gps.current.RoomMap, "云海入口") then
            -- 说明south临近的一步就是云海入口
            exe("south")
            tempTimer(0.5, function()
                -- 准备出云海,继续最后一步
                pkuxkx.gps.special.LastStepOutYunhai()
            end)
        else
            -- 说明不在南边, 继续往大方向(s)行走一步, 继续检查
            pkuxkx.gps.current.RoomMap = ""
            exe("south")
            tempTimer(0.5, function()
                pkuxkx.gps.special.Yunhai_CheckNorth()
            end)
        end
    else
        -- 说明还未获得地图, 重复执行
        exe("l south")
        tempTimer(0.5, function()
            pkuxkx.gps.special.Yunhai_CheckSouth()
        end)
    end
end
-- ---------------------------------------------------------------
-- 出云海(即往回走的步骤)
-- ---------------------------------------------------------------
function pkuxkx.gps.special.LastStepOutYunhai()
    -- 说明临近的一步就是云海入口, 可能在north, 或者在south
    local firstpart = string.sub(pkuxkx.gps.current.RoomMap, 0, pkuxkx.gps.current.RoomMap:len() / 2)
    local movement = ""
    if string.contain(firstpart, "云海入口") then
        movement = "north"
    else
        movement = "south"
    end
    -- common.debug("找到云海入口, 出云海了!~~~~")
    exe(movement)
    tempTimer(0.5, function()
        -- 已出云海,继续下一步
        -- 强制重新定位,
        pkuxkx.gps.current.RoomId = 3709
        -- 重新行走
        pkuxkx.gps.go(pkuxkx.path.targetroom)
    end)
end
-- ---------------------------------------------------------------
-- 杭州提督府花园迷宫走法
-- ---------------------------------------------------------------
function pkuxkx.gps.special.Huayuan(direction)
    common.warning(" -- 待完成 杭州提督府花园迷宫的走法 --")
end