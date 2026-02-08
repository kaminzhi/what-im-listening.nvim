local M = {}

local function parse_media_json(json_str)
    if not json_str or json_str == "" then
        return nil
    end
    
    -- Simple JSON parsing for known structure
    local success, data = pcall(vim.fn.json_decode, json_str)
    if not success or not data then
        return nil
    end
    
    if data.status == "nothing_playing" then
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
    local tool_path = script_path .. "../../macos/UniversalMediaTool"
    
    vim.system({ tool_path }, {
        timeout = 3000, 
        text = true,
    }, function(result)
        vim.schedule(function()
            if result.code ~= 0 or not result.stdout or result.stdout == "" then
                callback(nil)
                return
            end
            
            local parsed = parse_media_json(result.stdout)
            callback(parsed)
        end)
    end)
end

return M