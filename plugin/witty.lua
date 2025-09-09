if vim.fn.has("nvim-0.7.0") ~= 1 then
	vim.api.nvim_echo({ "witty.nvim requires at least nvim-0.7.0.\n" }, true, { "err" })
end

-- if vim.g.loaded_witty == 1 then
-- 	return
-- end
-- vim.g.loaded_witty = 1

local highlights = {
	WittyNormal = { link = "Normal" },
	WittyBorder = { link = "Normal", bg = "none" },
	WittyTitle = { link = "Normal" },
}

for k, v in pairs(highlights) do
	vim.api.nvim_set_hl(0, k, v)
end
