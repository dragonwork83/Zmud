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
-- function MapHelp.go(arg1, arg2)
-- end
-- ---------------------------------------------------------------
-- 包装 go 方法, 含后续处理script, 只允许有准确的房间名称/房间ID时使用
-- ---------------------------------------------------------------
-- function MapHelp.gotodo(room, script)
--     MapHelp.gotodoExtend(room, nil, script)
-- end
-- ---------------------------------------------------------------
-- 包装 go 方法, 含后续处理script, 只允许有准确的房间名称/房间ID时使用
-- ---------------------------------------------------------------
-- function MapHelp.gotodoExtend(area, room, script)
-- end
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
    if string.contain(address, "大理城中") then
        fix = string.replace(address, "大理城中", "大理城")
    end
    return fix
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
    pkuxkx.roombranch = {}
    local cursor = sqlconn:execute("select * from room ")
    row = cursor:fetch({}, "a")
    while row do
        -- print(string.format("Id: %s, Name: %s", row.id, row.name))
        table.insert(pkuxkx.room, row)
        if pkuxkx.roombranch[row.name] == nil then
            pkuxkx.roombranch[row.name] = {}
        end
        table.insert(pkuxkx.roombranch[row.name], row)
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
    local cursor = sqlconn:execute("select room1,room2,go,special,money,time,wugong,menpai,gender from direction where room2>0 and assume<>1")
    row = cursor:fetch({}, "a")
    while row do
        -- print(string.format("Id: %s, Name: %s", row.id, row.name))
        table.insert(pkuxkx.direction, row)
        -- 写入分表, 用于分库用.优化查询,避免遍历全direction表
        pkuxkx.directionbranch[row.room1] = pkuxkx.directionbranch[row.room1] or {}
        table.insert(pkuxkx.directionbranch[row.room1], row)
        row = cursor:fetch({}, "a")
    end
    -- 同时添加 guche表里的内容至direction, 并设置direction.go = "!zuoche name"
    cursor = sqlconn:execute("select room1,room2,money,name,distance from guche")
    row = cursor:fetch({}, "a")
    local entity = {}
    while row do
        entity = {
            room1 = row.room1,
            room2 = row.room2,
            special = "!zuoche " .. row.name,
            money = row.money,
        }
        table.insert(pkuxkx.direction, entity)
        -- 写入分表, 用于分库用.优化查询,避免遍历全direction表
        pkuxkx.directionbranch[entity.room1] = pkuxkx.directionbranch[entity.room1] or {}
        table.insert(pkuxkx.directionbranch[entity.room1], entity)
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
-- 根据 areaID 来得到区域的名称
-- ---------------------------------------------------------------
function MapHelp.getAreaName(areaid)
    local areaname = nil
    if pkuxkx.area == nil then
        MapHelp.getAllArea()
    end
    if areaid == 0 then
        return "未知区域"
    end
    for i = 1, #pkuxkx.area do
        if pkuxkx.area[i].id == areaid then
            areaname = pkuxkx.area[i].name
        end
    end
    return areaname
end
-- ---------------------------------------------------------------
-- 获取该区域的中心点/核心房间的房间id, roomID
-- ---------------------------------------------------------------
function MapHelp.getAreaCenter(areaid)
    local roomid = nil
    if pkuxkx.area == nil then
        MapHelp.getAllArea()
    end
    for i = 1, #pkuxkx.area do
        if pkuxkx.area[i].id == areaid then
            roomid = pkuxkx.area[i].baseroom
        end
    end
    return roomid
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
-- 根据 房间名 来获取 房间ID 
-- ---------------------------------------------------------------
function MapHelp.GetRoomID(s1, s2, display)
    if display == nil then
        display = true
    end
    if pkuxkx.room == nil then
        MapHelp.getAllRoom()
    end
    local roomid = nil
    local rooms = {}
    if (s2 == nil) then
        rooms = MapHelp.getRoomsByName(s1)
    else
        -- 说明s1为区域名, s2为房间名
        local aid = nil
        if (string.match(s1, "^%d+$") ~= nil) then
            -- 区域为数字ID的情况
            aid = s1
        else
            -- 区域为区域名的情况
            aid = MapHelp.getAreaId(s1)
            if (aid == nil) then
                echo("\n找不到该区域名.")
                return nil
            end
        end
        local area_rooms = MapHelp.getRoomsByArea(aid)
        for i = 1, #area_rooms do
            if area_rooms[i].name == s2 then
                table.insert(rooms, area_rooms[i])
            end
        end
    end

    if (rooms == nil) or table.len(rooms) == 0 then
        echo("\n找不到这个地名。")
    elseif table.len(rooms) == 1 then
        return rooms[1].id
    else
        if display == true then
            echo("\n有多个地点叫这个名字，如下：\n")
            for i = 1, #rooms do
                echo(MapHelp.getAreaName(rooms[i].area) .. " " .. rooms[i].name .. " id:" .. rooms[i].id .. "\n")
            end
        end
    end

    return nil
end
-- ---------------------------------------------------------------
-- -- 根据 房间名 来获取 房间ID (不显示重复可选择ID)
-- ---------------------------------------------------------------
function MapHelp.GetRoomID_NoDisplay(s1, s2)
    return MapHelp.GetRoomID(s1, s2, false)
end
-- ---------------------------------------------------------------
-- 获取 房间集合 -- 
-- 注意!!! 不同于 ppopkc.getRoomId只获得单一房间id, 在多房间下返回nil, 该方法会返回所有同名房间集合
-- 参数 s1 (区域中文名)
-- 参数 s2 (房间中文名)
-- ---------------------------------------------------------------
function MapHelp.getRooms(areaname, roomname)
    local rooms = {}
    if pkuxkx.room == nil then
        MapHelp.getAllRoom()
    end
    local areaid = MapHelp.getAreaId(areaname)
    if pkuxkx.roombranch[roomname] == nil or table.len(pkuxkx.roombranch[roomname]) == 0 then
        return rooms
    end
    for i = 1, #pkuxkx.roombranch[roomname] do
        if pkuxkx.roombranch[roomname][i].area == areaid then
            table.insert(rooms, pkuxkx.roombranch[roomname][i])
        end
    end
    return rooms
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
-- 根据房间名 获取同名房间的所有集合
-- ---------------------------------------------------------------
function MapHelp.getRoomsByName(roomname)
    if pkuxkx.room == nil then
        MapHelp.getAllRoom()
    end
    return pkuxkx.roombranch[roomname]
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
    -- 针对特殊,拆分产生异常的进行处理
    if addr == "洛阳城北桥" then
        -- 下面会拆分成 "洛阳城" "北桥"
        return "洛阳", "城北桥"
    end
    -- 以下为默认常规拆分
    if pkuxkx.area == nil then
        MapHelp.getAllArea()
    end
    local city = nil
    local name = nil
    for i = 1, #pkuxkx.area do
        -- 先通过 contain字段 查找
        local containstr = pkuxkx.area[i].contain
        containstr = containstr or pkuxkx.area[i].name
        if string.find(containstr, "|") then
            local contains = string.split(containstr, "|")
            for j = 1, #contains do
                if string.find then
                    local _, _, j_city, j_name = string.find(addr, "^(" .. contains[j] .. ")(.+)$")
                    -- 检查是否存在这个地址
                    if j_city then
                        local j_room = MapHelp.getRooms(j_city, j_name)
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
                local t_room = MapHelp.getRooms(t_city, t_name)
                if t_room then
                    city = t_city
                    name = t_name
                end
            end
        end

        if city == nil then
            -- 再通过 name查找
            local area_name = pkuxkx.area[i].name
            local st_, st_, st_city, st_name = string.find(addr, "^(" .. area_name .. ")(.+)$")
            -- 检查是否存在这个地址
            if st_city then
                local st_rooms = MapHelp.getRooms(st_city, st_name)
                if st_rooms then
                    city = st_city
                    name = st_name
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
