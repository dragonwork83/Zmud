pkuxkx = pkuxkx or {}
pkuxkx.seek = pkuxkx.seek or {}
-- 新一轮寻找的会话实例
pkuxkx.seek.session = pkuxkx.seek.session or {}
-- 该轮寻找NPC的名字
pkuxkx.seek.session.NPCName = ""
-- 用于保存NPC的英文ID
pkuxkx.seek.session.NPCId = ""
-- 当找到NPC时, 用于保存NPC所在的房间ID
pkuxkx.seek.session.NPCLocation = 0
-- 用于记录找到目标NPC后又经过了多少房间(此作为第二选项备选方案, 当第一方案异常时使用)
pkuxkx.seek.session.goneRoom = 0
-- 搜索的类型, 默认为1, 1.为搜索NPC中文名, 2.为搜索NPC英文ID
pkuxkx.seek.session.Type = 1
-- 该轮寻找的范围, 4代表相临的4个房间, 若为 0, 则代表整个区域area搜索, 注:! Range是判断范围搜索或区域搜索的重要和唯一依据
pkuxkx.seek.session.Range = 4
-- 该轮寻找的区域编号
pkuxkx.seek.session.Area = 1
pkuxkx.seek.session.AreaName = ""
-- 该轮搜寻的具体房间名 (范围搜索,特别是有同名房间时,pkuxkx.seek.session.Room会为多个集合, 若为区域搜索,则为单条集合, 即为中心点的房间集合)
pkuxkx.seek.session.Room = {}
pkuxkx.seek.session.RoomName = ""
-- 若查找多个同名房间, 需遍历完一个房间range内的所有房间后, 继续遍历下一个
-- 该RoomIndex用于多个同名房间集合时,记录当前遍历同名房间的索引, 如第一个同名房间周围集合时为RoomIndex = 1
pkuxkx.seek.session.RoomIndex = 0
-- 下一个要到达的节点ID
pkuxkx.seek.session.NextRoomID = 0
-- 某一单次查找时所需要检查的节点集合
pkuxkx.seek.session.Nodes = {}
-- 根据所有需要遍历的节点, 生成的搜索paths集合, 此path会略过一些重复节点(即已路过一次的节点)
-- Ps: 此paths会在搜寻/使用过程中不断减小变化, 在初始它和pkuxkx.seek.session.Paths一致, 后续会不断减掉已经走过的路径
pkuxkx.seek.session.Paths = {}
-- PathsAll用于保存最初生成的完整Paths, 不会因为搜寻过的路径而减少, 用于路径出错时的回滚比对
pkuxkx.seek.session.PathsAll = {}
-- 记录单次搜寻路径Path
pkuxkx.seek.session.SectionPath = {}
-- 单段path的Step计步, 用于当某一段path过长时的分段执行
pkuxkx.seek.session.WalkStep = 1

-- 是否已经找到NPC
pkuxkx.seek.session.Found = false
-- 该轮搜寻的找到后事件
pkuxkx.seek.session.foundoutEvent = nil
-- 该轮搜寻的找NPC失败的处理事件
pkuxkx.seek.session.failSeekEvent = nil

-- ---------------------------------------------------------------
-- 初始化单次搜寻Session
-- ---------------------------------------------------------------
function pkuxkx.seek.Init()
    pkuxkx.seek.session = {}
end
-- ---------------------------------------------------------------
-- 寻找某NPC的基方法
-- ---------------------------------------------------------------
function pkuxkx.seek.LookFor(npcname, area, room, range)
    -- 初始化本次搜寻会话
    pkuxkx.seek.session.Found = false
    pkuxkx.seek.session.NPCName = npcname
    pkuxkx.seek.session.Range = range or 4
    pkuxkx.seek.session.NPCId = ""
    pkuxkx.seek.session.NPCLocation = 0
    pkuxkx.seek.session.goneRoom = 0
    pkuxkx.seek.session.Area = pkuxkx.gps.getAreaId(area)
    pkuxkx.seek.session.AreaName = area
    if pkuxkx.seek.session.Area == nil or pkuxkx.seek.session.Area < 1 then
        common.warning("错误的区域Area名, 请检查该区域名,或添加进数据库!")
    end
    if room == nil then
        -- 说明会区域搜索
        pkuxkx.seek.session.Range = 0
        -- 说明是某区域的遍历
        pkuxkx.seek.session.Room = {}
        local room = pkuxkx.gps.getRooms(pkuxkx.seek.session.AreaName, pkuxkx.gps.GetRoomNameByID(pkuxkx.gps.getAreaCenter(pkuxkx.seek.session.Area)))
        if room then
            table.insert(pkuxkx.seek.session.Room, room[1])
        end
    else
        pkuxkx.seek.session.RoomName = room
        pkuxkx.seek.session.Room = pkuxkx.gps.getRooms(area, room)
        if range then
            pkuxkx.seek.session.Range = tonumber(range)
        end
        -- 若查找多个同名房间, 需遍历完一个房间range内的所有房间后, 继续遍历下一个
        if pkuxkx.seek.session.Room == nil or table.len(pkuxkx.seek.session.Room) == 0 then
            -- 说明输入的房间名异常,或数据库找不到.无法到达
            -- 调用失败事件
            common.warning("目标房间名异常或找不到,搜索放弃!")
            return pkuxkx.seek.failSeekHandle()
        end
    end
    -- 预检查搜寻地点是否可达, 避免生成搜索路径后go过去发现无法到达
    if pkuxkx.seek.PreExamPath() then
        -- 找到第一个可执行
        pkuxkx.seek.Process()
    else
        -- 失败会在PreExamPath中自我返回, 并调用pkuxkx.seek.failSeekHandle方法, 无需特殊处理
    end
end
-- ---------------------------------------------------------------
-- 预检查搜寻点路径是否可以到达
-- 同时生成/设置下一个到达点(即第一个搜寻节点)
-- ---------------------------------------------------------------
function pkuxkx.seek.PreExamPath()
    -- 检查路径是否可以到达
    if table.len(pkuxkx.seek.session.Room) > 0 then
        local IsAvailable = false
        local index = 1
        while index <= #pkuxkx.seek.session.Room and IsAvailable == false do
            if pkuxkx.gps.GetPath(1, pkuxkx.seek.session.Room[index].id) ~= nil or (1 == pkuxkx.seek.session.Room[index].id)  then
                IsAvailable = true
            end
            index = index + 1
        end
        if IsAvailable == false then
            common.warning("无有效路径到达,搜索放弃![房间ID:" .. pkuxkx.seek.session.Room[index - 1].id .. "]")
            return pkuxkx.seek.failSeekHandle()
        end
    else
        return false
    end
    return true
end
-- ---------------------------------------------------------------
-- 执行搜寻失败后的事件
-- ---------------------------------------------------------------
function pkuxkx.seek.failSeekHandle()
    disableTrigger("找人")
    if pkuxkx.seek.session.failSeekEvent then
        pkuxkx.seek.session.failSeekEvent()
    end
end
-- ---------------------------------------------------------------
-- 紧急停止后续的搜索
-- ---------------------------------------------------------------
function pkuxkx.seek.Stop()
    pkuxkx.gps.walk.allow = false
    pkuxkx.seek.session.Found = true
end
-- ---------------------------------------------------------------
-- 搜索具体执行
-- ---------------------------------------------------------------
function pkuxkx.seek.Process()
    disableTrigger("找人")
    -- 将要查找的第一个房间点(若有多个同名房间的情况下), 放入NextRoomID, 并从pkuxkx.seek.session.Room中移除该房间
    if pkuxkx.seek.session.Room and table.len(pkuxkx.seek.session.Room) > 0 then
        pkuxkx.seek.session.NextRoomID = pkuxkx.seek.session.Room[1].id
        table.remove(pkuxkx.seek.session.Room, 1)
    else
        -- 已查找完所有同名节点
        if pkuxkx.seek.session.Found == true then
            -- 去锁定的房间编号找NPC
            return pkuxkx.gps.gotodo(pkuxkx.seek.session.NPCLocation, function()
                if pkuxkx.seek.session.foundoutEvent then
                    pkuxkx.seek.session.foundoutEvent()
                end
                disableTrigger("找人")
            end)
        else
            -- 未发现目标NPC
            if pkuxkx.seek.session.RoomName == nil then
                pkuxkx.seek.session.RoomName = ""
            end
            common.warning("已完成全部查找,未发现目标[" .. pkuxkx.seek.session.NPCName .. "],位置:" .. pkuxkx.seek.session.AreaName .. pkuxkx.seek.session.RoomName .. "!")
            return pkuxkx.seek.failSeekHandle()
        end
    end
    -- 进行下一个同名房间大节点查找
    pkuxkx.gps.gotodo(pkuxkx.seek.session.NextRoomID, function()
        pkuxkx.seek.SingleNodeSeekProcess()
    end)
end
-- ---------------------------------------------------------------
-- 至某一个节点后, 单节点的搜寻方法
-- ---------------------------------------------------------------
function pkuxkx.seek.SingleNodeSeekProcess()
    enableTrigger("找人")
    -- 进行范围搜索
    pkuxkx.seek.session.Nodes = {}
    -- 根据 pkuxkx.seek.session.Range 判断是范围搜索 / 全区域搜索
    if pkuxkx.seek.session.Range > 0 then
        -- 范围搜索, BFS遍历
        local opennodes = {}
        table.insert(opennodes, pkuxkx.seek.session.NextRoomID)
        for i = 1, pkuxkx.seek.session.Range do
            for j = 1, #opennodes do
                local nearroomsID = pkuxkx.gps.GetNearRooms(opennodes[j], false, false)
                for k = 1, #nearroomsID do
                    if table.contain(opennodes, nearroomsID[k]) == false and pkuxkx.seek.IsAbandonNode(nearroomsID[k]) == false then
                        table.insert(opennodes, nearroomsID[k])
                    end
                end
            end
        end
        -- 此为需查找的所有房间节点集合
        pkuxkx.seek.session.Nodes = opennodes
        -- 获得单将的遍历节点集合.进行遍历
        pkuxkx.seek.GeneratePaths()
    else
        -- 区域搜索, DFS遍历
        -- TODO
        -- 暂用BFS替代,待优化
        local rooms = pkuxkx.gps.getRoomsByArea(pkuxkx.seek.session.Area)
        local opennodes = {}
        for i = 1, #rooms do
            if table.contain(opennodes, rooms[i].id) == false and pkuxkx.seek.IsAbandonNode(rooms[i].id) == false then
                table.insert(opennodes, rooms[i].id)
            end
        end
        -- 此为需查找的所有房间节点集合
        pkuxkx.seek.session.Nodes = opennodes
        -- 获得单将的遍历节点集合.进行遍历
        pkuxkx.seek.GeneratePaths()
    end
end
-- ---------------------------------------------------------------
-- 根据获取的需要遍历的房间集合, 进行遍历找人
-- ---------------------------------------------------------------
function pkuxkx.seek.GeneratePaths()
    -- display(pkuxkx.seek.session.Nodes)
    local paths = {}
    while table.len(pkuxkx.seek.session.Nodes) > 0 do
        if pkuxkx.seek.session.NextRoomID == pkuxkx.seek.session.Nodes[1] then
            table.remove(pkuxkx.seek.session.Nodes, 1)
        end
        -- print("pkuxkx.seek.session.NextRoomID:"..pkuxkx.seek.session.NextRoomID)
        -- print("pkuxkx.seek.session.Nodes[1]:"..pkuxkx.seek.session.Nodes[1])
        local _paths = pkuxkx.gps.GetPath(pkuxkx.seek.session.NextRoomID, pkuxkx.seek.session.Nodes[1])
        -- display(_paths)
        if pkuxkx.seek._checkPathAvailable(_paths) then
            -- 检查所经过的节点, 并将这些节点从 pkuxkx.seek.session.Nodes中移除
            for i = 1, #_paths do
                if table.contain(pkuxkx.seek.session.Nodes, _paths[i].room1) then
                    pkuxkx.seek._removeNode(_paths[i].room1)
                end
                -- if table.contain(pkuxkx.seek.session.Nodes, _paths[i].room2) then
                --     pkuxkx.seek._removeNode(_paths[i].room2)
                -- end
            end
            -- 赋值下一个节点, 继续循环查找并生成路径
            pkuxkx.seek.session.NextRoomID = pkuxkx.seek.session.Nodes[1]
            table.remove(pkuxkx.seek.session.Nodes, 1)
            for i = 1, #_paths do
                table.insert(paths, _paths[i])
            end
        else
            table.remove(pkuxkx.seek.session.Nodes, 1)
        end
    end

    local cpaths = {}
    -- 将本次大节点的全部路径根据步长拆分进行查询
    local singlesteplength = GetRoleConfig("WalkSteps")
    if singlesteplength == nil or singlesteplength == "" then
        -- 默认8步长
        singlesteplength = 8
    end
    while table.len(paths) > 0 do
        local _preparedpaths = {}
        while (table.len(_preparedpaths) < singlesteplength) and table.len(paths) > 0 do
            table.insert(_preparedpaths, paths[1])
            table.remove(paths, 1)
        end
        table.insert(cpaths, _preparedpaths)
    end
    -- display(cpaths)
    pkuxkx.seek.session.Paths = cpaths
    pkuxkx.seek.session.PathsAll = cpaths
    pkuxkx.seek.Implement()
end
-- ---------------------------------------------------------------
-- 执行行走搜索的具体实施
-- ---------------------------------------------------------------
function pkuxkx.seek.Implement()
    -- display(pkuxkx.seek.session.Paths)
    -- local cmd = pkuxkx.seek.path2cmd()
    -- print(cmd)
    if pkuxkx.seek.session.Found == true then
        -- (暂不采用回退的方式, 退回记录的房间进行查找)
        -- 去锁定的房间编号进行follow
        return pkuxkx.gps.gotodo(pkuxkx.seek.session.NPCLocation, function()
            if pkuxkx.seek.session.foundoutEvent then
                pkuxkx.seek.session.foundoutEvent()
            end
            disableTrigger("找人")
        end)
    end

    if pkuxkx.seek.session.Paths ~= nil and table.len(pkuxkx.seek.session.Paths) > 0 then
        -- 开始新一段节点的查找
        local singlepath = pkuxkx.seek.session.Paths[1]
        table.remove(pkuxkx.seek.session.Paths, 1)
        -- 重置errortimes
        pkuxkx.path.errortimes = 0
        -- 重置经过的房间
        pkuxkx.path.passedrooms = {}
        -- Section查找的具体实现
        pkuxkx.seek.WalkSection(singlepath)
    else
        -- 本次大节点查找完成, 继续执行 pkuxkx.seek.Process(), 或无后续同名大节点,则结束, 否则,继续下一同名节点查找
        pkuxkx.seek.Process()
    end
end
-- ---------------------------------------------------------------
-- 根据生成的搜寻路径来进行分阶段的走查
-- ---------------------------------------------------------------
function pkuxkx.seek.WalkSection(path)
    if pkuxkx.seek.session.Found == true then
        -- (暂不采用回退的方式, 退回记录的房间进行查找)
        -- 去锁定的房间编号进行follow
        return pkuxkx.gps.gotodo(pkuxkx.seek.session.NPCLocation, function()
            if pkuxkx.seek.session.foundoutEvent then
                pkuxkx.seek.session.foundoutEvent()
            end
            disableTrigger("找人")
        end)
    end

    -- 执行行走实际动作
    pkuxkx.gps.walk.Init(path)
    -- 到达目的地触发事件
    pkuxkx.gps.walk.arrivedEvent = function()
        -- 设置pkuxkx.gps.guess.RoomID 为当前ID
        pkuxkx.gps.guess.RoomId = path[#path].room2
        -- 设置pkuxkx.gps.current.RoomID 为当前ID
        pkuxkx.gps.current.RoomId = path[#path].room2
        -- GPS 到达目的地后的事件执行
        return pkuxkx.seek.Implement()
    end
    -- 行走出现异常后续处理方案
    pkuxkx.gps.walk.failEvent = function()
        -- 中止行走
        pkuxkx.gps.stop()
        -- 强制重新定位,
        pkuxkx.gps.current.RoomId = 0
        -- 重新行走
        -- 重新定位搜寻
        -- 思路为, 根据pkuxkx.seek.session.PathsAll 回滚一条 pkuxkx.seek.session.Paths的集合, 并定位到该集合的Room1, 重新执行一次 pkuxkx.seek.Implement()
        return pkuxkx.gps.gotodo(path[1].room1, function()
            pkuxkx.seek.WalkSection(path)
        end)
    end
    pkuxkx.gps.walk.Execute()
end
-- ---------------------------------------------------------------
-- 将过滤过的pkuxkx.seek.session.Paths集合转化为cmd指令行
-- ---------------------------------------------------------------
function pkuxkx.seek.path2cmd()
    local cmds = {}
    for i = 1, #pkuxkx.seek.session.Paths do
        for j = 1, #pkuxkx.seek.session.Paths[i] do
            if pkuxkx.seek.session.Paths[i][j].special ~= nil and pkuxkx.seek.session.Paths[i][j].special:len() > 0 then
                table.insert(cmds, pkuxkx.seek.session.Paths[i][j].special)
            end
            if pkuxkx.seek.session.Paths[i][j].go ~= nil and pkuxkx.seek.session.Paths[i][j].go:len() > 0 then
                table.insert(cmds, pkuxkx.seek.session.Paths[i][j].go)
            end
        end
    end
    return table.concat(cmds, ";")
end
-- ---------------------------------------------------------------
-- 移除某一节点, 从pkuxkx.seek.session.Nodes中
-- ---------------------------------------------------------------
function pkuxkx.seek._removeNode(node)
    for i = 1, #pkuxkx.seek.session.Nodes do
        if pkuxkx.seek.session.Nodes[i] == node then
            table.remove(pkuxkx.seek.session.Nodes, i)
        end
    end
end
-- ---------------------------------------------------------------
-- 检查搜索节点间的path的合法性, 避免如 过河, 坐车等节点
-- ---------------------------------------------------------------
function pkuxkx.seek._checkPathAvailable(path)
    local isAvailable = true
    if path == nil or table.len(path) == 0 then
        return false
    end
    for i = 1, #path do
        local cmd = pkuxkx.gps.special.convert2cmd(path[i])
        if string.contain(cmd, "!zuoche") or string.contain(cmd, "!river") then
            isAvailable = false
        end
    end
    return isAvailable
end

-- ---------------------------------------------------------------
-- 判断节点是否属于特殊节点/位置 (需排除, 不搜索的节点)
-- ---------------------------------------------------------------
function pkuxkx.seek.IsAbandonNode(roomid)
    if table.contain(pkuxkx.seek.AbandonRooms,roomid) then
        return true
    else
        return false
    end
end
pkuxkx.seek.AbandonRooms = {
    4462, -- 扬州 赏月台
    4506, -- 云海 的某一位置(非全部云海)
    4519,4520,4521,4522,4523,4524,-- 杀手帮作任务处
    247, -- 汝阳王府部分
    3500, -- 康亲王书房
    248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,614,615,616,617,618,619,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104,1105, -- 汝阳王府部分
}