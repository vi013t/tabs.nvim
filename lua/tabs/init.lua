local config = require("tabs.config")
local utils = require("tabs.utils")

local tabs = {}

--- Information about the buffers the user visits. This is always sorted by recency, i.e.,
--- the first element is the current buffer, the second is the lasy visited buffer, etc.
---
---@type { buffer: integer, icon: string | nil, icon_color: string | nil }[]
local visited_buffers = {}

local selected_index = 1

--- Formats the given text to be highlighted with the given highlight group,
--- as Vim expects it to be when rendering the tabline.
---
---@param text string The text to highlight
---@param group HighlightName The highlight group to highlight it with
---
---@return string text The highlighted text
function tabs.highlight(text, group)
	return "%#" .. group .. "#" .. text .. "%#TabsUnfocused#"
end

--- Creates the tabline. This is passed to `vim.opt.tabline` in the form:
---
--- ```lua
--- vim.opt.tabline = "%!v:lua.require('tabs').tabline()"
--- ```
---
--- When doing so, ensure that `vim.opt.showtabline = 2`.
---
---@return nil
function tabs.tabline()
	local result = ""

	-- Offsets
	for _, offset in ipairs(config.options.offsets) do
		for _, window in ipairs(vim.api.nvim_list_wins()) do
			local buffer = vim.api.nvim_win_get_buf(window)
			if vim.api.nvim_get_option_value("filetype", { buf = buffer }) == offset.filetype then
				result = result .. utils.center(offset.title(), vim.api.nvim_win_get_width(window))
			end
		end
	end

	-- Buffers
	for index, buffer_info in ipairs(visited_buffers) do
		if index == config.options.max_tabs + 1 then
			break
		end

		local buffer_exists, buffer_name = pcall(function()
			return vim.api.nvim_buf_get_name(buffer_info.buffer)
		end)

		local highlight = "TabsUnfocused"
		if index == selected_index then
			highlight = "TabsSelected"
		end
		if index == 1 then
			highlight = "TabsFocused"
		end

		if buffer_exists then
			local tab_title = buffer_name:match("([^/]+)$") or ""

			local extra_characters = 0
			if buffer_info.icon ~= nil then
				extra_characters = extra_characters + 2
			end

			local padding = math.max((config.options.tab_width - #tab_title - extra_characters) / 2, 0)

			-- Left padding
			result = result .. tabs.highlight((" "):rep(padding), highlight)

			-- Icon
			if buffer_info.icon ~= nil then
				result = result .. tabs.highlight(buffer_info.icon .. " ", buffer_info.icon_color)
			end

			-- Title
			result = result .. tabs.highlight(tab_title, highlight)

			-- Right padding
			result = result .. tabs.highlight((" "):rep(padding), highlight)

			-- Separator
			if index ~= 1 then
				result = result .. tabs.highlight("│", "TabsSeparator")
			end
		end
	end

	result = result .. tabs.highlight("", "TabsFocused")

	return result
end

--- Selects the next (right) tab.
---
---@return nil
function tabs.next()
	selected_index = math.min(selected_index + 1, #visited_buffers - 1)
	vim.cmd("redrawtabline")
end

--- Selects the previous (left) tab.
---
---@return nil
function tabs.previous()
	selected_index = math.max(selected_index - 1, 1)
	vim.cmd("redrawtabline")
end

--- Opens the selected tab.
---
---@return nil
function tabs.open()
	vim.api.nvim_set_current_buf(visited_buffers[selected_index].buffer)
	selected_index = 1
	vim.cmd("redrawtabline")
	if config.options.autohide then
		vim.opt.tabline = 0
	end
end

--- Sets up the plugin's highlights based on the user's configuration.
---
---@param highlights table<HighlightName, Highlight> The highlights from the user's configuration
---
---@return nil
local function setup_highlights(highlights)
	for name, value in pairs(highlights) do
		-- Foreground
		local fg = value.fg
		if not utils.is_hex_color(value.fg) then
			---@diagnostic disable-next-line: cast-local-type
			fg = vim.api.nvim_get_hl(0, { name = value.fg }).fg
		end

		-- Background
		local bg = value.bg
		if not utils.is_hex_color(value.bg) then
			---@diagnostic disable-next-line: cast-local-type
			bg = vim.api.nvim_get_hl(0, { name = value.bg }).bg
		end

		-- Set the highlight
		vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = value.bold, italic = value.italic })
	end
end

--- Called when the user enters a buffer. This gets information about the buffer
--- and adds it to the beginning of the `visited_buffers` list, removing old
--- information about the buffer if it exists.
---
---@param buffer integer The buffer number the user opened
---
---@return nil
local function visit_buffer(buffer)
	-- Ignored
	if vim.list_contains(config.options.ignored, vim.bo.ft) then
		return
	end

	-- Remove existing entry
	visited_buffers = vim.tbl_filter(function(buffer_info)
		return buffer_info.buffer ~= buffer
	end, visited_buffers)

	-- Devicon
	local has_devicons, devicons = pcall(function()
		return require("nvim-web-devicons")
	end)
	local icon = ""
	local icon_color = nil
	if has_devicons then
		local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })
		icon = devicons.get_icon_by_filetype(filetype, {})

		local icon_name = devicons.get_icon_name_by_filetype(filetype) or ""
		local icon_group = "DevIcon" .. icon_name:sub(1, 1):upper() .. icon_name:sub(2)

		local fg = vim.api.nvim_get_hl(0, { name = icon_group }).fg
		local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
		vim.api.nvim_set_hl(0, "Tabs" .. icon_group, { fg = fg, bg = bg })

		icon_color = "Tabs" .. icon_group
	end

	-- Add it
	table.insert(visited_buffers, 1, { buffer = buffer, icon = icon, icon_color = icon_color })

	-- Reload
	vim.cmd("redrawtabline")
end

--- Sets up the tabline plugin with the specified options.
---
---@param opts TabUserConfig Configuration options from the plugin user.
---
---@return nil
tabs.setup = function(opts)
	config.setup(opts)
	setup_highlights(config.options.highlights)

	vim.api.nvim_create_user_command("TabsNext", tabs.next, {})
	vim.api.nvim_create_user_command("TabsPrevious", tabs.previous, {})
	vim.api.nvim_create_user_command("TabsOpen", tabs.open, {})

	vim.opt.showtabline = 2
	if config.options.autohide then
		vim.opt.showtabline = 0
	end

	vim.opt.tabline = "%!v:lua.require('tabs').tabline()"

	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function(args)
			visit_buffer(args.buf)
		end,
	})
end

return tabs
