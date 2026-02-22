return function(services)
	local TweenService = services.TweenService
	local HttpService = services.HttpService

	local Colors = {
		Background = Color3.fromRGB(20, 20, 20),
		Sidebar = Color3.fromRGB(15, 15, 15),
		ItemBG = Color3.fromRGB(35, 35, 35),
		TextMain = Color3.fromRGB(255, 255, 255),
		TextSub = Color3.fromRGB(180, 180, 180),
		ToggleOn = Color3.fromRGB(0, 85, 165),
		ToggleOff = Color3.fromRGB(80, 80, 80),
		Button = Color3.fromRGB(50, 50, 50),
		ButtonHover= Color3.fromRGB(70, 70, 70),
		Accent = Color3.fromRGB(0, 85, 165),
		Stroke = Color3.fromRGB(60, 60, 60),
		HeaderLine = Color3.fromRGB(50, 50, 50),
		MiniGG = Color3.fromRGB(0, 0, 0),
	}

	local Themes = {
		Default = {
			Background = Color3.fromRGB(20, 20, 20),
			Sidebar = Color3.fromRGB(15, 15, 15),
			ItemBG = Color3.fromRGB(35, 35, 35),
			TextMain = Color3.fromRGB(255, 255, 255),
			TextSub = Color3.fromRGB(180, 180, 180),
			ToggleOn = Color3.fromRGB(0, 85, 165),
			ToggleOff = Color3.fromRGB(80, 80, 80),
			Button = Color3.fromRGB(50, 50, 50),
			ButtonHover = Color3.fromRGB(70, 70, 70),
			Accent = Color3.fromRGB(0, 85, 165),
			Stroke = Color3.fromRGB(60, 60, 60),
			HeaderLine = Color3.fromRGB(50, 50, 50),
			MiniGG = Color3.fromRGB(0, 0, 0),
		},
		Crimson = {
			Background = Color3.fromRGB(26, 16, 16),
			Sidebar = Color3.fromRGB(18, 10, 10),
			ItemBG = Color3.fromRGB(45, 22, 22),
			TextMain = Color3.fromRGB(255, 235, 235),
			TextSub = Color3.fromRGB(200, 150, 150),
			ToggleOn = Color3.fromRGB(200, 30, 30),
			ToggleOff = Color3.fromRGB(90, 45, 45),
			Button = Color3.fromRGB(65, 28, 28),
			ButtonHover= Color3.fromRGB(88, 38, 38),
			Accent = Color3.fromRGB(215, 35, 35),
			Stroke = Color3.fromRGB(130, 35, 35),
			HeaderLine = Color3.fromRGB(80, 30, 30),
			MiniGG = Color3.fromRGB(18, 6, 6),
		},
		Yellow = {
			Background = Color3.fromRGB(22, 20, 10),
			Sidebar = Color3.fromRGB(16, 14, 6),
			ItemBG = Color3.fromRGB(40, 36, 14),
			TextMain = Color3.fromRGB(255, 248, 200),
			TextSub = Color3.fromRGB(190, 170, 90),
			ToggleOn = Color3.fromRGB(210, 165, 0),
			ToggleOff = Color3.fromRGB(80, 68, 20),
			Button = Color3.fromRGB(55, 48, 16),
			ButtonHover = Color3.fromRGB(75, 65, 22),
			Accent = Color3.fromRGB(230, 185, 0),
			Stroke = Color3.fromRGB(100, 85, 20),
			HeaderLine = Color3.fromRGB(70, 60, 15),
			MiniGG = Color3.fromRGB(16, 12, 5),
		},
		NavyBlue = {
			Background = Color3.fromRGB(10, 14, 26),
			Sidebar = Color3.fromRGB(7, 10, 20),
			ItemBG = Color3.fromRGB(18, 26, 50),
			TextMain = Color3.fromRGB(210, 220, 255),
			TextSub = Color3.fromRGB(100, 125, 185),
			ToggleOn = Color3.fromRGB(40, 90, 200),
			ToggleOff = Color3.fromRGB(35, 50, 90),
			Button = Color3.fromRGB(22, 34, 68),
			ButtonHover= Color3.fromRGB(30, 46, 92),
			Accent = Color3.fromRGB(55, 110, 220),
			Stroke = Color3.fromRGB(40, 65, 140),
			HeaderLine = Color3.fromRGB(28, 44, 90),
			MiniGG = Color3.fromRGB(7, 8, 20),
		},
		CosmicPurple = {
			Background = Color3.fromRGB(16, 10, 24),
			Sidebar = Color3.fromRGB(11, 7, 18),
			ItemBG = Color3.fromRGB(32, 18, 50),
			TextMain = Color3.fromRGB(235, 215, 255),
			TextSub = Color3.fromRGB(155, 110, 200),
			ToggleOn = Color3.fromRGB(130, 50, 210),
			ToggleOff = Color3.fromRGB(65, 35, 95),
			Button = Color3.fromRGB(44, 24, 70),
			ButtonHover= Color3.fromRGB(60, 34, 95),
			Accent = Color3.fromRGB(150, 65, 235),
			Stroke = Color3.fromRGB(90, 45, 145),
			HeaderLine = Color3.fromRGB(55, 28, 88),
			MiniGG = Color3.fromRGB(14, 7, 21),
		},
		PinkFlakes = {
			Background = Color3.fromRGB(24, 12, 18),
			Sidebar = Color3.fromRGB(18, 8, 13),
			ItemBG = Color3.fromRGB(48, 22, 36),
			TextMain = Color3.fromRGB(255, 220, 235),
			TextSub = Color3.fromRGB(200, 130, 165),
			ToggleOn = Color3.fromRGB(210, 60, 120),
			ToggleOff = Color3.fromRGB(90, 35, 60),
			Button = Color3.fromRGB(65, 26, 45),
			ButtonHover= Color3.fromRGB(88, 36, 62),
			Accent = Color3.fromRGB(230, 75, 140),
			Stroke = Color3.fromRGB(140, 45, 88),
			HeaderLine = Color3.fromRGB(80, 28, 55),
			MiniGG = Color3.fromRGB(21, 7, 15),
		},
		TrueBlack = {
			Background = Color3.fromRGB(0, 0, 0),
			Sidebar = Color3.fromRGB(2, 2, 2),
			ItemBG = Color3.fromRGB(10, 10, 10),
			TextMain = Color3.fromRGB(240, 240, 240),
			TextSub = Color3.fromRGB(140, 140, 140),
			ToggleOn = Color3.fromRGB(0, 85, 165),
			ToggleOff = Color3.fromRGB(35, 35, 35),
			Button = Color3.fromRGB(14, 14, 14),
			ButtonHover = Color3.fromRGB(22, 22, 22),
			Accent = Color3.fromRGB(0, 85, 165),
			Stroke = Color3.fromRGB(28, 28, 28),
			HeaderLine = Color3.fromRGB(18, 18, 18),
			MiniGG = Color3.fromRGB(0, 0, 0),
		},
		Amber = {
			Background = Color3.fromRGB(20, 14, 6),
			Sidebar = Color3.fromRGB(14, 9, 3),
			ItemBG = Color3.fromRGB(40, 26, 8),
			TextMain = Color3.fromRGB(255, 235, 185),
			TextSub = Color3.fromRGB(190, 140, 70),
			ToggleOn = Color3.fromRGB(200, 110, 0),
			ToggleOff = Color3.fromRGB(80, 50, 14),
			Button = Color3.fromRGB(55, 34, 10),
			ButtonHover = Color3.fromRGB(75, 48, 14),
			Accent = Color3.fromRGB(220, 125, 0),
			Stroke = Color3.fromRGB(110, 65, 12),
			HeaderLine = Color3.fromRGB(68, 42, 8),
			MiniGG = Color3.fromRGB(18, 11, 2),
		},
		Evergreen = {
			Background = Color3.fromRGB(14, 22, 16),
			Sidebar = Color3.fromRGB(10, 16, 12),
			ItemBG = Color3.fromRGB(24, 40, 28),
			TextMain = Color3.fromRGB(215, 255, 220),
			TextSub = Color3.fromRGB(130, 185, 140),
			ToggleOn = Color3.fromRGB(38, 165, 68),
			ToggleOff = Color3.fromRGB(45, 75, 50),
			Button = Color3.fromRGB(30, 55, 35),
			ButtonHover = Color3.fromRGB(44, 72, 48),
			Accent = Color3.fromRGB(50, 185, 80),
			Stroke = Color3.fromRGB(45, 90, 52),
			HeaderLine = Color3.fromRGB(35, 62, 40),
			MiniGG = Color3.fromRGB(7, 12, 8),
		},
	}

	local ThemeDisplayNames = {
		Default = "Default",
		Crimson = "Crimson",
		Evergreen = "Evergreen",
		Yellow = "Yellow",
		NavyBlue = "Navy Blue",
		CosmicPurple = "Cosmic Purple",
		PinkFlakes = "Pink Flakes",
		TrueBlack = "True Black",
		Amber = "Amber",
		Custom = "Custom",
	}

	local MiniGGSizes = {
		["Very Small"] = {size = 38, stroke = 0.7, corner = 8},
		["Small"] = {size = 46, stroke = 0.9, corner = 9},
		["Default"] = {size = 55, stroke = 1.1, corner = 10},
		["Big"] = {size = 66, stroke = 1.4, corner = 12},
		["Very Big"] = {size = 80, stroke = 1.8, corner = 14},
	}

	local ThemedRefs = {}
	local _itemRegistry = {}
	local _regCounters = {}

	local function reg(obj, prop, colorRole)
		table.insert(ThemedRefs, {obj = obj, prop = prop, role = colorRole})
	end

	local function _reg(title, frame, origParent)
		local key = tostring(origParent)
		_regCounters[key] = (_regCounters[key] or 0) + 1
		frame.LayoutOrder = _regCounters[key]
		table.insert(_itemRegistry, {title = title:lower(), frame = frame, origParent = origParent})
	end

	local _toggleStates     = {}
	local _savedTogglesPath = "GGHub/ToggleStates.json"

	if isfile(_savedTogglesPath) then
		local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(_savedTogglesPath))
		if ok and data then _toggleStates = data end
	end

	local function saveToggleStates()
		pcall(function()
			if not isfolder("GGHub") then makefolder("GGHub") end
			writefile(_savedTogglesPath, HttpService:JSONEncode(_toggleStates))
		end)
	end

	local function generateCustomTheme(h, s, v)
		local function hsv(hh, ss, vv)
			return Color3.fromHSV(hh, math.clamp(ss, 0, 1), math.clamp(vv, 0, 1))
		end
		local function vivid(hh, ss, vv)
			local c = Color3.fromHSV(hh, math.clamp(ss, 0, 1), math.clamp(vv, 0, 1))
			return Color3.new(math.min(c.R * 1.18, 1), math.min(c.G * 1.18, 1), math.min(c.B * 1.18, 1))
		end
		return {
			Background = hsv(h, s * 0.45, v * 0.13),
			Sidebar = hsv(h, s * 0.45, v * 0.08),
			ItemBG = hsv(h, s * 0.60, v * 0.24),
			TextMain = hsv(h, s * 0.06, 0.97),
			TextSub = hsv(h, s * 0.40, 0.72),
			ToggleOn = vivid(h, s, v),
			ToggleOff = hsv(h, s * 0.40, 0.32),
			Button = hsv(h, s * 0.55, 0.28),
			ButtonHover = hsv(h, s * 0.65, 0.38),
			Accent = vivid(h, s, v),
			Stroke = hsv(h, s * 0.80, 0.42),
			HeaderLine  = hsv(h, s * 0.55, 0.24),
			MiniGG = hsv(h, s * 0.45, 0.06),
		}
	end

	local _savedCustomH = 0.6
	local _savedCustomS = 0.8
	local _savedCustomV = 0.85
	local currentThemeName = "Default"

	if not isfolder("GGHub") then makefolder("GGHub") end

	local _savedThemePath = "GGHub/ThemePreference.json"
	if isfile(_savedThemePath) then
		local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(_savedThemePath))
		if ok and data and Themes[data.theme] then
			currentThemeName = data.theme
			for k, v in pairs(Themes[data.theme]) do Colors[k] = v end
		elseif ok and data and data.theme == "Custom" and data.h then
			currentThemeName = "Custom"
			_savedCustomH = data.h
			_savedCustomS = data.s or 0.8
			_savedCustomV = data.v or 0.85
			local cTheme = generateCustomTheme(_savedCustomH, _savedCustomS, _savedCustomV)
			for k, cv in pairs(cTheme) do Colors[k] = cv end
		end
	end

	local _currentMiniSize = "Default"
	local _savedSizePath   = "GGHub/ButtonSize.json"
	if isfile(_savedSizePath) then
		local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(_savedSizePath))
		if ok and data and MiniGGSizes[data.size] then
			_currentMiniSize = data.size
		end
	end

	local function applyTheme(themeName)
		local theme = Themes[themeName]
		if not theme then return end
		currentThemeName = themeName
		pcall(function()
			if not isfolder("GGHub") then makefolder("GGHub") end
			writefile("GGHub/ThemePreference.json", HttpService:JSONEncode({theme = themeName}))
		end)
		for k, v in pairs(theme) do Colors[k] = v end
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for i = #ThemedRefs, 1, -1 do
			if not ThemedRefs[i].obj or not ThemedRefs[i].obj.Parent then
				table.remove(ThemedRefs, i)
			end
		end
		for _, ref in ipairs(ThemedRefs) do
			local color = theme[ref.role]
			if color then
				TweenService:Create(ref.obj, tweenInfo, {[ref.prop] = color}):Play()
			end
		end
	end

	local function applyCustomTheme(h, s, v)
		local theme = generateCustomTheme(h, s, v)
		currentThemeName = "Custom"
		for k, cv in pairs(theme) do Colors[k] = cv end
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for i = #ThemedRefs, 1, -1 do
			if not ThemedRefs[i].obj or not ThemedRefs[i].obj.Parent then
				table.remove(ThemedRefs, i)
			end
		end
		for _, ref in ipairs(ThemedRefs) do
			local color = theme[ref.role]
			if color then
				TweenService:Create(ref.obj, tweenInfo, {[ref.prop] = color}):Play()
			end
		end
		pcall(function()
			if not isfolder("GGHub") then makefolder("GGHub") end
			writefile("GGHub/ThemePreference.json", HttpService:JSONEncode({theme = "Custom", h = h, s = s, v = v}))
		end)
		_savedCustomH = h
		_savedCustomS = s
		_savedCustomV = v
	end

	return {
		Colors = Colors,
		Themes = Themes,
		ThemeDisplayNames = ThemeDisplayNames,
		MiniGGSizes = MiniGGSizes,
		ThemedRefs = ThemedRefs,
		_itemRegistry = _itemRegistry,
		_regCounters = _regCounters,
		reg = reg,
		_reg = _reg,
		_toggleStates = _toggleStates,
		_savedTogglesPath = _savedTogglesPath,
		saveToggleStates = saveToggleStates,
		generateCustomTheme = generateCustomTheme,
		applyTheme = applyTheme,
		applyCustomTheme = applyCustomTheme,
		currentThemeName = currentThemeName,
		_currentMiniSize = _currentMiniSize,
		_savedCustomH = _savedCustomH,
		_savedCustomS = _savedCustomS,
		_savedCustomV = _savedCustomV,
	}
end

local _savedKeybindPath = "GGHub/KeybindPreference.json"
local _savedKey = Enum.KeyCode.RightControl
if isfile(_savedKeybindPath) then
    local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(_savedKeybindPath))
    if ok and data and Enum.KeyCode[data.key] then
        _savedKey = Enum.KeyCode[data.key]
    end
end
