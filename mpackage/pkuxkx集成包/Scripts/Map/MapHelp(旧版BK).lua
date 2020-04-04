MapHelp = {}

function MapHelp.getFirstWords()
    -- require("firstwords")
    return FirstWords
end
-- ---------------------------------------------------------------
-- 获取第一个字, 通常是姓氏
-- ---------------------------------------------------------------
function MapHelp.getFirstWord(word)
    if not word then
        return ""
    end
    local fws = {}
    for w in string.gmatch(word, "..") do
        table.insert(fws, MapHelp.getFirstWords()[w])
    end
    return table.concat(fws)
end

function MapHelp.isCity(p_city)
    local l_result = false
    for k, v in pairs(citys) do
        if v == p_city then
            l_result = true
        end
    end
    for k, v in pairs(lookCitys) do
        if v == p_city then
            l_result = true
        end
    end
    for k, v in pairs(otherCitys) do
        if v == p_city then
            l_result = true
        end
    end
    return l_result
end

-- ---------------------------------------------------------------
-- 包装 go 方法
-- ---------------------------------------------------------------
function MapHelp.go(arg1, arg2)
    if (ses.gt.currentRoomId <= 0) then
        ppopkc.gon1 = arg1
        ppopkc.gon2 = arg2
        ses:setCb("funcEndDw", ppopkc.cbG)
        ses:setCb("funcDwFail", function()
            ses.gt:reDw()
        end)
        ses.gt:dw()
    else
        ppopkc.g(arg1, arg2)
    end
end
-- ---------------------------------------------------------------
-- 包装 go 方法
-- ---------------------------------------------------------------
function pkuxkx.go(arg1, arg2)
    return MapHelp.go(arg1, arg2)
end
-- ---------------------------------------------------------------
-- 包装 go 方法, 含后续处理script, 只允许有准确的房间名称/房间ID时使用
-- ---------------------------------------------------------------
function MapHelp.gotodo(room, script)
    if (ses.gt.currentRoomId <= 0) then
        ppopkc.gon1 = room
        ppopkc.gon2 = nil
        ppopkc.gonscript = script
        ses:setCb("funcEndDw", ppopkc.cbG)
        ses:setCb("funcDwFail", function()
            ses.gt:reDw()
        end)
        ses.gt:dw()
    else
        ppopkc.g(room, nil, script)
    end
end
-- ---------------------------------------------------------------
-- 包装 go 方法, 含后续处理script, 只允许有准确的房间名称/房间ID时使用
-- ---------------------------------------------------------------
function pkuxkx.gotodo(room, script)
    return MapHelp.gotodo(room, script)
end
-- ---------------------------------------------------------------
-- 包装 go 方法扩展, 含后续处理script, 允许同时有区域和房间名
-- ---------------------------------------------------------------
function pkuxkx.gotodoExtend(area, room, script)
    if (ses.gt.currentRoomId <= 0) then
        ppopkc.gon1 = area
        ppopkc.gon2 = room
        ppopkc.gonscript = script
        ses:setCb("funcEndDw", ppopkc.cbG)
        ses:setCb("funcDwFail", function()
            ses.gt:reDw()
        end)
        ses.gt:dw()
    else
        ppopkc.g(area, room, script)
    end
end
-- ---------------------------------------------------------------
-- 遍历房间集合处理程式
-- ---------------------------------------------------------------
function _traverseAreaHandle(collection, script)
    pkuxkx.travese = {}
    pkuxkx.travese.step = 1
    pkuxkx.travese.collection = collection
    pkuxkx.travese.needgoon = true  -- 是否继续搜索下个地方
    pkuxkx.travese.afterhandle = script
    if pkuxkx.travese.collection == nil or table.len(pkuxkx.travese.collection) == 0 then
        cecho("<red:gray>遍历异常。\n")
        return
    end
    ses:setCb(
    "funcEndPath",
    function()
        cecho("<purple>pkuxkx.travese.step : " .. pkuxkx.travese.step)
        if pkuxkx.travese.needgoon == false or ses.gt.personFound == true or (table.len(pkuxkx.travese.collection) == pkuxkx.travese.step) then
            cecho("<black:gray>遍历完成。\n")
            disableTrigger("找人")
            local func = pkuxkx.travese.afterhandle
            if func ~= nil then
                if type(func) == "function" then
                    func()
                else
                    local fun = _G[func]
                    if fun then
                        fun()
                    end
                end
            end
        else
            -- 继续遍历下一个房间
            pkuxkx.travese.step = pkuxkx.travese.step + 1
            ppopkc.goRoom(pkuxkx.travese.collection[pkuxkx.travese.step].id)
        end
    end
    )
    ses:setCb(
    "funcPathFail",
    function()
        if table.len(pkuxkx.travese.collection) == pkuxkx.travese.step then
            cecho("<black:gray>遍历完成。\n")
            disableTrigger("找人")
        else
            -- 继续遍历下一个房间
            pkuxkx.travese.step = pkuxkx.travese.step + 1
            ppopkc.goRoom(pkuxkx.travese.collection[pkuxkx.travese.step].id)
        end
    end
    )
    enableTrigger("找人")
    ppopkc.goRoom(pkuxkx.travese.collection[1].id)
end
-- ---------------------------------------------------------------
-- 遍历 某一个区域的所有房间
-- personnameType 即 要查找的NPC人名格式, 如名字中有一个空格,即为2 (如:"枫苍月的 慕容家贼"), 单纯名字不用填该参数
-- ---------------------------------------------------------------
function MapHelp.traverseArea(area, personname, script, personnameType)
    personnameType = personnameType or 0
    ses.gt.pnameType = personnameType
    ses.gt.personName = personname
    ses.gt.personFound = false
    local collection = MapHelp.getRoomsByArea(area)
    _traverseAreaHandle(collection, script)
end
-- ---------------------------------------------------------------
-- 遍历 某一个区域的所有房间
-- ---------------------------------------------------------------
function pkuxkx.traverseArea(area, personname, script, personnameType)
    MapHelp.traverseArea(area, personname, script, personnameType)
end
-- ---------------------------------------------------------------
-- 修正一些异常或模糊的地址为正常可被找到的地址
-- ---------------------------------------------------------------
function MapHelp.FixAddress(address)
    local fix = address
    if address == "长江北岸" then
        fix = "长江北岸陵矶"
    end
    if address == "长江南岸" then
        fix = "长江南岸陵矶"
    end
    if address == "黄河北岸" then
        fix = "黄河北岸风陵渡"
    end
    if address == "黄河南岸" then
        fix = "黄河南岸孟津渡"
    end
    if address == "星宿海" then
        fix = "星宿海星宿海"
    end
    if address == "荆州" then
        fix = "荆州荆州"
    end
    if address == "襄阳荆门" then
        fix = "荆州荆门"
    end
    if address == "襄阳华容道" then
        fix = "荆州华容道"
    end
    return fix
end
-- ---------------------------------------------------------------
-- 修正一些异常或模糊的地址为正常可被找到的地址
-- ---------------------------------------------------------------
function pkuxkx.FixAddress(address)
    return MapHelp.FixAddress(address)
end
-- ---------------------------------------------------------------
-- 修正一些获得的地址(与rooms里不匹配的名称), 使之与rooms数据相匹配
-- 原Mush lua中的 addrTrim(addr)方法
-- ---------------------------------------------------------------
function MapHelp.addrFix(addr)
    addr = del_string(addr, '姑苏')
    addr = string.gsub(addr, '小村', '华山村', 1)
    addr = string.gsub(addr, '大理天龙寺', '天龙寺', 1)
    addr = string.gsub(addr, '慕容', '姑苏慕容', 1)
    -- addr=string.gsub(addr,'明教溪口','宁波城溪口',1)
    return addr
end
-- ---------------------------------------------------------------
-- 获取所有的区域名, 并将之存入 pkuxkx.area
-- ---------------------------------------------------------------
function MapHelp.getAllArea()
    pkuxkx.area = {}
    local cursor = sqlconn:execute("select * from area ")
    row = cursor:fetch({}, "a")
    while row do
        -- print(string.format("Id: %s, Name: %s", row.id, row.name))
        table.insert(pkuxkx.area, row)
        row = cursor:fetch({}, "a")
    end
    cursor:close()
    return nil
end
-- ---------------------------------------------------------------
-- 获取所有的房间名, 并将之存入 pkuxkx.room
-- ---------------------------------------------------------------
function MapHelp.getAllRoom()
    pkuxkx.room = {}
    local cursor = sqlconn:execute("select * from room ")
    row = cursor:fetch({}, "a")
    while row do
        -- print(string.format("Id: %s, Name: %s", row.id, row.name))
        table.insert(pkuxkx.room, row)
        row = cursor:fetch({}, "a")
    end
    cursor:close()
    return nil
end
-- ---------------------------------------------------------------
-- 获取所有的出口, 并将之存入 pkuxkx.direction
-- ---------------------------------------------------------------
function MapHelp.getAllDirection()
    pkuxkx.direction = {}
    pkuxkx.directionbranch = {}
    local cursor = sqlconn:execute("select room1,room2,go,special from direction where room2>0 and assume<>1")
    row = cursor:fetch({}, "a")
    while row do
        -- print(string.format("Id: %s, Name: %s", row.id, row.name))
        table.insert(pkuxkx.direction, row)
        -- 写入分表, 用于分库用.优化查询,避免遍历全direction表
        pkuxkx.directionbranch[row.room1] = pkuxkx.directionbranch[row.room1] or {}
        table.insert(pkuxkx.directionbranch[row.room1], row)
        row = cursor:fetch({}, "a")
    end
    cursor:close()
    return nil
end
-- ---------------------------------------------------------------
-- 根据 area 来获取 区域id
-- ---------------------------------------------------------------
function MapHelp.getAreaId(areaname)
    local aid = nil
    if (areaname == nil) then
        return
    end
    if pkuxkx.area == nil then
        MapHelp.getAllArea()
    end
    for i = 1, #pkuxkx.area do
        -- 判断区域名
        if pkuxkx.area[i].name == areaname then
            aid = pkuxkx.area[i].id
        end
        if aid == nil then
            -- 判断区域别名
            local nickname = pkuxkx.area[i].contain
            if nickname and string.len(nickname) > 0 then
                if string.contain(nickname, "|") then
                    local contains = string.split(nickname, "|")
                    for j = 1, #contains do
                        if contains[j] == areaname then
                            aid = pkuxkx.area[i].id
                        end
                    end
                else
                    if nickname and string.len(nickname) > 0 and nickname == areaname then
                        aid = pkuxkx.area[i].id
                    end
                end
            end
        end
    end
    return aid
end
-- ---------------------------------------------------------------
-- 根据 area 来获取 区域id
-- ---------------------------------------------------------------
function pkuxkx.getAreaId(areaname)
    return MapHelp.getAreaId(areaname)
end
-- ---------------------------------------------------------------
-- 根据 roomid 来获取 房间中文名
-- ---------------------------------------------------------------
function MapHelp.GetRoomNameByID(roomid)
    local roomname = ""
    if pkuxkx.room == nil then
        MapHelp.getAllRoom()
    end
    for i = 1, #pkuxkx.room do
        if pkuxkx.room[i].id == roomid then
            roomname = pkuxkx.room[i].name
        end
    end
    return roomname
end
-- ---------------------------------------------------------------
-- 根据 roomid 来获取 房间中文名
-- ---------------------------------------------------------------
function pkuxkx.GetRoomNameByID(roomid)
    return MapHelp.GetRoomNameByID(roomid)
end

-- ---------------------------------------------------------------
-- 根据 房间名 来获取 房间ID, 需 区域ID(areaid)
-- ---------------------------------------------------------------
function MapHelp.GetRoomID(areaid, name)
    if pkuxkx.room == nil then
        MapHelp.getAllRoom()
    end
    for i = 1, #pkuxkx.room do
        if pkuxkx.room[i].area == areaid and pkuxkx.room[i].name == name then
            return pkuxkx.room[i].id
        end
    end
    return nil
end
-- ---------------------------------------------------------------
-- 根据 房间名 来获取 房间ID, 需 区域ID(areaid)
-- ---------------------------------------------------------------
function pkuxkx.GetRoomID(areaid, name)
    return MapHelp.GetRoomID(areaid, name)
end
-- ---------------------------------------------------------------
-- 获取 房间集合 -- 
-- 注意!!! 不同于 ppopkc.getRoomId只获得单一房间id, 在多房间下返回nil, 该方法会返回所有同名房间集合
-- 参数 s1 (区域中文名)
-- 参数 s2 (房间中文名)
-- ---------------------------------------------------------------
function MapHelp.getRooms(areaname, roomname)
    return ppopkc.getRoomList(areaname, roomname)
end
-- ---------------------------------------------------------------
-- 获取 房间集合 -- 
-- 注意!!! 不同于 ppopkc.getRoomId只获得单一房间id, 在多房间下返回nil, 该方法会返回所有同名房间集合
-- 参数 s1 (区域中文名)
-- 参数 s2 (房间中文名)
-- ---------------------------------------------------------------
function pkuxkx.getRooms(s1, s2)
    return MapHelp.getRooms(s1, s2)
end
-- ---------------------------------------------------------------
-- 获取 某一区域的房间集合
-- ---------------------------------------------------------------
function MapHelp.getRoomsByArea(area)
    local areaid = tonumber(area);
    if areaid == nil then
        areaid = MapHelp.getAreaId(area)
    end
    local collection = {}
    if pkuxkx.room == nil then
        MapHelp.getAllRoom()
    end
    for i = 1, #pkuxkx.room do
        if pkuxkx.room[i].area == areaid then
            table.insert(collection, pkuxkx.room[i])
        end
    end
    return collection
end
-- ---------------------------------------------------------------
-- 获取 某一区域的房间集合
-- ---------------------------------------------------------------
function pkuxkx.getRoomsByArea(area)
    return MapHelp.getRoomsByArea(area)
end
-- ---------------------------------------------------------------
-- 获取某一区域的所有房间出口集合
-- ---------------------------------------------------------------
function MapHelp.getDirectionsByArea(area)
    local roomcollection = MapHelp.getRoomsByArea(area)
    if pkuxkx.direction == nil then
        MapHelp.getAllDirection()
    end
    local directioncollection = {}
    for i = 1, #pkuxkx.direction do
        for j = 1, #roomcollection do
            if pkuxkx.direction[i].room1 == roomcollection[j].id then
                table.insert(directioncollection, pkuxkx.direction[i])
            end
        end
    end
    return directioncollection
end
-- -- ---------------------------------------------------------------
-- -- 根据一个地址(如: 华山镇岳宫),获取一个准确的目标定位,
-- -- 即 quest.area = "华山", quest.location = "镇岳宫",
-- -- 并返回该地区是否能够正确到达
-- -- ---------------------------------------------------------------
function MapHelp.getAddress(addr)
    if addr == nil or string.len(addr) < 2 then
        cecho("<purple>目标地址异常, Ex: " .. addr)
        return
    end
    if pkuxkx.area == nil then
        MapHelp.getAllArea()
    end
    local city = nil
    local name = nil
    for i = 1, #pkuxkx.area do
        -- 先通过 name查找
        local area_name = pkuxkx.area[i].name
        local st_, st_, st_city, st_name = string.find(addr, "^(" .. area_name .. ")(.+)$")
        -- 检查是否存在这个地址
        if st_city then
            local st_rooms = pkuxkx.getRooms(st_city, st_name)
            if st_rooms then
                city = st_city
                name = st_name
            end
        end

        if city == nil then
            -- 再通过 contain字段 查找
            local containstr = pkuxkx.area[i].contain
            containstr = containstr or pkuxkx.area[i].name
            if string.find(containstr, "|") then
                local contains = string.split(containstr, "|")
                for j = 1, #contains do
                    if string.find then
                        local _, _, j_city, j_name = string.find(addr, "^(" .. contains[j] .. ")(.+)$")
                        -- 检查是否存在这个地址
                        if j_city then
                            local j_room = pkuxkx.getRooms(j_city, j_name)
                            if j_room then
                                city = j_city
                                name = j_name
                            end
                        end
                    end
                end
            else
                local _, _, t_city, t_name = string.find(addr, "^(" .. containstr .. ")(.+)$")
                -- 检查是否存在这个地址
                if t_city then
                    local t_room = pkuxkx.getRooms(t_city, t_name)
                    if t_room then
                        city = t_city
                        name = t_name
                    end
                end
            end
        end
    end
    if city then
        return city, name
    else
        return nil
    end
end
-- ---------------------------------------------------------------
-- 根据一个地址(如: 华山镇岳宫),获取一个准确的目标定位, 
-- 即 quest.area = "华山", quest.location = "镇岳宫", 
-- 并返回该地区是否能够正确到达
-- ---------------------------------------------------------------
function pkuxkx.getAddress(addr)
    return MapHelp.getAddress(addr)
end

-- ---------------------------------------------------------------
-- 生成两点间最短路径
-- PS. 因有复杂路径的存在, 故不直接返回字符串path(如 e;s;w;n)
-- 返回格式为table格式的 path集
-- ---------------------------------------------------------------
function pkuxkx.GetPath(from, to)
    -- table.insert(pkuxkx.openrooms,from)
    pkuxkx.path = {}
    -- 获得的路径
    pkuxkx.path.route = {}
    pkuxkx.path.initialroom = from
    pkuxkx.path.targetroom = to
    pkuxkx.path.openrooms = {}
    pkuxkx.path.closerooms = {}
    pkuxkx.path.targetnode = {}
    -- 将 起始点放入封闭表
    local node = {}
    node.id = from
    node.parent = nil
    table.insert(pkuxkx.path.openrooms, node)
    table.insert(pkuxkx.path.closerooms, node)
    local nodes_route = _getNodeRouteHandle()
    return _generatePath(nodes_route)
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
    return path_table
end
-- ---------------------------------------------------------------
-- 获取两个临近点之间的到达方式, 返回 direction表的 单行row实体类型
-- ---------------------------------------------------------------
function _getSingleDirection(from, to)
    for i = 1, #pkuxkx.direction do
        if pkuxkx.direction[i].room1 == from and pkuxkx.direction[i].room2 == to then
            return pkuxkx.direction[i]
        end
    end
end

-- ---------------------------------------------------------------
-- 获得 各个节点间的跳转 route
-- 基于 BFS 的寻路算法.
-- ---------------------------------------------------------------
function _getNodeRouteHandle()
    local nodes_route = {}
    local pass = false
    local currentnode = nil
    local nearrooms = {}
    local node = {}
    local tstart = os.clock()
    while (table.len(pkuxkx.path.openrooms) > 0 and pass == false) do
        currentnode = pkuxkx.path.openrooms[1]
        table.remove(pkuxkx.path.openrooms, 1)
        -- table.insert(pkuxkx.path.closerooms,currentnode)
        nearrooms = pkuxkx.GetNearRooms(currentnode.id)
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
        print("寻路失败, 无简单路径!")
        return nil
    else
        local node = pkuxkx.path.targetnode
        while node and node.parent do
            print(node.id .. " -> " .. node.parent)
            table.insert(nodes_route, node.id)
            node = _GetParentNode(node)
        end
    end
    -- 补上起始节点
    if #nodes_route > 0 then
        table.insert(nodes_route, pkuxkx.path.initialroom)
    end
    local tdone = os.clock()
    print("寻找最近节点耗时: "..(tdone - tstart))
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
-- 获取临近房间
-- arg: roomid 房间编号id
-- ---------------------------------------------------------------
function pkuxkx.GetNearRooms(roomid, direct, bycar)
    local collection = {}
    direct = direct or false
    bycar = bycar or false
    if pkuxkx.direction == nil or #pkuxkx.direction < 2 then
        MapHelp.getAllDirection()
    end
    for i = 1, #pkuxkx.direction do
        if direct == true then
            if pkuxkx.direction[i].room1 == roomid and pkuxkx.direction[i].go and string.len(pkuxkx.direction[i].go) > 0 and (pkuxkx.direction[i].special == nil or string.len(pkuxkx.direction[i].special) == 0) then
                table.insert(collection, pkuxkx.direction[i].room2)
            end
        else
            if pkuxkx.direction[i].room1 == roomid then
                table.insert(collection, pkuxkx.direction[i].room2)
            end
        end
    end
    return collection
end

-- ---------------------------------------------------------------
-- 生成路径测试
-- ---------------------------------------------------------------
function path_test(from, to)
    local starttime = os.clock()
    pathtable = pkuxkx.GetPath(from, to)
    local donetime = os.clock()
    print("GetPath耗时: "..(donetime - starttime))
    if pathtable == nil then
        return "无法找到该路径"
    end
    g_path = ""
    for i = 1, #pathtable do
        if pathtable[i].go then
            g_path = g_path .. pathtable[i].go .. ";"
        else
            g_path = g_path .. pathtable[i].special .. ";"
        end
    end
    -- if string.len(g_path) > 100 then
    --     local pt = string.split(g_path,";")
    --     for i=1,#pt do
    --         print(pt[i])
    --     end
    -- else
        print("路径为: "..g_path)
    -- end
end















-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
----- 旧版部分   ------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
function MapHelp.getLookCity(path)
    if path == "meizhuang/plum_maze" then
        return nil
    end
    local place = MapHelp.getPlace(path)
    for k, v in pairs(place) do
        if (v == "zhiye" or v == "entry") then
            return nil
        end
        if v ~= "entry" then
            city = lookCitys[v]
        end
        if city then
            return city
        end
    end
end

function MapHelp.getPlace(path)
    local place = {}
    local i = 1
    while true do
        local n = string.find(path, "/", i)
        if n then
            table.insert(place, 1, string.sub(path, i, n - 1))
            i = n + 1
        else
            break
        end
    end
    return place
end

function MapHelp.getCityRooms(city)
    local rooms = {}
    local isCityFw = city and string.find(city, "^%l+$")
    for id, room in pairs(Mushmap.rooms) do
        local lookCity = isCityFw and MapHelp.getFirstWord(getLookCity(room.id)) or MapHelp.getLookCity(room.id)
        local taskCity = isCityFw and MapHelp.getFirstWord(getCity(room.id)) or MapHelp.getCity(room.id)
        if (city == lookCity) or (city == taskCity) or (room.outdoor and room.outdoor == city) then
            table.insert(rooms, id)
        end
    end
    return rooms
end

-- ---------------------------------------------------------------
-- 获取所属城市/区域名称
-- ---------------------------------------------------------------
function MapHelp.getCity(path)
    local place = MapHelp.getPlace(path)
    for k, v in pairs(place) do
        city = citys[v]
        if city then
            return city
        end
    end
    return ""
end

function MapHelp.getAroundRooms(name, city, length, type)
    local rooms = MapHelp.getRooms(name, city, type)
    local allRooms = {}
    for _, id in pairs(rooms) do
        local aroundRooms = Mushmap:getAroundRooms(id, length)
        for _, aroundRoom in pairs(aroundRooms) do
            if not Mushmap.rooms[aroundRoom].nofind then
                allRooms[aroundRoom] = true
            end
        end
    end
    return allRooms
end

function MapHelp.getNearRoom(from, to)
    if type(from) == "table" then
        from = from[1]
    end
    if countTab(to) == 1 then
        return to[1]
    end

    local parents, distances = Mushmap:lookPath(from)
    local length, p

    for k, v in pairs(to) do
        if distances[v] and (length == nil or length > distances[v]) then
            length = distances[v]
            p = k
        end
    end

    return to[p], p

end


-- Init Rooms
-- Mushmap = SjMap:new()
