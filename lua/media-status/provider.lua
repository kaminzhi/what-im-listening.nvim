local M = {}

-- Constants
local CONSTANTS = {
    TIMEOUT = 3000,
    TOOL_PATH_SUFFIX = "../../macos/UniversalMediaTool"
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
    local script_path = debug.getinfo(1).source:match("@?(.*/)") 
    local tool_path = script_path .. CONSTANTS.TOOL_PATH_SUFFIX
    
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