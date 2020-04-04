-- ---------------------------------------------------------------
-- 缓存操作相关类
-- ---------------------------------------------------------------
Cache = { }
local DEFAUTL_CACHE_TIME = 10

function Cache:new(size, time)
    time = time or DEFAUTL_CACHE_TIME
    local cache = { size = size, time = time }
    setmetatable(cache, self)
    self.__index = self
    return cache
end

function Cache:get(key)
    local value
    for k, v in pairs(self) do
        if type(k) == "number" and v.key == key and os.time() - v.time <= self.time then
            -- log.debug("Cache 命中，key = " .. v.key)
            value = v.value
            table.remove(self, k)
            table.insert(self, 1, v)
            break
        end
    end
    if not value then
        -- log.debug("Cache 未命中，key = " .. key)
    end
    return value
end

function Cache:add(key, value)
    local v = { }
    v.key = key
    v.value = value
    v.time = os.time()
    table.insert(self, 1, v)
    if table.getn(self) > self.size then
        table.remove(self, self.size + 1)
    end
end