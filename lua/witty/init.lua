local M = {}

function M.setup(config)
	-- Set configuration
	config = config or {
		keybinds = {
			split_toggle = "<Leader><CR>",
			float_toggle = "<Leader>f<CR>",
		},
	}

	-- Create stored state
	local state = {
		terminal = {
			buf = -1,
			win = -1,
		},
	}

	local function create_split_window(opts)
		-- Set options
		opts = opts or {}
		local height = opts.height or math.min(15, math.floor(vim.o.lines * 0.2))

		-- Create buffer
		local buf = nil
		if vim.api.nvim_buf_is_valid(opts.buf) then
			buf = opts.buf
		else
			buf = vim.api.nvim_create_buf(false, true)
		end

		vim.cmd.new()
		local win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_height(win, height)
		vim.api.nvim_set_current_buf(buf)
		return { buf = buf, win = win }
	end

	local function create_floating_window(opts)
		-- Set options
		opts = opts or {}
		local width = opts.width or math.floor(vim.o.columns * 0.8)
		local height = opts.height or math.floor(vim.o.lines * 0.8)
		local col = math.floor((vim.o.columns - width) / 2)
		local row = math.floor((vim.o.lines - height) / 2)

		-- Create buffer
		local buf = nil
		if vim.api.nvim_buf_is_valid(opts.buf) then
			buf = opts.buf
		else
			buf = vim.api.nvim_create_buf(false, true)
		end

		-- Set window configuration
		local win_config = {
			relative = "editor",
			width = width,
			height = height,
			col = col,
			row = row,
			style = "minimal",
			border = "rounded",
			title = " Terminal ",
			title_pos = "center",
		}

		-- Create floating window
		local win = vim.api.nvim_open_win(buf, true, win_config)
		return { buf = buf, win = win }
	end

	-- Open split terminal
	vim.keymap.set({ "n", "t" }, config.keybinds.split_toggle, function()
		if not vim.api.nvim_win_is_valid(state.terminal.win) then
			state.terminal = create_split_window({ buf = state.terminal.buf })
			if vim.bo[state.terminal.buf].buftype ~= "terminal" then
				vim.cmd.term()
			end
			vim.cmd.startinsert()
		else
			vim.api.nvim_win_hide(state.terminal.win)
		end
	end, { desc = "Toggle [<CR>]Terminal emulator" })

	-- Open floating terminal
	vim.keymap.set({ "n", "t" }, config.keybinds.float_toggle, function()
		if not vim.api.nvim_win_is_valid(state.terminal.win) then
			state.terminal = create_floating_window({ buf = state.terminal.buf })
			if vim.bo[state.terminal.buf].buftype ~= "terminal" then
				vim.cmd.term()
			end
			vim.cmd.startinsert()
		else
			vim.api.nvim_win_hide(state.terminal.win)
		end
	end, { desc = "Toggle [F]loating [<CR>]Terminal emulator" })
	config = config or {}
end

return M
