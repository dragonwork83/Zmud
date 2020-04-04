package.path = package.path .. ";..\\?.lua;"

require "skill"

job = {}
require("Component/common")
require("Component/tprint")
require("Job/job")
require("Job/murong")
require("Test/room_text")
require("Test/direction_text")

pkuxkx = pkuxkx or {}

pkuxkx.openrooms = {}
pkuxkx.closerooms = {}

function pkuxkx.GetPath(from, to)
    -- table.insert(pkuxkx.openrooms,from)
    pkuxkx.path = {}
    pkuxkx.path.currentroom = from
    pkuxkx.path.targetroom = to
    pkuxkx.path.openrooms = {}
    pkuxkx.path.closerooms = {}
    -- 将 起始点放入封闭表
    local node = {}
    node.id = from
    node.parent = ""
    table.insert(pkuxkx.path.closerooms, node)
    _getPathHandle(from,to)
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

function _getPathHandle(from, to)
    local nearrooms = pkuxkx.GetNearRooms(from)
    local added = false
    for i = 1, #nearrooms do
        local node = {}
        node["id"] = nearrooms[i]
        node["parent"] = from
        if _isInTable(pkuxkx.path.openrooms, node) == false and _isInTable(pkuxkx.path.closerooms, node) == false then
            -- 将该节点加入 开放房间名单
            table.insert(pkuxkx.path.openrooms, node)
            added = true
        end
    end
    -- 如果该节点无可继续下去的新节点, 则从开放房间中移除该节点,并且将其添入关闭房间列表中
    if added == false then
        for i=1,#pkuxkx.path.openrooms do
            if pkuxkx.path.openrooms[i].id == from then
                table.insert(pkuxkx.path.closerooms,pkuxkx.path.openrooms[i])
                table.remove(pkuxkx.path.openrooms,i)
            end
        end
    end
    _after_getPathHandle()
end
-- ---------------------------------------------------------------
-- 1. 判断开放列表是否已经空了，如果没有说明在达到结束点前已经找完了所有可能的路径点，寻路失败，算法结束；否则继续。
-- 2. 从开放列表拿出一个F值最小的点，作为寻路路径的下一步。
-- 3. 判断该点是否为结束点，如果是，则寻路成功，算法结束；否则继续。
-- 4. 将该点设为当前点P，跳回步骤c。
-- ---------------------------------------------------------------
function _after_getPathHandle()
    if table.len(pkuxkx.path.openrooms) == 0 then
        print("寻路失败, 无简单路径!")
    end
    local node = pkuxkx.path.openrooms[#pkuxkx.path.openrooms]
    if node.id == pkuxkx.path.targetroom then
        return print("寻路结束!找到路径")
    end
    _getPathHandle(node.id, pkuxkx.path.targetroom)
end
-- ---------------------------------------------------------------
-- 获取临近房间
-- arg: roomid 房间编号id
-- ---------------------------------------------------------------
function pkuxkx.GetNearRooms(roomid)
    local collection = {}
    for i = 1, #FZ.Direction do
        if FZ.Direction[i].room1 == roomid and FZ.Direction[i].go and string.len(FZ.Direction[i].go) > 0 then
            table.insert(collection, FZ.Direction[i].room2)
        end
    end
    return collection
end


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

pkuxkx.GetPath(2110, 2119)