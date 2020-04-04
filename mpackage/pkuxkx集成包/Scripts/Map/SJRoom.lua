SjRoom = { ways = { }, lengths = { }, nolooks = { } }

function SjRoom:new(room)
    local room = room or { }
    setmetatable(room, self)
    self.__index = self
    return room
end

function SjRoom:length(route)
    local length = self.lengths[route] or 1
    local isStr = length and type(length) == "string" or false
    if isStr then
        return loadstring(length)()
    else
        return length
    end
end