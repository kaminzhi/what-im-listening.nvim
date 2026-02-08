# what-im-listening.nvim

A lightweight Neovim plugin that displays currently playing media information in your statusline and provides media control functionality.

## Features

- Real-time media status display for statuslines (lualine, etc.)
- Media control commands (play/pause, next, previous)
- Customizable keyboard mappings
- Support for various media sources (Spotify, Apple Music, YouTube, browsers, etc.)
- Configurable icons and formatting
- Smart caching to minimize performance impact

## Requirements

- Neovim 0.8+
- macOS
- [nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli) (`brew install nowplaying-cli`)

## Installation

### lazy.nvim
```lua
{
  "kaminzhi/what-im-listening.nvim",
  build = "bash ./build.sh",
  config = function()
    require("what-im-listening").setup()
  end,
}
```

### packer.nvim
```lua
use {
  "kaminzhi/what-im-listening.nvim",
  run = "bash ./build.sh",
  config = function()
    require("what-im-listening").setup()
  end,
}
```

## Configuration

```lua
require("what-im-listening").setup({
  update_interval = 5000,  -- Update interval in milliseconds
  max_width = 50,          -- Max width for status display (0 = unlimited)
  
  -- Display options
  show_progress = true,
  show_time = true,
  show_artist = true,
  show_album = false,
  
  -- Keyboard mappings
  keymaps = {
    play_pause = "<leader>mp",   -- Toggle play/pause
    next = "<leader>mn",         -- Next track
    previous = "<leader>mP",     -- Previous track
    status = "<leader>ms"        -- Show media status
  },
  
  -- Custom icons
  -- icons = {
  --  playing = "▶",
  --  paused = "⏸",
  --  platforms = {
  --    -- Add custom platform icons
  --  }
  -- }
})
```

## Usage

### Lualine Integration

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      function()
        return require("what-im-listening").get_lualine_status()
      end
    }
  }
})
```

### Commands

- `:MediaStatus` - Show current media information
- `:MediaProgress` - Display playback progress
- `:MediaPlatforms` - List available platform icons
- `:MediaPlayPause` - Toggle play/pause
- `:MediaNext` - Skip to next track
- `:MediaPrevious` - Skip to previous track
- `:MediaReload` - Reload the plugin
- `:MediaRefresh` - Refresh media cache

### Default Key Mappings

- `<leader>mp` - Toggle play/pause
- `<leader>mn` - Next track
- `<leader>mP` - Previous track
- `<leader>ms` - Show media status

## API

```lua
local media = require("what-im-listening")

-- Get formatted status for statusline
media.get_status()

-- Get lualine-specific format
media.get_lualine_status()

-- Get raw media information
media.get_media_info(function(info)
  if info then
    print(info.title, info.artist)
  end
end)
```

## Build

The plugin includes a Swift binary for efficient media detection:

```bash
./build.sh
```