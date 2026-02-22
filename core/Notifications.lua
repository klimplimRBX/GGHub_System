return function(ctx)
	local TweenService = ctx.TweenService
	local RunService = ctx.RunService
	local Colors = ctx.Colors
	local reg = ctx.reg
	local gui = ctx.gui

	local notificationList = {}
	local NOTIF_W   = 280
	local NOTIF_GAP = 10
	local NOTIF_DUR = 4
	local NOTIF_X   = -(NOTIF_W + 16)

	local function repositionNotifs()
		local offsetY = 20
		for i = #notificationList, 1, -1 do
			local n = notificationList[i]
			if n and n.frame and n.frame.Parent and n.h then
				TweenService:Create(n.frame,
					TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{Position = UDim2.new(1, NOTIF_X, 1, -(offsetY + n.h))}
				):Play()
				offsetY = offsetY + n.h + NOTIF_GAP
			end
		end
	end

	local function showNotification(text)
		local TextService = game:GetService("TextService")
		local textSize = TextService:GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(NOTIF_W - 28, 9999))
		local notifH = 12 + 30 + 8 + textSize.Y + 16
		local entry = {h = notifH}
		table.insert(notificationList, entry)

		local notif = Instance.new("Frame")
		notif.Name = "GGNotif"
		notif.Size = UDim2.new(0, NOTIF_W, 0, notifH)
		notif.AnchorPoint = Vector2.new(0, 1)
		notif.BackgroundColor3 = Colors.ItemBG
		notif.BorderSizePixel  = 0
		notif.ZIndex = 50
		notif.Position = UDim2.new(1, 30, 1, -20)
		notif.Parent = gui
		Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 14)
		reg(notif, "BackgroundColor3", "ItemBG")
		entry.frame = notif

		local ggLabel = Instance.new("TextLabel")
		ggLabel.Text = "GG"
		ggLabel.Font = Enum.Font.GothamBold
		ggLabel.TextSize = 22
		ggLabel.TextColor3 = Colors.TextMain
		ggLabel.BackgroundTransparency = 1
		ggLabel.Size = UDim2.new(1, -56, 0, 30)
		ggLabel.Position = UDim2.new(0, 14, 0, 12)
		ggLabel.TextXAlignment = Enum.TextXAlignment.Left
		ggLabel.ZIndex = 51
		ggLabel.Parent = notif
		reg(ggLabel, "TextColor3", "TextMain")

		local msgLabel = Instance.new("TextLabel")
		msgLabel.Text = text
		msgLabel.Font = Enum.Font.Gotham
		msgLabel.TextSize = 13
		msgLabel.TextColor3 = Colors.TextSub
		msgLabel.BackgroundTransparency = 1
		msgLabel.Size = UDim2.new(1, -28, 0, textSize.Y)
		msgLabel.Position = UDim2.new(0, 14, 0, 50)
		msgLabel.TextWrapped = true
		msgLabel.TextXAlignment = Enum.TextXAlignment.Left
		msgLabel.ZIndex = 51
		msgLabel.Parent = notif
		reg(msgLabel, "TextColor3", "TextSub")

		local closeBtn = Instance.new("TextButton")
		closeBtn.Text = "×"
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 34
		closeBtn.TextColor3 = Colors.TextMain
		closeBtn.BackgroundTransparency = 1
		closeBtn.Size = UDim2.new(0, 50, 0, 50)
		closeBtn.Position = UDim2.new(1, -50, 0, 0)
		closeBtn.ZIndex = 52
		closeBtn.Parent = notif
		reg(closeBtn, "TextColor3", "TextMain")

		local timerLabel = Instance.new("TextLabel")
		timerLabel.Text = string.format("%.1fs", NOTIF_DUR)
		timerLabel.Font = Enum.Font.Gotham
		timerLabel.TextSize = 11
		timerLabel.TextColor3 = Colors.TextSub
		timerLabel.BackgroundTransparency = 1
		timerLabel.Size = UDim2.new(0, 44, 0, 16)
		timerLabel.Position = UDim2.new(1, -48, 1, -18)
		timerLabel.TextXAlignment = Enum.TextXAlignment.Center
		timerLabel.ZIndex = 52
		timerLabel.Parent = notif
		reg(timerLabel, "TextColor3", "TextSub")

		local dismissed = false
		local timerConn

		local function dismiss()
			if dismissed then return end
			dismissed = true
			if timerConn then timerConn:Disconnect() end
			local idx = table.find(notificationList, entry)
			if idx then table.remove(notificationList, idx) end
			TweenService:Create(notif,
				TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.new(1, 30, notif.Position.Y.Scale, notif.Position.Y.Offset)}
			):Play()
			task.delay(0.3, function()
				if notif and notif.Parent then notif:Destroy() end
				repositionNotifs()
			end)
		end

		closeBtn.MouseButton1Click:Connect(dismiss)

		task.spawn(function()
			task.wait()
			local bottomY = -(20 + notifH)
			notif.Position = UDim2.new(1, 30, 1, bottomY)
			local offsetY = 20 + notifH + NOTIF_GAP
			for i = #notificationList - 1, 1, -1 do
				local n = notificationList[i]
				if n and n.frame and n.frame.Parent and n.h then
					TweenService:Create(n.frame,
						TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Position = UDim2.new(1, NOTIF_X, 1, -(offsetY + n.h))}
					):Play()
					offsetY = offsetY + n.h + NOTIF_GAP
				end
			end
			TweenService:Create(notif,
				TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(1, NOTIF_X, 1, bottomY)}
			):Play()
			task.wait(0.3)
			if dismissed then return end
			local elapsed = 0
			timerConn = RunService.Heartbeat:Connect(function(dt)
				if dismissed then timerConn:Disconnect() return end
				elapsed = elapsed + dt
				local remaining = math.max(0, NOTIF_DUR - elapsed)
				timerLabel.Text = string.format("%.1fs", remaining)
				if elapsed >= NOTIF_DUR then
					timerConn:Disconnect()
					dismiss()
				end
			end)
		end)
	end

	return { show = showNotification }
end
