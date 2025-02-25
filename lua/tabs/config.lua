local config = {}

---@alias Highlight "TabsClose" | "TabsFocused" | "TabsUnfocused" | "TabsSeparator" | "TabsSelected" | "TabsSelectedClose"
---@alias Offset { filetype: string, title: fun(): string }

---@class TabConfig
---
---@field offsets Offset[]
---@field ignored string[]
---@field highlights table<Highlight, { bg?: string, fg?: string, bold?: boolean, italic?: boolean }>
---@field tab_width integer

---@alias UserOffset { filetype: string, title: fun(): string | string }

---@class TabUserConfig
---
---@field offsets? UserOffset[]
---@field ignored? string[]
---@field highlights? table<Highlight, { bg?: string, fg?: string, bold?: boolean, italic?: boolean }>
---@field tab_width? integer

---@type TabConfig
config.default = {

	--- Width of all tabs
	tab_width = 25,

	--- Only show the tabline when switching tabs
	autohide = false,

	--- Timeout to un-select tab after not confirming; Set to `nil` for no timeout
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

---@param opts TabUserConfig
function config.setup(opts)
	config.options = vim.tbl_deep_extend("force", config.default, opts)
end

return config
