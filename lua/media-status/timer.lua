local M = {}
local provider = require("media-status.provider")
local cache = require("media-status.cache")
local config = require("media-status.config")

local timer = nil

function M.start(initial_config)
    -- Ensure only one timer is running
    M.stop()
    
    timer = vim.loop.new_timer()
    timer:start(0, initial_config.update_interval, vim.schedule_wrap(function()
        -- Get latest config and format functions each time
        local current_config = config.get()
        
        provider.fetch(function(info)
            if info then
                local status = current_config.formats.status_format(info, current_config, current_config.max_width)
                local lualine = current_config.formats.lualine_format(info, current_config)
                cache.update_all(status, lualine)
            else
                cache.clear()
            end
        end)
    end))
end

function M.stop()
    if timer then
        timer:stop()
        timer:close()
        timer = nil
    end
end

function M.restart(config)
    M.stop()
    M.start(config)
end

return M