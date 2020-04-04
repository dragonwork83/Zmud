package.path = package.path .. ";..\\?.lua;"

pkuxkx = pkuxkx or {}

require "skill"

job = {}
require("Component/common4test")
require("Component/tprint")
require("Job/job")
require("Job/murong")
require("Map/MapHelp")
-- require("Map/gps")
require("Map/SpecialRoomHandle")
require("Test/room_text")
require("Test/direction_text")


pkuxkx.direction = FZ.Direction


print(" -- Debug环境 -- ")
-- tprint(pkuxkx.GetNearRooms(2110))
-- local t1 = {}
-- t1["id"] = 2116
-- t1["parent"] = 2110
-- local t2 = {}
-- t2["id"] = 2111
-- t2["parent"] = 2110
-- local t3 = {}
-- t3["id"] = 2104
-- t3["parent"] = 2110
-- table.insert(pkuxkx.openrooms, t1)
-- table.insert(pkuxkx.openrooms, t2)
-- print(_isInTable(pkuxkx.openrooms, t1))
-- print(_isInTable(pkuxkx.openrooms, t2))
-- print(_isInTable(pkuxkx.openrooms, t3))
-- pathtable = pkuxkx.GetPath(2110, 4267)
-- g_path = ""
-- for i = 1, #pathtable do
--     g_path = g_path .. pathtable[i].go .. ";"
-- end
-- print(g_path)

-- function tts(str)
--     print(str)
-- end

-- local thisevent = tts("xxxxaaaas")
-- common.eventHandle(thisevent)

local cmd = "!rest;east;north"
local cmd1 = string.sub(cmd,0,string.find(cmd,"!rest"))
cmd1 = string.replace(cmd1,"!","")
print(cmd1)
cmd2 = string.sub(cmd,string.find(cmd,"!rest") + 5,cmd:len())
print(cmd2)

local xxxx = {
    22,
    33
}
if table.contain(xxxx,33) then
    print("aaaaa")
end


print(" -- 运行完成 -- ")