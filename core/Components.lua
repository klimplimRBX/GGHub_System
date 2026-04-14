return function(ctx)
	local TweenService = ctx.TweenService
	local UserInputService = ctx.UserInputService
	local Colors = ctx.Colors
	local reg = ctx.reg
	local _reg = ctx._reg
	local ThemedRefs = ctx.ThemedRefs
	local _toggleStates = ctx._toggleStates
	local mStroke = ctx.mStroke
	local gui = ctx.gui

	local function createToggle(parent, titleText, desc, callback, initialState)
		local ToggleFrame = Instance.new("Frame")
		ToggleFrame.Size = UDim2.new(1, -10, 0, 65)
		ToggleFrame.BackgroundColor3 = Colors.ItemBG
		ToggleFrame.Parent = parent
		Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 12)
		reg(ToggleFrame, "BackgroundColor3", "ItemBG")
		_reg(titleText, ToggleFrame, parent)

		local TTitle = Instance.new("TextLabel")
		TTitle.Text = titleText
		TTitle.Size = UDim2.new(1, -75, 0, 25)
		TTitle.Position = UDim2.new(0, 15, 0, 10)
		TTitle.BackgroundTransparency = 1
		TTitle.TextColor3 = Colors.TextMain
		TTitle.Font = Enum.Font.GothamBold
		TTitle.TextSize = 16
		TTitle.TextXAlignment = Enum.TextXAlignment.Left
		TTitle.Parent = ToggleFrame
		reg(TTitle, "TextColor3", "TextMain")

		local TDesc = Instance.new("TextLabel")
		TDesc.Text = desc
		TDesc.Size = UDim2.new(1, -75, 0, 20)
		TDesc.Position = UDim2.new(0, 15, 0, 32)
		TDesc.BackgroundTransparency = 1
		TDesc.TextColor3 = Colors.TextSub
		TDesc.Font = Enum.Font.Gotham
		TDesc.TextSize = 12
		TDesc.TextXAlignment = Enum.TextXAlignment.Left
		TDesc.Parent = ToggleFrame
		reg(TDesc, "TextColor3", "TextSub")

		local SwitchBase = Instance.new("TextButton")
		SwitchBase.Text = ""
		SwitchBase.Size = UDim2.new(0, 50, 0, 28)
		SwitchBase.Position = UDim2.new(1, -65, 0.5, -14)
		SwitchBase.BackgroundColor3 = Colors.ToggleOff
		SwitchBase.Parent = ToggleFrame
		Instance.new("UICorner", SwitchBase).CornerRadius = UDim.new(1, 0)

		local Knob = Instance.new("Frame")
		Knob.Size = UDim2.new(0, 22, 0, 22)
		Knob.Position = UDim2.new(0, 3, 0.5, -11)
		Knob.BackgroundColor3 = Color3.new(1, 1, 1)
		Knob.Parent = SwitchBase
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

		local KnobStroke = Instance.new("UIStroke", Knob)
		KnobStroke.Color = Color3.fromRGB(0, 0, 0)
		KnobStroke.Thickness = 1
		KnobStroke.Transparency = 0.6

		ToggleFrame.MouseEnter:Connect(function()
			TweenService:Create(ToggleFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		ToggleFrame.MouseLeave:Connect(function()
			TweenService:Create(ToggleFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
		end)

		local toggled = (_toggleStates[titleText] ~= nil) and _toggleStates[titleText] or (initialState == true)
		local switchRef = {obj = SwitchBase, prop = "BackgroundColor3", role = toggled and "ToggleOn" or "ToggleOff"}
		table.insert(ThemedRefs, switchRef)

		if toggled then
			SwitchBase.BackgroundColor3 = Colors.ToggleOn
			Knob.Position = UDim2.new(0, 25, 0.5, -11)
		end

		SwitchBase.MouseButton1Click:Connect(function()
			toggled = not toggled
			switchRef.role = toggled and "ToggleOn" or "ToggleOff"
			TweenService:Create(SwitchBase, TweenInfo.new(0.121, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = toggled and Colors.ToggleOn or Colors.ToggleOff
			}):Play()
			TweenService:Create(Knob, TweenInfo.new(0.121, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = toggled and UDim2.new(0, 25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
			}):Play()
			if toggled then
				TweenService:Create(mStroke, TweenInfo.new(0.154), {Color = Colors.Accent}):Play()
				task.delay(0.308, function()
					TweenService:Create(mStroke, TweenInfo.new(0.308), {Color = Colors.Stroke}):Play()
				end)
			end
			_toggleStates[titleText] = toggled
			task.spawn(function() pcall(callback, toggled) end)
		end)
	end

	local function createButton(parent, titleText, desc, callback)
		local BtnWrapper = Instance.new("Frame")
		BtnWrapper.Size = UDim2.new(1, -10, 0, 60)
		BtnWrapper.BackgroundTransparency = 1
		BtnWrapper.Parent = parent
		_reg(titleText, BtnWrapper, parent)

		local BtnFrame = Instance.new("TextButton")
		BtnFrame.Size = UDim2.new(1, 0, 1, 0)
		BtnFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		BtnFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		BtnFrame.BackgroundColor3 = Colors.ItemBG
		BtnFrame.Parent = BtnWrapper
		BtnFrame.Text = ""
		BtnFrame.AutoButtonColor = false
		Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 12)
		reg(BtnFrame, "BackgroundColor3", "ItemBG")

		local TTitle = Instance.new("TextLabel")
		TTitle.Text = titleText
		TTitle.Size = UDim2.new(1, -20, 0, 25)
		TTitle.Position = UDim2.new(0, 15, 0, 10)
		TTitle.BackgroundTransparency = 1
		TTitle.TextColor3 = Colors.TextMain
		TTitle.Font = Enum.Font.GothamBold
		TTitle.TextSize = 16
		TTitle.TextXAlignment = Enum.TextXAlignment.Left
		TTitle.Parent = BtnFrame
		reg(TTitle, "TextColor3", "TextMain")

		local TDesc = Instance.new("TextLabel")
		TDesc.Text = desc
		TDesc.Size = UDim2.new(1, -20, 0, 20)
		TDesc.Position = UDim2.new(0, 15, 0, 32)
		TDesc.BackgroundTransparency = 1
		TDesc.TextColor3 = Colors.TextSub
		TDesc.Font = Enum.Font.Gotham
		TDesc.TextSize = 12
		TDesc.TextXAlignment = Enum.TextXAlignment.Left
		TDesc.Parent = BtnFrame
		reg(TDesc, "TextColor3", "TextSub")

		local Arrow = Instance.new("TextLabel")
		Arrow.Text = "›"
		Arrow.Size = UDim2.new(0, 20, 0, 20)
		Arrow.Position = UDim2.new(1, -30, 0.5, -10)
		Arrow.BackgroundTransparency = 1
		Arrow.TextColor3 = Color3.fromRGB(80, 80, 80)
		Arrow.TextSize = 20
		Arrow.Font = Enum.Font.GothamBold
		Arrow.Parent = BtnFrame

		local BtnScale = Instance.new("UIScale", BtnFrame)
		BtnScale.Scale = 1

		BtnFrame.MouseEnter:Connect(function()
			TweenService:Create(BtnFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
			TweenService:Create(Arrow, TweenInfo.new(0.11), {TextColor3 = Colors.Accent, Position = UDim2.new(1, -26, 0.5, -10)}):Play()
		end)
		BtnFrame.MouseLeave:Connect(function()
			TweenService:Create(BtnFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
			TweenService:Create(Arrow, TweenInfo.new(0.11), {TextColor3 = Color3.fromRGB(80, 80, 80), Position = UDim2.new(1, -30, 0.5, -10)}):Play()
		end)
		BtnFrame.MouseButton1Click:Connect(function()
			TweenService:Create(BtnScale, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.97}):Play()
			task.delay(0.06, function()
				TweenService:Create(BtnScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
			end)
			task.spawn(callback)
		end)
	end

	local function createSlider(parent, titleText, desc, minVal, maxVal, initialVal, callback)
		local SliderFrame = Instance.new("Frame")
		SliderFrame.Size = UDim2.new(1, -10, 0, 70)
		SliderFrame.BackgroundColor3 = Colors.ItemBG
		SliderFrame.Parent = parent
		Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 12)
		reg(SliderFrame, "BackgroundColor3", "ItemBG")
		_reg(titleText, SliderFrame, parent)

		local STitle = Instance.new("TextLabel")
		STitle.Text = titleText
		STitle.Size = UDim2.new(1, -80, 0, 22)
		STitle.Position = UDim2.new(0, 15, 0, 10)
		STitle.BackgroundTransparency = 1
		STitle.TextColor3 = Colors.TextMain
		STitle.Font = Enum.Font.GothamBold
		STitle.TextSize = 15
		STitle.TextXAlignment = Enum.TextXAlignment.Left
		STitle.Parent = SliderFrame
		reg(STitle, "TextColor3", "TextMain")

		local SDesc = Instance.new("TextLabel")
		SDesc.Text = desc
		SDesc.Size = UDim2.new(1, -80, 0, 16)
		SDesc.Position = UDim2.new(0, 15, 0, 30)
		SDesc.BackgroundTransparency = 1
		SDesc.TextColor3 = Colors.TextSub
		SDesc.Font = Enum.Font.Gotham
		SDesc.TextSize = 11
		SDesc.TextXAlignment = Enum.TextXAlignment.Left
		SDesc.Parent = SliderFrame
		reg(SDesc, "TextColor3", "TextSub")

		local SValLabel = Instance.new("TextLabel")
		SValLabel.Size = UDim2.new(0, 60, 0, 22)
		SValLabel.Position = UDim2.new(1, -70, 0, 10)
		SValLabel.BackgroundTransparency = 1
		SValLabel.TextColor3 = Colors.Accent
		SValLabel.Font = Enum.Font.GothamBold
		SValLabel.TextSize = 13
		SValLabel.TextXAlignment = Enum.TextXAlignment.Right
		SValLabel.Parent = SliderFrame
		reg(SValLabel, "TextColor3", "Accent")

		local Track = Instance.new("Frame")
		Track.Size = UDim2.new(1, -30, 0, 5)
		Track.Position = UDim2.new(0, 15, 1, -18)
		Track.BackgroundColor3 = Colors.ToggleOff
		Track.BorderSizePixel = 0
		Track.Parent = SliderFrame
		Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
		reg(Track, "BackgroundColor3", "ToggleOff")

		local Fill = Instance.new("Frame")
		Fill.Size = UDim2.new(0, 0, 1, 0)
		Fill.BackgroundColor3 = Colors.Accent
		Fill.BorderSizePixel = 0
		Fill.Parent = Track
		Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
		reg(Fill, "BackgroundColor3", "Accent")

		local Knob = Instance.new("Frame")
		Knob.Size = UDim2.new(0, 14, 0, 14)
		Knob.AnchorPoint = Vector2.new(0.5, 0.5)
		Knob.BackgroundColor3 = Color3.new(1, 1, 1)
		Knob.BorderSizePixel = 0
		Knob.ZIndex = 2
		Knob.Parent = Track
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
		local KnobStroke = Instance.new("UIStroke", Knob)
		KnobStroke.Color = Colors.Accent
		KnobStroke.Thickness = 1.5
		reg(KnobStroke, "Color", "Accent")

		local DragBtn = Instance.new("TextButton")
		DragBtn.Size = UDim2.new(1, 20, 0, 22)
		DragBtn.Position = UDim2.new(0, -10, 0.5, -11)
		DragBtn.BackgroundTransparency = 1
		DragBtn.Text = ""
		DragBtn.ZIndex = 3
		DragBtn.Parent = Track

		local currentVal = math.clamp(initialVal, minVal, maxVal)

		local function updateDisplay(val)
			local pct = (val - minVal) / (maxVal - minVal)
			Fill.Size = UDim2.new(pct, 0, 1, 0)
			Knob.Position = UDim2.new(pct, 0, 0.5, 0)
			SValLabel.Text = string.format("%.0f%%", pct * 100)
		end

		updateDisplay(currentVal)

		local dragging = false

		local function applyFromInput(input)
			local trackAbs = Track.AbsolutePosition
			local trackW = Track.AbsoluteSize.X
			local pct = math.clamp((input.Position.X - trackAbs.X) / trackW, 0, 1)
			currentVal = minVal + pct * (maxVal - minVal)
			updateDisplay(currentVal)
			pcall(callback, currentVal, pct)
		end

		DragBtn.MouseButton1Down:Connect(function() dragging = true end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or
			   input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
			                 input.UserInputType == Enum.UserInputType.Touch) then
				applyFromInput(input)
			end
		end)
		DragBtn.MouseButton1Click:Connect(function()
			applyFromInput({Position = UserInputService:GetMouseLocation()})
		end)

		SliderFrame.MouseEnter:Connect(function()
			TweenService:Create(SliderFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		SliderFrame.MouseLeave:Connect(function()
			TweenService:Create(SliderFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
		end)

		return {
			frame = SliderFrame,
			setValue = function(val)
				currentVal = math.clamp(val, minVal, maxVal)
				updateDisplay(currentVal)
			end
		}
	end

	local function createDropdown(parent, titleText, options, callback, initialValue)
		local selectedOption = initialValue or options[1] or ""
		local popupOpen = false
		local currentPopup = nil
		local currentBackdrop = nil
		local baseHeight = 60
		local optionHeight = 38
		local popupPad = 6

		local DropFrame = Instance.new("Frame")
		DropFrame.Size = UDim2.new(1, -10, 0, baseHeight)
		DropFrame.BackgroundColor3 = Colors.ItemBG
		DropFrame.Parent = parent
		DropFrame.ClipsDescendants = false
		Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 12)
		reg(DropFrame, "BackgroundColor3", "ItemBG")
		_reg(titleText, DropFrame, parent)

		local DTitle = Instance.new("TextLabel")
		DTitle.Text = titleText
		DTitle.Size = UDim2.new(0.5, -15, 0, 22)
		DTitle.Position = UDim2.new(0, 15, 0.5, -11)
		DTitle.BackgroundTransparency = 1
		DTitle.TextColor3 = Colors.TextMain
		DTitle.Font = Enum.Font.GothamBold
		DTitle.TextSize = 15
		DTitle.TextXAlignment = Enum.TextXAlignment.Left
		DTitle.Parent = DropFrame
		reg(DTitle, "TextColor3", "TextMain")

		local DValue = Instance.new("TextLabel")
		DValue.Text = selectedOption
		DValue.Size = UDim2.new(0.5, -50, 0, 22)
		DValue.Position = UDim2.new(0.5, 0, 0.5, -11)
		DValue.BackgroundTransparency = 1
		DValue.TextColor3 = Colors.TextSub
		DValue.Font = Enum.Font.Gotham
		DValue.TextSize = 14
		DValue.TextXAlignment = Enum.TextXAlignment.Right
		DValue.Parent = DropFrame
		reg(DValue, "TextColor3", "TextSub")

		local Chevron = Instance.new("TextLabel")
		Chevron.Text = "›"
		Chevron.Size = UDim2.new(0, 20, 0, 20)
		Chevron.Position = UDim2.new(1, -32, 0.5, -10)
		Chevron.BackgroundTransparency = 1
		Chevron.TextColor3 = Colors.TextSub
		Chevron.TextSize = 18
		Chevron.Font = Enum.Font.GothamBold
		Chevron.Rotation = 90
		Chevron.Parent = DropFrame
		reg(Chevron, "TextColor3", "TextSub")

		local ExpandBtn = Instance.new("TextButton")
		ExpandBtn.Size = UDim2.new(1, 0, 1, 0)
		ExpandBtn.BackgroundTransparency = 1
		ExpandBtn.Text = ""
		ExpandBtn.Parent = DropFrame

		ExpandBtn.MouseEnter:Connect(function()
			TweenService:Create(DropFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		ExpandBtn.MouseLeave:Connect(function()
			TweenService:Create(DropFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
		end)

		local function closePopup()
			if not popupOpen then return end
			popupOpen = false
			TweenService:Create(Chevron, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90}):Play()
			if currentPopup then
				local popScale = currentPopup:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", currentPopup)
				TweenService:Create(popScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.95}):Play()
				TweenService:Create(currentPopup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
				for _, c in ipairs(currentPopup:GetDescendants()) do
					if c:IsA("TextLabel") or c:IsA("TextButton") then
						TweenService:Create(c, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
					elseif c:IsA("Frame") then
						TweenService:Create(c, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
					end
				end
				local ref = currentPopup
				task.delay(0.16, function()
					if ref and ref.Parent then ref:Destroy() end
				end)
				currentPopup = nil
			end
			if currentBackdrop then
				currentBackdrop:Destroy()
				currentBackdrop = nil
			end
		end

		local function openPopup()
			if popupOpen then closePopup() return end
			popupOpen = true
			TweenService:Create(Chevron, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 270}):Play()

			local Backdrop = Instance.new("TextButton")
			Backdrop.Size = UDim2.new(1, 0, 1, 0)
			Backdrop.BackgroundTransparency = 1
			Backdrop.Text = ""
			Backdrop.ZIndex = 50
			Backdrop.Parent = gui
			currentBackdrop = Backdrop
			Backdrop.MouseButton1Click:Connect(closePopup)

			local absPos = DropFrame.AbsolutePosition
			local absSize = DropFrame.AbsoluteSize
			local popupW = absSize.X
			local visibleRows = math.min(#options, 5)
			local popupH = visibleRows * optionHeight + 10

			local Popup = Instance.new("Frame")
			Popup.Size = UDim2.new(0, popupW, 0, popupH)
			Popup.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + popupPad)
			Popup.BackgroundColor3 = Colors.ItemBG
			Popup.BackgroundTransparency = 1
			Popup.BorderSizePixel = 0
			Popup.ZIndex = 51
			Popup.ClipsDescendants = true
			Popup.Parent = gui
			Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 12)

			local PopupStroke = Instance.new("UIStroke", Popup)
			PopupStroke.Color = Colors.Stroke
			PopupStroke.Thickness = 1
			PopupStroke.Transparency = 1

			local PopScale = Instance.new("UIScale", Popup)
			PopScale.Scale = 0.92
			currentPopup = Popup

			local ListPad = Instance.new("ScrollingFrame", Popup)
			ListPad.Size = UDim2.new(1, -12, 1, -10)
			ListPad.Position = UDim2.new(0, 6, 0, 5)
			ListPad.BackgroundTransparency = 1
			ListPad.BorderSizePixel = 0
			ListPad.ZIndex = 52
			ListPad.ScrollBarThickness = 3
			ListPad.ScrollBarImageColor3 = Colors.Stroke
			ListPad.CanvasSize = UDim2.new(0, 0, 0, #options * optionHeight)
			ListPad.AutomaticCanvasSize = Enum.AutomaticSize.None
			local listLayout = Instance.new("UIListLayout", ListPad)
			listLayout.Padding = UDim.new(0, 4)

			for _, optName in ipairs(options) do
				local isSelected = (optName == selectedOption)

				local Row = Instance.new("TextButton")
				Row.Size = UDim2.new(1, 0, 0, optionHeight - 4)
				Row.BackgroundColor3 = isSelected and Colors.ButtonHover or Colors.ItemBG
				Row.BackgroundTransparency = 1
				Row.Text = ""
				Row.ZIndex = 53
				Row.Parent = ListPad
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

				local RowLabel = Instance.new("TextLabel")
				RowLabel.Text = optName
				RowLabel.Size = UDim2.new(1, -40, 1, 0)
				RowLabel.Position = UDim2.new(0, 12, 0, 0)
				RowLabel.BackgroundTransparency = 1
				RowLabel.TextColor3 = isSelected and Colors.TextMain or Colors.TextSub
				RowLabel.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
				RowLabel.TextSize = 14
				RowLabel.TextXAlignment = Enum.TextXAlignment.Left
				RowLabel.TextTransparency = 1
				RowLabel.ZIndex = 54
				RowLabel.Parent = Row

				local Check = Instance.new("TextLabel")
				Check.Text = "✓"
				Check.Size = UDim2.new(0, 22, 1, 0)
				Check.Position = UDim2.new(1, -26, 0, 0)
				Check.BackgroundTransparency = 1
				Check.TextColor3 = Colors.Accent
				Check.Font = Enum.Font.GothamBold
				Check.TextSize = 14
				Check.TextTransparency = 1
				Check.ZIndex = 54
				Check.Parent = Row

				Row.MouseEnter:Connect(function()
					if optName ~= selectedOption then
						TweenService:Create(Row, TweenInfo.new(0.09), {BackgroundColor3 = Colors.ButtonHover, BackgroundTransparency = 0}):Play()
						TweenService:Create(RowLabel, TweenInfo.new(0.09), {TextColor3 = Colors.TextMain}):Play()
					end
				end)
				Row.MouseLeave:Connect(function()
					if optName ~= selectedOption then
						TweenService:Create(Row, TweenInfo.new(0.09), {BackgroundTransparency = 1}):Play()
						TweenService:Create(RowLabel, TweenInfo.new(0.09), {TextColor3 = Colors.TextSub}):Play()
					end
				end)
				Row.MouseButton1Click:Connect(function()
					for _, child in ipairs(ListPad:GetChildren()) do
						if child:IsA("TextButton") then
							child.BackgroundTransparency = 1
							local lbl = child:FindFirstChildOfClass("TextLabel")
							if lbl then lbl.Font = Enum.Font.Gotham end
							for _, sub in ipairs(child:GetChildren()) do
								if sub:IsA("TextLabel") and sub.Text == "✓" then
									sub.TextTransparency = 1
								end
							end
						end
					end
					Row.BackgroundColor3 = Colors.ButtonHover
					Row.BackgroundTransparency = 0
					selectedOption = optName
					DValue.Text = optName
					pcall(callback, optName)
					closePopup()
				end)
			end

			local fadeIn = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local textIn = TweenInfo.new(0.14)
			TweenService:Create(PopScale, fadeIn, {Scale = 1}):Play()
			TweenService:Create(Popup, TweenInfo.new(0.14), {BackgroundTransparency = 0}):Play()
			TweenService:Create(PopupStroke, TweenInfo.new(0.14), {Transparency = 0.5}):Play()
			for _, child in ipairs(ListPad:GetChildren()) do
				if child:IsA("TextButton") then
					if child.BackgroundColor3 == Colors.ButtonHover then
						TweenService:Create(child, textIn, {BackgroundTransparency = 0}):Play()
					end
					for _, sub in ipairs(child:GetDescendants()) do
						if sub:IsA("TextLabel") then
							local targetTrans = 0
							if sub.Text == "✓" then
								targetTrans = (child.BackgroundColor3 == Colors.ButtonHover) and 0 or 1
							end
							TweenService:Create(sub, textIn, {TextTransparency = targetTrans}):Play()
						end
					end
				end
			end
		end

		ExpandBtn.MouseButton1Click:Connect(openPopup)
	end

	local function createMultiDropdown(parent, titleText, options, callback)
		local selectedOptions = {}
		local popupOpen = false
		local currentPopup = nil
		local currentBackdrop = nil
		local baseHeight = 60
		local optionHeight = 38
		local popupPad = 6

		local DropFrame = Instance.new("Frame")
		DropFrame.Size = UDim2.new(1, -10, 0, baseHeight)
		DropFrame.BackgroundColor3 = Colors.ItemBG
		DropFrame.Parent = parent
		DropFrame.ClipsDescendants = false
		Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 12)
		reg(DropFrame, "BackgroundColor3", "ItemBG")
		_reg(titleText, DropFrame, parent)

		local DTitle = Instance.new("TextLabel")
		DTitle.Text = titleText
		DTitle.Size = UDim2.new(0.5, -15, 0, 22)
		DTitle.Position = UDim2.new(0, 15, 0.5, -11)
		DTitle.BackgroundTransparency = 1
		DTitle.TextColor3 = Colors.TextMain
		DTitle.Font = Enum.Font.GothamBold
		DTitle.TextSize = 15
		DTitle.TextXAlignment = Enum.TextXAlignment.Left
		DTitle.Parent = DropFrame
		reg(DTitle, "TextColor3", "TextMain")

		local DValue = Instance.new("TextLabel")
		DValue.Text = "None"
		DValue.Size = UDim2.new(0.5, -50, 0, 22)
		DValue.Position = UDim2.new(0.5, 0, 0.5, -11)
		DValue.BackgroundTransparency = 1
		DValue.TextColor3 = Colors.TextSub
		DValue.Font = Enum.Font.Gotham
		DValue.TextSize = 14
		DValue.TextXAlignment = Enum.TextXAlignment.Right
		DValue.Parent = DropFrame
		reg(DValue, "TextColor3", "TextSub")

		local Chevron = Instance.new("TextLabel")
		Chevron.Text = "›"
		Chevron.Size = UDim2.new(0, 20, 0, 20)
		Chevron.Position = UDim2.new(1, -32, 0.5, -10)
		Chevron.BackgroundTransparency = 1
		Chevron.TextColor3 = Colors.TextSub
		Chevron.TextSize = 18
		Chevron.Font = Enum.Font.GothamBold
		Chevron.Rotation = 90
		Chevron.Parent = DropFrame
		reg(Chevron, "TextColor3", "TextSub")

		local ExpandBtn = Instance.new("TextButton")
		ExpandBtn.Size = UDim2.new(1, 0, 1, 0)
		ExpandBtn.BackgroundTransparency = 1
		ExpandBtn.Text = ""
		ExpandBtn.Parent = DropFrame

		ExpandBtn.MouseEnter:Connect(function()
			TweenService:Create(DropFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		ExpandBtn.MouseLeave:Connect(function()
			TweenService:Create(DropFrame, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
		end)

		local function updateValueLabel()
			local count = 0
			for _ in pairs(selectedOptions) do count += 1 end
			if count == 0 then
				DValue.Text = "None"
			elseif count == 1 then
				local name = next(selectedOptions)
				DValue.Text = name
			else
				DValue.Text = count .. " selected"
			end
		end

		local function closePopup()
			if not popupOpen then return end
			popupOpen = false
			TweenService:Create(Chevron, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90}):Play()
			if currentPopup then
				local popScale = currentPopup:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", currentPopup)
				TweenService:Create(popScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.95}):Play()
				TweenService:Create(currentPopup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
				for _, c in ipairs(currentPopup:GetDescendants()) do
					if c:IsA("TextLabel") or c:IsA("TextButton") then
						TweenService:Create(c, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
					elseif c:IsA("Frame") then
						TweenService:Create(c, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
					end
				end
				local ref = currentPopup
				task.delay(0.16, function()
					if ref and ref.Parent then ref:Destroy() end
				end)
				currentPopup = nil
			end
			if currentBackdrop then
				currentBackdrop:Destroy()
				currentBackdrop = nil
			end
		end

		local function openPopup()
			if popupOpen then closePopup() return end
			popupOpen = true
			TweenService:Create(Chevron, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 270}):Play()

			local Backdrop = Instance.new("TextButton")
			Backdrop.Size = UDim2.new(1, 0, 1, 0)
			Backdrop.BackgroundTransparency = 1
			Backdrop.Text = ""
			Backdrop.ZIndex = 50
			Backdrop.Parent = gui
			currentBackdrop = Backdrop
			Backdrop.MouseButton1Click:Connect(closePopup)

			local absPos = DropFrame.AbsolutePosition
			local absSize = DropFrame.AbsoluteSize
			local popupW = absSize.X
			local visibleRows = math.min(#options, 5)
			local popupH = visibleRows * optionHeight + 10

			local Popup = Instance.new("Frame")
			Popup.Size = UDim2.new(0, popupW, 0, popupH)
			Popup.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + popupPad)
			Popup.BackgroundColor3 = Colors.ItemBG
			Popup.BackgroundTransparency = 1
			Popup.BorderSizePixel = 0
			Popup.ZIndex = 51
			Popup.ClipsDescendants = true
			Popup.Parent = gui
			Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 12)

			local PopupStroke = Instance.new("UIStroke", Popup)
			PopupStroke.Color = Colors.Stroke
			PopupStroke.Thickness = 1
			PopupStroke.Transparency = 1

			local PopScale = Instance.new("UIScale", Popup)
			PopScale.Scale = 0.92
			currentPopup = Popup

			local ListPad = Instance.new("ScrollingFrame", Popup)
			ListPad.Size = UDim2.new(1, -12, 1, -10)
			ListPad.Position = UDim2.new(0, 6, 0, 5)
			ListPad.BackgroundTransparency = 1
			ListPad.BorderSizePixel = 0
			ListPad.ZIndex = 52
			ListPad.ScrollBarThickness = 3
			ListPad.ScrollBarImageColor3 = Colors.Stroke
			ListPad.CanvasSize = UDim2.new(0, 0, 0, #options * optionHeight)
			ListPad.AutomaticCanvasSize = Enum.AutomaticSize.None
			local listLayout = Instance.new("UIListLayout", ListPad)
			listLayout.Padding = UDim.new(0, 4)

			for _, optName in ipairs(options) do
				local isSelected = selectedOptions[optName] == true

				local Row = Instance.new("TextButton")
				Row.Size = UDim2.new(1, 0, 0, optionHeight - 4)
				Row.BackgroundColor3 = isSelected and Colors.ButtonHover or Colors.ItemBG
				Row.BackgroundTransparency = isSelected and 0 or 1
				Row.Text = ""
				Row.ZIndex = 53
				Row.Parent = ListPad
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

				local RowLabel = Instance.new("TextLabel")
				RowLabel.Text = optName
				RowLabel.Size = UDim2.new(1, -40, 1, 0)
				RowLabel.Position = UDim2.new(0, 12, 0, 0)
				RowLabel.BackgroundTransparency = 1
				RowLabel.TextColor3 = isSelected and Colors.TextMain or Colors.TextSub
				RowLabel.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
				RowLabel.TextSize = 14
				RowLabel.TextXAlignment = Enum.TextXAlignment.Left
				RowLabel.TextTransparency = 1
				RowLabel.ZIndex = 54
				RowLabel.Parent = Row

				local Check = Instance.new("TextLabel")
				Check.Text = "✓"
				Check.Size = UDim2.new(0, 22, 1, 0)
				Check.Position = UDim2.new(1, -26, 0, 0)
				Check.BackgroundTransparency = 1
				Check.TextColor3 = Colors.Accent
				Check.Font = Enum.Font.GothamBold
				Check.TextSize = 14
				Check.TextTransparency = 1
				Check.ZIndex = 54
				Check.Parent = Row

				Row.MouseEnter:Connect(function()
					if not selectedOptions[optName] then
						TweenService:Create(Row, TweenInfo.new(0.09), {BackgroundColor3 = Colors.ButtonHover, BackgroundTransparency = 0}):Play()
						TweenService:Create(RowLabel, TweenInfo.new(0.09), {TextColor3 = Colors.TextMain}):Play()
					end
				end)
				Row.MouseLeave:Connect(function()
					if not selectedOptions[optName] then
						TweenService:Create(Row, TweenInfo.new(0.09), {BackgroundTransparency = 1}):Play()
						TweenService:Create(RowLabel, TweenInfo.new(0.09), {TextColor3 = Colors.TextSub}):Play()
					end
				end)
				Row.MouseButton1Click:Connect(function()
					if selectedOptions[optName] then
						selectedOptions[optName] = nil
						TweenService:Create(Row, TweenInfo.new(0.09), {BackgroundTransparency = 1}):Play()
						TweenService:Create(RowLabel, TweenInfo.new(0.09), {TextColor3 = Colors.TextSub, Font = Enum.Font.Gotham}):Play()
						TweenService:Create(Check, TweenInfo.new(0.09), {TextTransparency = 1}):Play()
					else
						selectedOptions[optName] = true
						TweenService:Create(Row, TweenInfo.new(0.09), {BackgroundColor3 = Colors.ButtonHover, BackgroundTransparency = 0}):Play()
						TweenService:Create(RowLabel, TweenInfo.new(0.09), {TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold}):Play()
						TweenService:Create(Check, TweenInfo.new(0.09), {TextTransparency = 0}):Play()
					end
					updateValueLabel()
					local result = {}
					for k in pairs(selectedOptions) do table.insert(result, k) end
					pcall(callback, result)
				end)
			end

			local fadeIn = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local textIn = TweenInfo.new(0.14)
			TweenService:Create(PopScale, fadeIn, {Scale = 1}):Play()
			TweenService:Create(Popup, TweenInfo.new(0.14), {BackgroundTransparency = 0}):Play()
			TweenService:Create(PopupStroke, TweenInfo.new(0.14), {Transparency = 0.5}):Play()
			for _, child in ipairs(ListPad:GetChildren()) do
				if child:IsA("TextButton") then
					if selectedOptions[child:FindFirstChildOfClass("TextLabel") and child:FindFirstChildOfClass("TextLabel").Text] then
						TweenService:Create(child, textIn, {BackgroundTransparency = 0}):Play()
					end
					for _, sub in ipairs(child:GetDescendants()) do
						if sub:IsA("TextLabel") then
							local targetTrans = 0
							if sub.Text == "✓" then
								targetTrans = selectedOptions[child:FindFirstChildOfClass("TextLabel") and child:FindFirstChildOfClass("TextLabel").Text] and 0 or 1
							end
							TweenService:Create(sub, textIn, {TextTransparency = targetTrans}):Play()
						end
					end
				end
			end
		end

		ExpandBtn.MouseButton1Click:Connect(openPopup)
	end

	local _colorPickerOpen = false
	local _colorPickerFrame = nil

	local function openColorPicker(initH, initS, initV)
		if _colorPickerOpen and _colorPickerFrame and _colorPickerFrame.Parent then return end
		_colorPickerOpen = true

		if ctx.closeUI then ctx.closeUI() end

		initH = initH or 0.6
		initS = initS or 0.8
		initV = initV or 0.85

		local pH, pS, pV = initH, initS, initV
		local connections = {}

		local CPW = 360
		local CPH = 310
		local SQ_X = 14
		local SQ_Y = 54
		local SQ_W = 188
		local SQ_H = 188
		local BW = 20
		local HX = SQ_X + SQ_W + 10
		local VX = HX + BW + 8
		local BY = SQ_Y + SQ_H + 14
		local PW = 42
		local RW = 48
		local RG = 4
		local RX = SQ_X + PW + 8
		local AX = RX + (RW + RG) * 3 + 6
		local AW = CPW - AX - 12

		local cpWin = Instance.new("Frame")
		cpWin.Name = "GGHub_ColorPicker"
		cpWin.Size = UDim2.new(0, CPW, 0, CPH)
		cpWin.Position = UDim2.new(0.5, -CPW / 2, 0.5, -CPH / 2)
		cpWin.BackgroundColor3 = Colors.Background
		cpWin.BorderSizePixel = 0
		cpWin.Active = true
		cpWin.ZIndex = 60
		cpWin.Parent = gui
		Instance.new("UICorner", cpWin).CornerRadius = UDim.new(0, 14)
		local cpStroke = Instance.new("UIStroke", cpWin)
		cpStroke.Color = Colors.Stroke
		cpStroke.Thickness = 1
		_colorPickerFrame = cpWin
		reg(cpWin, "BackgroundColor3", "Background")

		local cpTitle = Instance.new("TextLabel")
		cpTitle.Text = "Custom Color"
		cpTitle.Font = Enum.Font.GothamBold
		cpTitle.TextSize = 14
		cpTitle.TextColor3 = Colors.TextMain
		cpTitle.BackgroundTransparency = 1
		cpTitle.Size = UDim2.new(1, -50, 0, 44)
		cpTitle.Position = UDim2.new(0, 14, 0, 0)
		cpTitle.TextXAlignment = Enum.TextXAlignment.Left
		cpTitle.ZIndex = 62
		cpTitle.Parent = cpWin
		reg(cpTitle, "TextColor3", "TextMain")

		local cpClose = Instance.new("TextButton")
		cpClose.Text = "×"
		cpClose.Size = UDim2.new(0, 28, 0, 28)
		cpClose.Position = UDim2.new(1, -38, 0, 8)
		cpClose.BackgroundColor3 = Colors.Button
		cpClose.TextColor3 = Colors.TextMain
		cpClose.TextSize = 20
		cpClose.Font = Enum.Font.GothamBold
		cpClose.BorderSizePixel = 0
		cpClose.Active = true
		cpClose.ZIndex = 65
		cpClose.Parent = cpWin
		Instance.new("UICorner", cpClose)
		reg(cpClose, "BackgroundColor3", "Button")
		reg(cpClose, "TextColor3", "TextMain")

		local cpLine = Instance.new("Frame")
		cpLine.Size = UDim2.new(1, -20, 0, 1)
		cpLine.Position = UDim2.new(0, 10, 0, 44)
		cpLine.BackgroundColor3 = Colors.HeaderLine
		cpLine.BorderSizePixel = 0
		cpLine.ZIndex = 61
		cpLine.Parent = cpWin
		reg(cpLine, "BackgroundColor3", "HeaderLine")

		local dragBtn = Instance.new("TextButton")
		dragBtn.Size = UDim2.new(1, 0, 0, 44)
		dragBtn.Position = UDim2.new(0, 0, 0, 0)
		dragBtn.BackgroundTransparency = 1
		dragBtn.Text = ""
		dragBtn.ZIndex = 61
		dragBtn.Parent = cpWin

		do
			local dragging = false
			local dragStart, startPos
			dragBtn.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = inp.Position
					startPos = cpWin.Position
				end
			end)
			table.insert(connections, UserInputService.InputChanged:Connect(function(inp)
				if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
					local delta = inp.Position - dragStart
					cpWin.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end))
			table.insert(connections, UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end))
		end

		local svSq = Instance.new("Frame")
		svSq.Size = UDim2.new(0, SQ_W, 0, SQ_H)
		svSq.Position = UDim2.new(0, SQ_X, 0, SQ_Y)
		svSq.BackgroundColor3 = Color3.fromHSV(pH, 1, 1)
		svSq.BorderSizePixel = 0
		svSq.ClipsDescendants = true
		svSq.ZIndex = 61
		svSq.Parent = cpWin

		local satOvr = Instance.new("Frame")
		satOvr.Size = UDim2.new(1, 0, 1, 0)
		satOvr.BackgroundColor3 = Color3.new(1, 1, 1)
		satOvr.BorderSizePixel = 0
		satOvr.ZIndex = 62
		satOvr.Parent = svSq
		local satGrad = Instance.new("UIGradient", satOvr)
		satGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
		satGrad.Rotation = 0

		local valOvr = Instance.new("Frame")
		valOvr.Size = UDim2.new(1, 0, 1, 0)
		valOvr.BackgroundColor3 = Color3.new(0, 0, 0)
		valOvr.BorderSizePixel = 0
		valOvr.ZIndex = 63
		valOvr.Parent = svSq
		local valGrad = Instance.new("UIGradient", valOvr)
		valGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
		valGrad.Rotation = 90

		local svKnob = Instance.new("Frame")
		svKnob.Size = UDim2.new(0, 14, 0, 14)
		svKnob.AnchorPoint = Vector2.new(0.5, 0.5)
		svKnob.BackgroundColor3 = Color3.fromHSV(pH, pS, pV)
		svKnob.BorderSizePixel = 0
		svKnob.ZIndex = 65
		svKnob.Position = UDim2.new(pS, 0, 1 - pV, 0)
		svKnob.Parent = svSq
		Instance.new("UICorner", svKnob).CornerRadius = UDim.new(1, 0)
		local svKStr = Instance.new("UIStroke", svKnob)
		svKStr.Thickness = 2
		svKStr.Color = Color3.new(1, 1, 1)
		svKStr.Transparency = 0.1

		local svBtn = Instance.new("TextButton")
		svBtn.Size = UDim2.new(1, 0, 1, 0)
		svBtn.BackgroundTransparency = 1
		svBtn.Text = ""
		svBtn.ZIndex = 66
		svBtn.Active = true
		svBtn.AutoButtonColor = false
		svBtn.Parent = svSq

		local hueBar = Instance.new("Frame")
		hueBar.Size = UDim2.new(0, BW, 0, SQ_H)
		hueBar.Position = UDim2.new(0, HX, 0, SQ_Y)
		hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
		hueBar.BorderSizePixel = 0
		hueBar.ClipsDescendants = true
		hueBar.ZIndex = 61
		hueBar.Parent = cpWin
		Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 6)

		local hueFill = Instance.new("Frame")
		hueFill.Size = UDim2.new(1, 0, 1, 0)
		hueFill.BackgroundColor3 = Color3.new(1, 1, 1)
		hueFill.BorderSizePixel = 0
		hueFill.ZIndex = 62
		hueFill.Parent = hueBar
		local hueKpts = {}
		for i = 0, 19 do
			hueKpts[i + 1] = ColorSequenceKeypoint.new(i / 19, Color3.fromHSV(i / 19, 1, 1))
		end
		local hueGrad = Instance.new("UIGradient", hueFill)
		hueGrad.Color = ColorSequence.new(hueKpts)
		hueGrad.Rotation = 90

		local hueKnob = Instance.new("Frame")
		hueKnob.Size = UDim2.new(1, 6, 0, 5)
		hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
		hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
		hueKnob.BorderSizePixel = 0
		hueKnob.ZIndex = 65
		hueKnob.Position = UDim2.new(0.5, 0, pH, 0)
		hueKnob.Parent = hueBar
		Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 3)
		local hkStr = Instance.new("UIStroke", hueKnob)
		hkStr.Thickness = 1.5
		hkStr.Color = Color3.new(0, 0, 0)
		hkStr.Transparency = 0.35

		local hueBtn = Instance.new("TextButton")
		hueBtn.Size = UDim2.new(1, 0, 1, 0)
		hueBtn.BackgroundTransparency = 1
		hueBtn.Text = ""
		hueBtn.ZIndex = 66
		hueBtn.Active = true
		hueBtn.AutoButtonColor = false
		hueBtn.Parent = hueBar

		local vrtBar = Instance.new("Frame")
		vrtBar.Size = UDim2.new(0, BW, 0, SQ_H)
		vrtBar.Position = UDim2.new(0, VX, 0, SQ_Y)
		vrtBar.BackgroundColor3 = Color3.new(0, 0, 0)
		vrtBar.BorderSizePixel = 0
		vrtBar.ClipsDescendants = true
		vrtBar.ZIndex = 61
		vrtBar.Parent = cpWin
		Instance.new("UICorner", vrtBar).CornerRadius = UDim.new(0, 6)

		local vrtFill = Instance.new("Frame")
		vrtFill.Size = UDim2.new(1, 0, 1, 0)
		vrtFill.BackgroundColor3 = Color3.fromHSV(pH, pS, 1)
		vrtFill.BorderSizePixel = 0
		vrtFill.ZIndex = 62
		vrtFill.Parent = vrtBar
		local vrtGrad = Instance.new("UIGradient", vrtFill)
		vrtGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0, 0, 0))
		vrtGrad.Rotation = 90

		local vrtKnob = Instance.new("Frame")
		vrtKnob.Size = UDim2.new(1, 6, 0, 5)
		vrtKnob.AnchorPoint = Vector2.new(0.5, 0.5)
		vrtKnob.BackgroundColor3 = Color3.new(1, 1, 1)
		vrtKnob.BorderSizePixel = 0
		vrtKnob.ZIndex = 65
		vrtKnob.Position = UDim2.new(0.5, 0, 1 - pV, 0)
		vrtKnob.Parent = vrtBar
		Instance.new("UICorner", vrtKnob).CornerRadius = UDim.new(0, 3)
		local vrtKStr = Instance.new("UIStroke", vrtKnob)
		vrtKStr.Color = Color3.new(0.15, 0.15, 0.15)
		vrtKStr.Thickness = 1.5

		local vrtBtn = Instance.new("TextButton")
		vrtBtn.Size = UDim2.new(1, 0, 1, 0)
		vrtBtn.BackgroundTransparency = 1
		vrtBtn.Text = ""
		vrtBtn.ZIndex = 66
		vrtBtn.Active = true
		vrtBtn.AutoButtonColor = false
		vrtBtn.Parent = vrtBar

		local initCol = Color3.fromHSV(pH, pS, pV)

		local function makeRGBInput(label, xOff, initVal)
			local wrapper = Instance.new("Frame")
			wrapper.Size = UDim2.new(0, RW, 0, 40)
			wrapper.Position = UDim2.new(0, xOff, 0, BY + 2)
			wrapper.BackgroundTransparency = 1
			wrapper.ZIndex = 61
			wrapper.Parent = cpWin

			local lbl = Instance.new("TextLabel")
			lbl.Text = label
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 10
			lbl.TextColor3 = Colors.TextSub
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(1, 0, 0, 13)
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.ZIndex = 62
			lbl.Parent = wrapper
			reg(lbl, "TextColor3", "TextSub")

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, 0, 0, 27)
			box.Position = UDim2.new(0, 0, 0, 13)
			box.BackgroundColor3 = Colors.ItemBG
			box.TextColor3 = Colors.TextMain
			box.PlaceholderColor3 = Colors.TextSub
			box.Font = Enum.Font.GothamBold
			box.TextSize = 12
			box.Text = tostring(initVal)
			box.ClearTextOnFocus = false
			box.TextXAlignment = Enum.TextXAlignment.Center
			box.BorderSizePixel = 0
			box.ZIndex = 62
			box.Parent = wrapper
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
			reg(box, "BackgroundColor3", "ItemBG")
			reg(box, "TextColor3", "TextMain")
			return box
		end

		local rBox = makeRGBInput("R", RX, math.floor(initCol.R * 255 + 0.5))
		local gBox = makeRGBInput("G", RX + (RW + RG), math.floor(initCol.G * 255 + 0.5))
		local bBox = makeRGBInput("B", RX + (RW + RG) * 2, math.floor(initCol.B * 255 + 0.5))

		local prevSwatch = Instance.new("Frame")
		prevSwatch.Size = UDim2.new(0, PW, 0, 40)
		prevSwatch.Position = UDim2.new(0, SQ_X, 0, BY + 2)
		prevSwatch.BackgroundColor3 = initCol
		prevSwatch.BorderSizePixel = 0
		prevSwatch.ZIndex = 61
		prevSwatch.Parent = cpWin
		Instance.new("UICorner", prevSwatch).CornerRadius = UDim.new(0, 8)

		local applyBtn = Instance.new("TextButton")
		applyBtn.Size = UDim2.new(0, AW, 0, 40)
		applyBtn.Position = UDim2.new(0, AX, 0, BY + 2)
		applyBtn.BackgroundColor3 = Colors.Accent
		applyBtn.TextColor3 = Color3.new(1, 1, 1)
		applyBtn.Font = Enum.Font.GothamBold
		applyBtn.TextSize = 13
		applyBtn.Text = "Apply"
		applyBtn.BorderSizePixel = 0
		applyBtn.Active = true
		applyBtn.ZIndex = 61
		applyBtn.Parent = cpWin
		Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 10)
		reg(applyBtn, "BackgroundColor3", "Accent")

		local function updatePicker()
			local col = Color3.fromHSV(pH, pS, pV)
			svSq.BackgroundColor3 = Color3.fromHSV(pH, 1, 1)
			svKnob.Position = UDim2.new(pS, 0, 1 - pV, 0)
			svKnob.BackgroundColor3 = col
			hueKnob.Position = UDim2.new(0.5, 0, pH, 0)
			vrtFill.BackgroundColor3 = Color3.fromHSV(pH, pS, 1)
			vrtKnob.Position = UDim2.new(0.5, 0, 1 - pV, 0)
			prevSwatch.BackgroundColor3 = col
			if not rBox:IsFocused() and not gBox:IsFocused() and not bBox:IsFocused() then
				rBox.Text = tostring(math.floor(col.R * 255 + 0.5))
				gBox.Text = tostring(math.floor(col.G * 255 + 0.5))
				bBox.Text = tostring(math.floor(col.B * 255 + 0.5))
			end
		end

		updatePicker()

		local svDragging, hueDragging, vrtDragging = false, false, false
		local inputPos = Vector2.new(0, 0)

		local function applySV()
			local abs = svSq.AbsolutePosition
			local sz = svSq.AbsoluteSize
			pS = math.clamp((inputPos.X - abs.X) / sz.X, 0, 1)
			pV = 1 - math.clamp((inputPos.Y - abs.Y) / sz.Y, 0, 1)
			updatePicker()
		end

		local function applyHue()
			local abs = hueBar.AbsolutePosition
			local sz = hueBar.AbsoluteSize
			pH = math.clamp((inputPos.Y - abs.Y) / sz.Y, 0, 1)
			updatePicker()
		end

		local function applyVrt()
			local abs = vrtBar.AbsolutePosition
			local sz = vrtBar.AbsoluteSize
			pV = 1 - math.clamp((inputPos.Y - abs.Y) / sz.Y, 0, 1)
			updatePicker()
		end

		svBtn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				svDragging = true; inputPos = Vector2.new(inp.Position.X, inp.Position.Y); applySV()
			end
		end)
		hueBtn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				hueDragging = true; inputPos = Vector2.new(inp.Position.X, inp.Position.Y); applyHue()
			end
		end)
		vrtBtn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				vrtDragging = true; inputPos = Vector2.new(inp.Position.X, inp.Position.Y); applyVrt()
			end
		end)

		table.insert(connections, UserInputService.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
				inputPos = Vector2.new(inp.Position.X, inp.Position.Y)
				if svDragging  then applySV()  end
				if hueDragging then applyHue() end
				if vrtDragging then applyVrt() end
			end
		end))

		table.insert(connections, UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				svDragging = false; hueDragging = false; vrtDragging = false
			end
		end))

		local function onRGBFocusLost()
			local r = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
			local g = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
			local b = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
			pH, pS, pV = Color3.toHSV(Color3.fromRGB(r, g, b))
			updatePicker()
		end
		rBox.FocusLost:Connect(onRGBFocusLost)
		gBox.FocusLost:Connect(onRGBFocusLost)
		bBox.FocusLost:Connect(onRGBFocusLost)

		local _pickerDone = false
		local function closePicker(doApply)
			if _pickerDone then return end
			_pickerDone = true
			for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
			connections = {}
			_colorPickerOpen = false
			_colorPickerFrame = nil
			if doApply and ctx.applyCustomTheme then ctx.applyCustomTheme(pH, pS, pV) end
			local sc = cpWin:FindFirstChildOfClass("UIScale")
			if sc then TweenService:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.88}):Play() end
			local winRef = cpWin
			local wasApply = doApply
			task.delay(0.15, function()
				if winRef and winRef.Parent then winRef:Destroy() end
				if ctx.openUI then ctx.openUI() end
				if wasApply and ctx.showNotification then
					task.delay(0.35, function() ctx.showNotification("Custom theme applied!") end)
				end
			end)
		end

		cpClose.MouseButton1Click:Connect(function() closePicker(false) end)
		applyBtn.MouseButton1Click:Connect(function() closePicker(true) end)

		cpClose.MouseEnter:Connect(function()
			TweenService:Create(cpClose, TweenInfo.new(0.11), {BackgroundColor3 = Color3.fromRGB(185, 45, 45)}):Play()
		end)
		cpClose.MouseLeave:Connect(function()
			TweenService:Create(cpClose, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Button}):Play()
		end)
		applyBtn.MouseEnter:Connect(function()
			TweenService:Create(applyBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		applyBtn.MouseLeave:Connect(function()
			TweenService:Create(applyBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Accent}):Play()
		end)

		local cpScale = Instance.new("UIScale", cpWin)
		cpScale.Scale = 0.88
		TweenService:Create(cpScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end

	return {
		createToggle = createToggle,
		createButton = createButton,
		createSlider = createSlider,
		createDropdown = createDropdown,
		createMultiDropdown = createMultiDropdown,
		openColorPicker = openColorPicker,
	}
end
