# font-resize.nvim

Lua plugin that adds browser-like keybinds for zooming in and out.

| **Action**            | **Keymaps**                                                          | **Vim Commands**     |
| --------------------- | -------------------------------------------------------------------- | -------------------- |
| Increase font size    | <kbd>Ctrl</kbd>+<kbd>+</kbd> / <kbd>Ctrl</kbd>+<kbd>ScrollUp</kbd>   | `FontSizeUp`         |
| Decrease font size    | <kbd>Ctrl</kbd>+<kbd>-</kbd> / <kbd>Ctrl</kbd>+<kbd>ScrollDown</kbd> | `FontSizeDown`       |
| Reset font to default | <kbd>Ctrl</kbd>+<kbd>0</kbd>                                         | `FontReset`          |

## Installation

A simple way to install the plugin is via a plugin manager. E.g., [packer.nvim][]

```lua
use "mawillcockson/font-resize.nvim"
```

The plugin can be loaded like a normal plugin in e.g. [`init.lua`][]. Additionally, you can wrap it in a condition to only be loaded when using a GUI client:

```lua
if vim.g.neovide or vim.g.goneovim or vim.g.nvui or vim.g.gnvim then
  require("font-resize")
end
```

### Fancy notifications (optional)

This plugin can use any notification library that has the same API as [Neovim's builtin `vim.notify()`][]. [rcarriga/nvim-notify][] is one such library.

If using [packer.nvim][], it can be specified as a dependency:

```lua
use {
  "mawillcockson/font-resize.nvim",
  requires = {
    "rcarriga/nvim-notify",
  },
}
```

If using [rcarriga/nvim-notify][], the background colour of the notification popups should be configured to match the background colour of the Neovim window (e.g. black):

```lua
if vim.g.neovide or vim.g.goneovim or vim.g.nvui or vim.g.gnvim then
  require("size-matters")
    require("notify").setup({
      background_colour = "#000000" -- hex code (e.g. your terminal or ui's background colour)
    })
end
```

[More info about `background_colour` in `notify.setup()`.][background_colour]

## Configuration

This is a full configuration example using [packer.nvim][], including all the configuration options that this plugin accepts.

```lua
use {
  "mawillcockson/font-resize.nvim",
  -- Mark this plugin as one that will be manually loaded, instead of
  -- automatically when Neovim launches. packer.nvim also supports configuring
  -- loading on keybinds, filetype events, etc.
  opt = true,
  -- (optional) Add a notification plugin as a dependency, for fancy font size
  -- update messages. This isn't required, and can be removed. The plugin must
  -- be able to be used as:
  --[[
    require("notify")("message", vim.log.levels.WARN, {opts = true})
  --]]
  -- That is, it must be installed and require-able with the name `notify`, and
  -- must provide a function that matches Neovim's builtin `vim.notify()`
  -- interface.
  requires = {
    {
      "rcarriga/nvim-notify",
      -- If the plugin is installed with a name other than `notify`,
      -- packer.nvim can be configured to override that name with `notify`
      --[[
      as = "notify",
      --]]
      -- When this dependency is loaded, run this function, which sets the
      -- background color of the notification popup window to the hex code for
      -- black. Change this if the background of your Neovim UI is not black.
      config = function()
        require("notify").setup{
          background_colour = "#000000",
        }
      end,
    },
  },
  -- The font-resize plugin provides a setup() function that it requires to be
  -- called before the plugin will start resizing the font. packer.nvim makes
  -- available a config= option for providing a function that will be called
  -- immediately after the plugin is loaded.
  config = function()
    -- These are the default values used if the name is not set in the table
    -- passed to setup(), but many of the values should not be copied and used
    -- as-is
    require("font-resize").setup{
      -- If this is set to `true`, the setup() function will configure keybinds
      -- to match the table at the top of this README
      use_default_mappings = true,
      -- The amount by which to increase and decrease the font size each time a
      -- keybind is pressed or a :FontSizeUp / :FontSizeDown command is called
      step_size = 1,
      -- Sets whether to print a message each time the font is resized or reset
      -- NOTE: it does not matter if rcarriga/nvim-notify is installed or not, this
      -- is a global flag to enable ANY notifications or not
      -- By default, this will enable notifications only if a plugin called
      -- `notify` is available
      -- Should be set to `true` or `false` if set at all
      notifications = pcall(require, "notify"),
      -- The value to reset the font to in case something goes wrong, or the
      -- reset keybind or function is used.
      -- By default, this records the value of the `guifont` option when the
      -- plugin is first loaded
      -- This should be set to a valid value to pass to the set_font_function()
      -- (e.g. "Consolas:h12")
      default_guifont = vim.o.guifont,
      -- The function to use to change the font. Takes a single argument that's
      -- formatted for use with `:set guifont=...`
      -- This function should raise an error instead of failing silently, as
      -- internally the updated font size isn't saved when this function call
      -- fails, enabling recovery from e.g. a too-small font size by using the
      -- :FontSizeUp command or keybind
      set_font_function = function(guifont)
        vim.api.nvim_set_option_value("guifont", guifont, {})
      end,
    }
  end,
  -- The keybinds that packer.nvim should watch, and load this plugin when one
  -- is pressed. These are the default keybinds that this plugin uses if
  -- `use_default_mappings` is set to `true`.
  keys = {
    -- As of August 2022, FVim and neovim-qt work with all the keybinds, and
    ---[[ Goneovim only works with these
    "<C-=>", -- up
    "<C-->", -- down
    "<C-0>", -- reset
    --]]
    ---[[ Neovide only works with these
    "<C-ScrollWheelUp>",
    "<C-ScrollWheelDown>",
    --]]
    -- The keybinds may work in the terminal, but this plugin should not be
    -- loaded in that case as the terminal should handle the font resizing, not
    -- Neovim's TUI
  },
  -- packer.nvim will watch calls to require() for these names, and will load
  -- this plugin when a matching one is encountered. This means that loading
  -- this plugin in lua only needs `require("font-resize")`, and doesn't need a
  -- preceding call to `vim.cmd[[:packadd font-resize.nvim]]`, even though this
  -- configuration marks this plugin as `opt = true` and its name is
  -- `font-resize.nvim`, not `font-resize`.
  module = "font-resize",
},
```

## Requirements

nvim >= v0.7 _- as APIs introduced with v0.7 are used._

An error message should be printed if this requirement isn't met.

[packer.nvim]: <https://github.com/wbthomason/packer.nvim>
[`init.lua`]: <https://neovim.io/doc/user/starting.html#init.lua>
[Neovim's builtin `vim.notify()`]: <https://neovim.io/doc/user/lua.html#vim.notify()>
[rcarriga/nvim-notify]: <https://github.com/rcarriga/nvim-notify>
[background_colour]: <https://github.com/rcarriga/nvim-notify/issues/101#issuecomment-1147351791>
