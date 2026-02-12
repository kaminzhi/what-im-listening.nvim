local M = {}

-- Constants
local CONSTANTS = {
    TIMEOUT = 3000
}

local function parse_media_json(json_str)
    if not json_str or json_str == "" then
        return nil
    end
    
    local success, data = pcall(vim.fn.json_decode, json_str)
    if not success or not data or data.status == "nothing_playing" then
        return nil
    end
    
    -- Return structured media info
    return {
        title = data.title,
        artist = data.artist,
        album = data.album,
        duration = data.duration,
        elapsed = data.elapsed,
        progress = data.progress,
        is_playing = data.is_playing,
        playback_rate = data.playback_rate,
        source = data.source
    }
end

function M.fetch(callback)
    local script_path = debug.getinfo(1).source:match("@?(.*)")
    local script_dir = script_path:match("(.*)/")
    local plugin_root = script_dir:match("(.*)/lua/what%-im%-listening")
    local tool_path = plugin_root .. "/macos/UniversalMediaTool"
    
    if vim.fn.executable(tool_path) == 0 then
        vim.schedule(function()
            vim.notify("UniversalMediaTool not found at: " .. tool_path, vim.log.levels.ERROR)
            callback(nil)
        end)
        return
    end
    vim.system({ tool_path }, {
        timeout = CONSTANTS.TIMEOUT, 
        text = true,
    }, function(result)
        vim.schedule(function()
            local parsed = (result.code == 0 and result.stdout and result.stdout ~= "") 
                and parse_media_json(result.stdout) or nil
            callback(parsed)
        end)
    end)
end

return M