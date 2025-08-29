if vim.fn.has("nvim-0.7.0") ~= 1 then
	vim.api.nvim_echo({ "witty.nvim requires at least nvim-0.7.0.\n" }, true, { "err" })
end
