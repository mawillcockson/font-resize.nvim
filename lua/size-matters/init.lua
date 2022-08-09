local M = {}

local notify_status, notify = pcall(require, "notify")
local notifyOpts = { render = "minimal", timeout = 150, minimum_width = 10 }

local config = {
	default_mappings = true,
	step_size = 1,
	notifications = notify_status,
	reset_font = vim.api.nvim_get_option("guifont")
}

function M.setup(opts)
  config = vim.tbl_deep_extend("keep", opts, config)
  if config.notifications and not notify_status then
    vim.notify(
      "size-matters: rcarriga/nvim-notify not installed, falling back to builtin vim.notify()",
      vim.log.levels.WARN
    )
    notify = vim.notify
  end
end

local currFont, currFontList, currRemainingFontOptions, currFontSize

local function get_font()
	currFont = vim.api.nvim_get_option("guifont")
	-- split at the first colon character
	currFontList, currRemainingFontOptions = currFont:match("^(.-)(:.*)$")
	if currFontList == nil or currRemainingFontOptions == nil then
		vim.notify("size-matters: error matching 'guifont'", vim.log.levels.ERROR)
		return false
	end
	-- match the number part of the height option
	currFontSize = currRemainingFontOptions:match(":h([%d.]+)")
	if currFontSize == nil or currFontSize == "" then
		vim.notify("size-matters: error matching 'guifont'", vim.log.levels.ERROR)
		return false
	end
	-- remove the height option
	currRemainingFontOptions = currRemainingFontOptions:gsub(":h[%d.]+", "")
	return true
end

function M.update_font(direct, num)
	if not get_font() then return end
	num = type(num) == "string" and tonumber(num) or config.step_size
	if direct == "grow" then
		currFont = currFontList .. ":h" .. tostring(tonumber(currFontSize) + num) .. currRemainingFontOptions
		if config.notifications then notify(" FontSize " .. tonumber(currFontSize) + num, vim.log.levels.INFO, notifyOpts) end
	elseif direct == "shrink" then
		currFont = currFontList .. ":h" .. tostring(tonumber(currFontSize) - num) .. currRemainingFontOptions
		if config.notifications then notify(" FontSize " .. tonumber(currFontSize) - num, vim.log.levels.INFO, notifyOpts) end
	end
	vim.opt.guifont = currFont
end

function M.reset_font()
	vim.opt.guifont = config.reset_font
	if config.notifications then notify(" " .. config.reset_font, vim.log.levels.INFO, notifyOpts) end
end

local cmd = vim.api.nvim_create_user_command
cmd("FontSizeUp", function(num) M.update_font("grow", num.args) end, { nargs = 1 })
cmd("FontSizeDown", function(num) M.update_font("shrink", num.args) end, { nargs = 1 })
cmd("FontReset", function() M.reset_font() end, {})

if config.default_mappings then
	local map = vim.keymap.set
	map("n", "<C-+>", function() M.update_font("grow") end, { desc = "Increase font size" })
	map("n", "<C-S-+>", function() M.update_font("grow") end, { desc = "Increase font size" })
	map("n", "<C-->", function() M.update_font("shrink") end, { desc = "Decrease font size" })
	map("n", "<C-ScrollWheelUp>", function() M.update_font("grow") end, { desc = "Increase font size" })
	map("n", "<C-ScrollWheelDown>", function() M.update_font("shrink") end, { desc = "Decrease font size" })
	map("n", "<A-C-=>", M.reset_font, { desc = "Reset to default font" })
end

return M
