-- ---------------------------------------------------------------
-- 特殊房间处理
-- ---------------------------------------------------------------
function path_specialPlace()
    local special_path
    if location.room_relation == "西湖边↙｜白堤柳浪闻莺西湖边" then
        special_path = "sw"
    end
    if string.find(location.room, "字门") then
        special_path = "se;e;e;e"
    end
    if location.room_relation == "大草原｜大草原----大草原----大草原｜大草原大草原" then
        special_path = "w;w"
    end
    if location.room_relation == "大草原｜小路----大草原----大草原｜大草原大草原" then
        special_path = "w"
    end
    if location.room == "麻田地" then
        special_path = "nu;n;ne;e;e;e"
    end
    if location.room_relation == "九老洞九老洞" or location.room_relation == "不知道哪里九老洞 不知道哪里 九老洞" then
        special_path = "drop fire;leave;leave;leave;leave;leave;leave;out;ne;ed;ne;ed"
    end
    -- if location.room == '梅林' then
    --     quick_locate = 0
    --     exe('n;n;n')
    --     return mlOutt()
    -- end
    if location.room == "渔船" then
        special_path = "out;w;s;out;w;s;out;w;s"
    end
    if location.room == "小木筏" then
        special_path = toSldHua()
    end
    if location.room == "泉水中" then
        special_path = "tiao out;tiao out"
    end
    if location.area ~= "峨嵋山" and location.room == "水潭" then
        special_path = "pa up"
    end
    return special_path
end
-- ---------------------------------------------------------------
-- 路径consider..
-- ---------------------------------------------------------------
function path_consider(skip_stepto)
    SJConfig.DebugShow("路径生成开始...", 3)
    -- 是否跳转
    skip_stepto = skip_stepto or 0
    -- SJConfig.DebugShow("跳过路径Step为: "..skip_stepto, 3)
    -- 是否跳转至某一步... 如路径有5段, 默认从第1段开始,如想直接跳至从第3段开始,可传参 path_consider(2)
    locate_finish = 0
    -- if flag.find == 1 then
    --     return
    -- end
    local l_sour, l_dest, l_path, l_way
    local l_where = location.area .. location.room
    if roomMaze[l_where] then
        -- 有area和room完整定位的特殊房间集合走法
        if type(roomMaze[l_where]) == "function" then
            l_way = roomMaze[l_where]()
        else
            l_way = roomMaze[l_where]
        end
    else
        -- 无area之类的和一些特殊房间处理
        l_way = path_specialPlace()
    end
    if l_way then
        exe(l_way)
        quick_locate = 0
        local temp_loclarea = location.area
        if temp_loclarea == nil then
            temp_loclarea = ""
        end
        chats_locate("定位系统：地图系统此地点【" .. temp_loclarea .. location.room .. "】无简单路径，移动寻找确切定位点！", "red")
        return checkWait(goContinue, 0.3)
    end

    -- sour 起始位置相关集合  id表示房间英文名
    sour.rooms = {}
    -- dest 目标/终点位置相关集合
    dest.rooms = {}
    -- 验证sour.id的正确性
    if sour.id and Mushmap.rooms[sour.id].name ~= location.room then
        sour.id = nil
    end
    if not sour.id and road.id and Mushmap.rooms[road.id] and Mushmap.rooms[road.id].name == location.room then
        sour.id = road.id
    end
    if dest.id == nil then
        dest.rooms = MapHelp.getRooms(dest.room, dest.area)
    end
    if sour.id ~= nil then
        chats_locate("定位系统：从【" .. sour.id .. "】出发!")
    else
        sour.area = location.area
        sour.room = location.room
        sour.rooms = MapHelp.getRooms(sour.room, sour.area)
        chats_locate("定位系统：从【" .. sour.area .. sour.room .. "】出发!")
        if table.getn(sour.rooms) == 0 then
            if location.room_relation ~= "" then
                -- 这里可以尝试定位没有归属地的房间
                chats_locate("定位系统：没有归属地的房间加入了room_relative，【可以尝试定位没有归属地的房间】", "LimeGreen")
            end
            chats_locate("定位系统：地图系统无此地点【" .. location.area .. location.room .. "】资料，随机移动寻找确切定位点！", "red")
            exe('stand;leave;climb up;push flag')
            exe(location.dir)
            quick_locate = 0
            return checkWait(goContinue, 0.3)
        end
        -- if table.getn(sour.rooms)>1 and sour.id~='city/jiangbei' then
        if table.getn(sour.rooms) > 1 then
            chats_locate("定位系统：进入第一个同名房间判断【" .. sour.room .. "】了!", "LimeGreen")
            SJConfig.DebugShow("定位系统：进入第一个同名房间判断【" .. sour.room .. "】了!")
            if location.room_relation ~= "" then
                SJConfig.DebugShow("定位系统：房间关系为【" .. location.room_relation .. "】", "LimeGreen")
            end
            for i = 1, table.getn(sour.rooms) do
                if
                    (location.room_relation ~= "" and
                        Mushmap.rooms[sour.rooms[i]].room_relative == location.room_relation)
                 then
                    chats_locate("定位系统：尝试精确定位！", "LimeGreen")
                    sour.id = sour.rooms[i]
                    return check_halt(path_consider)
                    -- return go(road.act, dest.area, dest.room, sour.rooms[i])
                end
            end
            -- 根据房间里的NPC判断当前房间所属, 含corpse的判断
            for p in pairs(location.id) do
                local l_cnt = 0
                local l_id
                for k, v in pairs(sour.rooms) do
                    local l_corpse
                    if string.find(p, "的尸体") then
                        l_corpse = del_string(p, "的尸体")
                    else
                        l_corpse = p
                    end
                    if
                        Mushmap.rooms[v] and Mushmap.rooms[v].objs and
                            (Mushmap.rooms[v].objs[p] or Mushmap.rooms[v].objs[l_corpse])
                     then
                        l_cnt = l_cnt + 1
                        l_id = v
                    end
                end
                if l_cnt == 1 then
                    return go(road.act, dest.area, dest.room, l_id)
                end
            end
            -- 根据房间出口判断当前房间所属
            for p in pairs(location.exit) do
                local l_cnt = 0
                local l_id
                for i = 1, table.getn(sour.rooms) do
                    if
                        Mushmap.rooms[sour.rooms[i]] and Mushmap.rooms[sour.rooms[i]].ways and
                            Mushmap.rooms[sour.rooms[i]].ways[p]
                     then
                        l_cnt = l_cnt + 1
                        l_id = sour.rooms[i]
                    end
                end
                if l_cnt == 1 then
                    return go(road.act, dest.area, dest.room, l_id)
                end
            end
            --        end
            --        -- if table.getn(sour.rooms)>1 and sour.id~='city/jiangbei' then
            --        if table.getn(sour.rooms) > 1 then
            -------------------------------------------------------------------------
            if location.room_relation ~= "" then
                -- 触发器获取到房间相对关系字符串
                for i = 1, table.getn(sour.rooms) do
                    if
                        (location.room_relation ~= "" and
                            Mushmap.rooms[sour.rooms[i]].room_relative == location.room_relation)
                     then
                        -- return go(road.act,dest.area,dest.room,sour.rooms[i])
                        chats_locate("定位系统：精确定位房间id为：【" .. sour.rooms[i] .. "】", "LimeGreen")
                        sour.id = sour.rooms[i]
                        return check_halt(path_consider)
                    else
                        chats_locate("定位系统：地图系统此地点【" .. location.area .. location.room .. "】无法精确定位，随机移动！", "red")
                        -- exe("stand;leave")
                        exe(location.dir)
                        quick_locate = 0
                        return checkWait(goContinue, 0.3)
                    end
                end
            else
                chats_locate("定位系统：地图系统此地点【" .. location.area .. location.room .. "】存在不止一处，随机移动寻找确切定位点！", "red")
                -- exe("stand;leave")
                exe(location.dir)
                quick_locate = 0
                return checkWait(goContinue, 0.3)
            end
        end
    end
    if dest.id == nil and table.getn(dest.rooms) == 0 then
        cecho("<red>Path Consider GetRooms Error!")
        return false
    end
    -- path_Debug()
    path_create()
    road.i = skip_stepto

    -- 针对一些特殊地点的路径处理..
    -- 1. 针对华山村碎石路的处理,  因前面有关于松树林迷宫的部分, 故还需要依赖path_create处理出来的特殊路径的方式走,直到走出迷宫后, 因华山村有6个碎石路, 当一个碎石路找不到时,会开启范围搜索, 容易再次进入迷宫, 造成近乎无限循环,浪费大量时间, 故特别定制华山村的搜索路径, 尽量避免重复进入迷宫
    -- road.detail {
    -- "halt;west;west;west;west;west;west;west;west;west;west",
    -- "west",
    -- "#hsssl",
    -- "west;south;west;west;west;west"
    -- }
    -- 如上所示, 从road.detail的第四段, 即road.i == 4 开始, 替换为特殊搜索路径, 再针对华山任务的NPC会BLOCK 玩家的情况, 可直接进行该地区的遍历
    -- 故该路径改写, 针对华山任务, 其它不会block玩家的任务--不适用
    -- [[[该方法证实只是理论上的有效性, 实际Log中还是会出现碎石路问题]]]
    -- if job.name == "huashan" and job.area == "华山村" and job.room == "碎石路" then
    -- -- if job.area == "华山村" and job.room == "碎石路" then
    --     if table.len(road.detail) > 1 and road.detail[table.len(road.detail) - 1] == "#hsssl" then
    --         local tablelen = tonumber(table.len(road.detail))
    --         road.detail[tablelen] = "west;south;west;west;w;w;w;w;e;e;s;s;n;n;"
    --     end
    -- end

    -- SJConfig.DebugShow("华山碎石路调试 !~~~~~")
    -- display(road)

    -- return check_halt(path_start)
    return check_halt(path_start)
end

-- ---------------------------------------------------------------
-- 调试路径用
-- ---------------------------------------------------------------
function path_Debug()
    if sour ~= nil then
        print(" -- sour below: ")
        display(sour)
    end
    if dest ~= nil then
        print(" -- dest below: ")
        display(dest)
    end
    if location ~= nil then
        print(" -- location below: ")
        display(location)
    end
    print("计算路径--")
    echo(path_calculate())
end
-- ---------------------------------------------------------------
-- 计算出到达目标房间的路径str
-- ---------------------------------------------------------------
function path_calculate()
    local l_sour, l_dest, l_path, l_distance
    sour.rooms = {}
    dest.rooms = {}

    if sour.id == nil then
        sour.room = location.room
        sour.area = location.area
        sour.rooms = MapHelp.getRooms(sour.room, sour.area)
        if table.getn(sour.rooms) == 0 then
            SJConfig.DebugShow("Path Cal GetSourRooms 0 Error!")
            return false
        end
        l_sour = sour.rooms[1]
    else
        l_sour = sour.id
    end
    if dest.id == nil then
        dest.rooms = MapHelp.getRooms(dest.room, dest.area)

        -- if WhereIgnores[dest.area..dest.room] then
        --   return false
        -- end
        if table.getn(dest.rooms) == 0 then
            SJConfig.DebugShow("Path Cal GetDestRooms 0 Error!")
            return false
        end

        l_dest, l_distance = MapHelp.getNearRoom(l_sour, dest.rooms)
        if not l_dest then
            SJConfig.DebugShow("无法到达" .. dest.area .. dest.room)
            return false
        end
    end

    if dest.id ~= nil then
        l_dest = dest.id
    end
    if sour.id ~= nil then
        l_sour = sour.id
    end
    road.id = l_dest
    l_path = Mushmap:getPath(l_sour, l_dest)
    if not l_path then
        SJConfig.DebugShow("GetPath Error!")
        return false
    end
    -- echo("计算l_path为: "..l_path)
    return l_path
end

-- ---------------------------------------------------------------
-- 产生/生成路径
-- ---------------------------------------------------------------
function path_create()
    local l_set, l_cmdscount
    local l_num = 0
    local l_cnt = 1
    road.detail = {}
    l_cmdscount = 0
    l_path = path_calculate()
    -- cecho("<red>"..l_path)
    if type(l_path) ~= "string" then
        if math.random(1, 4) == 1 then
            l_path = "stand;out;northeast;northwest;southeast;southwest;south;south;south;south;south"
        elseif math.random(1, 4) == 2 then
            l_path = "stand;out;northeast;northwest;southeast;southwest;east;east;east;east;east;east"
        elseif math.random(1, 4) == 3 then
            l_path = "stand;out;northeast;northwest;southeast;southwest;west;west;west;west;west;west"
        else
            l_path = "stand;out;northeast;northwest;southeast;southwest;north;north;north;north;north"
        end
    end
    l_set = string.split(l_path, ";")
    l_cmdscount = table.getn(l_set)
    --print(l_path)
    if wdgostart == 1 then
        if l_cmdscount <= wd_distance then
            l_cmdscount = wd_distance
        end
        for i = 1, table.getn(l_set) do
            if i < l_cmdscount - wd_distance - 2 then
                if string.find(l_set[i], "#") then
                    if l_num > 0 then
                        l_cnt = l_cnt + 1
                    end
                    road.detail[l_cnt] = l_set[i]
                    l_cnt = l_cnt + 1
                    l_num = 0
                else
                    if l_num == 0 then
                        road.detail[l_cnt] = l_set[i]
                    else
                        road.detail[l_cnt] = road.detail[l_cnt] .. ";" .. l_set[i]
                    end
                    l_num = l_num + 1
                    if l_num > road.steps then
                        l_cnt = l_cnt + 1
                        l_num = 0
                    end
                end
            else
                if string.find(l_set[i], "#") then
                    if l_num > 0 then
                        l_cnt = l_cnt + 1
                    end
                    road.detail[l_cnt] = l_set[i]
                    l_cnt = l_cnt + 1
                    l_num = 0
                else
                    if l_num == 0 then
                        road.detail[l_cnt] = l_set[i]
                    else
                        road.detail[l_cnt] = road.detail[l_cnt] .. ";" .. l_set[i]
                    end
                    l_num = l_num + 1
                    if l_num > 0 then
                        l_cnt = l_cnt + 1
                        l_num = 0
                    end
                end
            end
        end
    else
        for i = 1, table.getn(l_set) do
            if string.find(l_set[i], "#") then
                if l_num > 0 then
                    l_cnt = l_cnt + 1
                end
                road.detail[l_cnt] = l_set[i]
                l_cnt = l_cnt + 1
                l_num = 0
            else
                if l_num == 0 then
                    road.detail[l_cnt] = l_set[i]
                else
                    road.detail[l_cnt] = road.detail[l_cnt] .. ";" .. l_set[i]
                end
                l_num = l_num + 1
                if l_num > road.steps then
                    l_cnt = l_cnt + 1
                    l_num = 0
                end
            end
        end
    end
    SJConfig.DebugShow("生成路径为: " .. l_path, 3)
end
-- ---------------------------------------------------------------
-- 准备开始行走
-- ---------------------------------------------------------------
function path_start()
    KillTimer("roadWait")
    local l_road
    road.i = road.i + 1
    if flag.find == 1 then
        return
    end
    if road.i > table.getn(road.detail) then
        locate_finish = "go_confirm"
        return locate()
    end
    l_road = road.detail[road.i]
    if string.find(l_road, "#") then
        local _, _, func, params = string.find(l_road, "^#(%a%w*)%s*(.-)$")
        if func then
            echo("当前l_road为:"..l_road)
            return _G[func](params)
        end
    else
        exe(l_road .. ";yun jingli")
        -- SJConfig.DebugShow("road.i:"..road.i)
        -- display(road.detail)
        -- print("run path_start: " .. l_road)
        -- print("location.room:"..location.room.." dest.room:"..dest.room)
        walk_wait()
    end
end
