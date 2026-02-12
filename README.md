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
- Nerd Fonts
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
  
  -- Adaptive width settings for lualine
  adaptive_width = true,         -- Enable adaptive width based on window size
  min_display_width = 30,        -- Minimum width for any display
  width_ratio = 0.3,             -- Max ratio of statusline width to use (0.3 = 30%)
  priority_levels = {            -- Content priority when space is limited
    icon = 1,                    -- Platform icon (highest priority)
    title = 2,                   -- Song title
    artist = 3,                  -- Artist name
    progress = 4,                -- Progress bar
    time = 5                     -- Time info (lowest priority)
  },
  
  -- Lualine specific settings (for cleaner statusline display)
  lualine = {
    show_progress = false,       -- Don't clutter lualine with progress bar
    show_time = false,           -- Don't show time in lualine
    show_artist = true,          -- Show artist name if space allows
  },
  
  -- Display options (for :MediaStatus and other commands)
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

## Examples

### Adaptive Display for Different Window Sizes

```lua
require("what-im-listening").setup({
  adaptive_width = true,
  width_ratio = 0.25,        -- Use max 25% of statusline width
  min_display_width = 20,    -- Always show at least 20 characters
  
  -- Customize priority levels (1 = highest priority, 5 = lowest)
  priority_levels = {
    icon = 1,      -- Always show platform icon
    title = 2,     -- Song title (will be truncated if needed)
    artist = 3,    -- Artist name (hidden in narrow windows)
    progress = 4,  -- Progress bar (hidden in medium windows)
    time = 5       -- Time info (hidden in wide windows)
  },
  
  show_progress = true,
  show_time = true,
  show_artist = true,
})
```

### Lualine Setup with Multiple Components

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      -- Other components
      'encoding',
      'fileformat',
      
      -- Media status - will adapt to remaining space
      {
        function()
          return require("what-im-listening").get_lualine_status()
        end,
        color = { fg = '#ff6b6b' },  -- Optional: customize color
        separator = { left = '', right = '' },
      },
      
      'filetype',
    }
  }
})
```

### Static Width Configuration (Disable Adaptive)

```lua
-- For users who prefer fixed width display
require("what-im-listening").setup({
  adaptive_width = false,  -- Disable adaptive width
  max_width = 60,          -- Fixed maximum width
  
  show_progress = false,   -- Manually control what to show
  show_time = false,
  show_artist = true,
})
```

## Build

The plugin includes a Swift binary for efficient media detection:

```bash
./build.sh
```
