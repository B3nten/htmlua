local h = {}
local h_mt = {
	__index = function(_, key)
		return function(props)
			local obj = { __tag = key }
			for k, v in pairs(props) do
				obj[k] = v
			end
			return obj
		end
	end
}
setmetatable(h, h_mt)

local function camel_to_kebab(str)
	return str:gsub("%u", function(c) return "-" .. c:lower() end)
end

local function parseStyles(style)
	local str = ""
	for i, v in pairs(style) do
		str = str .. camel_to_kebab(i) .. ":" .. v .. ";"
	end
	return str
end

function h.render(element, indentLevel)
	indentLevel = indentLevel or 0
	local indent = string.rep("\t", indentLevel)

	-- Initialize the HTML output string
	local html = ""

	-- If the element is not a table or doesn't have a __tag, ignore it
	if type(element) == "string" then
		return element
	end

	if type(element) ~= "table" or not element.__tag then
		return ""
	end

	-- Open the HTML tag
	html = html .. indent .. "<" .. element.__tag

	-- Add attributes
	for k, v in pairs(element) do
		if k == "style" and type(v) == "table" then
			html = html .. string.format(' %s="%s"', k, parseStyles(v))
		elseif type(k) == "string" and k:sub(1, 2) == "hx" then
			html = html .. string.format(' %s="%s"', camel_to_kebab(k), v)
		elseif k ~= "__tag" and type(v) ~= "table" and type(k) ~= "number" then
			html = html .. string.format(' %s="%s"', k, v)
		end
	end

	-- Close the opening tag
	html = html .. ">\n"

	-- Process children and nested attributes
	for k, v in pairs(element) do
		if type(v) == "table" then
			html = html .. h.render(v, indentLevel + 1)
		elseif k ~= "__tag" and type(k) == "number" then
			html = html .. indent .. "\t" .. tostring(v) .. "\n"
		end
	end

	-- Close the HTML tag
	html = html .. indent .. "</" .. element.__tag .. ">\n"

	return html
end

local markup = h.div {
	class = "text-3xl",
	"cool",
	"ok",
	hxSwap = "outerHTML",
	h.span {
		"lol",
		id = "span",
		style = { backgroundColor = "red", objectFit = "cover" },
		h.a{
			src = "lol",
			"cool shit here"
		}
	}
}

local html = h.render(markup)
print(html)
