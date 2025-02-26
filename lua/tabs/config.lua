local config = {}

---@alias HighlightName "TabsClose" | "TabsFocused" | "TabsUnfocused" | "TabsSeparator" | "TabsSelected" | "TabsSelectedClose"
---@alias Highlight { bg?: string, fg?: string, bold?: boolean, italic?: boolean }
---@alias Offset { filetype: string, title: fun(): string }

---@class TabConfig
---
---@field offsets Offset[]
---@field ignored string[]
---@field highlights table<HighlightName, Highlight>
---@field tab_width integer
---@field autohide boolean
---@field max_tabs integer

---@alias UserOffset { filetype: string, title: string | fun(): string }

---@class TabUserConfig
---
---@field offsets? UserOffset[]
---@field ignored? string[]
---@field highlights? table<HighlightName, Highlight>
---@field tab_width? integer
---@field autohide? boolean

---@type TabConfig
config.default = {

	--- Width of all tabs
	tab_width = 25,

	max_tabs = 6,

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

		{
			filetype = "dragonfly",
			title = function()
				local has_devicons = pcall(require, "nvim-web-devicons")
				if has_devicons then
					return " Dragonfly"
				else
					return "Dragonfly"
				end
			end,
		},
	},

	--- Filetypes to ignore and not show tabs for
	ignored = { "neo-tree" },

	--- Highlight groups used by the plugin. `fg` and `bg` values can either be hex colors
	--- or existing highlight group names
	highlights = {
		["TabsFocused"] = { fg = "Normal", bg = "Normal" },
		["TabsUnfocused"] = { fg = "NormalFloat", bg = "NormalFloat" },
		["TabsSelected"] = { fg = "Type", bg = "NormalFloat", bold = true, italic = true },
		["TabsSeparator"] = { fg = "NonText", bg = "NormalFloat" },
	},
}

---@param opts TabUserConfig
function config.setup(opts)
	config.options = vim.tbl_deep_extend("force", config.default, opts)

	-- Offsets
	config.options.offsets = vim.tbl_map(function(offset)
		if type(offset.title) == "string" then
			local title = offset.title
			offset.title = function()
				return title
			end
		end
		return offset
	end, config.options.offsets)
end

return config
