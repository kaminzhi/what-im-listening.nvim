local M = {}

-- Base icons
M.base = {
    playing = "",
    paused = "", 
    music = "♪",
    progress_filled = "█",
    progress_empty = "░",
}

-- Platform icons
M.platforms = {
    ["Spotify"] = "󰓇",
    ["com.spotify.client"] = "󰓇",
    
    ["Apple Music"] = "",
    ["Music"] = "", 
    ["iTunes"] = "",
    ["com.apple.Music"] = "",
    ["com.apple.iTunes"] = "",
    
    -- YouTube Music versions
    ["YouTube Music"] = "󰗃",
    ["com.github.th-ch.youtube-music"] = "󰗃",
    ["com.google.ios.youtubemusic"] = "󰗃",
    
    -- YouTube Music PWA versions:
    -- ["com.google.chrome.app.cinhimbmmoonh..."] = "󰗃",
    -- ["com.brave.browser.app..."] = "󰗃",
    
    ["YouTube"] = "󰗃",
    ["Chrome"] = "",
    ["Safari"] = "", 
    ["Firefox"] = "",
    ["System"] = "",
    ["Unknown"] = ""
}

function M.get_all()
    return {
        playing = M.base.playing,
        paused = M.base.paused,
        music = M.base.music,
        progress_filled = M.base.progress_filled,
        progress_empty = M.base.progress_empty,
        platforms = vim.deepcopy(M.platforms)
    }
end

function M.get_platform_icon(source)
    return M.platforms[source] or M.platforms["Unknown"]
end

function M.add_platform_icon(source, icon)
    M.platforms[source] = icon
end

return M