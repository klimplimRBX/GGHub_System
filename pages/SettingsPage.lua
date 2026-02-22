return function(ctx)
	local TweenService = ctx.TweenService
	local UserInputService = ctx.UserInputService
	local Colors = ctx.Colors
	local reg = ctx.reg
	local _reg = ctx._reg
	local _regCounters = ctx._regCounters
	local createButton = ctx.createButton
	local createToggle = ctx.createToggle
	local createSlider = ctx.createSlider
	local createDropdown = ctx.createDropdown
	local showNotification = ctx.showNotification
	local applyTheme = ctx.applyTheme
	local openColorPicker = ctx.openColorPicker
	local ThemeDisplayNames = ctx.ThemeDisplayNames
	local currentThemeName = ctx.theme.name
	local setMiniGGSize = ctx.setMiniGGSize
	local _currentMiniSize = ctx.currentMiniSize
	local MainFrame = ctx.MainFrame
	local showGlow = ctx.showGlow
	local hideGlow = ctx.hideGlow
	local tweenGlow = ctx.tweenGlow
	local applyGlowIntensity = ctx.applyGlowIntensity
	local saveToggleStates = ctx.saveToggleStates
	local _toggleStates = ctx._toggleStates
	local _savedTogglesPath = ctx._savedTogglesPath
	local settingsPage = ctx.settingsPage
	local _savedCustomH = ctx.theme.customH
	local _savedCustomS = ctx.theme.customS
	local _savedCustomV = ctx.theme.customV
	local RunService = ctx.RunService

	createDropdown(settingsPage, "Theme",
		{"Default", "Crimson", "Evergreen", "Yellow", "Navy Blue", "Cosmic Purple", "Pink Flakes", "True Black", "Amber", "Custom"},
		function(value)
			if value == "Custom" then
				openColorPicker(_savedCustomH, _savedCustomS, _savedCustomV)
				return
			end
			local nameMap = {
				["Default"] = "Default",
				["Crimson"] = "Crimson",
				["Evergreen"] = "Evergreen",
				["Yellow"] = "Yellow",
				["Navy Blue"] = "NavyBlue",
				["Cosmic Purple"] = "CosmicPurple",
				["Pink Flakes"] = "PinkFlakes",
				["True Black"] = "TrueBlack",
				["Amber"] = "Amber",
			}
			local key = nameMap[value]
			if key then applyTheme(key) end
		end,
		ThemeDisplayNames[currentThemeName] or currentThemeName or "Default"
	)

	createDropdown(settingsPage, "Button Size",
		{"Very Small", "Small", "Default", "Big", "Very Big"},
		function(value)
			setMiniGGSize(value)
		end,
		_currentMiniSize
	)

	local glowEnabled = ctx.glow.enabled
	local glowIntensity = ctx.glow.intensity
	local _savedGlowPath = "GGHub/GlowPreference.json"

	local function saveGlowPrefs()
		pcall(function()
			if not isfolder("GGHub") then makefolder("GGHub") end
			writefile(_savedGlowPath,
				game:GetService("HttpService"):JSONEncode({
					enabled = glowEnabled,
					intensity = glowIntensity,
				}))
		end)
	end

	local glowSliderWrapper = Instance.new("Frame")
	glowSliderWrapper.Size = UDim2.new(1, 0, 0, 0)
	glowSliderWrapper.BackgroundTransparency = 1
	glowSliderWrapper.ClipsDescendants = true
	glowSliderWrapper.Visible = false

	local function setSliderVisible(visible, animate)
		local targetH = visible and 80 or 0
		if animate then
			if visible then
				glowSliderWrapper.Visible = true
			end
			TweenService:Create(glowSliderWrapper,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(1, 0, 0, targetH)}
			):Play()
			if not visible then
				task.delay(0.26, function()
					glowSliderWrapper.Visible = false
				end)
			end
		else
			glowSliderWrapper.Size = UDim2.new(1, 0, 0, targetH)
			glowSliderWrapper.Visible = visible
		end
	end

	createToggle(settingsPage, "Glow Effect", "Glow around main window", function(state)
		glowEnabled = state
		ctx.glow.enabled = state
		setSliderVisible(state, true)
		if state then
			if MainFrame.Visible then
				showGlow()
				applyGlowIntensity(glowIntensity, 0.3)
			end
		else
			tweenGlow(0, 0.25)
			task.delay(0.26, function()
				if not glowEnabled then hideGlow() end
			end)
		end
		saveGlowPrefs()
	end, glowEnabled)

	glowSliderWrapper.Parent = settingsPage
	glowSliderWrapper.LayoutOrder = _regCounters[tostring(settingsPage)] + 1
	_regCounters[tostring(settingsPage)] = _regCounters[tostring(settingsPage)] + 1

	createSlider(glowSliderWrapper, "Glow Intensity", "Brightness of the glow", 0, 100, glowIntensity * 100, function(val, pct)
		glowIntensity = pct
		ctx.glow.intensity = pct
		if glowEnabled and MainFrame.Visible then
			applyGlowIntensity(glowIntensity, 0.1)
		end
		saveGlowPrefs()
	end)

	if glowEnabled then
		glowSliderWrapper.Visible = true
		glowSliderWrapper.Size = UDim2.new(1, 0, 0, 80)
	else
		glowSliderWrapper.Visible = false
		glowSliderWrapper.Size = UDim2.new(1, 0, 0, 0)
	end

	local _keybind = ctx.kb.key
	local _bindingMode = false
	local _savedKeybindPath = "GGHub/KeybindPreference.json"

	if isfile(_savedKeybindPath) then
		local ok, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), readfile(_savedKeybindPath))
		if ok and data and data.key then
			pcall(function()
				_keybind = Enum.KeyCode[data.key]
				ctx.kb.key = _keybind
			end)
		end
	end

	local KeybindFrame = Instance.new("Frame")
	KeybindFrame.Size = UDim2.new(1, -10, 0, 65)
	KeybindFrame.BackgroundColor3 = Colors.ItemBG
	KeybindFrame.Parent = settingsPage
	Instance.new("UICorner", KeybindFrame).CornerRadius = UDim.new(0, 12)
	reg(KeybindFrame, "BackgroundColor3", "ItemBG")
	_reg("Keybind", KeybindFrame, settingsPage)

	local KBTitle = Instance.new("TextLabel")
	KBTitle.Text = "Keybind"
	KBTitle.Size = UDim2.new(1, -140, 0, 25)
	KBTitle.Position = UDim2.new(0, 15, 0, 10)
	KBTitle.BackgroundTransparency = 1
	KBTitle.TextColor3 = Colors.TextMain
	KBTitle.Font = Enum.Font.GothamBold
	KBTitle.TextSize = 16
	KBTitle.TextXAlignment = Enum.TextXAlignment.Left
	KBTitle.Parent = KeybindFrame
	reg(KBTitle, "TextColor3", "TextMain")

	local KBDesc = Instance.new("TextLabel")
	KBDesc.Text = "Toggle UI on PC"
	KBDesc.Size = UDim2.new(1, -140, 0, 20)
	KBDesc.Position = UDim2.new(0, 15, 0, 32)
	KBDesc.BackgroundTransparency = 1
	KBDesc.TextColor3 = Colors.TextSub
	KBDesc.Font = Enum.Font.Gotham
	KBDesc.TextSize = 12
	KBDesc.TextXAlignment = Enum.TextXAlignment.Left
	KBDesc.Parent = KeybindFrame
	reg(KBDesc, "TextColor3", "TextSub")

	local KBBtn = Instance.new("TextButton")
	KBBtn.Size = UDim2.new(0, 110, 0, 32)
	KBBtn.Position = UDim2.new(1, -120, 0.5, -16)
	KBBtn.BackgroundColor3 = Colors.Button
	KBBtn.TextColor3 = Colors.TextMain
	KBBtn.Font = Enum.Font.Gotham
	KBBtn.TextSize = 12
	KBBtn.Text = _keybind.Name
	KBBtn.Parent = KeybindFrame
	Instance.new("UICorner", KBBtn).CornerRadius = UDim.new(0, 8)
	reg(KBBtn, "BackgroundColor3", "Button")
	reg(KBBtn, "TextColor3", "TextMain")

	KeybindFrame.MouseEnter:Connect(function()
		TweenService:Create(KeybindFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
	end)
	KeybindFrame.MouseLeave:Connect(function()
		TweenService:Create(KeybindFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
	end)

	KBBtn.MouseButton1Click:Connect(function()
		if _bindingMode then return end
		_bindingMode = true
		KBBtn.Text = "Press a key..."
		TweenService:Create(KBBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Accent}):Play()
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if _bindingMode then
			_bindingMode = false
			_keybind = input.KeyCode
			ctx.kb.key = input.KeyCode
			KBBtn.Text = input.KeyCode.Name
			TweenService:Create(KBBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Button}):Play()
			pcall(function()
				if not isfolder("GGHub") then makefolder("GGHub") end
				writefile(_savedKeybindPath, game:GetService("HttpService"):JSONEncode({key = input.KeyCode.Name}))
			end)
			return
		end
		if input.KeyCode == _keybind then
			if ctx.state.uiOpen then ctx.closeUI() else ctx.openUI() end
		end
	end)

	createButton(settingsPage, "Save Settings", "Saves everything from this section", function()
		saveToggleStates()
		showNotification("Settings saved!")
	end)

	createButton(settingsPage, "Reset Settings", "Clear all saved toggle states", function()
		for k in pairs(_toggleStates) do _toggleStates[k] = nil end
		pcall(function()
			if isfile(_savedTogglesPath) then delfile(_savedTogglesPath) end
		end)
		showNotification("Settings cleared!")
	end)

	local function loadOldScript(url)
    if getgenv().__GGHub_Cleanup then
        for _, fn in ipairs(getgenv().__GGHub_Cleanup) do
            pcall(fn)
        end
    end
    getgenv().__GGHub_Running = false
    getgenv().__GGHub_Notify = nil
    getgenv().__GGHub_Cleanup = nil
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local targetGui = playerGui:FindFirstChild("GGHub_v09")
    if targetGui and targetGui:IsA("ScreenGui") then
        pcall(function() targetGui:Destroy() end)
    end                         
    task.wait(0.1)              
    loadstring(game:HttpGet(url))()
end

	createButton(settingsPage, "Valentine Event Script", "Goes to the valentine event GGHub version", function()
		loadOldScript("https://raw.githubusercontent.com/klimplimRBX/GGHub/main/GGHubValentinesEvent.lua")
	end)

	createButton(settingsPage, "Arcade Event Script", "Goes to the arcade event GGHub version", function()
		loadOldScript("https://raw.githubusercontent.com/klimplimRBX/GGHub/main/GGHubArcadeEvent.lua")
	end)

	createButton(settingsPage, "Money Event Script", "Goes to the Money event GGHub version", function()
		loadOldScript("https://raw.githubusercontent.com/klimplimRBX/GGHub/main/GGHubMoneyEvent.lua")
	end)
end
