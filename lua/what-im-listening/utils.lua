local M = {}

function M.format_time(seconds)
    if not seconds then return "--:--" end
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

function M.format_progress_bar(progress, width, config)
    width = width or 15
    local filled = math.floor(progress * width / 100)
    local bar = string.rep(config.icons.progress_filled, filled) .. 
               string.rep(config.icons.progress_empty, width - filled)
    return bar
end

function M.count_utf8_chars(text)
    if not text then return 0 end
    
    local char_count = 0
    local i = 1
    while i <= #text do
        local byte = string.byte(text, i)
        if not byte then break end
        
        local char_len = 1
        if byte >= 240 then
            char_len = 4
        elseif byte >= 224 then
            char_len = 3
        elseif byte >= 192 then
            char_len = 2
        end
        
        char_count = char_count + 1
        i = i + char_len
    end
    
    return char_count
end

function M.truncate_text(text, max_width)
    if not max_width or max_width == 0 then
        return text
    end

    local char_count = M.count_utf8_chars(text)
    if char_count <= max_width then
        return text
    end
    
    return M.safe_utf8_truncate(text, max_width - 3) .. "..."
end


function M.safe_utf8_truncate(text, max_chars)
    if not text or not max_chars or max_chars <= 0 then
        return ""
    end

    local chars = {}
    local i = 1
    while i <= #text do
        local byte = string.byte(text, i)
        if not byte then break end
        
        local char_len = 1
        if byte >= 240 then
            char_len = 4
        elseif byte >= 224 then
            char_len = 3
        elseif byte >= 192 then
            char_len = 2
        end
        
        if i + char_len - 1 <= #text then
            table.insert(chars, string.sub(text, i, i + char_len - 1))
        end
        i = i + char_len
    end
    
    -- Return the first max_chars
    if #chars <= max_chars then
        return text
    end
    
    return table.concat(chars, "", 1, max_chars)
end

function M.is_pwa_app(source)
    if not source then return false end
    return string.match(source, "com%.google%.chrome%.app%.") or 
           string.match(source, "com%.brave%.browser%.app%.") or
           string.match(source, "com%.microsoft%.edgemac%.app%.")
end

function M.deep_merge(base, override)
    local result = vim.deepcopy(base)
    return vim.tbl_deep_extend("force", result, override or {})
end

function M.get_window_width()
    local win = vim.api.nvim_get_current_win()
    return vim.api.nvim_win_get_width(win)
end

function M.calculate_lualine_width(config)
    if not config.adaptive_width then
        return config.max_width or 0
    end

    local ok, window_width = pcall(function()
        local win = vim.api.nvim_get_current_win()
        return vim.api.nvim_win_get_width(win)
    end)
    
    if not ok or not window_width then
        return config.max_width or 50
    end

    local calculated_width = math.floor(window_width * (config.width_ratio or 0.25))
    local min_width = config.min_display_width or 15
    
    -- For narrow windows
    if window_width < 80 then
        return math.max(10, calculated_width)
    else
        return math.max(min_width, calculated_width)
    end
end

function M.smart_truncate(parts, max_width, config)
    if not max_width or max_width == 0 then
        return table.concat(parts, "")
    end

    local full_text = table.concat(parts, "")
    if M.count_utf8_chars(full_text) <= max_width then
        return full_text
    end

    local content_order = {
        { key = "icon", priority = config.priority_levels.icon },
        { key = "title", priority = config.priority_levels.title },
        { key = "artist", priority = config.priority_levels.artist },
        { key = "progress", priority = config.priority_levels.progress },
        { key = "time", priority = config.priority_levels.time }
    }
    
    table.sort(content_order, function(a, b) return a.priority < b.priority end)

    local result_parts = {}
    local current_length = 0
    
    for _, item in ipairs(content_order) do
        if parts[item.key] then
            local part_text = parts[item.key]
            local potential_length = current_length + M.count_utf8_chars(part_text)
            
            if potential_length <= max_width then
                table.insert(result_parts, part_text)
                current_length = potential_length
            else
                local available_space = max_width - current_length - 3
                if available_space > 5 and item.key == "title" then
                    local truncated = M.safe_utf8_truncate(part_text, available_space) .. "..."
                    table.insert(result_parts, truncated)
                end
                break
            end
        end
    end
    
    return table.concat(result_parts, "")
end

return M