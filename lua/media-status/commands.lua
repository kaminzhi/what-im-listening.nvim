local M = {}
local provider = require("media-status.provider")
local utils = require("media-status.utils")

function M.create_commands(config)
    -- MediaStatus command
    vim.api.nvim_create_user_command("MediaStatus", function()
        provider.fetch(function(info)
            if info then
                local msg = config.formats.notify_format(info, config)
                vim.notify(msg, vim.log.levels.INFO, { title = "Media Status" })
            else
                vim.notify("Nothing playing or media paused", vim.log.levels.WARN)
            end
        end)
    end, {})
    
    -- MediaProgress command
    vim.api.nvim_create_user_command("MediaProgress", function()
        provider.fetch(function(info)
            if info and info.progress then
                local progress_msg = config.formats.progress_format(info, config)
                vim.notify(progress_msg, vim.log.levels.INFO, { title = "Media Progress" })
            else
                vim.notify("No media progress available", vim.log.levels.WARN)
            end
        end)
    end, {})
    
    -- MediaProgressBar command
    vim.api.nvim_create_user_command("MediaProgressBar", function()
        provider.fetch(function(info)
            if info and info.progress then
                local wide_bar = utils.format_progress_bar(info.progress, 30, config)
                local percentage = string.format("%3d%%", info.progress)
                local time_info = utils.format_time(info.elapsed) .. " / " .. utils.format_time(info.duration)
                
                local msg = wide_bar .. "  " .. percentage .. "\n" .. 
                           time_info .. "  [" .. (info.title or "Unknown") .. "]"
                           
                vim.notify(msg, vim.log.levels.INFO, { title = "Progress Bar" })
            else
                vim.notify("No progress data", vim.log.levels.WARN)
            end
        end)
    end, {})
    
    -- MediaPlatforms command
    vim.api.nvim_create_user_command("MediaPlatforms", function()
        local platforms_info = "Media Platform Icons:\n"
        for platform, icon in pairs(config.icons.platforms) do
            platforms_info = platforms_info .. icon .. " " .. platform .. "\n"
        end
        platforms_info = platforms_info .. "\nCurrent playing:"
        
        provider.fetch(function(info)
            if info then
                local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
                local status_icon = info.is_playing and config.icons.playing or config.icons.paused
                platforms_info = platforms_info .. "\n" .. platform_icon .. " " .. status_icon .. " " .. 
                               (info.title or "Unknown") .. " [" .. (info.source or "Unknown") .. "]"
            else
                platforms_info = platforms_info .. "\nNothing playing"
            end
            vim.notify(platforms_info, vim.log.levels.INFO, { title = "Platform Icons" })
        end)
    end, {})
    
    -- MediaDebug command
    vim.api.nvim_create_user_command("MediaDebug", function()
        M.debug_info(config)
    end, {})
    
    -- MediaFindID command
    vim.api.nvim_create_user_command("MediaFindID", function()
        M.find_app_id(config)
    end, { desc = "Find current media app ID" })
end

function M.debug_info(config)
    provider.fetch(function(info)
        print("=== Real-time Debug Info ===")  
        print("Title raw:", info and info.title)
        print("Artist raw:", info and info.artist)
        print("Album raw:", info and info.album)
        print("Source:", info and info.source)
        print("Duration:", info and info.duration, "seconds")
        print("Elapsed (calculated):", info and info.elapsed, "seconds") 
        print("Progress:", info and info.progress, "%")
        print("Is playing:", info and info.is_playing)
        print("Playback rate:", info and info.playback_rate)
        
        if info and info.source then
            local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
            print("Platform icon:", platform_icon, "for", info.source)
            
            -- Help user configure PWA ID
            if info.source and not config.icons.platforms[info.source] then
                print("Platform icon not found, you can add:")
                print('   ["' .. info.source .. '"] = "icon",')  
            end
            
            -- Special detection for PWA apps
            if utils.is_pwa_app(info.source) then
                print("PWA app detected:", info.source)
                print("Suggested config:")
                print('   ["' .. info.source .. '"] = "icon",  -- YouTube Music PWA')
            end
        end
        
        if info and info.elapsed and info.duration then
            local elapsed_formatted = string.format("%02d:%02d", 
                math.floor(info.elapsed / 60), math.floor(info.elapsed % 60))
            local duration_formatted = string.format("%02d:%02d", 
                math.floor(info.duration / 60), math.floor(info.duration % 60))
            print("Time display:", elapsed_formatted .. " / " .. duration_formatted)
            
            -- Add timezone debug info
            local handle = io.popen("date -u '+%s'")
            local current_utc = handle:read("*l")
            handle:close()
            print("Current UTC timestamp:", current_utc)
            print("Time until song ends:", math.max(0, info.duration - info.elapsed), "seconds")
        end
    end)
end

function M.find_app_id(config)
    provider.fetch(function(info)
        if info and info.source then
            print("Current media app ID:")
            print("   Source:", info.source)
            print("   Title:", info.title)
            print("Add to config:")
            print('require("media-status").setup({')
            print('  icons = {')
            print('    platforms = {')
            print('      ["' .. info.source .. '"] = "icon",')
            print('    }')
            print('  }')
            print('})')
            
            if string.match(info.source, "%.app%.") then
                print("Tip: This seems to be a PWA app, possibly YouTube Music or other web apps")
            end
        else
            print("No media currently playing, please start a music app first")
        end
    end)
end

function M.test_config(config)
    local mock_info = {
        title = "Test Song",
        artist = "Test Artist",
        source = "Spotify", 
        is_playing = true,
        progress = 45,
        elapsed = 120,
        duration = 240
    }
    
    print("Configuration test:")
    print("Lualine format:", config.formats.lualine_format(mock_info, config))
    print("Notification format:", config.formats.notify_format(mock_info, config))
    print("Platform icon:", config.icons.platforms[mock_info.source])
end

return M