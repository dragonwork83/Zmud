
function messageShow(p_msg, ccolor, bcolor)
    local c_color = ccolor or "white"
    local b_color = bcolor or "green"

    if isNil(p_msg) then
        return
    end

    if flag.note and flag.note == 1 then
        if flag.log and flag.log == "yes" then
            chats_log(p_msg, c_color, b_color)
        else
            ColourNote("white", "black", p_msg)
        end
    else
        chats_log(p_msg, c_color, b_color)
    end
end
function messageShowT(p_msg, ccolor, bcolor)
    local c_color = ccolor or "yellow"
    local b_color = bcolor or "green"

    if isNil(p_msg) then
        return
    end

    chats_log(p_msg, c_color, b_color)
end
function chats_log(logs,color,bcolor)
    -- 待重新实现, 将内容写至UI中.
    -- Kauna.ChatCapture(logs.."\n",1)
    -- Kauna.ChatCapture(logs.."\n",4)
end