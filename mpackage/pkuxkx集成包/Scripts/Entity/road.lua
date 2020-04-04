-------------------------------------------------
--         Put your Lua functions here.        --
--                                             --
-- Note that you can also use external Scripts --
-------------------------------------------------

road = {
    sour = "当铺_襄阳城",
    city = "襄阳城_襄阳城",
    dest = "襄阳城_当铺",
    where = "襄阳城当铺",
    test = {},
    detail = {},
    act = nil,
    i = 0,
    temp = 0,
    find = 0,
    wipe_id = nil,
    wipe_who = nil,
    wipe_con = nil,
    resume = nil,
    wait = 0.18,
    steps = 12,
    locate_finish = 0,
    cmd = nil,
    cmd_save = nil,
    maze = nil
}

if SJConfig.Debug then
    road.wait = 0.25
    road.steps = 10
end
