local dapui = require('dapui')
dapui.setup()


local dap = require('dap')
local uivar = require('dap.ui.widgets')
local dapp = require('nvim-dap-projects')
dapp.search_project_config()

dap.set_log_level("DEBUG")
-- dap.adapters.lldb = {
--  type = 'executable',
--  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
--  name = 'lldb'
--}

dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
end
dap.listeners.after.event_terminated['dapui_config'] = function()
    dapui.close()
end
dap.listeners.after.event_exited['dapui_config'] = function()
    dapui.close()
end

vim.keymap.set("n", "<leader>dt", dapui.toggle)
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<S-,>", dap.step_out)
vim.keymap.set("n", "<S-.>", dap.step_into)
vim.keymap.set("n", "<S-;>", dap.step_over)
vim.keymap.set("n", "<leader>dn", dap.continue)
vim.keymap.set("n", "<leader>dx", dap.stop)
vim.keymap.set("n", "<leader>d_", dap.run_last)
-- vim.keymap.set("n", "<leader>dr", dap.repl.open({}, "vsplit"))
-- :sovim.keymap.set("n", "<leader>di", uivar.hover(function() return vim.fn.expand("<cexpr>") end))
-- vim.keymap.set("v", "<leader>di", uivar.visual_hover())
-- vim.keymap.set("n", "<leader>d?", uivar.scopes())
-- vim.keymap.set("n", "<leader>de", dap.set_exception_breakpoints({"all"}))
