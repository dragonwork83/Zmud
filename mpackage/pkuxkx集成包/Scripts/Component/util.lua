-- ---------------------------------------------------------------
-- 转换中文数字 为 罗马数字
-- ---------------------------------------------------------------
function trans(num)
	if not num then
	  return 0
	end
	local _, _, wan, other = string.find(num, "^(.-)万(.*)$")
	local result = 0
	if wan then
	  result = result + trans0(wan) * 10000
	  num = other
	end
	result = result + trans0(num)
	return result
  end
-- ---------------------------------------------------------------
-- 转换中文数字 为 罗马数字 -- 具体实现
-- ---------------------------------------------------------------
  function trans0(num)
	num = string.gsub(num, "^十(.*)$", "一十%1")
	num = string.gsub(num, "零十", "一十")
	num = string.gsub(num, "零", "")
	local result = 0
	local numbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九"}
	for k, v in pairs(numbers) do
	  num = string.gsub(num, v, k)
	end
	local units = {["0|"] = "十", ["00|"] = "百", ["000|"] = "千"}
	for k, v in pairs(units) do
	  num = string.gsub(num, v, k)
	end
	for v in string.gmatch(num, "(%d+)") do
	  result = result + v
	end
	return result
  end



log = {}
function getLogLevel()
	local _level = log_level or GetVariable("log_level") or tonumber(getInit():GetVariable("log_level")) or DEFAULT_LOG_LEVEL
	return tonumber(_level)
end

function log.write(file, level, color, ...)
	local msg = ""
	for _, v in pairs({...}) do
		msg = msg .. tostring(v) .. " "
	end
	msg = level .. " : " .. msg
	local date = os.date("%y/%m/%d %X")
	local logMsg = date .. " : " .. GetInfo(2) .. " ： " .. msg .. "\n"
	print(date .. " : " .. msg)
	cap(date .. " : " .. msg, nil, color)
	writeFile(GetInfo(57) .. "logs/" .. file, logMsg, true)
end

function log.debug(...)
	if getLogLevel() <= LEVEL_DEBUG then
		log.write("debug.log", "debug", "silver", ...)
	end
end

function log.info(...)
	if getLogLevel() <= LEVEL_INFO then
		log.write("info.log", "info", nil, ...)
	end
end

function log.warn(...)
	if getLogLevel() <= LEVEL_WARN then
		log.write("warn.log", "warn", "lime", ...)
	end
end

function log.error(...)
	if getLogLevel() <= LEVEL_ERROR then
		log.write("error.log", "error", "red", ...)
	end
end

function readFile(path)
	local f = io.open(path, "r")
	if not f then
		return false
	else
		local content = f:read("*all")
		f:close()
		return content
	end
end

function writeFile(path, msg, append)
	local type = append and "a" or "w"
	local f = io.open(path, type)
	f:write(msg)
	f:close()
end
