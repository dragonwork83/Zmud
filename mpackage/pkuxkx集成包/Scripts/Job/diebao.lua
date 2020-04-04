--
-- diebao.lua
--
--[[
    谍报任务
--]]



-- ---------------------------------------------------------------
-- Test Function
-- ---------------------------------------------------------------
function tts()
    str = "荆弘浪▊　▊　▊　▊　▊　▊　▊　▊　皱眉相认都史————西湖梅庄@@@@小院"
    str1 = "晋阳●●●地主家●●●花园桂●●●挪移忽然小子"
    str2 = "段誉见多端喝道◥　◥　◥　◥　◥　◥　◥　◥　鲍素＼　／＼　／＼　／＼　／＼　／杀手帮｜｜｜杀手帮广场"

    texthandle(str)
    texthandle(str1)
    texthandle(str2)
end

-- ---------------------------------------------------------------
-- 谍报 密文拆解
-- ---------------------------------------------------------------
function texthandle(str)
    local clr_str = specialletter_replace(str)
    local tab = string.split(clr_str, " ")
    display(tab)
end
-- ---------------------------------------------------------------
-- 异常字符排除
-- ---------------------------------------------------------------
function specialletter_replace(o_str)
    --   print(o_str)
    local str = ""
    for pos, code in utf8.next, o_str do
        if code > 12288 and code < 65295 then
            -- print(pos, code)
            str = str .. utf8.char(code)
        else
            str = str .. " "
        end
    end
    return str
end
