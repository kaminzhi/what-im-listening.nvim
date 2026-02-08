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
    if not max_width or max_width == 0 or #text <= max_width then
        return text
    end
    if #text > max_width then
        return string.sub(text, 1, max_width - 3) .. "..."
    end
    return text
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

return M