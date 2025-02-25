local utils = {}

---@param text string
function utils.center(text, length)
	-- Strip highlight groups out
	local raw_text = text:gsub("%%#[a-zA-Z]+#", "")

	local width = vim.fn.strwidth(raw_text)

	if width > length then
		return text:sub(1, length - 1) .. ""
	end

	local left_padding = (length - width) / 2
	local right_padding = left_padding
	if width % 2 == 0 then
		right_padding = right_padding + 1
	end
	return (" "):rep(left_padding) .. text .. (" "):rep(right_padding)
end

return utils
