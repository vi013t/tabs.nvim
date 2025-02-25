local config = require("tabs.config")
local utils = require("tabs.utils")

local tabs = {}

local visited_buffers = {}

local selected_index = 1

--- Formats the given text to be highlighted with the given highlight group,
--- as Vim expects it to be when rendering the tabline.
---
---@param text string
---@param group Highlight
---
---@return string
function tabs.highlight(text, group)
	return "%#" .. group .. "#" .. text .. "%#TabsUnfocused#"
end

---@return nil
tabs.tabline = function()
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

		local close_highlight = highlight .. "Close"

		if buffer_exists then
			local tab_title = buffer_name:match("([^/]+)$") or ""

			local extra_characters = 3
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

			-- Close button
			result = result .. tabs.highlight(" 󰅖 ", close_highlight)

			-- Separator
			if index ~= 1 and index ~= #visited_buffers - 1 then
				result = result .. tabs.highlight("│", "TabsSeparator")
			end
		end
	end

	result = result .. tabs.highlight("", "TabsFocused")

	return result
end

---@return nil
function tabs.next()
	selected_index = selected_index + 1
	vim.cmd("redrawtabline")
end

---@return nil
function tabs.previous()
	selected_index = selected_index - 1
	vim.cmd("redrawtabline")
end

---@return nil
function tabs.select()
	vim.api.nvim_set_current_buf(visited_buffers[selected_index].buffer)
	selected_index = 1
	vim.cmd("redrawtabline")
end

---
---
---@param opts TabUserConfig
---
---@return nil
tabs.setup = function(opts)
	config.setup(opts)

	for name, value in pairs(config.options.highlights) do
		local fg = vim.api.nvim_get_hl(0, { name = value.fg }).fg
		local bg = vim.api.nvim_get_hl(0, { name = value.bg }).bg
		vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = value.bold, italic = value.italic })
	end

	vim.api.nvim_create_user_command("TabsNext", tabs.next, {})
	vim.api.nvim_create_user_command("TabsOpen", tabs.select, {})

	vim.opt.showtabline = 2
	vim.opt.tabline = "%!v:lua.require('tabs').tabline()"

	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function(args)
			-- Ignored
			if vim.list_contains(config.options.ignored, vim.bo.ft) then
				return
			end

			-- Remove existing entry
			visited_buffers = vim.tbl_filter(function(buffer_info)
				return buffer_info.buffer ~= args.buf
			end, visited_buffers)

			-- Devicon
			local has_devicons, devicons = pcall(function()
				return require("nvim-web-devicons")
			end)
			local icon = ""
			local icon_color = nil
			if has_devicons then
				local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
				icon = devicons.get_icon_by_filetype(filetype, {})

				local icon_group = "DevIcon" .. filetype:sub(1, 1):upper() .. filetype:sub(2)

				local fg = vim.api.nvim_get_hl(0, { name = icon_group }).fg
				local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
				vim.api.nvim_set_hl(0, "Tabs" .. icon_group, { fg = fg, bg = bg })

				icon_color = "Tabs" .. icon_group
			end

			-- Add it
			table.insert(visited_buffers, 1, { buffer = args.buf, icon = icon, icon_color = icon_color })

			-- Reload
			vim.cmd("redrawtabline")
		end,
	})
end

return tabs
