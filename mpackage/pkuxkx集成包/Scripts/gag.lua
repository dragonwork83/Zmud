--
-- gag.lua
--
-- ----------------------------------------------------------
-- 用于处理 一些垃圾信息, 避免垃圾信息刷屏,而找不到关键信息
-- 临时隐藏无效的垃圾的文字信息的触发器

-- ----------------------------------------------------------
--
--[[

eg.

require "gag"


--]]

gag = { }

function gag.Activate()
    enableTrigger("Gag")
end

function gag.Deactivate()
    disableTrigger("Gag")
end