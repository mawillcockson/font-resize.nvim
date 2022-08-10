local M = {}

local max = math.max
local vim_o = vim.o
local set = vim.api.nvim_set_option_value
local INFO = vim.log.levels.INFO
local WARN = vim.log.levels.WARN
local ERROR = vim.log.levels.ERROR

local notify_status, notify = pcall(require, "notify")
local notifyOpts = {
  render = "minimal",
  timeout = 150,
  minimum_width = 10,
}

M.default_config = {
  default_mappings = true,
  step_size = 1,
  notifications = notify_status,
  default_guifont = vim_o.guifont,
  set_font_function = function(guifont) set("guifont", guifont, {}) end,
}

M.config = false

function M.setup(opts)
  for k, v in pairs(opts) do
    if M.default_config[k] == nil then
      vim.notify(
        "size-matters: unrecognized configuration option: '"..tostring(k).."'",
        WARN
      )
      opts[k] = nil
    end
    if type(v) ~= type(M.default_config[k]) then
      vim.notify(
        "size-matters: for option '"..tostring(k).."' expected type '"..type(M.default_config[k])..
        "' got type '"..type(v)"'",
        ERROR
      )
      return
    end
  end
  M.config = vim.tbl_deep_extend("keep", opts, M.default_config)
  if M.config.notifications and not notify_status then
    vim.notify(
      "size-matters: rcarriga/nvim-notify not installed, falling back to builtin vim.notify()",
      WARN
    )
    notify = vim.notify
  elseif not M.config.notifications then
    notify = false
  end

  if M.config.default_mappings then
    local map = vim.keymap.set
    --[[ I don't know how to map these
    ---- the last comment on this answer has some detail:
    ---- https://stackoverflow.com/a/7653633
    ---- I don't know what the story is in Neovim
    map("n", "<C-+>", M.increase, { desc = "Increase font size" })
    map("n", "<C-S-+>", M.increase, { desc = "Increase font size" })
    map("n", "<C-->", M.decrease, { desc = "Decrease font size" })
    map("n", "<A-C-=>", M.reset_font, { desc = "Reset to default font" })
    --]]
    map("n", "<C-ScrollWheelUp>", M.increase, { desc = "Increase font size" })
    map("n", "<C-ScrollWheelDown>", M.decrease, { desc = "Decrease font size" })
  end

  M.font_change_event()
end

function M.font_change_event()
  local guifont = vim_o.guifont
  -- split at the first colon character
  local font_list, remaining_opts = guifont:match("^(.-)(:.*)$")
  if font_list == nil or remaining_opts == nil then
    vim.notify("size-matters: error matching 'guifont'", ERROR)
    M.config = false
    return
  end
  -- match the number part of the height option
  local size = tonumber(remaining_opts:match(":h([%d.]+)"))
  if not size then
    vim.notify("size-matters: error matching 'guifont' height option", ERROR)
    M.config = false
    return
  end
  -- remove the height option
  remaining_opts = remaining_opts:gsub(":h[%d.]+", "")

  M.config.font_list = font_list
  M.config.remaining_opts = remaining_opts
  M.config.size = size
end

function M.increase()
  local config = M.config
  if not config then
    vim.notify(
      "size-matters: not configured (was setup() called?)",
      ERROR
    )
    return
  end

  local new_size = config.size + config.step_size
  local notify = notify
  if notify then
    notify(" font size "..new_size, INFO, notifyOpts)
  end
  config.set_font_function(config.font_list..":h"..new_size..config.remaining_opts)
  config.size = new_size
end

function M.decrease()
  local config = M.config
  if not config then
    vim.notify(
      "size-matters: not configured (was setup() called?)",
      ERROR
    )
    return
  end

  local new_size = max(config.size - config.step_size, 1)
  local notify = notify
  if notify then
    notify(" font size "..new_size, INFO, notifyOpts)
  end
  -- config.set_font_function(config.font_list..":h"..new_size..config.remaining_opts)
  vim_o.guifont = config.font_list..":h"..new_size..config.remaining_opts
  config.size = new_size
end

function M.reset_font()
  local default_guifont = M.config.default_guifont
  if notify then
    notify(" "..default_guifont, INFO, notifyOpts)
  end
  config.set_font_function(default_guifont)
end

local cmd = vim.api.nvim_create_user_command
cmd("FontSizeUp", M.increase, {})
cmd("FontSizeDown", M.decrease, {})
cmd("FontReset", M.reset_font, {})

return M
