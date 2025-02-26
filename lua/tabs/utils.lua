local utils = {}

--- Centers the given text in the given length, padding it with spaces.
--- If the text is too long, it will be truncated with ellipsis.
---
---@param text string The text to center
---@param length integer The length of the space to center the text in.
---
---@return string text The centered text, padded with spaces.
function utils.center(text, length)
	-- Strip highlight groups out
	local raw_text = text:gsub("%%#[a-zA-Z]+#", "")

	-- Get the actual text width in glyphs, not bytes
	local width = vim.fn.strwidth(raw_text)

	-- If the text is too long, truncate it and return it
	if width > length then
		return text:sub(1, length - 1) .. ""
	end

	-- Get padding
	local left_padding = (length - width) / 2
	local right_padding = left_padding
	if width % 2 == 0 then
		right_padding = right_padding + 1
	end

	-- Return padded text
	return (" "):rep(left_padding) .. text .. (" "):rep(right_padding)
end

--- Returns whether the given string is a 6 digit hex color.
---
---@param text string the text to test.
---
---@return boolean is_hex_color Whether the given text is a hex color.
function utils.is_hex_color(text)
	local match = text:match("^#%x%x%x%x%x%x$")
	return match ~= nil
end

return utils
