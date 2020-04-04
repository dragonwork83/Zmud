--
-- MissionPunishment.lua
--
-- ----------------------------------------------------------
-- 用于处理 当前在任务惩罚期间时执行的事情
-- 避免干等任务惩罚时间, 提高效率
-- 该惩罚多出现于当exp较低时
-- ----------------------------------------------------------
--
--[[

eg.

--]]
MissionPunishment = {
    AlreadyGiveUp = false
}

function MissionPunishment.PunishmentHandle(busySecond)
    disAll()

    if busySecond > 10 then
        quest.desc = "任务惩罚 " .. busySecond .. "秒"
        quest.note = ""
        quest.update()
    else
        quest.desc = ""
        quest.note = ""
        quest.update()
    end

    if busySecond >= 60 then
        -- 判断是否达到学习条件, 即是否技能等级不足,需要学习或者领悟
        if NeedStudy() then
            SJConfig.DebugShow("达到学习条件, 利用任务惩罚时间去补skill~")
            return FetchPot()
        end
    end

    if busySecond >= 40 then
        zhunbeineili(check_food, true)
    end

    -- if busySecond == 20 then
    -- 短时间内进行一些基本的药品补充等
    if
        (Bag and Bag["黄金"] and Bag["黄金"].cnt and Bag["黄金"].cnt < count.gold_max and score.gold > count.gold_max) or
            (Bag and Bag["黄金"] and Bag["黄金"].cnt and Bag["黄金"].cnt > count.gold_max * 4)
     then
        quest.name = "状态检查"
        quest.status = "检查黄金"
        quest.update()
        return check_gold()
    end

    if
        score.gold and score.gold > 100 and drugPrepare["川贝内息丸"] and
            (Bag["川贝内息丸"] == nil or Bag["川贝内息丸"].cnt < count.cbw_max)
     then
        quest.name = "状态检查"
        quest.status = "检查 川贝内息丸"
        quest.location = ""
        quest.update()
        return checkNxw()
    end

    -- 判断是否已放弃任务, 避免二次busy
    -- if MissionPunishment.AlreadyGiveUp ~= true and busySecond > 120 then
    --     if job.last == "huashan" then
    --         func = huashanFindFail
    --     elseif job.last == "wudang" then
    --         func = function()
    --             wudangTrigger()
    --             go(wudangFangqi, "武当山", "三清殿")
    --         end
    --     elseif job.last == "songxin" then
    --         func = function()
    --             songxin_trigger()
    --             go(songxin_fangqi, "大理城", "驿站")
    --         end
    --     elseif job.last == "xueshan" then
    --         func = function()
    --             go(xueshan_fangqi, "大雪山", "入幽口")
    --         end
    --     end
    -- end

    -- if not Bag["绳子"] then
    --     CheckRope(check_food)
    -- end

    --    beiok()
    local func = function()
        exe("yun regenerate;yun qi;yun jingli;")
        check_food()
    end

    check_busy(func)
    -- 给 beihook 赋值, 即赋值后续要执行的function
    -- beihook = function xxx()
    -- 执行 beiok 停止bei,执行后续
    -- beiok()
    -- switch study/prepare/food/repair/doing LL
end -- function check
