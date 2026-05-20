--- yank-append: ranger-style "ya" — add current selection/hovered to the existing yanked buffer
--- without overwriting it. Usage from keymap:
---     plugin yank-append           -- append (copy)
---     plugin yank-append -- --cut  -- append (cut)

local collect = ya.sync(function()
	local urls, seen = {}, {}
	local function add(u)
		local s = tostring(u)
		if not seen[s] then
			seen[s] = true
			urls[#urls + 1] = Url(s)
		end
	end

	for _, u in pairs(cx.yanked) do
		add(u)
	end

	local tab = cx.active
	if #tab.selected > 0 then
		for _, u in pairs(tab.selected) do
			add(u)
		end
	elseif tab.current.hovered then
		add(tab.current.hovered.url)
	end

	return urls
end)

local function entry(_, job)
	local cut = false
	for _, a in ipairs(job.args or {}) do
		if a == "--cut" then
			cut = true
		end
	end

	local merged = collect()
	if #merged == 0 then
		return
	end

	ya.emit("escape", { select = true })
	merged.state = "on"
	ya.emit("toggle_all", merged)
	ya.emit("yank", cut and { cut = true } or {})
end

return { entry = entry }
