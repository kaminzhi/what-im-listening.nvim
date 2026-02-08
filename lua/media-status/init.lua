-- Main entry point - assembles all modules
local M = {}

-- Import modules
local config = require("media-status.config")
local formats = require("media-status.formats")
local commands = require("media-status.commands")
local cache = require("media-status.cache")
local timer = require("media-status.timer")
local provider = require("media-status.provider")
local utils = require("media-status.utils")

function M.setup(opts)
    local cfg = config.setup(opts)
    
    local default_formats = formats.get_defaults()
    local user_formats = opts and opts.formats or {}
    cfg.formats = utils.deep_merge(default_formats, user_formats)
    
    config.update_formats(cfg.formats)
    cache.clear()
    commands.create_commands(cfg)
    
    vim.api.nvim_create_user_command("MediaReload", function()
        M.reload()
        vim.notify("Media Status plugin reloaded", vim.log.levels.INFO)
    end, { desc = "Reload media status plugin" })
    
    vim.api.nvim_create_user_command("MediaRefresh", function()
        cache.clear()
        M.refresh()
        vim.notify("Media status cache refreshed", vim.log.levels.INFO)
    end, { desc = "Refresh media status cache immediately" })
    
    timer.start(cfg)
end

function M.get_status()
    return cache.get_status()
end

function M.get_lualine_status()
    return cache.get_lualine()
end

function M.get_media_info(callback)
    provider.fetch(callback)
end

function M.refresh()
    local cfg = config.get()
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

function M.reload()
    timer.stop()
    cache.clear()
    local cfg = config.get()
    timer.start(cfg)
    M.refresh()
end

function M.get_config()
    return config.get()
end

return M