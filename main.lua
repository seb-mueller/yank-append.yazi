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

	-- since yazi v26.8.15, `cx.yanked` and `tab.selected` yield File, not Url
	for _, f in pairs(cx.yanked) do
		add(f.url)
	end

	local tab = cx.active
	if #tab.selected > 0 then
		for _, f in pairs(tab.selected) do
			add(f.url)
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

	-- `toggle_all` takes File objects; given none it selects the whole CWD
	local files = {}
	for _, u in ipairs(collect()) do
		files[#files + 1] = fs.file(u)
	end
	if #files == 0 then
		return
	end

	ya.emit("escape", { select = true })
	files.state = "on"
	ya.emit("toggle_all", files)
	ya.emit("yank", cut and { cut = true } or {})
end

return { entry = entry }
