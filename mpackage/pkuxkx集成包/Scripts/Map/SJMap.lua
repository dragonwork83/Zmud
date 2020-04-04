-- SjMap class
SjMap = {count = 0}
local cache = Cache:new(2)

function SjMap:new(Mushmap)
    local Mushmap = Mushmap or {rooms = {}}
    setmetatable(Mushmap, self)
    self.__index = self
    return Mushmap
end

function SjMap:addRoom(room)
    self.rooms[room.id] = SjRoom:new(room)
    self.count = self.count + 1
end

function SjMap:room(id)
    return self.rooms[id]
end

function SjMap:getMinRoom(pending)
    local processRoomId
    local minDistance
    for roomId, length in pairs(pending) do
        if minDistance == nil or length < minDistance then
            minDistance = length
            processRoomId = roomId
        end
    end
    if processRoomId then
        pending[processRoomId] = nil
    end
    return processRoomId
end

function SjMap:process(red, distances, pending, parents, from)
    red[from] = true
    local fromRoom = self:room(from)
    for route, to in pairs(fromRoom.ways) do
        local routeLength = fromRoom:length(route)
        if routeLength then
            local length = distances[from] + routeLength
            local distance = distances[to]
            if distance == nil or length < distance then
                distances[to] = length
                if red[to] == nil then
                    pending[to] = length
                end
                parents[to] = {parent = from, route = route}
            end
        end
    end
end

function SjMap:init(red, distances, pending, parents, from)
    red[from] = true
    distances[from] = 0
    parents[from] = {parent = from, route = ""}
    self:process(red, distances, pending, parents, from)
end

function SjMap:lookPath(from)
    local value = cache:get(from)
    if not value then
        local red = {}
        local pending = {}
        distances = {}
        parents = {}
        self:init(red, distances, pending, parents, from)
        for i = 0, self.count do
            local processRoomId = self:getMinRoom(pending)
            if processRoomId then
                self:process(red, distances, pending, parents, processRoomId)
            else
                break
            end
        end
        -- cache last parents and distances
        parentsCache = {}
        distancesCache = {}
        value = {}
        value.parents = parents
        value.distances = distances
        cache:add(from, value)
    end
    return value.parents, value.distances
end

function SjMap:getAroundRooms(path, length)
    if length == 0 or length == nil then
        return {path}
    end
    local parents, distances = self:lookPath(path)
    local rooms = {}
    for k, v in pairs(distances) do
        if string.find(path, "mr/") and string.find(k, "mr/") and v <= length then
            table.insert(rooms, k)
        end
        if string.find(path, "yanziwu/") and string.find(k, "yanziwu/") and v <= length then
            table.insert(rooms, k)
        end
        if string.find(path, "mtl/") and string.find(k, "mtl/") and v <= length then
            table.insert(rooms, k)
        end

        -- SJConfig.DebugShow("SJMap length: "..length.."  ||| k: "..k.." ||| v: "..v)
        if
            not string.find(path, "mr/") and not string.find(path, "yanziwu/") and not string.find(path, "mtl/") and
                v <= tonumber(length)
         then
            table.insert(rooms, k)
        end
    end
    return rooms
end

function SjMap:getPath(from, to, try)
    -- TraceOut("SjMap:getPath： from = " .. from .. " ，to = " .. to)
    local parents, distances = self:lookPath(from)
    local length = distances[to]
    local path = {""}
    local room = to
    repeat
        local parentInfo = parents[room]
        local fromRoom = Mushmap.rooms[from]
        local toRoom = Mushmap.rooms[to]
        if parentInfo == nil then
            if not try then
                if not to or not from then
                    SJConfig.DebugShow("异常：SjMap:getPath - 缺少 from 或者 to ")
                else
                    SJConfig.DebugShow("从：" .. from .. " 至：" .. to .. "，无法到达。")
                end
            end
            return false
        end
        local parent = parentInfo.parent
        local route = parentInfo.route
        local parentRoom = Mushmap.rooms[parent]
        local precmds = parentRoom.precmds
        local precmd = precmds and precmds[route]
        local postcmds = parentRoom.postcmds
        local postcmd = postcmds and postcmds[route]
        local blocks = parentRoom.blocks
        local block = blocks and blocks[route]
        local lengths = parentRoom.lengths
        local len = lengths and lengths[route]
        if postcmd then
            table.insert(path, 1, ";")
            table.insert(path, 1, postcmd)
        end
        table.insert(path, 1, ";")
        table.insert(path, 1, route)
        if precmd then
            table.insert(path, 1, ";")
            table.insert(path, 1, precmd)
        end
        if block then
            for _, b in pairs(block) do
                local sameParty = b.party and b.party == score.party
                local cond = b.cond and b.cond()
                if not sameParty and not cond then
                    if hp.exp < b.exp then
                        return false
                    else
                        table.insert(path, 1, ";")
                        table.insert(path, 1, "#wipe " .. b.id)
                    end
                end
            end
        end
        if len then
            local isStr = len and type(len) == "string" or false
            if isStr then
                if not loadstring(len)() then
                    return false
                end
            end
        end
        room = parent
    until room == from
    table.insert(path, 1, ";")
    table.insert(path, 1, "halt")
    local p = table.concat(path)
    -- print("length="..length)
    return p, length
end

function SjMap:getPathWd(from, to, try)
    TraceOut("SjMap:getPath： from = " .. from .. " ，to = " .. to)
    local parents, distances = self:lookPath(from)
    local length = distances[to]
    local path = {""}
    local room = to
    local isPublic = true
    local backToMain = nil
    repeat
        local parentInfo = parents[room]
        local fromRoom = Mushmap.rooms[from]
        local toRoom = Mushmap.rooms[to]
        if parentInfo == nil then
            if not try then
            -- Note("从：" .. fromRoom .. " 至：" .. toRoom .. "，无法到达。")
            end
            return false
        end
        local parent = parentInfo.parent
        local route = parentInfo.route
        local parentRoom = Mushmap.rooms[parent]
        local precmds = parentRoom.precmds
        local precmd = precmds and precmds[route]
        local postcmds = parentRoom.postcmds
        local postcmd = postcmds and postcmds[route]
        local blocks = parentRoom.blocks
        local block = blocks and blocks[route]
        local lengths = parentRoom.lengths
        local len = lengths and lengths[route]
        if postcmd then
            table.insert(path, 1, ";")
            table.insert(path, 1, postcmd)
        end
        table.insert(path, 1, ";")
        table.insert(path, 1, route)
        if route == "#duCjiang" or route == "#duHhe" or route == "#backToMain" then
            backToMain = true
        end
        if precmd then
            table.insert(path, 1, ";")
            table.insert(path, 1, precmd)
        end

        -- ask npc 止步功能，added by playplay
        if job.name == "wudang" and killer_id ~= nil then
            tmp.wdScan = true
            table.insert(path, 1, ";")
            --			table.insert(path,1,"nkill "..killer_id)
            table.insert(path, 1, "ask " .. killer_id .. " about 撅起屁股，不要反抗！")
        end
        if job.name == "songxin2" and tmp.sxScan and sxjob.id and not sxid_noScan[sxjob.id] and sxjob.id ~= "wei shi" then
            tmp.sx2Scan = true
            table.insert(path, 1, ";")
            table.insert(path, 1, "ask " .. sxjob.id .. " about 你有信！")
        end
        if job.name == "tdh" and tmp.askid ~= nil then
            tmp.tdhScan = true
            table.insert(path, 1, ";")
            table.insert(path, 1, "ask " .. tmp.askid .. " about 天地会")
        end
        if job.name == "songxin" and tmp.sxScan and sxjob.id and not sxid_noScan[sxjob.id] and sxjob.id ~= "wei shi" then
            tmp.sx1Scan = true
            table.insert(path, 1, ";")
            table.insert(path, 1, "ask " .. sxjob.id .. " about 你有信！")
        end
        if job.name == "xueshan" and tmp.askid ~= nil then
            tmp.xsScan = true
            table.insert(path, 1, ";")
            table.insert(path, 1, "ask " .. tmp.askid .. " about 美女一起玩啊")
        end
        if
            (job.name == "songshan" or job.name == "gaibang" or (job.name == "clb" and job.progress == 3)) and
                tmp.askid ~= nil and
                tmp.askid ~= "wei shi" and
                tmp.askid ~= "qin bing"
         then
            tmp.Scan = true
            table.insert(path, 1, ";")
            table.insert(path, 1, "ask " .. tmp.askid .. " about 撅起屁股，不要反抗！")
        end
        if job.name == "clb" and job.progress and job.progress == 2 and job.clb2_id then
            table.insert(path, 1, ";")
            table.insert(path, 1, "xw " .. job.clb2_id)
        end
        if block then
            isPublic = false
            for _, b in pairs(block) do
                local sameParty = b.party and b.party == score.party
                local cond = b.cond and b.cond()
                if not sameParty and not cond then
                    if hp.exp < b.exp then
                        return false
                    else
                        table.insert(path, 1, ";")
                        table.insert(path, 1, "#wipe " .. b.id)
                    end
                end
            end
        end
        if len then
            local isStr = len and type(len) == "string" or false
            if isStr then
                isPublic = false
                if not loadstring(len)() then
                    return false
                end
            end
        end
        room = parent
    until room == from
    table.insert(path, 1, ";")
    table.insert(path, 1, "halt")

    --做clb2，在path的尾部加上xw, xw是xunwen的mud alias，不能直接用xunwen，因为mush里有xun alias --playplay
    if job.name == "clb" and job.progress and job.progress == 2 and job.clb2_id then
        table.insert(path, table.getn(path) + 1, ";xw " .. job.clb2_id)
    end
    --clb2任务，在回到中原地区找玩家时，在完成渡河后再进行xunwen。删除回到中原之前的path中的xunwen。 --playplay
    if job.name == "clb" and job.progress == 2 and job.clb2_id and backToMain then
        local w = table.getn(path) / 2
        for a = 1, w do
            for b = 1, a do
                if path[b] == "#duHhe" or path[b] == "#duCjiang" or path[b] == "#backToMain" then
                    break
                elseif path[b] == "xw " .. job.clb2_id then
                    table.remove(path, b)
                    local c = b - 1
                    if path[c] == ";" then
                        table.remove(path, c)
                    end
                end
            end
        end
    end
    --ask npc 止步功能，只保留最后几步中的ask，删除之前的没有必要的ask，-- playplay
    if
        job.name == "clb" and job.progress == 2 and job.clb2_id and not backToMain and table.getn(path) > 30 and
            not tmp.clb2XwFail
     then
        local w = table.getn(path) / 4
        for a = 1, w do
            if path[a] == "xw " .. job.clb2_id then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
    end
    if tmp.sx2Scan and sxjob.id and not tmp.searching then
        --    print("现在开始精简扫街path。")
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "songxin " .. sxjob.id or path[a] == "ask " .. sxjob.id .. " about 你有信！" then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
        tmp.sx2Scan = nil
    end
    if tmp.Scan and tmp.askid and not tmp.find then
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "ask " .. tmp.askid .. " about 撅起屁股，不要反抗！" then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
        tmp.Scan = nil
    end
    if tmp.wdScan and killer_id and not tmp.find then
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "ask " .. killer_id .. " about 撅起屁股，不要反抗！" then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
        tmp.wdScan = nil
    end
    if tmp.sx1Scan and sxjob.id and not tmp.searching then
        --    print("现在开始精简扫街path。")
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "ask " .. sxjob.id .. " about 你有信！" then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
        tmp.sx1Scan = nil
    end
    if tmp.tdhScan and tmp.askid and not tmp.find then
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "ask " .. tmp.askid .. " about 天地会" then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
        tmp.tdhScan = nil
    end
    if tmp.xsScan and tmp.askid and not tmp.find then
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "ask " .. tmp.askid .. " about 美女一起玩啊" then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            end
        end
        tmp.xsScan = nil
    end
    if killer_id ~= nil and tmp.wdScan and not tmp.searching then
        tmp.wdScan = nil
        local w = table.getn(path) / 2 - 6
        for a = 1, w do
            if path[a] == "nkill " .. killer_id then
                table.remove(path, a)
                local c = a - 1
                if path[c] == ";" then
                    table.remove(path, c)
                end
            --  break
            end
        end
    --    	end
    end
    local p = table.concat(path)
    return p, length, isPublic
end
