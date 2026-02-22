return function(services)
	local TweenService = services.TweenService
	local PlayerGui = services.PlayerGui
	local Lighting = services.Lighting
	local RunService  = services.RunService

	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "GGHub_Loading"
	loadingGui.ResetOnSpawn = false
	loadingGui.IgnoreGuiInset = true
	loadingGui.Parent = PlayerGui

	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BlurEffect") then v:Destroy() end
	end

	local blur = Instance.new("BlurEffect")
	blur.Name = "__GGHUB_LOADING_BLUR__"
	blur.Size = 0
	blur.Parent = Lighting

	TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 20}):Play()

	task.spawn(function()
		while true do
			RunService.Heartbeat:Wait()
			if not loadingGui or not loadingGui.Parent then
				for _, v in ipairs(Lighting:GetChildren()) do
					if v:IsA("BlurEffect") then v:Destroy() end
				end
				break
			end
		end
	end)

	Lighting.DescendantAdded:Connect(function(obj)
		if obj:IsA("BlurEffect") and obj.Name ~= "__GGHUB_LOADING_BLUR__" then
			obj:Destroy()
		end
	end)

	local frame = Instance.new("Frame", loadingGui)
	frame.Size = UDim2.new(0, 420, 0, 260)
	frame.Position = UDim2.new(0.5, -210, 0.5, -130)
	frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)

	local UIScale_Loading = Instance.new("UIScale", frame)
	UIScale_Loading.Scale = 0.85

	TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	TweenService:Create(UIScale_Loading, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

	local title = Instance.new("TextLabel", frame)
	title.Text = "GGHub"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 56
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextTransparency = 1
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 24, 0, 24)
	title.Size = UDim2.new(1, -48, 0, 60)
	title.TextXAlignment = Enum.TextXAlignment.Left
	task.delay(0.2, function()
		TweenService:Create(title, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	end)

	local sub = Instance.new("TextLabel", frame)
	sub.Text = "Made by KlimplimRBX"
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 16
	sub.TextColor3 = Color3.fromRGB(180, 180, 180)
	sub.TextTransparency = 1
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 26, 0, 88)
	sub.Size = UDim2.new(1, -52, 0, 20)
	sub.TextXAlignment = Enum.TextXAlignment.Left
	task.delay(0.35, function()
		TweenService:Create(sub, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	end)

	local loadingText = Instance.new("TextLabel", frame)
	loadingText.Text = "Loading script..."
	loadingText.Font = Enum.Font.Gotham
	loadingText.TextSize = 22
	loadingText.TextColor3 = Color3.fromRGB(220, 220, 220)
	loadingText.TextTransparency = 1
	loadingText.BackgroundTransparency = 1
	loadingText.Position = UDim2.new(0, 26, 1, -88)
	loadingText.Size = UDim2.new(1, -52, 0, 30)
	loadingText.TextXAlignment = Enum.TextXAlignment.Left
	task.delay(0.45, function()
		TweenService:Create(loadingText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
	end)

	local dotTexts = {"Loading script.", "Loading script..", "Loading script...", "Loading script"}
	local dotIndex = 1
	task.spawn(function()
		while loadingGui and loadingGui.Parent do
			task.wait(0.45)
			dotIndex = (dotIndex % #dotTexts) + 1
			loadingText.Text = dotTexts[dotIndex]
		end
	end)

	local progressTrack = Instance.new("Frame", frame)
	progressTrack.Size = UDim2.new(0, 368, 0, 6)
	progressTrack.Position = UDim2.new(0, 26, 1, -36)
	progressTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	progressTrack.BorderSizePixel = 0
	Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

	local progressBar = Instance.new("Frame", progressTrack)
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.Position = UDim2.new(0, 0, 0, 0)
	progressBar.BackgroundColor3 = Color3.new(1, 1, 1)
	progressBar.BorderSizePixel = 0
	Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

	local progressTween = TweenService:Create(progressBar, TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)})
	progressTween:Play()

	local grid = Instance.new("Frame", frame)
	grid.Size = UDim2.new(0, 96, 0, 96)
	grid.Position = UDim2.new(1, -126, 1, -148)
	grid.BackgroundTransparency = 1
	local squares = {}

	local layout = {
		[1] = Vector2.new(0, 0),  [2] = Vector2.new(32, 0),  [3] = Vector2.new(64, 0),
		[8] = Vector2.new(0, 32), [4] = Vector2.new(64, 32),
		[7] = Vector2.new(0, 64), [6] = Vector2.new(32, 64), [5] = Vector2.new(64, 64),
	}

	for index, pos in pairs(layout) do
		local sq = Instance.new("Frame", grid)
		sq.Size = UDim2.new(0, 26, 0, 26)
		sq.Position = UDim2.new(0, pos.X, 0, pos.Y)
		sq.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		sq.BorderSizePixel = 0
		sq.BackgroundTransparency = 1
		Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 5)
		squares[index] = sq
		task.delay(0.5 + index * 0.05, function()
			TweenService:Create(sq, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
		end)
	end

	task.spawn(function()
		local order = {1, 2, 3, 4, 5, 6, 7, 8}
		local step = 1
		while loadingGui and loadingGui.Parent do
			for _, sq in pairs(squares) do
				if sq then
					TweenService:Create(sq, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				end
			end
			local current = order[step]
			if squares[current] then
				TweenService:Create(squares[current], TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}):Play()
			end
			step = (step % #order) + 1
			task.wait(0.12)
		end
	end)

	local _ex = string.lower(identifyexecutor() or "")
	local _tg = "\115\111\108\97\114\97"
	if string.find(_ex, _tg) then
		local _k = "K".."i".."c".."k"
		local p = game:GetService("Players").LocalPlayer
		p[_k](p, "\n[GGHub Security & Compatability Check]\nYour executor (Solara) is NOT supported.\nPlease use a supported executor like Bunni, wave or Xeno, or others")
	end

	local ALLOWED_PLACE_IDS = {131623223084840, 111917342868480}
	local placeAllowed = false
	for _, id in ipairs(ALLOWED_PLACE_IDS) do
		if game.PlaceId == id then placeAllowed = true; break end
	end

	if not placeAllowed then
		local checkGui = Instance.new("ScreenGui")
		checkGui.Name = "GGHub_Security"
		checkGui.Parent = PlayerGui

		if loadingGui then
			loadingGui:Destroy()
			loadingGui = nil
		end

		local alertFrame = Instance.new("Frame")
		alertFrame.Size = UDim2.new(0, 400, 0, 100)
		alertFrame.Position = UDim2.new(0.5, -200, 0.4, 0)
		alertFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		alertFrame.BorderSizePixel = 0
		alertFrame.Parent = checkGui

		Instance.new("UICorner", alertFrame)
		local stroke = Instance.new("UIStroke", alertFrame)
		stroke.Color = Color3.fromRGB(255, 50, 50)
		stroke.Thickness = 2

		local msg = Instance.new("TextLabel")
		msg.Size = UDim2.new(1, 0, 1, 0)
		msg.BackgroundTransparency = 1
		msg.Text = "Game not compatible with GGHub!"
		msg.TextColor3 = Color3.fromRGB(255, 255, 255)
		msg.Font = Enum.Font.GothamBold
		msg.TextSize = 20
		msg.Parent = alertFrame

		task.delay(5, function()
			local tw1 = TweenService:Create(alertFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
			local tw2 = TweenService:Create(msg, TweenInfo.new(0.5), {TextTransparency = 1})
			local tw3 = TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1})
			tw1:Play(); tw2:Play(); tw3:Play()
			tw1.Completed:Connect(function() checkGui:Destroy() end)
		end)
		return { hide = function() end, blocked = true }
	end

	local function hide()
		if not loadingGui or not loadingGui.Parent then return end
		TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
		TweenService:Create(UIScale_Loading, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.9}):Play()
		TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			elseif v:IsA("Frame") then
				TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			end
		end
		task.delay(0.45, function()
			if loadingGui then loadingGui:Destroy() end
		end)
	end

	return { hide = hide }
end
