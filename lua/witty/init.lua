local M = {}

function M.setup(config)
	-- Create stored state
	local state = {
		terminal = {
			buf = vim.api.nvim_create_buf(false, true),
			win = -1,
		},
		type = (config and config.defaults and config.defaults.type) or "floating",
	}

	local function create_split_window(opts)
		print(state.terminal.buf)
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

		-- Set window configuration
		local win_config = {
			win = -1,
			split = "below",
			height = height,
		}

		local win = vim.api.nvim_open_win(buf, true, win_config)
		return { buf = buf, win = win }
	end

	local function create_vertical_window(opts)
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

		-- Set window configuration
		local win_config = {
			win = -1,
			split = "right",
			height = height,
		}

		local win = vim.api.nvim_open_win(buf, true, win_config)
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
			border = "rounded",
			title = " Terminal ",
			title_pos = "center",
		}

		-- Create floating window
		local win = vim.api.nvim_open_win(buf, true, win_config)
		vim.api.nvim_set_option_value(
			"winhighlight",
			"Normal:WittyNormal,FloatBorder:WittyBorder,FloatTitle:WittyTitle",
			{ scope = "local", win = win }
		)
		return { buf = buf, win = win }
	end

	local witty_toggle = "<Leader><CR>"
	local float_toggle = "<Leader>wf"
	local split_toggle = "<Leader>ws"
	local vertical_toggle = "<Leader>wv"
	local witty_hide = "q"

	if config.keybinds and config.keybinds.witty_toggle then
		witty_toggle = config.keybinds.witty_toggle
	end

	if config.keybinds and config.keybinds.float_toggle then
		float_toggle = config.keybinds.float_toggle
	end

	if config.keybinds and config.keybinds.split_toggle then
		split_toggle = config.keybinds.split_toggle
	end

	if config.keybinds and config.keybinds.vertical_toggle then
		vertical_toggle = config.keybinds.vertical_toggle
	end

	if config.keybinds and config.keybinds.witty_hide then
		witty_hide = config.keybinds.witty_hide
	end

	-- Hides the Witty terminal window if it exists.
	local function hide_terminal()
		if vim.api.nvim_win_is_valid(state.terminal.win) then
			vim.api.nvim_win_hide(state.terminal.win)
		end
	end

	-- Toggle terminal
	vim.keymap.set({ "n", "t" }, witty_toggle, function()
		if not vim.api.nvim_win_is_valid(state.terminal.win) then
			if state.type == "floating" then
				state.terminal = create_floating_window({ buf = state.terminal.buf })
			elseif state.type == "split" then
				state.terminal = create_split_window({ buf = state.terminal.buf })
			elseif state.type == "vertical" then
				state.terminal = create_vertical_window({ buf = state.terminal.buf })
			end

			if vim.bo[state.terminal.buf].buftype ~= "terminal" then
				vim.cmd.term()
			end
			vim.cmd.startinsert()
		else
			vim.api.nvim_win_hide(state.terminal.win)
		end
	end, { desc = "Toggle Terminal emulator" })

	-- Open split terminal
	vim.keymap.set({ "n", "t" }, split_toggle, function()
		if not vim.api.nvim_win_is_valid(state.terminal.win) or state.type ~= "split" then
			state.type = "split"
			hide_terminal()
			state.terminal = create_split_window({ buf = state.terminal.buf })
			if vim.bo[state.terminal.buf].buftype ~= "terminal" then
				vim.cmd.term()
			end
			vim.cmd.startinsert()
		end
	end, { desc = "Toggle [W]itty [S]plit" })

	-- Open floating terminal
	vim.keymap.set({ "n", "t" }, float_toggle, function()
		if not vim.api.nvim_win_is_valid(state.terminal.win) or state.type ~= "floating" then
			state.type = "floating"
			hide_terminal()
			state.terminal = create_floating_window({ buf = state.terminal.buf })
			if vim.bo[state.terminal.buf].buftype ~= "terminal" then
				vim.cmd.term()
			end
			vim.cmd.startinsert()
		end
	end, { desc = "Toggle [W]itty [F]loating" })

	-- Open vertical terminal
	vim.keymap.set({ "n", "t" }, vertical_toggle, function()
		if not vim.api.nvim_win_is_valid(state.terminal.win) or state.type ~= "vertical" then
			state.type = "vertical"
			hide_terminal()
			state.terminal = create_vertical_window({ buf = state.terminal.buf })
			if vim.bo[state.terminal.buf].buftype ~= "terminal" then
				vim.cmd.term()
			end
			vim.cmd.startinsert()
		end
	end, { desc = "Toggle [W]itty [V]ertical" })

	-- Hide terminal
	vim.keymap.set("n", witty_hide, function()
		hide_terminal()
	end, { buffer = state.terminal.buf, desc = "Exit Witty" })

	-- Escape to exit terminal
	vim.keymap.set("n", "<Esc>", function()
		hide_terminal()
		print(state.terminal.buf)
	end, { buffer = state.terminal.buf, desc = "Exit Witty" })

	local term_group = vim.api.nvim_create_augroup("terminal-mode-options", { clear = true })

	vim.api.nvim_create_autocmd("TermEnter", {
		desc = "Change local options when exiting Terminal Mode",
		group = term_group,
		callback = function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
		end,
	})

	vim.api.nvim_create_autocmd("TermLeave", {
		desc = "Change local options when exiting Terminal Mode",
		group = term_group,
		callback = function()
			vim.opt_local.number = true
			vim.opt_local.relativenumber = true
		end,
	})
end

return M
