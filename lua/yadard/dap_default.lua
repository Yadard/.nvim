local dap = require('dap')

-- Python Debug Adapter
dap.adapters.python = {
	type = 'executable',
	command = '/usr/bin/python', -- Or the path to your python executable
	args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
	{
		type = 'python',
		request = 'launch',
		name = 'Launch file',
		-- The path to the file to be debugged, which is the current file
		program = "${file}",
		-- Optional: The directory where the debugger should start
		cwd = vim.fn.getcwd(),
		-- Optional: command-line arguments for your script
		args = function()
			local input = vim.fn.input("Arguments: ")
			local args = {}
			for arg in string.gmatch(input, "[^%s]+") do
				table.insert(args, arg)
			end
			return args
		end,
	},
}

dap.adapters.codelldb = {
	type = 'server',
	-- This dynamically finds the codelldb executable inside your Mason installation
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
	port = "${port}"
}

-- The 'c' and 'cpp' filetypes will share the same configuration.
dap.configurations.c = {
	{
		name = "Launch file",
		type = "codelldb", -- This must match the name of the adapter.
		request = "launch",

		-- This function will run before launching, asking for the executable path.
		program = "${workspaceFolder}/a.out",

		cwd = '${workspaceFolder}',
		stopOnEntry = false,

		-- We can reuse our global function to ask for arguments!
		args = ArgsInput,
	},
}

dap.configurations.cpp = dap.configurations.c -- Share the same config for C++
