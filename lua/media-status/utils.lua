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

function M.truncate_text(text, max_width)
    if not max_width or max_width == 0 then
        return text
    end
    
    local char_count = vim.fn.strchars(text)
    if char_count <= max_width then
        return text
    end
    
    if char_count > max_width then
        return M.safe_utf8_truncate(text, max_width - 3) .. "..."
    end
    return text
end

-- Safe UTF-8 truncation using character count instead of byte count
function M.safe_utf8_truncate(text, max_width)
    if not text or not max_width or max_width <= 0 then
        return ""
    end
    
    -- Use vim's string functions for proper UTF-8 handling
    local char_count = vim.fn.strchars(text)
    if char_count <= max_width then
        return text
    end
    
    -- Truncate by character count, not byte count
    return vim.fn.strpart(text, 0, max_width)
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

-- Get current window width
function M.get_window_width()
    local win = vim.api.nvim_get_current_win()
    return vim.api.nvim_win_get_width(win)
end

-- Calculate available width for lualine component
function M.calculate_lualine_width(config)
    if not config.adaptive_width then
        return config.max_width
    end
    
    -- Get current window width safely
    local ok, window_width = pcall(function()
        local win = vim.api.nvim_get_current_win()
        return vim.api.nvim_win_get_width(win)
    end)
    
    if not ok or not window_width then
        return config.max_width  -- Fallback to max_width if can't get window width
    end
    
    local max_component_width = math.floor(window_width * config.width_ratio)
    return math.max(config.min_display_width, max_component_width)
end

-- Smart truncate based on content priority
function M.smart_truncate(parts, max_width, config)
    if not max_width or max_width == 0 then
        return table.concat(parts, "")
    end
    
    -- Calculate full length using character count
    local full_text = table.concat(parts, "")
    if vim.fn.strchars(full_text) <= max_width then
        return full_text
    end
    
    -- Sort parts by priority (lower number = higher priority)
    local content_order = {
        { key = "icon", priority = config.priority_levels.icon },
        { key = "title", priority = config.priority_levels.title },
        { key = "artist", priority = config.priority_levels.artist },
        { key = "progress", priority = config.priority_levels.progress },
        { key = "time", priority = config.priority_levels.time }
    }
    
    table.sort(content_order, function(a, b) return a.priority < b.priority end)
    
    -- Start with highest priority items
    local result_parts = {}
    local current_length = 0
    
    for _, item in ipairs(content_order) do
        if parts[item.key] then
            local part_text = parts[item.key]
            local potential_length = current_length + vim.fn.strchars(part_text)
            
            if potential_length <= max_width then
                table.insert(result_parts, part_text)
                current_length = potential_length
            else
                -- Try to fit a truncated version
                local available_space = max_width - current_length - 3 -- space for "..."
                if available_space > 5 and item.key == "title" then -- Only truncate title if reasonable space
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