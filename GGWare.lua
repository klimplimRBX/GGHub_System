-- =====================================

--[[ GGHub is an open source script :D
       So have fun getting some functions 
       from here and using then on your own script
]]--

-- ============= GGHub v0.9 (Animated btw because i'm proud of this now) ===============

if getgenv().__GGHub_Running then
	if getgenv().__GGHub_Notify then
		getgenv().__GGHub_Notify("GGHub is already running!")
	end
	return
end
getgenv().__GGHub_Running = true
getgenv().__GGHub_Cleanup = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BASE_URL = "https://raw.githubusercontent.com/klimplimRBX/GGHub_System/main/"

local function loadModule(path)
	return loadstring(game:HttpGet(BASE_URL .. path))()
end

-- ===================================================
--              LOADING SCREEN
-- ===================================================

local loading = loadModule("core/Loading.lua")({
	TweenService = TweenService,
	PlayerGui = PlayerGui,
	Lighting = Lighting,
	RunService = RunService,
})

if loading.blocked then
	getgenv().__GGHub_Running = false
	return
end

-- ===================================================
--            COLORS & THEMES
-- ===================================================

loading.setProgress(0.08, "Loading themes...")

local themes = loadModule("core/Theme.lua")({
	TweenService = TweenService,
	HttpService = HttpService,
})

local Colors = themes.Colors
local ThemedRefs = themes.ThemedRefs
local _itemRegistry = themes._itemRegistry
local _regCounters = themes._regCounters
local reg = themes.reg
local _reg = themes._reg
local _toggleStates = themes._toggleStates
local _savedTogglesPath = themes._savedTogglesPath
local saveToggleStates = themes.saveToggleStates
local applyTheme = themes.applyTheme
local applyCustomTheme = themes.applyCustomTheme
local ThemeDisplayNames = themes.ThemeDisplayNames
local MiniGGSizes = themes.MiniGGSizes
local _currentMiniSize = themes._currentMiniSize
local currentThemeName = themes.currentThemeName
local _savedCustomH = themes._savedCustomH
local _savedCustomS = themes._savedCustomS
local _savedCustomV = themes._savedCustomV

loading.setProgress(0.18, "Building UI...")

-- ===================================================

if PlayerGui:FindFirstChild("GGHub_v09") then
	PlayerGui.GGHub_v09:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GGHub_v09"
gui.Parent = PlayerGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ===================================================
--            DRAG FUNCTION
-- ===================================================

local function makeDraggable(object)
	local dragging, dragInput, dragStart, startPos
	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	object.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local uiOpen = false
local openUI, closeUI

-- ===================================================
--         MINI BUTTON & RAINBOW
-- ===================================================

local MiniGG = Instance.new("TextButton")
MiniGG.Name = "MiniGG"
MiniGG.Size = UDim2.new(0, 55, 0, 55)
MiniGG.Position = UDim2.new(0.05, 0, 0.2, 0)
MiniGG.Text = "GG"
MiniGG.TextScaled = true
MiniGG.Font = Enum.Font.SourceSansBold
MiniGG.TextColor3 = Color3.new(1, 1, 1)
MiniGG.BackgroundColor3 = Colors.MiniGG
MiniGG.Visible = false
MiniGG.Parent = gui
Instance.new("UICorner", MiniGG).CornerRadius = UDim.new(0, 10)
reg(MiniGG, "BackgroundColor3", "MiniGG")

local kStroke = Instance.new("UIStroke")
kStroke.Color = Color3.fromRGB(60, 60, 60)
kStroke.Thickness = 0.7
kStroke.Parent = MiniGG
makeDraggable(MiniGG)

local function setMiniGGSize(name)
	local s = MiniGGSizes[name]
	if not s then return end
	_currentMiniSize = name
	TweenService:Create(MiniGG, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, s.size, 0, s.size)
	}):Play()
	kStroke.Thickness = s.stroke
	local corner = MiniGG:FindFirstChildOfClass("UICorner")
	if corner then corner.CornerRadius = UDim.new(0, s.corner) end
	pcall(function()
		if not isfolder("GGHub") then makefolder("GGHub") end
		writefile("GGHub/ButtonSize.json", HttpService:JSONEncode({size = name}))
	end)
end

do
	local s = MiniGGSizes[_currentMiniSize]
	if s then
		MiniGG.Size = UDim2.new(0, s.size, 0, s.size)
		kStroke.Thickness = s.stroke
		local corner = MiniGG:FindFirstChildOfClass("UICorner")
		if corner then corner.CornerRadius = UDim.new(0, s.corner) end
	end
end

local rainbowConnection
local rainbowHue = 0

local function startRainbow()
	if rainbowConnection then return end
	rainbowConnection = RunService.Heartbeat:Connect(function()
		rainbowHue = (rainbowHue + 0.8) % 360
		kStroke.Color = Color3.fromHSV(rainbowHue / 360, 0.75, 1)
	end)
end

local function stopRainbow()
	if rainbowConnection then
		rainbowConnection:Disconnect()
		rainbowConnection = nil
	end
end

MiniGG.MouseEnter:Connect(function()
	TweenService:Create(MiniGG, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
end)
MiniGG.MouseLeave:Connect(function()
	TweenService:Create(MiniGG, TweenInfo.new(0.11), {BackgroundColor3 = Colors.MiniGG}):Play()
end)

-- ===================================================
--            MAINFRAME & GLOW
-- ===================================================

local BASE_W, BASE_H = 580, 360

local function getScreenScale()
	if UserInputService.TouchEnabled then return 1 end
	local vp = workspace.CurrentCamera.ViewportSize
	local scaleX = vp.X / 1280
	local scaleY = vp.Y / 720
	return math.clamp(math.min(scaleX, scaleY), 0.45, 1)
end

local _uiScale = getScreenScale()

local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, BASE_W, 0, BASE_H)
MainFrame.Position = UDim2.new(0.5, -BASE_W / 2, 0.5, -BASE_H / 2)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.GroupTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = gui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local mStroke = Instance.new("UIStroke")
mStroke.Color = Colors.Stroke
mStroke.Parent = MainFrame
makeDraggable(MainFrame)

reg(MainFrame, "BackgroundColor3", "Background")
reg(mStroke, "Color", "Stroke")

local glowLayers = {}
local totalLayers = 20
local maxPad = 18

for i = 1, totalLayers do
	local t = (i - 1) / (totalLayers - 1)
	local pad = math.floor(1 + t * (maxPad - 1) + 0.5)
	local alpha = 0.65 + (1 - 0.65) * (t ^ 0.5)

	local g = Instance.new("Frame")
	g.Name = "GlowLayer" .. i
	g.BackgroundColor3 = Colors.Accent
	g.BackgroundTransparency = alpha
	g.BorderSizePixel = 0
	g.ZIndex = 0
	g.Visible = false
	g.Parent = gui
	Instance.new("UICorner", g).CornerRadius = UDim.new(0, 12 + pad)
	table.insert(glowLayers, {frame = g, pad = pad, alpha = alpha})
	reg(g, "BackgroundColor3", "Accent")
end

local function updateGlow()
	local abs = MainFrame.AbsolutePosition
	local siz = MainFrame.AbsoluteSize
	local cornerBase = 12 * _uiScale
	for _, layer in ipairs(glowLayers) do
		local p = layer.pad
		layer.frame.Size = UDim2.new(0, siz.X + p * 2, 0, siz.Y + p * 2)
		layer.frame.Position = UDim2.new(0, abs.X - p, 0, abs.Y - p)
		local corner = layer.frame:FindFirstChildOfClass("UICorner")
		if corner then corner.CornerRadius = UDim.new(0, cornerBase + p) end
	end
end

MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateGlow)
MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGlow)

local glowState = {enabled = false, intensity = 1}
local _savedGlowPath = "GGHub/GlowPreference.json"
if isfile(_savedGlowPath) then
	local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(_savedGlowPath))
	if ok and data then
		if type(data.enabled) == "boolean" then glowState.enabled = data.enabled end
		if type(data.intensity) == "number" then glowState.intensity = math.clamp(data.intensity, 0, 1) end
	end
end

if glowState.enabled then
	_toggleStates["Glow Effect"] = true
end

local function applyGlowIntensity(intensity, duration)
	duration = duration or 0
	for _, layer in ipairs(glowLayers) do
		local goal = 1 - intensity * (1 - layer.alpha)
		if duration > 0 then
			TweenService:Create(layer.frame,
				TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = goal}
			):Play()
		else
			layer.frame.BackgroundTransparency = goal
		end
	end
end

local function tweenGlow(targetAlpha, duration)
	if not glowState.enabled then return end
	for _, layer in ipairs(glowLayers) do
		local base = 1 - glowState.intensity * (1 - layer.alpha)
		local goal = base + (1 - base) * (1 - targetAlpha)
		TweenService:Create(layer.frame,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = goal}
		):Play()
	end
end

local function showGlow() for _, l in ipairs(glowLayers) do l.frame.Visible = true  end end
local function hideGlow() for _, l in ipairs(glowLayers) do l.frame.Visible = false end end

task.spawn(function()
	while true do
		if MainFrame.Visible and glowState.enabled then
			tweenGlow(0.9, 2.0)
			task.wait(2.0)
			tweenGlow(1.0, 2.0)
			task.wait(2.0)
		else
			task.wait(0.5)
		end
	end
end)

local UIScale_Main = Instance.new("UIScale", MainFrame)
UIScale_Main.Scale = _uiScale

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local newScale = getScreenScale()
	_uiScale = newScale
	if MainFrame.Visible then
		UIScale_Main.Scale = newScale
	end
end)

-- ===================================================
--              HEADER BAR
-- ===================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local AppTitle = Instance.new("TextLabel")
AppTitle.Text = "GGHub v0.9"
AppTitle.Size = UDim2.new(0, 200, 0, 20)
AppTitle.Position = UDim2.new(0, 15, 0, 12)
AppTitle.Font = Enum.Font.GothamBold
AppTitle.TextSize = 18
AppTitle.TextColor3 = Colors.TextMain
AppTitle.TextXAlignment = Enum.TextXAlignment.Left
AppTitle.BackgroundTransparency = 1
AppTitle.Parent = Header
reg(AppTitle, "TextColor3", "TextMain")

local AppSignature = Instance.new("TextLabel")
AppSignature.Text = "Made by KlimplimRBX - The last update before the biggest yet"
AppSignature.Size = UDim2.new(0, 300, 0, 15)
AppSignature.Position = UDim2.new(0, 15, 0, 32)
AppSignature.Font = Enum.Font.Gotham
AppSignature.TextSize = 11
AppSignature.TextColor3 = Colors.TextSub
AppSignature.TextXAlignment = Enum.TextXAlignment.Left
AppSignature.BackgroundTransparency = 1
AppSignature.Parent = Header
reg(AppSignature, "TextColor3", "TextSub")

local HeaderLine = Instance.new("Frame", MainFrame)
HeaderLine.Size = UDim2.new(1, -20, 0, 1)
HeaderLine.Position = UDim2.new(0, 10, 0, 50)
HeaderLine.BackgroundColor3 = Colors.HeaderLine
HeaderLine.BorderSizePixel = 0
reg(HeaderLine, "BackgroundColor3", "HeaderLine")

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 9)
CloseBtn.BackgroundColor3 = Colors.Button
CloseBtn.TextColor3 = Colors.TextMain
CloseBtn.TextSize = 24
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn)
reg(CloseBtn, "BackgroundColor3", "Button")
reg(CloseBtn, "TextColor3", "TextMain")

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -80, 0, 9)
MinBtn.BackgroundColor3 = Colors.Button
MinBtn.TextColor3 = Colors.TextMain
MinBtn.TextSize = 20
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn)
reg(MinBtn, "BackgroundColor3", "Button")
reg(MinBtn, "TextColor3", "TextMain")

local function addHeaderBtnHover(btn, hoverColor)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.11), {BackgroundColor3 = hoverColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Button}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.055), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.077), {BackgroundColor3 = hoverColor}):Play()
	end)
end

addHeaderBtnHover(CloseBtn, Color3.fromRGB(185, 45, 45))
addHeaderBtnHover(MinBtn,   Color3.fromRGB(60, 60, 60))

-- ===================================================
--         PAGE SYSTEM & SIDEBAR
-- ===================================================

local BodyFrame = Instance.new("Frame")
BodyFrame.Size = UDim2.new(1, 0, 1, -55)
BodyFrame.Position = UDim2.new(0, 0, 0, 55)
BodyFrame.BackgroundTransparency = 1
BodyFrame.Parent = MainFrame

local Pages = {}
local SidebarButtons = {}
local currentPage = nil

local function createPage(name)
	local wrapper = Instance.new("CanvasGroup")
	wrapper.Name = name .. "Page"
	wrapper.Size = UDim2.new(1, -85, 1, -20)
	wrapper.Position = UDim2.new(0, 75, 0, 10)
	wrapper.BackgroundTransparency = 1
	wrapper.BorderSizePixel = 0
	wrapper.Visible = false
	wrapper.GroupTransparency = 1
	wrapper.Parent = BodyFrame

	local page = Instance.new("ScrollingFrame", wrapper)
	page.Name = "Scroll"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local _ll = Instance.new("UIListLayout", page)
	_ll.Padding = UDim.new(0, 10)
	_ll.SortOrder = Enum.SortOrder.LayoutOrder
	Pages[name] = wrapper
	return page
end

local _searchOpen = false
local closeSearch

local function showPage(name)
	if name == currentPage then return end
	if _searchOpen and name ~= "Search" then
		closeSearch()
	end
	if currentPage and Pages[currentPage] and currentPage ~= "Search" then
		local old = Pages[currentPage]
		TweenService:Create(old, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
		task.delay(0.077, function() old.Visible = false end)
	end

	task.delay(currentPage and 0.06 or 0, function()
		local p = Pages[name]
		if p then
			p.Visible = true
			p.GroupTransparency = 1
			TweenService:Create(p, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
		end
	end)

	for n, b in pairs(SidebarButtons) do
		local isActive = (n == name)
		TweenService:Create(b, TweenInfo.new(0.154), {
			BackgroundTransparency = isActive and 0.8 or 1,
			TextColor3 = isActive and Colors.TextMain or Color3.fromRGB(100, 100, 100)
		}):Play()
		if isActive then
			local sc = b:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", b)
			TweenService:Create(sc, TweenInfo.new(0.077, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.15}):Play()
			task.delay(0.077, function()
				TweenService:Create(sc, TweenInfo.new(0.11, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			end)
		end
	end

	currentPage = name
end

local homePage = createPage("Home")
local scriptPage = createPage("Scripts")
local mapPage = createPage("Map")
local settingsPage = createPage("Settings")

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 65, 1, 0)
Sidebar.BackgroundColor3 = Colors.Background
Sidebar.BorderSizePixel = 0
Sidebar.Parent = BodyFrame
reg(Sidebar, "BackgroundColor3", "Background")

local function addSideIcon(text, yPos, target)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.Size = UDim2.new(0, 50, 0, 50)
	btn.Position = UDim2.new(0.5, -25, 0, yPos)
	btn.BackgroundTransparency = 1
	btn.TextSize = 28
	btn.Parent = Sidebar
	btn.TextColor3 = Color3.fromRGB(100, 100, 100)
	Instance.new("UICorner", btn)
	Instance.new("UIScale", btn).Scale = 1
	SidebarButtons[target] = btn

	btn.MouseEnter:Connect(function()
		if currentPage ~= target then
			local sc = btn:FindFirstChildOfClass("UIScale")
			TweenService:Create(sc,  TweenInfo.new(0.11, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
			TweenService:Create(btn, TweenInfo.new(0.11), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if currentPage ~= target then
			local sc = btn:FindFirstChildOfClass("UIScale")
			TweenService:Create(sc,  TweenInfo.new(0.11), {Scale = 1}):Play()
			TweenService:Create(btn, TweenInfo.new(0.11), {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		end
	end)
	btn.MouseButton1Click:Connect(function()
		showPage(target)
	end)
end

addSideIcon("🏠", 10,  "Home")
addSideIcon("⚡", 70,  "Scripts")
addSideIcon("🗺️", 130, "Map")
addSideIcon("⚙️", 190, "Settings")

local SearchBtn = Instance.new("TextButton")
SearchBtn.Text = "🔍"
SearchBtn.Size = UDim2.new(0, 36, 0, 36)
SearchBtn.Position = UDim2.new(0.5, -18, 1, -52)
SearchBtn.BackgroundTransparency = 1
SearchBtn.TextSize = 18
SearchBtn.Parent = Sidebar
SearchBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", SearchBtn)
Instance.new("UIScale", SearchBtn).Scale = 1

SearchBtn.MouseEnter:Connect(function()
	if currentPage ~= "Search" then
		local sc = SearchBtn:FindFirstChildOfClass("UIScale")
		TweenService:Create(sc,  TweenInfo.new(0.11, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
		TweenService:Create(SearchBtn, TweenInfo.new(0.11), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
	end
end)
SearchBtn.MouseLeave:Connect(function()
	if currentPage ~= "Search" then
		local sc = SearchBtn:FindFirstChildOfClass("UIScale")
		TweenService:Create(sc, TweenInfo.new(0.11), {Scale = 1}):Play()
		TweenService:Create(SearchBtn, TweenInfo.new(0.11), {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
	end
end)

-- ===================================================
--          NOTIFICATION SYSTEM
-- ===================================================

loading.setProgress(0.35, "Loading modules...")

local notifModule, shaders
local modulesLoaded = 0

task.spawn(function()
	notifModule = loadModule("core/Notifications.lua")({
		TweenService = TweenService,
		RunService = RunService,
		Colors = Colors,
		reg = reg,
		gui = gui,
	})
	modulesLoaded += 1
end)

task.spawn(function()
	shaders = loadModule("core/Shaders.lua")({
		Lighting = Lighting,
	})
	modulesLoaded += 1
end)

repeat task.wait(0.05) until modulesLoaded >= 2

local showNotification = notifModule.show
getgenv().__GGHub_Notify = showNotification

-- ===================================================
--       UI COMPONENT CREATORS
-- ===================================================

loading.setProgress(0.55, "Loading components...")

local ctx = {
	TweenService = TweenService,
	UserInputService = UserInputService,
	Colors = Colors,
	reg = reg,
	_reg = _reg,
	ThemedRefs = ThemedRefs,
	_toggleStates = _toggleStates,
	mStroke = mStroke,
	gui = gui,
	applyCustomTheme = applyCustomTheme,
	showNotification = showNotification,
	state = {uiOpen = false},
	kb = {key = Enum.KeyCode.RightControl},
	glow = glowState,
}

local components = loadModule("core/Components.lua")(ctx)

local createToggle = components.createToggle
local createButton = components.createButton
local createSlider = components.createSlider
local createDropdown = components.createDropdown
local openColorPicker = components.openColorPicker

-- ===================================================
--         SHADERS
-- ===================================================

loading.setProgress(0.68, "Loading pages...")

local pagesLoaded = 0

task.spawn(function()
	loadModule("pages/HomePage.lua")({
		createButton = createButton,
		createDropdown = createDropdown,
		createToggle = createToggle,
		showNotification = showNotification,
		homePage = homePage,
		LocalPlayer = LocalPlayer,
		shaders = shaders,
	})
	pagesLoaded += 1
end)

-- ===================================================
--         SCRIPTS PAGE CONTENT
-- ===================================================

task.spawn(function()
	loadModule("pages/ScriptsPage.lua")({
		createButton = createButton,
		createToggle = createToggle,
		showNotification = showNotification,
		scriptPage = scriptPage,
		LocalPlayer = LocalPlayer,
		RunService = RunService,
	})
	pagesLoaded += 1
end)

-- ===================================================
--         MAP PAGE CONTENT
-- ===================================================

task.spawn(function()
	loadModule("pages/MapPage.lua")({
		createButton = createButton,
		showNotification = showNotification,
		mapPage = mapPage,
		LocalPlayer = LocalPlayer,
		RunService = RunService,
	})
	pagesLoaded += 1
end)

-- ===================================================
--         SETTINGS PAGE CONTENT
-- ===================================================

task.spawn(function()
	loadModule("pages/SettingsPage.lua")({
		TweenService = TweenService,
		UserInputService = UserInputService,
		Colors = Colors,
		reg = reg,
		_reg = _reg,
		_regCounters = _regCounters,
		createButton = createButton,
		createToggle = createToggle,
		createSlider = createSlider,
		createDropdown = createDropdown,
		showNotification = showNotification,
		applyTheme = applyTheme,
		openColorPicker = openColorPicker,
		ThemeDisplayNames = ThemeDisplayNames,
		theme = {
			name = currentThemeName,
			customH = _savedCustomH,
			customS = _savedCustomS,
			customV = _savedCustomV,
		},
		setMiniGGSize = setMiniGGSize,
		currentMiniSize = _currentMiniSize,
		MainFrame = MainFrame,
		showGlow = showGlow,
		hideGlow = hideGlow,
		tweenGlow = tweenGlow,
		applyGlowIntensity = applyGlowIntensity,
		saveToggleStates = saveToggleStates,
		_toggleStates = _toggleStates,
		_savedTogglesPath = _savedTogglesPath,
		settingsPage = settingsPage,
		RunService = RunService,
		state = ctx.state,
		kb = ctx.kb,
		glow = glowState,
		openUI = function() if openUI  then openUI()  end end,
		closeUI = function() if closeUI then closeUI() end end,
	})
	pagesLoaded += 1
end)

repeat task.wait(0.05) until pagesLoaded >= 4

-- ===================================================
--                 SEARCH SYSTEM
-- ===================================================

local _prevPage = "Home"

local searchWrapper = Instance.new("CanvasGroup")
searchWrapper.Name = "SearchPage"
searchWrapper.Size = UDim2.new(1, -85, 1, -20)
searchWrapper.Position = UDim2.new(0, 75, 0, 10)
searchWrapper.BackgroundTransparency = 1
searchWrapper.BorderSizePixel = 0
searchWrapper.Visible = false
searchWrapper.GroupTransparency = 1
searchWrapper.Parent = BodyFrame
Pages["Search"] = searchWrapper

local SearchBarFrame = Instance.new("Frame")
SearchBarFrame.Size = UDim2.new(1, -10, 0, 40)
SearchBarFrame.Position = UDim2.new(0, 5, 0, 0)
SearchBarFrame.BackgroundColor3 = Colors.ItemBG
SearchBarFrame.BorderSizePixel = 0
SearchBarFrame.Parent = searchWrapper
Instance.new("UICorner", SearchBarFrame).CornerRadius = UDim.new(0, 12)
reg(SearchBarFrame, "BackgroundColor3", "ItemBG")

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Text = "🔍"
SearchIcon.Size = UDim2.new(0, 28, 1, 0)
SearchIcon.Position = UDim2.new(0, 8, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.TextSize = 15
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.Parent = SearchBarFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -46, 1, 0)
SearchBox.Position = UDim2.new(0, 42, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.TextColor3 = Colors.TextMain
SearchBox.PlaceholderColor3 = Colors.TextSub
SearchBox.PlaceholderText = "Search for anything..."
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchBarFrame
reg(SearchBox, "TextColor3", "TextMain")

local searchScroll = Instance.new("ScrollingFrame")
searchScroll.Size = UDim2.new(1, 0, 1, -50)
searchScroll.Position = UDim2.new(0, 0, 0, 50)
searchScroll.BackgroundTransparency = 1
searchScroll.BorderSizePixel = 0
searchScroll.ScrollBarThickness = 3
searchScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
searchScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
searchScroll.ScrollingEnabled = false
searchScroll.Parent = searchWrapper
local searchLayout = Instance.new("UIListLayout", searchScroll)
searchLayout.Padding = UDim.new(0, 10)

local EmptyLabel = Instance.new("TextLabel")
EmptyLabel.Size = UDim2.new(1, 0, 0, 60)
EmptyLabel.BackgroundTransparency = 1
EmptyLabel.Text = "Nothing was found with the name you searched :("
EmptyLabel.Font = Enum.Font.Gotham
EmptyLabel.TextSize = 13
EmptyLabel.TextColor3 = Colors.TextSub
EmptyLabel.TextWrapped = true
EmptyLabel.TextXAlignment = Enum.TextXAlignment.Center
EmptyLabel.TextYAlignment = Enum.TextYAlignment.Center
EmptyLabel.Visible = false
EmptyLabel.Parent = searchScroll
reg(EmptyLabel, "TextColor3", "TextSub")

local function restoreAll()
	for _, item in ipairs(_itemRegistry) do
		if item.frame and item.frame.Parent ~= item.origParent then
			item.frame.Parent = item.origParent
		end
	end
	searchScroll.ScrollingEnabled = false
	searchScroll.CanvasPosition = Vector2.new(0, 0)
end

local function runSearch(query)
	query = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
	if query == "" then
		restoreAll()
		EmptyLabel.Visible = false
		return
	end
	local found = 0
	for _, item in ipairs(_itemRegistry) do
		if not item.frame or not item.frame.Parent then continue end
		if item.title:find(query, 1, true) then
			if item.frame.Parent ~= searchScroll then
				item.frame.Parent = searchScroll
			end
			found = found + 1
		else
			if item.frame.Parent == searchScroll then
				item.frame.Parent = item.origParent
			end
		end
	end
	EmptyLabel.Visible = (found == 0)
	searchScroll.ScrollingEnabled = (found > 0)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	runSearch(SearchBox.Text)
end)

local function openSearch()
	if _searchOpen then return end
	_searchOpen = true
	_prevPage = currentPage or "Home"
	SearchBox.Text = ""
	EmptyLabel.Visible = false
	restoreAll()

	if currentPage and Pages[currentPage] then
		local old = Pages[currentPage]
		TweenService:Create(old, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
		task.delay(0.077, function() old.Visible = false end)
	end

	currentPage = "Search"
	for n, b in pairs(SidebarButtons) do
		TweenService:Create(b, TweenInfo.new(0.154), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
	end
	TweenService:Create(SearchBtn, TweenInfo.new(0.154), {TextColor3 = Colors.TextMain}):Play()

	task.delay(0.06, function()
		searchWrapper.Visible = true
		searchWrapper.GroupTransparency = 1
		TweenService:Create(searchWrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
		task.defer(function() SearchBox:CaptureFocus() end)
	end)
end

closeSearch = function()
	if not _searchOpen then return end
	_searchOpen = false
	SearchBox.Text = ""
	EmptyLabel.Visible = false
	restoreAll()
	TweenService:Create(searchWrapper, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
	task.delay(0.077, function() searchWrapper.Visible = false end)
	TweenService:Create(SearchBtn, TweenInfo.new(0.154), {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
end

SearchBtn.MouseButton1Click:Connect(function()
	if _searchOpen then
		closeSearch()
		showPage(_prevPage)
	else
		openSearch()
	end
end)

-- ===================================================
--         INITIALIZE & CLOSE/MIN LOGIC
-- ===================================================

showPage("Home")

uiOpen = true
ctx.state.uiOpen = true

local _openTweens = {}
local function cancelOpenTweens()
	for _, t in ipairs(_openTweens) do pcall(function() t:Cancel() end) end
	_openTweens = {}
end

openUI = function()
	uiOpen = true
	ctx.state.uiOpen = true
	cancelOpenTweens()
	stopRainbow()
	MiniGG.Visible = false
	MainFrame.Visible = true
	UIScale_Main.Scale = _uiScale * 0.92
	MainFrame.GroupTransparency = 1
	mStroke.Transparency = 1
	if glowState.enabled then
		showGlow()
		for _, l in ipairs(glowLayers) do l.frame.BackgroundTransparency = 1 end
	end
	table.insert(_openTweens, TweenService:Create(MainFrame, TweenInfo.new(0.231, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0}))
	table.insert(_openTweens, TweenService:Create(UIScale_Main, TweenInfo.new(0.231, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = _uiScale}))
	table.insert(_openTweens, TweenService:Create(mStroke, TweenInfo.new(0.231), {Transparency = 0}))
	for _, t in ipairs(_openTweens) do t:Play() end
	if glowState.enabled then tweenGlow(1.0, 0.3) end
end

closeUI = function()
	uiOpen = false
	ctx.state.uiOpen = false
	cancelOpenTweens()
	TweenService:Create(MainFrame, TweenInfo.new(0.154, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
	TweenService:Create(UIScale_Main, TweenInfo.new(0.154, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = _uiScale * 0.92}):Play()
	TweenService:Create(mStroke, TweenInfo.new(0.132), {Transparency = 1}):Play()
	tweenGlow(0, 0.154)
	task.delay(0.165, function()
		MainFrame.Visible = false
		hideGlow()
		MiniGG.Visible = true
		startRainbow()
		local sc = MiniGG:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", MiniGG)
		sc.Scale = 0.5
		TweenService:Create(sc, TweenInfo.new(0.198, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

ctx.openUI = openUI
ctx.closeUI = closeUI

CloseBtn.Active = true
MinBtn.Active = true
MiniGG.Active = true

CloseBtn.MouseButton1Click:Connect(function()
	getgenv().__GGHub_Running = false
	getgenv().__GGHub_Notify = nil
	TweenService:Create(MainFrame, TweenInfo.new(0.165, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
	TweenService:Create(UIScale_Main, TweenInfo.new(0.165, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.88}):Play()
	TweenService:Create(mStroke, TweenInfo.new(0.132), {Transparency = 1}):Play()
	tweenGlow(0, 0.165)
	task.delay(0.198, function() gui:Destroy() end)
end)

MinBtn.MouseButton1Click:Connect(function()
	if uiOpen then closeUI() else openUI() end
end)

MiniGG.MouseButton1Click:Connect(function()
	openUI()
end)

-- =========================
-- LOADING BAR FUNC
-- =========================

loading.setProgress(1, "Done!")
task.wait(0.3)

loading.hide()

task.wait(0.308)
MainFrame.Visible = true
mStroke.Transparency = 1
UIScale_Main.Scale = _uiScale * 0.88
if glowState.enabled then
	showGlow()
	for _, l in ipairs(glowLayers) do l.frame.BackgroundTransparency = 1 end
end
TweenService:Create(MainFrame, TweenInfo.new(0.231, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	GroupTransparency = 0
}):Play()
TweenService:Create(UIScale_Main, TweenInfo.new(0.231, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Scale = _uiScale
}):Play()
TweenService:Create(mStroke, TweenInfo.new(0.231), {Transparency = 0}):Play()
if glowState.enabled then tweenGlow(1.0, 0.4) end

print("GGHub Fully Loaded")
