# tabs.nvim

A (WIP) tabline plugin for Neovim that always shows your tabs in order of recency.

## Installation

With `lazy.nvim`:

```lua
{
	"vi013t/tabs.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional
	opts = {},
	event = "VeryLazy",

	-- example keymaps
	init = function()
		vim.keymap.set("n", "<C-S-L>", require("tabs").next)
		vim.keymap.set("n", "<C-S-H>", require("tabs").previous)
		vim.keymap.set("n", "<C-S-CR>", require("tabs").select)
	end
}
```

## Configuration

<summary>
	<details>Default Configuration</details>

```lua
opts = {
	--- Width of all tabs
	tab_width = 25,

	--- Only show the tabline when switching tabs
	autohide = false,

	--- Timeout (in seconds) to un-select tab after not confirming; Set to `nil` for no timeout
	timeout = 5,

	--- Offsets for the tabline
	offsets = {

		-- Neo-tree
		{
			filetype = "neo-tree",
			title = function()
				local has_devicons = pcall(require, "nvim-web-devicons")
				if has_devicons then
					return " Neo-Tree"
				else
					return "Neo-Tree"
				end
			end,
		},
	},

	--- Filetypes to ignore and not show tabs for
	ignored = { "neo-tree" },

	--- Highlight groups used by the plugin. `fg` and `bg` values can either be hex colors
	--- or existing highlight group names
	highlights = {
		["TabsUnfocused"] = { fg = "NormalFloat", bg = "NormalFloat" },
		["TabsUnfocusedClose"] = { fg = "DiagnosticError", bg = "NormalFloat" },

		["TabsFocused"] = { fg = "Normal", bg = "Normal" },
		["TabsFocusedClose"] = { fg = "DiagnosticError", bg = "Normal" },

		["TabsSelected"] = { fg = "Type", bg = "NormalFloat", bold = true, italic = true },
		["TabsSelectedClose"] = { fg = "DiagnosticError", bg = "NormalFloat" },

		["TabsSeparator"] = { fg = "NonText", bg = "NormalFloat" },
	},
}
```
</summary>
