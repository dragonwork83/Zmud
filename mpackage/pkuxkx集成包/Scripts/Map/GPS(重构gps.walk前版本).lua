pkuxkx = pkuxkx or {}
pkuxkx.gps = pkuxkx.gps or {}
-- gps cache, 用于保存已计算并生成过的路径, 以提高寻路效率
pkuxkx.gps.cache = pkuxkx.gps.cache or {}
-- Look后执行的事件(常用于确定当前位置,或进行复杂地型的后续行走)
pkuxkx.gps.afterLookEvent = pkuxkx.gps.afterLookEvent or nil
-- Look定位后的下一步, 如精准定位或复杂地型行走
pkuxkx.gps.nextLocationEvent = pkuxkx.gps.nextLocationEvent or nil
-- 定位结束前,要作的事(预留)
pkuxkx.gps.endLocationEvent = pkuxkx.gps.endLocationEvent or nil
-- 定位后执行的事件
pkuxkx.gps.afterLocationEvent = pkuxkx.gps.afterLocationEvent or nil
-- 自动行走抵达(到达目的地后)的后续执行事件
pkuxkx.gps.arriveEvent = pkuxkx.gps.arriveEvent or nil
-- 定位失败执行事件(预留)
pkuxkx.gps.failLocationEvent = pkuxkx.gps.failLocationEvent or nil
-- 是否紧急停止当前行走(用于行走中暂停)
pkuxkx.gps.allowwalking = true
-- 当前房间相关
pkuxkx.gps.current = pkuxkx.gps.current or {}
-- 由于 pkuxkx.gps.current系列会在每次行走前被清空重置, 故保存另一组数据
pkuxkx.gps.guess = pkuxkx.gps.guess or {}
pkuxkx.gps.guess.RoomId = nil
pkuxkx.gps.guess.RoomName = nil
-- 当前房间id
pkuxkx.gps.current.AreaId = pkuxkx.gps.current.AreaId or nil
pkuxkx.gps.current.AreaName = pkuxkx.gps.current.AreaName or nil
pkuxkx.gps.current.RoomId = pkuxkx.gps.current.RoomId or nil
pkuxkx.gps.current.RoomName = pkuxkx.gps.current.RoomName or nil
pkuxkx.gps.current.RoomDesc = pkuxkx.gps.current.RoomDesc or ""
pkuxkx.gps.current.Directions = pkuxkx.gps.current.Directions or {}
pkuxkx.gps.current.RoomMap = pkuxkx.gps.current.RoomMap or nil
pkuxkx.gps.current.Persons = pkuxkx.gps.current.Persons or {}
pkuxkx.gps.current.Board = pkuxkx.gps.current.Board or {}
pkuxkx.gps.current.WalkNode = pkuxkx.gps.current.WalkNode or nil
pkuxkx.gps.current.WalkLink = pkuxkx.gps.current.WalkLink or {}

-- ---------------------------------------------------------------
-- 快速猜测定位, 根据pkuxkx.gps.guess的相关参数
-- ---------------------------------------------------------------
function pkuxkx.gps.GuessLocate()
    -- 快速定位优化,
    -- 1.根据guess.RoomID是否与guess.RoomName匹配
    if pkuxkx.gps.guess.RoomId ~= nil and pkuxkx.gps.guess.RoomName ~= nil then
        if pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.guess.RoomId) == pkuxkx.gps.guess.RoomName then
            pkuxkx.gps.current.RoomId = pkuxkx.gps.guess.RoomId
        end
    end
    -- 2.根据guess.RoomName若是唯一值,则可推导出RoomId
    if pkuxkx.gps.current.RoomId == nil and pkuxkx.gps.guess.RoomName ~= nil then
        local roomid = MapHelp.GetRoomID_NoDisplay(pkuxkx.gps.guess.RoomName)
        if roomid then
            pkuxkx.gps.current.RoomId = roomid
        end
    end
end
-- ---------------------------------------------------------------
-- 当前位置缺失, 重新定位当前房间
-- ---------------------------------------------------------------
function pkuxkx.gps.Locate()
    pkuxkx.gps.afterLookEvent = pkuxkx.gps.getLocation
    pkuxkx.gps.Look()
end
-- ---------------------------------------------------------------
-- 当前位置缺失, 重新定位当前房间
-- ---------------------------------------------------------------
function pkuxkx.gps.dw()
    pkuxkx.gps.Locate()
end
-- ---------------------------------------------------------------
-- 根据Look到的信息, 获取当前定位
-- ---------------------------------------------------------------
function pkuxkx.gps.getLocation()
    if pkuxkx.room == nil or table.len(pkuxkx.room) == 0 then
        MapHelp.getAllRoom()
    end
    local currentroom = pkuxkx.gps.getRoomsByName(pkuxkx.gps.current.RoomName)
    if currentroom == nil or table.len(currentroom) == 0 then
        common.error("定位失败！数据库中找不到这个地方，你可能需要更新数据库。")
        if (pkuxkx.gps.failLocationEvent) then
            pkuxkx.gps.failLocationEvent()
        end
        return
    elseif table.len(currentroom) == 1 then
        -- 赋值当前房间ID
        pkuxkx.gps.current.RoomId = currentroom[1].id
        pkuxkx.gps.current.AreaId = pkuxkx.gps.current.AreaId or currentroom[1].area
        common.log("定位成功！房间ID：" .. currentroom[1].id)
        if (pkuxkx.gps.afterLocationEvent) then
            pkuxkx.gps.afterLocationEvent()
        end
    else
        pkuxkx.gps.nextLocationEvent = pkuxkx.gps.getlocationAdvance
        enableTrigger("记录房间")
        send("hit;localmaps;q;walk -c;response path 2")
    end
end
-- ---------------------------------------------------------------
-- 进一步具体定位,根据localmaps, map等
-- 用于,当一般定位找不到准确定位点的时候
-- ---------------------------------------------------------------
function pkuxkx.gps.getlocationAdvance()
    local aid
    if (pkuxkx.gps.current.AreaName == nil) then
        aid = 0
    else
        aid = MapHelp.getAreaId(pkuxkx.gps.current.AreaName)
        if (aid == nil) then
            common.error("定位失败！未知的区域名。")
            if (pkuxkx.gps.failLocationEvent ~= nil) then
                pkuxkx.gps.failLocationEvent()
            end
            return
        end
    end
    local rooms = MapHelp.getRooms(pkuxkx.gps.current.AreaName, pkuxkx.gps.current.RoomName)
    local samenameRooms = {}
    if table.len(rooms) == 1 then
        -- 若该区域的同名房间只有一个
        table.insert(samenameRooms, rooms[1])
    else
        -- 先判断 description
        local tempcollection = _getSingleRoomByDesc(rooms, pkuxkx.gps.current.RoomDesc)
        if table.len(tempcollection) == 1 then
            table.insert(samenameRooms, tempcollection[1])
        elseif table.len(tempcollection) > 1 then
            -- 再结合判断map
            tempcollection = _getSingleRoomByMap(tempcollection, pkuxkx.gps.current.RoomMap)
            if table.len(tempcollection) == 1 then
                table.insert(samenameRooms, tempcollection[1])
            end
        else
            common.warning("找不到相符合的描述Description, 当前描述为: " .. pkuxkx.gps.current.RoomDesc)
            tempcollection = _getSingleRoomByMap(rooms, pkuxkx.gps.current.RoomMap)
            if table.len(tempcollection) == 1 then
                table.insert(samenameRooms, tempcollection[1])
            end
        end
    end

    if table.len(samenameRooms) == 1 then
        pkuxkx.gps.current.RoomId = samenameRooms[1].id
        pkuxkx.gps.current.AreaId = pkuxkx.gps.current.AreaId or samenameRooms[1].area
        common.log("定位成功！房间ID：" .. pkuxkx.gps.current.RoomId)
    else
        -- 更进一步, 根据NPC名称进行定位
        if pkuxkx.NPC == nil then
            pkuxkx.GetAllNPC()
        end
        if pkuxkx.gps.current.Persons and table.len(pkuxkx.gps.current.Persons) > 0 then
            local hasGetRoomId = false
            local i = 1
            while i <= #pkuxkx.gps.current.Persons and hasGetRoomId == false do
                local npcs = {}
                local npcname = pkuxkx.gps.current.Persons[i][1]
                if pkuxkx.NPCbranch[npcname] then
                    for j = 1, #pkuxkx.NPCbranch[npcname] do
                        if pkuxkx.gps.GetRoomNameByID(pkuxkx.NPCbranch[npcname][j].room) == pkuxkx.gps.current.RoomName then
                            table.insert(npcs, pkuxkx.NPCbranch[npcname][j])
                        end
                    end
                end
                if table.len(npcs) == 1 then
                    pkuxkx.gps.current.RoomId = npcs[1].room
                    hasGetRoomId = true
                end
            end
            if hasGetRoomId == true then
                common.log("定位成功！房间ID：" .. pkuxkx.gps.current.RoomId)
            else
                common.warning("定位失败！有多个地点与这个地方描述相同，请在别的地方使用dw。")
                if (pkuxkx.gps.failLocationEvent ~= nil) then
                    pkuxkx.gps.failLocationEvent()
                end
                return
            end
        else
            common.warning("定位失败！有多个地点与这个地方描述相同，请在别的地方使用dw。")
            if (pkuxkx.gps.failLocationEvent ~= nil) then
                pkuxkx.gps.failLocationEvent()
            end
            return
        end
    end
    if (pkuxkx.gps.afterLocationEvent) then
        pkuxkx.gps.afterLocationEvent()
    end
end
-- ---------------------------------------------------------------
-- 根据房间描述RoomDesc, 来从集合中获取唯一的集合,若无则返回{}
-- ---------------------------------------------------------------
function _getSingleRoomByDesc(roomcollection, desc)
    local collection = {}
    for i = 1, #roomcollection do
        if utf8.trim(desc) == utf8.trim(roomcollection[i].description) then
            table.insert(collection, roomcollection[i])
        end
    end
    return collection
end
-- ---------------------------------------------------------------
-- 根据房间地图关系RoomMap, 来从集合中获取唯一的集合,若无则返回{}
-- ---------------------------------------------------------------
function _getSingleRoomByMap(roomcollection, map)
    local collection = {}
    for i = 1, #roomcollection do
        if utf8.trim(map) == utf8.trim(roomcollection[i].map) then
            table.insert(collection, roomcollection[i])
        end
    end
    return collection
end
-- ---------------------------------------------------------------
-- 初始化当前房间数据, 即刚到一个新房间之前进行初始化, 避免旧房间的脏数据影响新房间
-- ---------------------------------------------------------------
function pkuxkx.gps.currentInit()
    -- roomName.clear();
    -- roomDesc.clear();
    -- roomMap.clear();
    -- persons = newTable(ses->L);
    -- directions = newTable(ses->L);
    -- boards = newTable(ses->L);
    -- needRego = false;
    -- looking = true;
    pkuxkx.gps.current = {}
    pkuxkx.gps.current.RoomId = nil
    pkuxkx.gps.current.RoomName = ""
    pkuxkx.gps.current.RoomDesc = ""
    pkuxkx.gps.current.Directions = {}
    pkuxkx.gps.current.RoomMap = nil
    pkuxkx.gps.current.Persons = {}
    pkuxkx.gps.current.Board = {}
end
-- ---------------------------------------------------------------
-- Look前作的准备动作, 通常用于重新定位前使用
-- ---------------------------------------------------------------
function pkuxkx.gps.Look()
    pkuxkx.gps.currentInit()
    enableTrigger("记录房间详细描述")
    enableTrigger("look翻页")
    enableTrigger("记录小地图")
    exe("look;response path 1")
end
-- ---------------------------------------------------------------
-- 走到一个新房间(另一个房间)的处理事件
-- ---------------------------------------------------------------
function pkuxkx.gps.newroomHandle()
    pkuxkx.gps.currentInit()
end
-- ---------------------------------------------------------------
-- go 指定房间
-- ---------------------------------------------------------------
function pkuxkx.gps.goRoom(roomid)
    -- 进行快速猜测定位
    pkuxkx.gps.GuessLocate()

    -- 若当前房间号为0, 则返回重新定位
    if (pkuxkx.gps.current.RoomId == 0) then
        pkuxkx.gps.goArgs1 = roomid
        pkuxkx.gps.afterLocationEvent = pkuxkx.gps.go
        return pkuxkx.gps.Locate()
    end
    -- 若当前房间即目的地, 则执行到达后续事件
    if (roomid == pkuxkx.gps.current.RoomId) then
        common.log("已到达目的地!")
        return pkuxkx.gps.arriveHandle()
    end
    -- if (false) then
    exe("set brief 1")
    -- end
    -- 生成路径
    local pathcollection = pkuxkx.gps.GetPath(pkuxkx.gps.current.RoomId, roomid)
    if pathcollection == nil or table.len(pathcollection) == 0 then
        cecho("<green:gray>无有效路径到达目标房间: " .. roomid)
        return
    end
    -- 开启行走权限开关
    -- pkuxkx.gps.allowwalking = true
    -- -- 执行行走实际动作
    -- pkuxkx.gps.walkHandle()
    pkuxkx.gps.walk.Init(pkuxkx.path.route)
    -- 到达目的地触发事件
    pkuxkx.gps.walk.arrivedEvent = function()
        common.log("已到达目的地!")
        -- 设置pkuxkx.gps.guess.RoomID 为当前ID
        pkuxkx.gps.guess.RoomId = pkuxkx.path.targetroom
        -- 设置pkuxkx.gps.current.RoomID 为当前ID
        pkuxkx.gps.current.RoomId = pkuxkx.path.targetroom
        -- GPS 到达目的地后的事件执行
        return pkuxkx.gps.arriveHandle()
    end
    -- 行走出现异常后续处理方案
    pkuxkx.gps.walk.failEvent = function()
        -- 中止行走
        pkuxkx.gps.stop()
        -- 强制重新定位,
        pkuxkx.gps.current.RoomId = 0
        -- 重新行走
        return pkuxkx.gps.go(pkuxkx.path.targetroom)
    end
    pkuxkx.gps.walk.Execute()
end
-- ---------------------------------------------------------------
-- GPS 行走具体执行处理方法(要在生成路径后)
-- ---------------------------------------------------------------
function pkuxkx.gps.walkHandle()
    if pkuxkx.gps.allowwalking == false then
        -- 紧急停止则不再继续行走
        common.debug(" -紧急停止则不再继续行走- ", 3)
        return
    end
    local paths = pkuxkx.path.route
    if paths == nil or table.len(paths) == 0 then
        common.error("行走时路径Paths异常! 当前房间: " .. pkuxkx.gps.current.RoomId)
        return
    end

    if pkuxkx.path.step > 1 or (pkuxkx.path.step == 1 and table.len(pkuxkx.path.routecache) > 0) then
        -- 非第一次的后续/继续行走(即执行了第一阶段的行走指令,但还未计算已行走的步数,所以在此情况下pkuxkx.path.step还为原值,以下进行定位赋值)
        -- 定位当前走到第几步
        -- pkuxkx.path.passedrooms 上阶段已经走的
        -- pkuxkx.path.routecache 上阶段应该要走的
        if pkuxkx.path.passedrooms == nil or table.len(pkuxkx.path.passedrooms) == 0 then
            -- 说明还未接收到服务器的response, 或被未知原因block, 重新再走
            -- 继续常规走法, 往下即可
            pkuxkx.path.errortimes = pkuxkx.path.errortimes + 1
            -- 0.5秒后重新检查是否服务器已经回应
            if pkuxkx.path.errortimes > 20 then
                common.error("pkuxkx.path.errortimes异常: " .. pkuxkx.path.errortimes)
                return
            else
                return tempTimer(0.5, [[pkuxkx.gps.walkHandle()]])
            end
        end

        if table.len(pkuxkx.path.passedrooms) >= table.len(pkuxkx.path.routecache) then
            -- 已经接收到服务器返回, 并且已经走动, 中间可能产生异常走动,或手动输入look等情况,造成房间数较多
            if pkuxkx.path.passedrooms[#pkuxkx.path.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.path.routecache[#pkuxkx.path.routecache].room2) then
                -- 当前(最后)房间名字与路径中最后房间名字相同,则假定为已经到达理想位置
                pkuxkx.path.step = pkuxkx.path.step + #pkuxkx.path.routecache
            else
                common.debug("pkuxkx.path.passedrooms[#pkuxkx.path.passedrooms] : " .. pkuxkx.path.passedrooms[#pkuxkx.path.passedrooms], 3)
                common.debug("pkuxkx.gps.GetRoomNameByID(pkuxkx.path.routecache[#pkuxkx.path.routecache].room2) : " .. pkuxkx.gps.GetRoomNameByID(pkuxkx.path.routecache[#pkuxkx.path.routecache].room2), 3)
                -- 说明行走中遇到异常情况, 重新定位行走
                common.warning("行走中遇到异常情况, 重新定位行走!")
                -- 中止行走
                pkuxkx.gps.stop()
                -- 强制重新定位,
                pkuxkx.gps.current.RoomId = 0
                -- 重新行走
                return pkuxkx.gps.go(pkuxkx.path.targetroom)
            end
        else
            -- 未走到预期位置(有可能服务器返回信息不全, 并不代表未走到预期位置)
            -- 判断最后的房间名称是否和预期房间名一致
            if pkuxkx.path.passedrooms[#pkuxkx.path.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.path.routecache[#pkuxkx.path.routecache].room2) then
                pkuxkx.path.step = pkuxkx.path.step + #pkuxkx.path.routecache
            else
                common.warning("未走到预期位置, 重新定位行走!")
                -- 中止行走
                pkuxkx.gps.stop()
                -- 强制重新定位,
                pkuxkx.gps.current.RoomId = 0
                -- 重新行走
                return pkuxkx.gps.go(pkuxkx.path.targetroom)
            end
        end
    end

    -- 判断是否到达目的地(Ps. 因pkuxkx.path.step的初始为1, 所以走完后会比pkuxkx.path.route的长度多1.)
    if pkuxkx.path.step == #pkuxkx.path.route + 1 and pkuxkx.path.passedrooms[#pkuxkx.path.passedrooms] == pkuxkx.gps.GetRoomNameByID(pkuxkx.path.targetroom) then
        common.log("已到达目的地!")
        -- 设置pkuxkx.gps.guess.RoomID 为当前ID
        pkuxkx.gps.guess.RoomId = pkuxkx.path.targetroom
        -- 设置pkuxkx.gps.current.RoomID 为当前ID
        pkuxkx.gps.current.RoomId = pkuxkx.path.targetroom
        -- GPS 到达目的地后的事件执行
        return pkuxkx.gps.arriveHandle()
    end

    -- ---------------------------------------------------------------
    -- 以上步骤获得了正确的pkuxkx.path.step,
    -- 并已到达了预期的地点(如果不是第一步pkuxkx.path.step=00), 可以进行下一步
    -- 开始进入下一步行走
    -- 1. 先判断下一步是否特殊地形行走部分
    if pkuxkx.path.step <= #pkuxkx.path.route then
        if (pkuxkx.path.route[pkuxkx.path.step].special ~= nil and string.contain(pkuxkx.path.route[pkuxkx.path.step].special, "!")) or (pkuxkx.path.route[pkuxkx.path.step].go ~= nil and string.contain(pkuxkx.path.route[pkuxkx.path.step].go, "!")) then
            -- 设置单步特殊路径至pkuxkx.path.routecache里
            pkuxkx.path.routecache = {}
            pkuxkx.path.passedrooms = {}
            table.insert(pkuxkx.path.routecache, pkuxkx.path.route[pkuxkx.path.step])
            return pkuxkx.gps.specialStepHandle(pkuxkx.path.route[pkuxkx.path.step])
        end
    end

    -- 2. 常规行走部分
    local singlesteplength = GetRoleConfig("WalkSteps")
    if singlesteplength == nil or singlesteplength == "" then
        -- 默认10步长
        singlesteplength = 10
    end
    local _preparedpaths = {}
    local IsSpecialStep = false
    local currentStepsNum = pkuxkx.path.step
    while (table.len(_preparedpaths) < singlesteplength + 1) and ((currentStepsNum + table.len(_preparedpaths)) <= #pkuxkx.path.route) and IsSpecialStep == false do
        local cmd = ""
        -- common.log("path.route index:" .. (currentStepsNum + table.len(_preparedpaths)))
        -- 先执行special, 再执行go里面的内容
        if pkuxkx.path.route[currentStepsNum + table.len(_preparedpaths)].special ~= nil then
            cmd = cmd .. pkuxkx.path.route[currentStepsNum + table.len(_preparedpaths)].special
        end
        if pkuxkx.path.route[currentStepsNum + table.len(_preparedpaths)].go ~= nil then
            cmd = cmd .. pkuxkx.path.route[currentStepsNum + table.len(_preparedpaths)].go
        end
        if string.contain(cmd, "!") then
            -- 退出循环,只执行前面一步
            IsSpecialStep = true
        else
            table.insert(_preparedpaths, pkuxkx.path.route[currentStepsNum + table.len(_preparedpaths)])
        end
    end
    -- 重置pkuxkx.path.passedrooms, pkuxkx.path.routecache,进行下一阶段行走赋值
    pkuxkx.path.routecache = {}
    pkuxkx.path.passedrooms = {}
    if table.len(_preparedpaths) > 0 then
        -- 将得出的路径,加入到 正行走中的路径缓存
        for i = 1, #_preparedpaths do
            table.insert(pkuxkx.path.routecache, _preparedpaths[i])
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
            -- 提前一步置入 set brief 3
            if ((pkuxkx.path.step + i) == #pkuxkx.path.route) or #pkuxkx.path.route == 1 then
                table.insert(cmds, "set brief 3")
            end
        end
        enableTrigger("单步行走")
        exe(table.concat(cmds, ";"))
        -- 0.5秒后检查是否到达了目标位置(也可能是路径中停下的位置), 以便 继续执行
        tempTimer(0.5, [[pkuxkx.gps.walkHandle()]])
    end
end
-- ---------------------------------------------------------------
-- 添加已经经过的房间至 pkuxkx.path.passedrooms
-- ---------------------------------------------------------------
function pkuxkx.gps.addPassedRoom(roomname)
    if pkuxkx.gps.walk and pkuxkx.gps.walk.passedrooms ~= nil and roomname then
        table.insert(pkuxkx.gps.walk.passedrooms, roomname)
    end
end
-- ---------------------------------------------------------------
-- 特殊路径处理, 即路径中含有"!" 的处理
-- ---------------------------------------------------------------
function pkuxkx.gps.specialStepHandle(direction)
    -- display(direction)
    -- 重置脏数据
    pkuxkx.gps.special.gothroughtcmds = ""
    local cmd = ""
    if direction.special ~= nil and direction.special:len() > 0 then
        cmd = direction.special .. ";"
    end
    if direction.go ~= nil and direction.go:len() > 0 then
        cmd = string.append(cmd, direction.go)
    end
    -- 特殊路径 分类处理
    if string.contain(cmd, "!test ") then
        return pkuxkx.gps.special.CheckThrough(direction)
    elseif string.contain(cmd, "!step") then
        return pkuxkx.gps.special.CheckThrough(direction)
    elseif string.contain(cmd, "!river") then
        return expandAlias("fufeizuochuan")
    elseif string.contain(cmd, "!zuoche") then
        return expandAlias(string.replace(cmd, "!", ""))
    elseif string.contain(cmd, "!murong") then
        return pkuxkx.gps.special.LongDistanceHandle(direction)
    elseif string.contain(cmd, "!wait") then
        return pkuxkx.gps.special.WaitArrive(direction)
    elseif string.contain(cmd, "!drink") then
        return pkuxkx.gps.special.Desert(direction)
    elseif string.contain(cmd, "!rest") then
        return pkuxkx.gps.special.Busy(direction)
    elseif string.contain(cmd, "!dw") then
        return pkuxkx.gps.special.ReLocate(direction)
    elseif string.contain(cmd, "!yunhai") then
        return pkuxkx.gps.special.Yunhai(direction)
    elseif string.contain(cmd, "!huayuan") then
        return pkuxkx.gps.special.Huayuan(direction)
    elseif string.contain(cmd, "!taolin") then
        return common.warning("!taolin 还未实现!")
    elseif string.contain(cmd, "!songlin") then
        return common.warning("!songlin 还未实现!")
    end
end
-- ---------------------------------------------------------------
-- GPS 到达目的地后的事件执行
-- ---------------------------------------------------------------
function pkuxkx.gps.arriveHandle()
    if pkuxkx.gps.arriveEvent then
        common.eventHandle(pkuxkx.gps.arriveEvent)
        -- 清空pkuxkx.gps.arriveEvent
        pkuxkx.gps.arriveEvent = nil
    end
end
-- ---------------------------------------------------------------
-- 继续行走(在BUSY / 错位置 / 重定位 / !wait / !river 等情况过后的继续行走)
-- ---------------------------------------------------------------
function pkuxkx.gps.continue2Walk()
    common.warning("待实现 continue2Walk 方法! ")
end
-- ---------------------------------------------------------------
-- 中止行走
-- ---------------------------------------------------------------
function pkuxkx.gps.stop()
    disableTrigger("单步行走")
    disableTrigger("坐船")
    disableTrigger("坐车")
    pkuxkx.gps.walk.allow = false
    -- 此处不重置整个pkuxkx.path 集合, 因为有可能后续重新查找,或重新定位行走还会用到之前留存pkuxkx.path里的目标地址等
    -- 如此重置errortimes等,可提前重置
end
-- ---------------------------------------------------------------
-- 生成两点间最短路径
-- PS. 因有复杂路径的存在, 故不直接返回字符串path(如 e;s;w;n)
-- 返回格式为table格式的 path集
-- ---------------------------------------------------------------
function pkuxkx.gps.GetPath(from, to)
    -- common.log("from:"..from.." | to:"..to)
    -- table.insert(pkuxkx.openrooms,from)
    pkuxkx.path = {}
    -- 获得的路径
    pkuxkx.path.route = {}
    -- 正行走中的路径缓存(走路中动态变化)
    pkuxkx.path.routecache = {}
    -- 已经经过的房间, 用于记录走路的进度
    pkuxkx.path.passedrooms = {}
    pkuxkx.path.initialroom = from
    pkuxkx.path.targetroom = to
    -- 当前行走到第几步
    pkuxkx.path.step = 1
    -- 错误/重试次数
    pkuxkx.path.errortimes = 0
    pkuxkx.path.openrooms = {}
    pkuxkx.path.closerooms = {}
    pkuxkx.path.targetnode = {}

    -- 检查 cache 中是否存在相同路径,并获取使用
    if pkuxkx.gps.cache ~= nil and pkuxkx.gps.cache[pkuxkx.path.initialroom .. "->" .. pkuxkx.path.targetroom] ~= nil then
        pkuxkx.path.route = pkuxkx.gps.cache[pkuxkx.path.initialroom .. "->" .. pkuxkx.path.targetroom]
        return pkuxkx.path.route
    end

    -- 开始计算/获得路径path
    -- 将 起始点放入封闭表
    local node = {}
    node.id = from
    node.parent = nil
    table.insert(pkuxkx.path.openrooms, node)
    table.insert(pkuxkx.path.closerooms, node)
    -- 先尝试直达节点方案
    local nodes_route = _getNodeRouteHandle(true)
    -- 若无简单直达节点方案, 则尝试寻找复杂节点方案
    pkuxkx.path.openrooms = {}
    pkuxkx.path.closerooms = {}
    table.insert(pkuxkx.path.openrooms, node)
    table.insert(pkuxkx.path.closerooms, node)
    nodes_route = nodes_route or _getNodeRouteHandle(false)
    pkuxkx.path.route = _generatePath(nodes_route)
    return pkuxkx.path.route
end
-- ---------------------------------------------------------------
-- 特殊处理该值是否存在于table中, 因为value为一个小table,故不能用通用方法处理
-- 该方法专用于 pkuxkx.path.openrooms 和 pkuxkx.path.closerooms 格式的比较
-- value 仅为 含有parent和 id的table格式
-- ---------------------------------------------------------------
function _isInTable(table, value)
    for i = 1, #table do
        if table[i].id == value.id then
            return true
        end
    end
    return false
end
-- ---------------------------------------------------------------
-- 根据 Nodes_route 各节点间的最短路径路由, 生成/获取具体的方向,生成路径Path_table
-- PS. 因有复杂路径的存在, 故不直接返回字符串path(如 e;s;w;n)
-- 返回格式为table格式的 path集
-- ---------------------------------------------------------------
function _generatePath(nodes_route)
    if nodes_route == nil or #nodes_route == 0 then
        return nil
    end
    local path_table = {}
    nodes_route = common.reverseTable(nodes_route)
    for i = 1, #nodes_route do
        if i < #nodes_route then
            table.insert(path_table, _getSingleDirection(nodes_route[i], nodes_route[i + 1]))
        end
    end
    -- 将获得的p2p路径存入cache, 以提高复用率 (后续遍历路径一样需要存入cache)
    if path_table ~= nil and table.len(path_table) > 0 then
        local cachename = pkuxkx.path.initialroom .. "->" .. pkuxkx.path.targetroom
        pkuxkx.gps.cache = pkuxkx.gps.cache or {}
        if pkuxkx.gps.cache[cachename] == nil then
            pkuxkx.gps.cache[cachename] = path_table
        end
    end

    return path_table
end
-- ---------------------------------------------------------------
-- 计算当前路径的优先级, 值越大,说明阻力越大,优先级越小
-- ---------------------------------------------------------------
function _calculateDirectionPriority(direction)
    local priority = 0
    -- 判断特殊路径
    if direction.go ~= nil and direction.go:len() > 0 then
        if string.contain(direction.go, "!") then
            priority = priority + 1
        end
    end
    if direction.special ~= nil and direction.special:len() > 2 then
        priority = priority + 1
        if string.contain(direction.special, "!") then
            priority = priority + 2
        end
    end
    -- 判断金钱
    if direction.money ~= nil and tonumber(direction.money) > 10 then
        priority = priority + 1
        if tonumber(direction.money) > 100 then
            priority = priority + 1
        end
        if tonumber(direction.money) > 500 then
            priority = priority + 1
        end
        if tonumber(direction.money) > 1000 then
            priority = priority + 1
        end
    end
    -- 判断时间
    if direction.time ~= nil and tonumber(direction.time) > 10 then
        priority = priority + 1
        if tonumber(direction.time) > 20 then
            priority = priority + 1
        end
        if tonumber(direction.time) > 50 then
            priority = priority + 1
        end
        if tonumber(direction.time) > 100 then
            priority = priority + 1
        end
    end
    return priority
end
-- ---------------------------------------------------------------
-- 获取两个临近点之间的到达方式, 返回 direction表的 单行row实体类型
-- ---------------------------------------------------------------
function _getSingleDirection(from, to)
    local collection = pkuxkx.directionbranch[from]
    local directions = {}
    for i = 1, #collection do
        if collection[i].room1 == from and collection[i].room2 == to then
            -- 判断当前direction 是否满足条件(如金钱,武功,门派,性别等)
            -- 因有可能相同出口,有多条记录,其中一条为门派专用,另一条为special出口,可能需要杀掉guard
            -- 故需要增加此判断, 与增加节点时的判断一致, 避免造成两者结果不符
            if _Direction_IsAvailable(collection[i]) == true then
                table.insert(directions, collection[i])
                -- return collection[i]
            end
        end
    end
    if table.len(directions) == 1 then
        return directions[1]
    elseif table.len(directions) > 1 then
        -- 多条路径,选择最优路径
        -- 计算每种路径的优先级,并放入table排序,取最优
        local prioritytable = {}
        for i = 1, #directions do
            local pi = _calculateDirectionPriority(directions[i])
            local tb = { index = i, priority = pi }
            table.insert(prioritytable, tb)
        end
        table.sort(prioritytable, function(a, b) return a.priority < b.priority end)
        -- display(prioritytable)
        return directions[prioritytable[1].index]
    end
end
-- ---------------------------------------------------------------
-- 获得 各个节点间的跳转 route
-- 基于 BFS 的寻路算法.
-- args: direct (默认false), 即是否选择简单路径直达, 而不选择含有!的路径
-- ---------------------------------------------------------------
function _getNodeRouteHandle(direct)
    direct = direct or false
    local nodes_route = {}
    local pass = false
    local currentnode = nil
    local nearrooms = {}
    local node = {}
    -- local tstart = os.clock()
    while (table.len(pkuxkx.path.openrooms) > 0 and pass == false) do
        currentnode = pkuxkx.path.openrooms[1]
        table.remove(pkuxkx.path.openrooms, 1)
        -- table.insert(pkuxkx.path.closerooms,currentnode)
        nearrooms = pkuxkx.gps.GetNearRooms(currentnode.id, direct)
        for i = 1, #nearrooms do
            node = {}
            node["id"] = nearrooms[i]
            node["parent"] = currentnode.id
            if _isInTable(pkuxkx.path.openrooms, node) == false and _isInTable(pkuxkx.path.closerooms, node) == false then
                if node.id == pkuxkx.path.targetroom then
                    pass = true
                    pkuxkx.path.targetnode = node
                end
                -- 将该节点加入 开放房间名单
                table.insert(pkuxkx.path.openrooms, node)
                table.insert(pkuxkx.path.closerooms, node)
            end
        end
    end

    if pass == false then
        -- print("寻路失败, 无简单路径!")
        return nil
    else
        local node = pkuxkx.path.targetnode
        while node and node.parent do
            -- print(node.id .. " -> " .. node.parent)
            table.insert(nodes_route, node.id)
            node = _GetParentNode(node)
        end
    end
    -- 补上起始节点
    if #nodes_route > 0 then
        table.insert(nodes_route, pkuxkx.path.initialroom)
    end
    -- local tdone = os.clock()
    -- print("寻找最近节点耗时: " .. (tdone - tstart))
    return nodes_route
end

-- ---------------------------------------------------------------
-- 获取当前节点的父结点.并返回
-- ---------------------------------------------------------------
function _GetParentNode(currentnode)
    local node = nil
    if currentnode.parent == nil then
        return node
    end
    for i = 1, #pkuxkx.path.closerooms do
        if pkuxkx.path.closerooms[i].id == currentnode.parent then
            node = pkuxkx.path.closerooms[i]
        end
    end
    return node
end
-- ---------------------------------------------------------------
-- 判断该 Direction记录,是否符合条件,是否可用
-- 含 金钱判断, 耗时判断, 武功判断, 门派判断, 性别判断等
-- ---------------------------------------------------------------
function _Direction_IsAvailable(thisdirection)
    local isAvailable = true
    -- 判断 GPS模式, 是否高效耗钱模式
    local gps_mode = tonumber(GetRoleConfig("GPSMode")) or 0
    if gps_mode == 0 and thisdirection.money ~= nil and tonumber(thisdirection.money) > 1000 then
        isAvailable = false
    end
    ----------------
    -- 判断 武功wugong
    ----------------
    -- 判断 门派 menpai
    if thisdirection.menpai ~= nil and thisdirection.menpai:len() > 1 and score.party ~= thisdirection.menpai then
        isAvailable = false
    end
    ----------------
    -- 判断 性别 gender
    return isAvailable
end
-- ---------------------------------------------------------------
-- 获取临近房间
-- arg: roomid 房间编号id
-- arg: direct 是否只获取直达路径, 默认为false
-- ---------------------------------------------------------------
function pkuxkx.gps.GetNearRooms(roomid, direct)
    local collection = {}
    direct = direct or false
    if pkuxkx.direction == nil or #pkuxkx.direction < 2 then
        MapHelp.getAllDirection()
    end
    local thisroomdirections = pkuxkx.directionbranch[roomid]
    if thisroomdirections == nil or table.len(thisroomdirections) == 0 then
        return collection
    end
    for i = 1, #thisroomdirections do
        -- 判断该direction是否符合条件
        local isAvailable = _Direction_IsAvailable(thisroomdirections[i])
        if direct == true then
            if thisroomdirections[i].room1 == roomid and (thisroomdirections[i].go == nil or string.contain(thisroomdirections[i].go, "!") == false) and (thisroomdirections[i].special == nil or string.contain(thisroomdirections[i].special, "!") == false) and isAvailable == true then
                table.insert(collection, thisroomdirections[i].room2)
            end
        else
            if thisroomdirections[i].room1 == roomid and isAvailable == true then
                table.insert(collection, thisroomdirections[i].room2)
            end
        end
    end
    return collection
end
-- ---------------------------------------------------------------
-- 获得相反方向命令
-- ---------------------------------------------------------------
function pkuxkx.gps.getRevDirect(dstr)
    local ns = dstr
    local n
    if (string.len(dstr) <= 2 and dstr ~= "up") then
        ns, n = ns:gsub("s", "n")
        if (n == 0) then ns = ns:gsub("n", "s") end
        ns, n = ns:gsub("e", "w")
        if (n == 0) then ns = ns:gsub("w", "e") end
        ns, n = ns:gsub("d", "u")
        if (n == 0) then ns = ns:gsub("u", "d") end
    else
        ns, n = ns:gsub("south", "north")
        if (n == 0) then
            ns, n = ns:gsub("north", "south")
            --注意south和out冲突
            if (n == 0) then
                n = ns:find("enter", 1, true)
                if (n == nil) then
                    ns = ns:gsub("out", "enter")
                else
                    ns = "out"
                end
            end
        end
        ns, n = ns:gsub("east", "west")
        if (n == 0) then
            ns = ns:gsub("west", "east")
        end
        ns, n = ns:gsub("down", "up")
        if (n == 0) then
            ns = ns:gsub("up", "down")
        end
    end
    return ns
end

-- ---------------------------------------------------------------
-- 包装 go 方法
-- ---------------------------------------------------------------
function pkuxkx.gps.go(arg1, arg2)
    if arg1 == nil then
        -- 若无参数, 说明是定位后或其它事件后重新执行,直接从预保留的pkuxkx.gps参数中获取
        arg1 = pkuxkx.gps.goArgs1
        arg2 = pkuxkx.gps.goArgs2
    else
        -- 有参数,则说明是一次全新的go, 则重新赋值所有参数, 避免原脏数据影响后续操作
        pkuxkx.gps.goArgs1 = arg1
        pkuxkx.gps.goArgs2 = arg2
    end

    -- 进行快速猜测定位
    pkuxkx.gps.GuessLocate()
    if pkuxkx.gps.current.RoomId == nil or (pkuxkx.gps.current.RoomId <= 0) then
        pkuxkx.gps.afterLocationEvent = pkuxkx.gps.go
        pkuxkx.gps.failLocationEvent = function()
            common.error("定位失败! 待完善地图以及定位失败的随机移动部分!~~~~~~~~")
        end
        pkuxkx.gps.Locate()
    else
        if (arg2 == nil) then
            if (string.match(arg1, "^%d+$") ~= nil) then
                -- 若为数字,则假定此为正确的房间ID,直接走
                return pkuxkx.gps.goRoom(tonumber(arg1))
            elseif (string.match(arg1, "^%w+$") ~= nil) then
                -- 检查用户路径/目的地的alias设置
                -- TODO (priority 5)
                local i, j = string.find(Role.mapsettings.mapaliases, "|" .. arg1 .. "=", 1, true)
                if (i ~= nil) then
                    j = j + 1
                    i = string.find(Role.mapsettings.mapaliases, "|", j, true)
                    if (i == nil) then
                        echo('\nRole.mapsettings.mapaliases 参数内容有错误，请手动修复它。')
                    else
                        local a = tonumber(string.sub(Role.mapsettings.mapaliases, j, i - 1))
                        pkuxkx.gps.goRoom(arg1)
                        return
                    end
                end
            end
        end

        local r = MapHelp.GetRoomID(arg1, arg2)
        if (r ~= nil) then
            pkuxkx.gps.goRoom(r)
        end
    end
end
-- ---------------------------------------------------------------
-- 包装 go 方法, 含后续处理script, 只允许有准确的房间名称/房间ID时使用
-- ---------------------------------------------------------------
function pkuxkx.gps.gotodo(room, script)
    return pkuxkx.gps.gotodoExtend(room, nil, script)
end
-- ---------------------------------------------------------------
-- 包装 go 方法扩展, 含后续处理script, 允许同时有区域和房间名
-- ---------------------------------------------------------------
function pkuxkx.gps.gotodoExtend(area, room, script)
    local arg1 = area
    local arg2 = room
    local aftergoEvent = script
    if arg1 == nil then
        -- 若无参数, 说明是定位后或其它事件后重新执行,直接从预保留的pkuxkx.gps参数中获取
        arg1 = pkuxkx.gps.goArgs1
        arg2 = pkuxkx.gps.goArgs2
        aftergoEvent = pkuxkx.gps.goArgs_aftergoEvent
    else
        -- 有参数,则说明是一次全新的go, 则重新赋值所有参数, 避免原脏数据影响后续操作
        pkuxkx.gps.goArgs1 = arg1
        pkuxkx.gps.goArgs2 = arg2
        pkuxkx.gps.goArgs_aftergoEvent = aftergoEvent
    end

    -- 进行快速猜测定位
    pkuxkx.gps.GuessLocate()
    if pkuxkx.gps.current.RoomId == nil or (pkuxkx.gps.current.RoomId <= 0) then
        pkuxkx.gps.afterLocationEvent = pkuxkx.gps.gotodoExtend
        pkuxkx.gps.failLocationEvent = function()
            common.error("定位失败! 待完善地图以及定位失败的随机移动部分!~~~~~~~~")
        end
        pkuxkx.gps.Locate()
    else
        pkuxkx.gps.arriveEvent = function()
            cecho("<black:gray>已到达目的地。\n")
            if aftergoEvent ~= nil then
                common.eventHandle(aftergoEvent)
            end
        end

        if (arg2 == nil) then
            if (string.match(arg1, "^%d+$") ~= nil) then
                -- 若为数字,则假定此为正确的房间ID,直接走
                return pkuxkx.gps.goRoom(tonumber(arg1))
            elseif (string.match(arg1, "^%w+$") ~= nil) then
                -- 检查用户路径/目的地的alias设置
                -- TODO (priority 5)
                local i, j = string.find(Role.mapsettings.mapaliases, "|" .. arg1 .. "=", 1, true)
                if (i ~= nil) then
                    j = j + 1
                    i = string.find(Role.mapsettings.mapaliases, "|", j, true)
                    if (i == nil) then
                        echo('\nRole.mapsettings.mapaliases 参数内容有错误，请手动修复它。')
                    else
                        local a = tonumber(string.sub(Role.mapsettings.mapaliases, j, i - 1))
                        pkuxkx.gps.goRoom(arg1)
                        return
                    end
                end
            end
        end

        local r = MapHelp.GetRoomID(arg1, arg2)
        if (r ~= nil) then
            pkuxkx.gps.goRoom(r)
        end
    end
end
-- ---------------------------------------------------------------
-- 遍历 某一个区域的所有房间
-- ---------------------------------------------------------------
function pkuxkx.gps.traverseArea(area, personname, script, personnameType)
    MapHelp.traverseArea(area, personname, script, personnameType)
end
-- ---------------------------------------------------------------
-- 修正一些异常或模糊的地址为正常可被找到的地址
-- ---------------------------------------------------------------
function pkuxkx.gps.FixAddress(address)
    return MapHelp.FixAddress(address)
end
-- ---------------------------------------------------------------
-- 根据 area 来获取 区域id
-- ---------------------------------------------------------------
function pkuxkx.gps.getAreaId(areaname)
    return MapHelp.getAreaId(areaname)
end
-- ---------------------------------------------------------------
-- 根据 areaID 来得到区域的名称
-- ---------------------------------------------------------------
function pkuxkx.gps.getAreaName(areaid)
    return MapHelp.getAreaName(areaid)
end
-- ---------------------------------------------------------------
-- 获取该区域的中心点/核心房间的房间id, roomID
-- ---------------------------------------------------------------
function pkuxkx.gps.getAreaCenter(areaid)
    return MapHelp.getAreaCenter(areaid)
end
-- ---------------------------------------------------------------
-- 根据 roomid 来获取 房间中文名
-- ---------------------------------------------------------------
function pkuxkx.gps.GetRoomNameByID(roomid)
    return MapHelp.GetRoomNameByID(roomid)
end
-- ---------------------------------------------------------------
-- 根据 房间名 来获取 房间ID, 需 区域ID(areaid)
-- ---------------------------------------------------------------
function pkuxkx.gps.GetRoomID(areaid, name)
    return MapHelp.GetRoomID(areaid, name)
end
-- ---------------------------------------------------------------
-- 获取 房间集合 --
-- 注意!!! 不同于 ppopkc.getRoomId只获得单一房间id, 在多房间下返回nil, 该方法会返回所有同名房间集合
-- 参数 s1 (区域中文名)
-- 参数 s2 (房间中文名)
-- ---------------------------------------------------------------
function pkuxkx.gps.getRooms(s1, s2)
    return MapHelp.getRooms(s1, s2)
end
-- ---------------------------------------------------------------
-- 根据房间名 获取同名房间的所有集合
-- ---------------------------------------------------------------
function pkuxkx.gps.getRoomsByName(roomname)
    return MapHelp.getRoomsByName(roomname)
end
-- ---------------------------------------------------------------
-- 获取 某一区域的房间集合
-- ---------------------------------------------------------------
function pkuxkx.gps.getRoomsByArea(area)
    return MapHelp.getRoomsByArea(area)
end
-- ---------------------------------------------------------------
-- 根据一个地址(如: 华山镇岳宫),获取一个准确的目标定位, 
-- 即 quest.area = "华山", quest.location = "镇岳宫", 
-- 并返回该地区是否能够正确到达
-- ---------------------------------------------------------------
function pkuxkx.gps.getAddress(addr)
    return MapHelp.getAddress(addr)
end













-- ---------------------------------------------------------------
-- 生成路径测试
-- ---------------------------------------------------------------
function pkuxkx.gps.pathtest(from, to)
    local starttime = os.clock()
    pathtable = pkuxkx.gps.GetPath(from, to)
    local donetime = os.clock()
    print("GetPath耗时: " .. (donetime - starttime))
    if pathtable == nil then
        return "无法找到该路径"
    end
    local g_path = {}
    for i = 1, #pathtable do
        if pathtable[i].go then
            table.insert(g_path, pathtable[i].go)
        else
            table.insert(g_path, pathtable[i].special)
        end
    end
    -- if string.len(g_path) > 100 then
    --     local pt = string.split(g_path,";")
    --     for i=1,#pt do
    --         print(pt[i])
    --     end
    -- else
    print("路径为: " .. table.concat(g_path, ";"))
    -- end
end