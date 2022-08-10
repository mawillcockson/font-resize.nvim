if vim.fn.has("nvim-0.7.0") == 0 then
	vim.api.nvim_err_writeln("font-resize requires nvim version 0.7 or above")
	return
end
