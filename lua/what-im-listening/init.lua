-- Main entry point - assembles all modules
local M = {}

-- Import modules
local config = require("what-im-listening.config")
local formats = require("what-im-listening.formats")
local commands = require("what-im-listening.commands")
local cache = require("what-im-listening.cache")
local timer = require("what-im-listening.timer")
local provider = require("what-im-listening.provider")
local utils = require("what-im-listening.utils")

-- Utility function for creating commands with consistent notification pattern
local function create_management_command(name, func, success_msg, desc)
    vim.api.nvim_create_user_command(name, function()
        func()
        vim.notify(success_msg, vim.log.levels.INFO)
    end, { desc = desc })
end

-- Common refresh logic extracted to avoid duplication
local function update_media_cache(cfg)
    provider.fetch(function(info)
        if info then
            local status = cfg.formats.status_format(info, cfg, cfg.max_width)
            local lualine = cfg.formats.lualine_format(info, cfg)
            cache.update_all(status, lualine, info)
        else
            cache.clear()
        end
    end)
end

function M.setup(opts)
    local cfg = config.setup(opts)
    
    -- Optimize format merging
    local user_formats = (opts and opts.formats) or {}
    cfg.formats = utils.deep_merge(formats.get_defaults(), user_formats)
    
    config.update_formats(cfg.formats)
    cache.clear()
    commands.create_commands(cfg)
    
    -- Create management commands with unified pattern
    create_management_command("MediaReload", 
        function() M.reload() end,
        "Media Status plugin reloaded", 
        "Reload media status plugin")
        
    create_management_command("MediaRefresh", 
        function() 
            cache.clear()
            M.refresh() 
        end,
        "Media status cache refreshed", 
        "Refresh media status cache immediately")
    
    timer.start(cfg)
end

-- Simplified API functions
function M.get_status()
    return cache.get_status()
end

function M.get_lualine_status()
    return cache.get_lualine()
end

function M.get_media_info(callback)
    provider.fetch(callback)
end

function M.get_config()
    return config.get()
end

function M.refresh()
    update_media_cache(config.get())
end

function M.reload()
    timer.stop()
    cache.clear()
    local cfg = config.get()
    timer.start(cfg)
    M.refresh()
end

return M