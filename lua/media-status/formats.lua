local M = {}
local utils = require("media-status.utils")

-- Default notification format
function M.notify_format(info, config)
    local status_icon = info.is_playing and config.icons.playing or config.icons.paused
    local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
    
    local display = platform_icon .. " " .. status_icon .. " " .. (info.title or "Unknown")
    
    if info.artist then
        display = display .. " - " .. info.artist
    end
    
    if info.elapsed and info.duration then
        local time_info = "[" .. utils.format_time(info.elapsed) .. "/" .. utils.format_time(info.duration) .. "]"
        display = display .. " " .. time_info
    end
    
    return display
end

-- Progress bar format
function M.progress_format(info, config)
    local lines = {}
    
    if info.progress then
        local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
        local status_icon = info.is_playing and config.icons.playing or config.icons.paused
        local bar = utils.format_progress_bar(info.progress, config.progress_width, config)
        local time_info = utils.format_time(info.elapsed) .. " / " .. utils.format_time(info.duration)

        local progress_line = bar .. " " .. info.progress .. "% " .. time_info
        table.insert(lines, progress_line)

        table.insert(lines, platform_icon .. " " .. status_icon .. " Track: " .. (info.title or "Unknown"))
        if info.artist then
            table.insert(lines, "By: " .. info.artist)
        end
        if info.source and info.source ~= "Unknown" then
            table.insert(lines, "Source: " .. info.source)
        end
    else
        table.insert(lines, "No progress available")
    end
    
    return table.concat(lines, "\n")
end

-- Lualine format: {source} {title} - {artist} (full display, no truncation)
function M.lualine_format(info, config)
    if not info or not info.title then return "" end
    
    local result = ""
    
    -- {source} - 平台图标
    if info.source then
        local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
        result = platform_icon
    end
    
    -- {title}
    if result ~= "" then
        result = result .. " " .. info.title
    else
        result = info.title
    end
    
    -- - {artist}
    if info.artist then
        result = result .. " - " .. info.artist
    end
    
    -- Don't truncate for lualine, show full content
    return result
end

-- Complete status bar format
function M.status_format(info, config, max_width)
    if not info or not info.title then return "" end
    
    local parts = {}

    -- Add platform icon
    if info.source then
        local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
        table.insert(parts, platform_icon)
    end
    
    if info.is_playing ~= nil then
        table.insert(parts, info.is_playing and config.icons.playing or config.icons.paused)
    end

    table.insert(parts, info.title)

    if config.show_artist and info.artist then
        table.insert(parts, config.separators.artist .. info.artist)
    end
    if config.show_album and info.album then
        table.insert(parts, " · " .. info.album)
    end
    
    if config.show_progress and info.progress then
        local progress_parts = {}

        local filled = math.floor(info.progress * config.progress_width / 100)
        local bar = string.rep(config.icons.progress_filled, filled) .. 
                   string.rep(config.icons.progress_empty, config.progress_width - filled)
        table.insert(progress_parts, bar)
        
        if config.show_time and info.elapsed and info.duration then
            local time_info = utils.format_time(info.elapsed) .. config.separators.time .. utils.format_time(info.duration)
            table.insert(progress_parts, time_info)
        end
        
        local progress_str = table.concat(progress_parts, " ")
        table.insert(parts, " " .. string.format(config.separators.progress_wrap, progress_str))
    end
    
    local display = table.concat(parts, "")
    
    return utils.truncate_text(display, max_width)
end

-- Get all default formats
function M.get_defaults()
    return {
        notify_format = M.notify_format,
        progress_format = M.progress_format,
        lualine_format = M.lualine_format,
        status_format = M.status_format,
    }
end

return M