--
-- funcHook.lua
--
-- ----------------------------------------------------------
-- 实体类集合
-- for checkhalt, checkbusy,checkbei等函数传参调用其它方法时,带该方法的参数使用
-- 其中 funchHook.func 为方法引用, funcHook.arg1 ~ funcHook.arg4 为所引用方法所需的参数, 最多可带四个参数
-- ----------------------------------------------------------
--
--[[


eg.

require "Entity"

function tes(arg1, arg2)
    print("arg1:" .. arg1)
--    print("arg2:" .. arg2)
end

function testhaltok()
    local funcE = funcHook:new()
    funcE.func = tes
    funcE.arg1 = "参数1测试"
    funcE.arg2 = nil
    check_halt(funcE)
end


--]]


local funcHook = {
    func = test,
    arg1 = nil,
    arg2 = nil,
    arg3 = nil,
    arg4 = nil
}

function funcHook:new()
    --  创建新的表作为实例的对象
    local self = { }
    -- 设置class为对象元表的__index
    setmetatable(self, { __index = funcHook })
    -- 返回该新表
    return self
end

-- function funcHook:func()
-- end

return funcHook
