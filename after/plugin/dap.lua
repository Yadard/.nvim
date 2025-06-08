local dapui = require('dapui')
local dap = require('dap')
local uivar = require('dap.ui.widgets')
local dapp = require('nvim-dap-projects')
local mason_dap = require("mason-nvim-dap")

require('nvim-dap-virtual-text').setup {
	-- Your custom settings here, for example:
	commented = true,

	-- This is the key option. It tells the plugin to show details
	-- for the exception when the debugger is paused on an error.
	display_error_message = true,

	-- Other options to customize the display...
	virt_text_pos = 'eol', -- 'eol' or 'overlay'
	all_frames = false,
	virt_text_win_col = nil,
}


dapui.setup({
	layouts = {
		{
			elements = {
				-- Elements to show on the left panel
				{ id = "scopes",      size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks",      size = 0.25 },
				{ id = "watches",     size = 0.25 },
			},
			size = 40, -- Left panel width
			position = "left",
		},
		{
			elements = {
				-- Elements to show on the bottom panel
				{ id = "repl",    size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 10, -- Bottom panel height
			position = "bottom",
		},
	},
})

dap.set_log_level("DEBUG")

-- =============================================================================
-- 5. EXPLICIT UI MANAGEMENT (SAFE LISTENERS)
-- =============================================================================
-- This block explicitly tells the UI to open and close when DAP sessions
-- start and stop. Using vim.schedule() makes these calls safe and
-- prevents the race condition errors you were seeing previously.
-- =============================================================================


dap.listeners.after.event_initialized['dapui_open'] = function()
	vim.schedule(function()
		require('dapui').open()
	end)
end

dap.listeners.before.event_terminated['dapui_close'] = function()
	vim.schedule(function()
		require('dapui').close()
	end)
end

dap.listeners.after.event_exited['dapui_close'] = function()
	vim.schedule(function()
		require('dapui').close()
	end)
end

DAP_PRE_LAUNCH_TASK = nil

---
-- A universal "launch" function that is highly flexible.
-- 1. Skips the build step if _G.DAP_PRE_LAUNCH_TASK is nil or an empty string.
-- 2. Accepts an optional 'on_success' callback function to run.
--    If no callback is provided, it defaults to `dap.continue()`.
--
-- @param on_success_callback function (optional) The function to call after a
--        successful build or when skipping the build.
function build_and_debug(on_success_callback)
	-- Define the default action if no callback is provided.
	local on_success = on_success_callback or function()
		require('dap').continue()
	end

	local build_command = _G.DAP_PRE_LAUNCH_TASK

	-- Check if we should skip the build step.
	if not build_command or build_command == "" then
		vim.notify("No pre-launch task specified. Starting debugger directly...", vim.log.levels.INFO, { title = "DAP" })
		-- If skipping, just run the success callback immediately.
		on_success()
		return
	end

	-- If a build command was found, execute it.
	vim.notify("🚀 Running pre-launch task: " .. build_command, vim.log.levels.INFO, { title = "Pre-Launch Task" })
	local output = vim.fn.system(build_command)

	if vim.v.shell_error == 0 then
		vim.notify("✅ Task successful! Launching debugger...", vim.log.levels.INFO, { title = "Pre-Launch Task" })
		-- On successful build, run the success callback.
		on_success()
	else
		vim.notify("❌ Task FAILED! Debugger not launched.", vim.log.levels.ERROR, { title = "Pre-Launch Task" })
		print("==================== TASK FAILED ====================")
		print(output)
		print("=====================================================")
	end
end

-- UI & Session Control -------------------------------------------------------

vim.keymap.set("n", "<leader>dt", function() dapui.toggle() end, { desc = "DAP UI: Toggle" })
vim.keymap.set("n", "<leader>dx", function() dap.terminate() end, { desc = "DAP: Close Session" })

-- Exception Breakpoint Controls
vim.keymap.set("n", "<leader>deu", function()
	dap.set_exception_breakpoints({ "uncaught" })
	vim.notify("[DAP] Will break on UNCAUGHT exceptions.", vim.log.levels.INFO)
end, { desc = "DAP: Break on Uncaught Exceptions" })

vim.keymap.set("n", "<leader>dea", function()
	dap.set_exception_breakpoints({ "raised", "uncaught" })
	vim.notify("[DAP] Will break on ALL exceptions.", vim.log.levels.INFO)
end, { desc = "DAP: Break on All Exceptions" })

vim.keymap.set("n", "<leader>deo", function()
	dap.set_exception_breakpoints({})
	vim.notify("[DAP] Exception breakpoints turned OFF.", vim.log.levels.INFO)
end, { desc = "DAP: Turn Off Exception Breakpoints" })

-- Execution & Flow Control ---------------------------------------------------

vim.keymap.set('n', '<leader>dr', function() build_and_debug(dap.restart) end, { desc = "DAP: Restart Session" })
vim.keymap.set("n", "<leader>dn", function() build_and_debug(dap.continue) end, { desc = "DAP: Continue / Start" })
vim.keymap.set("n", "<leader>d_", function() build_and_debug(dap.run_last) end, { desc = "DAP: Run Last" })
vim.keymap.set("n", "<leader>dj", function() dap.step_over() end, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<leader>dk", function() dap.step_into() end, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<leader>dl", function() dap.step_out() end, { desc = "DAP: Step Out" })
vim.keymap.set('n', '<leader>dc', function() build_and_debug(dap.run_to_cursor) end, { desc = "DAP: Run to Cursor" })

-- Breakpoints & Inspection ---------------------------------------------------

vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set('n', '<leader>dB', function()
	local condition = vim.fn.input("Breakpoint condition: ")
	dap.set_breakpoint(condition)
end, { desc = "DAP: Set Conditional Breakpoint" })

vim.keymap.set("n", "<leader>d$", function() dap.repl.open({}, "vsplit") end, { desc = "DAP: Open REPL" })
vim.keymap.set("n", "<leader>d?", function()
	-- This allows you to type an expression to evaluate in the UI
	require("dapui").eval()
end, { desc = "DAP UI: Evaluate Expression" })

-- Hover Information ----------------------------------------------------------

vim.keymap.set("n", "<leader>di", function() require("dap.ui.widgets").hover() end, { desc = "DAP UI: Hover Variable" })
vim.keymap.set("v", "<leader>di", function() require("dap.ui.widgets").visual_hover() end,
	{ desc = "DAP UI: Hover Visual Selection" })
vim.keymap.set("n", "<leader>dei", function()
	require("dap.ui.widgets").fill_exception_info()
end, { desc = "DAP: Show Exception Info" })


-- IDE-Style Function Key Mappings --------------------------------------------
-- (Common mappings for those used to traditional IDEs)
--
vim.keymap.set('n', '<F4>', function() build_and_debug(dap.restart) end, { desc = "DAP: Restart Session" })
vim.keymap.set('n', '<F5>', function() build_and_debug(dap.continue) end, { desc = "DAP: Continue" })
vim.keymap.set('n', '<F9>', function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })

-- <F21> means Shift+F9
vim.keymap.set('n', '<F21>', function()
	local condition = vim.fn.input("Breakpoint condition: ")
	dap.set_breakpoint(condition)
end, { desc = "DAP: Set Conditional Breakpoint" })

vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "DAP: Step Over" })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "DAP: Step Into" })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = "DAP: Step Out" })


-- =============================================================================
-- ||                 GENERATE PROJECT-SPECIFIC DAP CONFIG                    ||
-- =============================================================================
-- || This section defines the :GenLaunch command which creates a             ||
-- || ./.nvim/launch.lua file using the new labeled configuration system.     ||
-- =============================================================================

---
-- Dumps the current configuration for the active filetype into a
-- launch.lua file, setting it as the 'default' labeled config.
local function dump_dap_config_as_default()
	-- 1. Get the current buffer's filetype and active DAP config
	local dap = require('dap')
	local ft = vim.bo.filetype
	if not ft or ft == '' then
		vim.notify("[DAP] No filetype detected for current buffer.", vim.log.levels.ERROR)
		return
	end

	local active_configs = dap.configurations[ft]
	if not active_configs or #active_configs == 0 then
		vim.notify("[DAP] No DAP configuration found for filetype: " .. ft, vim.log.levels.ERROR)
		return
	end

	-- We'll take the first available config as our template
	local config_to_save = vim.deepcopy(active_configs[1])

	-- 2. Inject the required fields for our label system
	config_to_save.label = "default"
	config_to_save.filetype = ft

	-- 3. Build the PROJECT_DAP_CONFIGS table with our single 'default' entry
	local project_configs_table = {
		default = config_to_save
	}

	-- 4. Serialize the new table and the adapters into strings
	local project_configs_string = vim.inspect(project_configs_table)
	local adapters_string = vim.inspect(dap.adapters)

	-- 5. Prepare the new file content in the correct format
	local file_content = string.format([[-- DAP configuration automatically generated by :GenLaunch on %s
-- This file uses the PROJECT_DAP_CONFIGS table structure.

-- You can define project-specific adapters here if needed.
-- The global adapters at the time of generation are included below.
local dap = require('dap')
dap.adapters = %s

-- This table holds all named debug configurations for the project.
-- The 'default' label is special: it will be loaded automatically on startup.
PROJECT_DAP_CONFIGS = %s
]], os.date(), adapters_string, project_configs_string)

	-- 6. Define paths and write the file
	local cwd = vim.fn.getcwd()
	local dir_path = cwd .. "/.nvim"
	local file_path = dir_path .. "/launch.lua"
	vim.fn.mkdir(dir_path, "p")

	local file = io.open(file_path, "w")
	if not file then
		vim.notify("[DAP] Error: Could not write to " .. file_path, vim.log.levels.ERROR)
		return
	end

	file:write(file_content)
	file:close()
	vim.notify("[DAP] Successfully generated labeled config: " .. file_path, vim.log.levels.INFO)
end

-- Create the user command pointing to the new function
vim.api.nvim_create_user_command(
	"GenLaunch",
	dump_dap_config_as_default,
	{
		desc = "Generates ./.nvim/launch.lua with the current config as 'default'"
	}
)

-- =============================================================================
-- 4. PROJECT-SPECIFIC CONFIGURATION LOGIC (ADVANCED)
-- =============================================================================
-- This section handles loading and selecting from a list of labeled configs.

---
-- Sets the active DAP configuration for a filetype based on a label.
-- @param label string The key from the PROJECT_DAP_CONFIGS table.
local function set_active_dap_config(label)
	-- 1. Check if the global project configs table has been loaded
	if not PROJECT_DAP_CONFIGS then
		vim.notify("[DAP] No project configurations loaded.", vim.log.levels.WARN)
		return
	end

	-- 2. Find the configuration corresponding to the label
	local selected_config = PROJECT_DAP_CONFIGS[label]
	if not selected_config then
		vim.notify("[DAP] No configuration found for label: " .. label, vim.log.levels.ERROR)
		return
	end

	-- 3. Get the filetype and clear any existing configs for it
	local ft = selected_config.filetype
	if not ft then
		vim.notify("[DAP] Config '" .. label .. "' is missing a 'filetype' field.", vim.log.levels.ERROR)
		return
	end
	dap.configurations[ft] = nil -- Clear previous configurations

	-- 4. Set the new active configuration
	-- We wrap it in a table because dap.configurations expects a list.
	dap.configurations[ft] = { selected_config }

	vim.notify("[DAP] Set active configuration to: " .. label, vim.log.levels.INFO)
end

---
-- Loads the launch.lua file and sets the 'default' config if it exists.
local function load_project_dap_config()
	local project_root = vim.fn.getcwd()
	local project_launch_file = project_root .. "/.nvim/launch.lua"
	local trust_file = project_root .. "/.nvim/.trusted"

	if vim.fn.filereadable(project_launch_file) ~= 1 then return end

	if vim.fn.filereadable(trust_file) == 1 then
		-- Reset the global table before loading
		PROJECT_DAP_CONFIGS = nil
		local ok, err = pcall(dofile, project_launch_file)
		if not ok then
			vim.notify("[DAP] Error in project config: " .. err, vim.log.levels.ERROR)
		else
			-- After loading, automatically set the "default" config if it exists
			if PROJECT_DAP_CONFIGS and PROJECT_DAP_CONFIGS.default then
				set_active_dap_config("default")
			else
				vim.notify("[DAP] Loaded project configs. Use :SetDAP to choose one.", vim.log.levels.INFO)
			end
		end
	else
		vim.notify("[DAP] Found project config, but it is NOT trusted.", vim.log.levels.WARN)
	end
end

-- Create the :SetDAP command
vim.api.nvim_create_user_command(
	"SetDAP",
	function(opts)
		set_active_dap_config(opts.args)
	end,
	{
		nargs = 1, -- Expects exactly one argument (the label)
		complete = function()
			-- Provide tab-completion for the labels!
			if PROJECT_DAP_CONFIGS then
				local labels = {}
				for k, _ in pairs(PROJECT_DAP_CONFIGS) do table.insert(labels, k) end
				return labels
			end
			return {}
		end,
		desc = "Set the active DAP configuration by label: :SetDAP <label>"
	}
)

-- (The rest of your config: autocommand, GenLaunch command, initial call...)
-- The autocommand to reload the file on save still works perfectly with this new setup.
local dap_project_group = vim.api.nvim_create_augroup('DapProjectConfig', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
	group = dap_project_group,
	pattern = '*/.nvim/launch.lua',
	callback = load_project_dap_config,
	desc = "Reload DAP project config on save"
})

---
-- A reusable function that prompts the user to enter command-line arguments
-- for a DAP session. It parses the input string into a table of arguments.
-- @return table A list of strings, e.g., {"--foo", "bar"}
function ArgsInput()
	-- 1. Display a prompt and get the input string from the user.
	local input_str = vim.fn.input("Enter Arguments: ")

	-- 2. If the user just presses Enter, return an empty table.
	if input_str == "" then
		return {}
	end

	-- 3. Parse the input string, splitting by spaces.
	local args_table = {}
	-- The pattern '[^%s]+' finds all sequences of one or more non-space characters.
	for arg in string.gmatch(input_str, "[^%s]+") do
		table.insert(args_table, vim.fn.expand(arg))
	end

	-- 4. Return the final table of arguments.
	return args_table
end

-- Run the loading function once on startup
load_project_dap_config()


-- =============================================================================
-- ||                     TEMPORARY DEBUG KEYMAP                            ||
-- =============================================================================
-- This keymap will print the contents of DAP modules so we can find functions.
vim.keymap.set('n', '<leader>DUMP', function()
	-- Clear previous messages
	vim.cmd('messages clear')

	print("--- INSPECTING nvim-dap's WIDGETS ---")
	-- We use pcall (protected call) so it doesn't error if the module doesn't exist
	local dap_widgets_ok, dap_widgets = pcall(require, "dap.ui.widgets")
	if dap_widgets_ok then
		print(vim.inspect(dap_widgets))
	else
		print("Could not require 'dap.ui.widgets'.")
	end

	print("\n--- INSPECTING nvim-dap-ui ---")
	local dapui_ok, dapui = pcall(require, "dapui")
	if dapui_ok then
		print(vim.inspect(dapui))
	else
		print("Could not require 'dapui'.")
	end

	print("\n--- INSPECTION COMPLETE ---")
	print("Please run :messages and copy the output above this line.")
end, { desc = "DEBUG: Dump DAP/DAPUI module contents" })
