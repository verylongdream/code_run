-- Function to detect the filetype based on file extension
local function detect_filetype(file)
	local ext = file:match("^.+(%..+)$")
	if ext == ".py" then
		return "python"
	elseif ext == ".js" then
		return "node"
	else
		return nil
	end
end

local term_buf = nil
local term_win = nil

local function run_code()
	local file = vim.fn.expand("%:p")

	local filetype = detect_filetype(file)
	if not filetype then
		print("Unsupported file type")
		return
	end

	-- Check if the terminal buffer and window still exist
	if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) or not vim.api.nvim_win_is_valid(term_win) then
		-- Open a vertical split with terminal
		vim.cmd("vsplit | terminal")
		-- Store the terminal buffer ID and window ID
		term_buf = vim.api.nvim_get_current_buf()
		term_win = vim.api.nvim_get_current_win()
	else
		-- Navigate to the existing terminal window
		vim.api.nvim_set_current_win(term_win)
	end

	-- Depending on the file type, choose the command to run
	local command
	if filetype == "python" then
		command = string.format(':call jobsend(b:terminal_job_id, "python %s\\n")', file)
	elseif filetype == "node" then
		command = string.format(':call jobsend(b:terminal_job_id, "node %s\\n")', file)
	end

	vim.cmd(command)

	-- Return focus to the original window
	vim.cmd("wincmd p")
end

-- Setup function to bind the key
local function setup()
	vim.api.nvim_set_keymap('n', '<leader>t', ':lua run_code()<CR>', { noremap = true, silent = true })
end

return {
	run_code = run_code,
	setup = setup
}
