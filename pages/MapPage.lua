return function(ctx)
	local TweenService    = game:GetService("TweenService")
	local HttpService     = game:GetService("HttpService")
	local createButton    = ctx.createButton
	local showNotification = ctx.showNotification
	local mapPage         = ctx.mapPage
	local LocalPlayer     = ctx.LocalPlayer
	local RunService      = ctx.RunService
	local Colors          = ctx.Colors
	local reg             = ctx.reg
	local gui             = ctx.gui
	local openUI          = ctx.openUI
	local closeUI         = ctx.closeUI

	-- ===================================================
	--          HELPERS DE MOVIMENTO
	-- ===================================================

	local function getSpeed()
		local speed = 150
		pcall(function()
			local char = LocalPlayer.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.WalkSpeed then
					speed = math.max(hum.WalkSpeed * 2, 150)
				end
			end
		end)
		return speed
	end

	local function flyThroughWaypoints(wps)
		local speed = getSpeed()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if not root then return end

		-- Noclip temporário
		local noclipConn = RunService.Stepped:Connect(function()
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)

		for _, targetPos in ipairs(wps) do
			while root.Parent and (root.Position - targetPos).Magnitude > 1.5 do
				local dt = RunService.Heartbeat:Wait()
				if not root.Parent then break end
				local remaining = targetPos - root.Position
				local step = math.min(speed * dt, remaining.Magnitude)
				root.CFrame = root.CFrame + remaining.Unit * step
				root.AssemblyLinearVelocity = Vector3.zero
			end
			if root.Parent then
				root.CFrame = CFrame.new(targetPos)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end

		noclipConn:Disconnect()
		-- Restaura colisão
		pcall(function()
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.CanCollide = true
				end
			end
		end)
	end

	local function teleportToNPC(name, pos)
		task.spawn(function()
			showNotification("Indo até " .. name .. "...")
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local root = char:WaitForChild("HumanoidRootPart", 5)
			if not root then return end

			flyThroughWaypoints({
				Vector3.new(root.Position.X, -25, root.Position.Z),
				Vector3.new(pos.X, -25, pos.Z),
				pos,
			})

			showNotification("Chegou em " .. name .. "!")
		end)
	end

	-- ===================================================
	--          NPC TELEPORT BUTTONS
	-- ===================================================

	-- Separador
	local sepFrame = Instance.new("Frame")
	sepFrame.Size = UDim2.new(1, -10, 0, 30)
	sepFrame.BackgroundTransparency = 1
	sepFrame.Parent = mapPage

	local sepLine = Instance.new("Frame")
	sepLine.Size = UDim2.new(0.25, 0, 0, 1)
	sepLine.Position = UDim2.new(0, 0, 0.5, 0)
	sepLine.BackgroundColor3 = Colors.HeaderLine
	sepLine.BorderSizePixel = 0
	sepLine.Parent = sepFrame

	local sepLbl = Instance.new("TextLabel")
	sepLbl.Text = "── NPC TELEPORT ──"
	sepLbl.Size = UDim2.new(1, 0, 1, 0)
	sepLbl.BackgroundTransparency = 1
	sepLbl.TextColor3 = Colors.TextSub
	sepLbl.Font = Enum.Font.GothamBold
	sepLbl.TextSize = 11
	sepLbl.TextXAlignment = Enum.TextXAlignment.Center
	sepLbl.Parent = sepFrame

	local sepLine2 = Instance.new("Frame")
	sepLine2.Size = UDim2.new(0.25, 0, 0, 1)
	sepLine2.Position = UDim2.new(0.75, 0, 0.5, 0)
	sepLine2.BackgroundColor3 = Colors.HeaderLine
	sepLine2.BorderSizePixel = 0
	sepLine2.Parent = sepFrame

	local NPCS = {
		{ name = "Sam",     desc = "Seed Shop (Default)",      pos = Vector3.new(36.6, 3.0, -27.0) },
		{ name = "Steven",  desc = "Sell Stuff (Default)",     pos = Vector3.new(36.6, 3.0, 0.4)   },
		{ name = "Poppy",   desc = "Easter Shop (Candy Seeds)",pos = Vector3.new(-138.7, 3.5, -15.0)},
		{ name = "Alan",    desc = "Sell Stuff (Easter)",      pos = Vector3.new(-70.0, 3.5, -15.7) },
		{ name = "Boppy",   desc = "Egg Hunt (Easter)",        pos = Vector3.new(-150, 3.0, -15)    },
		{ name = "Eloise",  desc = "Gears (Green Stand)",      pos = Vector3.new(-235.4, 3.0, -5.0) },
		{ name = "Raphael", desc = "Pet Eggs (Yellow Stand)",  pos = Vector3.new(-235.4, 3.0, 9.0)  },
	}

	for _, npc in ipairs(NPCS) do
		local _npc = npc
		createButton(mapPage, "Ir para " .. _npc.name, _npc.desc, function()
			teleportToNPC(_npc.name, _npc.pos)
		end)
	end

	-- ===================================================
	--          CUSTOM WAYPOINTS
	-- ===================================================

	local WAYPOINTS_PATH = "GGHub/Waypoints.json"
	local savedWaypoints = {}

	pcall(function()
		if isfile(WAYPOINTS_PATH) then
			local data = HttpService:JSONDecode(readfile(WAYPOINTS_PATH))
			if type(data) == "table" then
				savedWaypoints = data
			end
		end
	end)

	local function saveWaypoints()
		pcall(function()
			if not isfolder("GGHub") then makefolder("GGHub") end
			writefile(WAYPOINTS_PATH, HttpService:JSONEncode(savedWaypoints))
		end)
	end

	local waypointFrames = {}
	local createWaypointBtnWrapper = nil
	local _deleteDialogOpen = false
	local _createDialogOpen = false

	local openDeleteDialog
	local renderWaypoints

	openDeleteDialog = function(wpRef)
		if _deleteDialogOpen then return end
		_deleteDialogOpen = true
		closeUI()

		local dialog = Instance.new("Frame")
		dialog.Name = "WaypointDeleteDialog"
		dialog.Size = UDim2.new(0, 280, 0, 148)
		dialog.Position = UDim2.new(0.5, -140, 0.5, -74)
		dialog.BackgroundColor3 = Colors.Background
		dialog.BorderSizePixel = 0
		dialog.ZIndex = 100
		dialog.Parent = gui
		Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 12)
		local dStroke = Instance.new("UIStroke", dialog)
		dStroke.Color = Colors.Stroke
		dStroke.Thickness = 1

		local title = Instance.new("TextLabel")
		title.Text = "Deletar Waypoint"
		title.Size = UDim2.new(1, -20, 0, 24)
		title.Position = UDim2.new(0, 15, 0, 13)
		title.BackgroundTransparency = 1
		title.TextColor3 = Colors.TextMain
		title.Font = Enum.Font.GothamBold
		title.TextSize = 15
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 101
		title.Parent = dialog

		local sep = Instance.new("Frame")
		sep.Size = UDim2.new(1, -20, 0, 1)
		sep.Position = UDim2.new(0, 10, 0, 44)
		sep.BackgroundColor3 = Colors.HeaderLine
		sep.BorderSizePixel = 0
		sep.ZIndex = 101
		sep.Parent = dialog

		local question = Instance.new("TextLabel")
		question.Text = 'Deletar "' .. wpRef.name .. '"?'
		question.Size = UDim2.new(1, -20, 0, 42)
		question.Position = UDim2.new(0, 10, 0, 52)
		question.BackgroundTransparency = 1
		question.TextColor3 = Colors.TextSub
		question.Font = Enum.Font.Gotham
		question.TextSize = 13
		question.TextWrapped = true
		question.TextXAlignment = Enum.TextXAlignment.Center
		question.TextYAlignment = Enum.TextYAlignment.Center
		question.ZIndex = 101
		question.Parent = dialog

		local function closeDialog(doDelete)
			_deleteDialogOpen = false
			local sc = dialog:FindFirstChildOfClass("UIScale")
			if sc then
				TweenService:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.88}):Play()
			end
			task.delay(0.15, function()
				dialog:Destroy()
				openUI()
				if doDelete then
					for i, w in ipairs(savedWaypoints) do
						if w == wpRef then table.remove(savedWaypoints, i) break end
					end
					saveWaypoints()
					renderWaypoints()
					showNotification("Waypoint deletado!")
				end
			end)
		end

		local cancelBtn = Instance.new("TextButton")
		cancelBtn.Text = "Cancelar"
		cancelBtn.Size = UDim2.new(0, 115, 0, 36)
		cancelBtn.Position = UDim2.new(0, 15, 1, -51)
		cancelBtn.BackgroundColor3 = Colors.Button
		cancelBtn.TextColor3 = Colors.TextMain
		cancelBtn.Font = Enum.Font.GothamBold
		cancelBtn.TextSize = 13
		cancelBtn.AutoButtonColor = false
		cancelBtn.ZIndex = 101
		cancelBtn.Parent = dialog
		Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

		local confirmBtn = Instance.new("TextButton")
		confirmBtn.Text = "Deletar"
		confirmBtn.Size = UDim2.new(0, 115, 0, 36)
		confirmBtn.Position = UDim2.new(1, -130, 1, -51)
		confirmBtn.BackgroundColor3 = Color3.fromRGB(185, 45, 45)
		confirmBtn.TextColor3 = Color3.new(1, 1, 1)
		confirmBtn.Font = Enum.Font.GothamBold
		confirmBtn.TextSize = 13
		confirmBtn.AutoButtonColor = false
		confirmBtn.ZIndex = 101
		confirmBtn.Parent = dialog
		Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

		cancelBtn.MouseEnter:Connect(function()
			TweenService:Create(cancelBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		cancelBtn.MouseLeave:Connect(function()
			TweenService:Create(cancelBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Button}):Play()
		end)
		confirmBtn.MouseEnter:Connect(function()
			TweenService:Create(confirmBtn, TweenInfo.new(0.11), {BackgroundColor3 = Color3.fromRGB(210, 55, 55)}):Play()
		end)
		confirmBtn.MouseLeave:Connect(function()
			TweenService:Create(confirmBtn, TweenInfo.new(0.11), {BackgroundColor3 = Color3.fromRGB(185, 45, 45)}):Play()
		end)

		cancelBtn.MouseButton1Click:Connect(function() closeDialog(false) end)
		confirmBtn.MouseButton1Click:Connect(function() closeDialog(true) end)

		local sc = Instance.new("UIScale", dialog)
		sc.Scale = 0.88
		TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end

	renderWaypoints = function()
		for _, f in ipairs(waypointFrames) do
			pcall(function() f:Destroy() end)
		end
		waypointFrames = {}

		for i, wp in ipairs(savedWaypoints) do
			local row = Instance.new("Frame")
			row.Name = "WaypointRow"
			row.Size = UDim2.new(1, -10, 0, 60)
			row.BackgroundColor3 = Colors.ItemBG
			row.LayoutOrder = 100 + i
			row.Parent = mapPage
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
			if reg then reg(row, "BackgroundColor3", "ItemBG") end

			row.MouseEnter:Connect(function()
				TweenService:Create(row, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
			end)
			row.MouseLeave:Connect(function()
				TweenService:Create(row, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG}):Play()
			end)

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Text = wp.name
			nameLabel.Size = UDim2.new(1, -170, 0, 25)
			nameLabel.Position = UDim2.new(0, 15, 0, 9)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = Colors.TextMain
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 15
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Parent = row
			if reg then reg(nameLabel, "TextColor3", "TextMain") end

			local coordLabel = Instance.new("TextLabel")
			coordLabel.Text = string.format("%.1f, %.1f, %.1f", wp.x, wp.y, wp.z)
			coordLabel.Size = UDim2.new(1, -170, 0, 17)
			coordLabel.Position = UDim2.new(0, 15, 0, 35)
			coordLabel.BackgroundTransparency = 1
			coordLabel.TextColor3 = Colors.TextSub
			coordLabel.Font = Enum.Font.Gotham
			coordLabel.TextSize = 11
			coordLabel.TextXAlignment = Enum.TextXAlignment.Left
			coordLabel.Parent = row
			if reg then reg(coordLabel, "TextColor3", "TextSub") end

			local deleteBtn = Instance.new("TextButton")
			deleteBtn.Text = "🗑️"
			deleteBtn.Size = UDim2.new(0, 34, 0, 34)
			deleteBtn.Position = UDim2.new(1, -154, 0.5, -17)
			deleteBtn.BackgroundColor3 = Color3.fromRGB(155, 38, 38)
			deleteBtn.TextColor3 = Color3.new(1, 1, 1)
			deleteBtn.TextSize = 16
			deleteBtn.Font = Enum.Font.Gotham
			deleteBtn.AutoButtonColor = false
			deleteBtn.Parent = row
			Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0, 8)

			local teleBtn = Instance.new("TextButton")
			teleBtn.Text = "Teleport"
			teleBtn.Size = UDim2.new(0, 105, 0, 34)
			teleBtn.Position = UDim2.new(1, -113, 0.5, -17)
			teleBtn.BackgroundColor3 = Colors.Accent
			teleBtn.TextColor3 = Color3.new(1, 1, 1)
			teleBtn.TextSize = 13
			teleBtn.Font = Enum.Font.GothamBold
			teleBtn.AutoButtonColor = false
			teleBtn.Parent = row
			Instance.new("UICorner", teleBtn).CornerRadius = UDim.new(0, 8)
			if reg then reg(teleBtn, "BackgroundColor3", "Accent") end

			deleteBtn.MouseEnter:Connect(function()
				TweenService:Create(deleteBtn, TweenInfo.new(0.11), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
			end)
			deleteBtn.MouseLeave:Connect(function()
				TweenService:Create(deleteBtn, TweenInfo.new(0.11), {BackgroundColor3 = Color3.fromRGB(155, 38, 38)}):Play()
			end)
			teleBtn.MouseEnter:Connect(function()
				TweenService:Create(teleBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
			end)
			teleBtn.MouseLeave:Connect(function()
				TweenService:Create(teleBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Accent}):Play()
			end)

			local wpRef = wp
			teleBtn.MouseButton1Click:Connect(function()
				task.spawn(function()
					local pos = Vector3.new(wpRef.x, wpRef.y, wpRef.z)
					local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
					local root = char:WaitForChild("HumanoidRootPart", 5)
					if not root then return end
					showNotification("Indo para " .. wpRef.name .. "...")
					flyThroughWaypoints({
						Vector3.new(root.Position.X, -25, root.Position.Z),
						Vector3.new(pos.X, -25, pos.Z),
						pos,
					})
					showNotification("Chegou em " .. wpRef.name .. "!")
				end)
			end)

			deleteBtn.MouseButton1Click:Connect(function()
				openDeleteDialog(wpRef)
			end)

			table.insert(waypointFrames, row)
		end

		if createWaypointBtnWrapper then
			createWaypointBtnWrapper.LayoutOrder = 999
		end
	end

	local function openCreateDialog()
		if _createDialogOpen then return end
		_createDialogOpen = true
		closeUI()

		local HEIGHT_COMPACT  = 236
		local HEIGHT_EXPANDED = 303
		local WIN_W = 320

		local win = Instance.new("Frame")
		win.Name = "WaypointCreateDialog"
		win.Size = UDim2.new(0, WIN_W, 0, HEIGHT_COMPACT)
		win.Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -HEIGHT_COMPACT / 2)
		win.BackgroundColor3 = Colors.Background
		win.BorderSizePixel = 0
		win.ZIndex = 100
		win.Parent = gui
		Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
		local wStroke = Instance.new("UIStroke", win)
		wStroke.Color = Colors.Stroke
		wStroke.Thickness = 1

		local dragging, dragStart, startPos = false, nil, nil
		win.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = win.Position
			end
		end)
		win.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		win.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Text = "Criar Waypoint"
		titleLabel.Size = UDim2.new(1, -55, 0, 42)
		titleLabel.Position = UDim2.new(0, 15, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextColor3 = Colors.TextMain
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 16
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Center
		titleLabel.ZIndex = 101
		titleLabel.Parent = win

		local closeX = Instance.new("TextButton")
		closeX.Text = "×"
		closeX.Size = UDim2.new(0, 28, 0, 28)
		closeX.Position = UDim2.new(1, -38, 0, 7)
		closeX.BackgroundColor3 = Colors.Button
		closeX.TextColor3 = Colors.TextMain
		closeX.TextSize = 20
		closeX.Font = Enum.Font.Gotham
		closeX.AutoButtonColor = false
		closeX.ZIndex = 102
		closeX.Parent = win
		Instance.new("UICorner", closeX).CornerRadius = UDim.new(0, 7)

		local sep = Instance.new("Frame")
		sep.Size = UDim2.new(1, -20, 0, 1)
		sep.Position = UDim2.new(0, 10, 0, 42)
		sep.BackgroundColor3 = Colors.HeaderLine
		sep.BorderSizePixel = 0
		sep.ZIndex = 101
		sep.Parent = win

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Text = "Nome"
		nameLbl.Size = UDim2.new(1, -30, 0, 16)
		nameLbl.Position = UDim2.new(0, 15, 0, 53)
		nameLbl.BackgroundTransparency = 1
		nameLbl.TextColor3 = Colors.TextSub
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 11
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.ZIndex = 101
		nameLbl.Parent = win

		local nameBox = Instance.new("TextBox")
		nameBox.PlaceholderText = "Nome do waypoint..."
		nameBox.Text = ""
		nameBox.Size = UDim2.new(1, -30, 0, 34)
		nameBox.Position = UDim2.new(0, 15, 0, 71)
		nameBox.BackgroundColor3 = Colors.ItemBG
		nameBox.TextColor3 = Colors.TextMain
		nameBox.PlaceholderColor3 = Colors.TextSub
		nameBox.Font = Enum.Font.Gotham
		nameBox.TextSize = 13
		nameBox.ClearTextOnFocus = false
		nameBox.BorderSizePixel = 0
		nameBox.ZIndex = 102
		nameBox.Parent = win
		Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)
		Instance.new("UIPadding", nameBox).PaddingLeft = UDim.new(0, 10)

		local posLbl = Instance.new("TextLabel")
		posLbl.Text = "Posição"
		posLbl.Size = UDim2.new(1, -30, 0, 16)
		posLbl.Position = UDim2.new(0, 15, 0, 116)
		posLbl.BackgroundTransparency = 1
		posLbl.TextColor3 = Colors.TextSub
		posLbl.Font = Enum.Font.GothamBold
		posLbl.TextSize = 11
		posLbl.TextXAlignment = Enum.TextXAlignment.Left
		posLbl.ZIndex = 101
		posLbl.Parent = win

		local BTN_W = (WIN_W - 30 - 8) / 2

		local optCurrent = Instance.new("TextButton")
		optCurrent.Text = "Posição Atual"
		optCurrent.Size = UDim2.new(0, BTN_W, 0, 34)
		optCurrent.Position = UDim2.new(0, 15, 0, 134)
		optCurrent.BackgroundColor3 = Colors.Accent
		optCurrent.TextColor3 = Color3.new(1,1,1)
		optCurrent.Font = Enum.Font.GothamBold
		optCurrent.TextSize = 12
		optCurrent.AutoButtonColor = false
		optCurrent.ZIndex = 102
		optCurrent.Parent = win
		Instance.new("UICorner", optCurrent).CornerRadius = UDim.new(0, 8)

		local optCustom = Instance.new("TextButton")
		optCustom.Text = "Coordenadas"
		optCustom.Size = UDim2.new(0, BTN_W, 0, 34)
		optCustom.Position = UDim2.new(0, 15 + BTN_W + 8, 0, 134)
		optCustom.BackgroundColor3 = Colors.ItemBG
		optCustom.TextColor3 = Colors.TextMain
		optCustom.Font = Enum.Font.GothamBold
		optCustom.TextSize = 12
		optCustom.AutoButtonColor = false
		optCustom.ZIndex = 102
		optCustom.Parent = win
		Instance.new("UICorner", optCustom).CornerRadius = UDim.new(0, 8)

		local coordsFrame = Instance.new("Frame")
		coordsFrame.Size = UDim2.new(1, -30, 0, 52)
		coordsFrame.Position = UDim2.new(0, 15, 0, 177)
		coordsFrame.BackgroundTransparency = 1
		coordsFrame.Visible = false
		coordsFrame.ZIndex = 101
		coordsFrame.Parent = win

		local function makeCoordBox(label, xOff)
			local w = Instance.new("Frame")
			w.Size = UDim2.new(0, 88, 1, 0)
			w.Position = UDim2.new(0, xOff, 0, 0)
			w.BackgroundTransparency = 1
			w.ZIndex = 101
			w.Parent = coordsFrame

			local lbl = Instance.new("TextLabel")
			lbl.Text = label
			lbl.Size = UDim2.new(1, 0, 0, 16)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Colors.TextSub
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 11
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.ZIndex = 102
			lbl.Parent = w

			local box = Instance.new("TextBox")
			box.PlaceholderText = "0"
			box.Text = "0"
			box.Size = UDim2.new(1, 0, 0, 32)
			box.Position = UDim2.new(0, 0, 0, 18)
			box.BackgroundColor3 = Colors.ItemBG
			box.TextColor3 = Colors.TextMain
			box.PlaceholderColor3 = Colors.TextSub
			box.Font = Enum.Font.GothamBold
			box.TextSize = 13
			box.ClearTextOnFocus = false
			box.TextXAlignment = Enum.TextXAlignment.Center
			box.BorderSizePixel = 0
			box.ZIndex = 102
			box.Parent = w
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
			return box
		end

		local xBox = makeCoordBox("X", 0)
		local yBox = makeCoordBox("Y", 97)
		local zBox = makeCoordBox("Z", 194)

		local createBtn = Instance.new("TextButton")
		createBtn.Text = "Criar Waypoint"
		createBtn.Size = UDim2.new(1, -30, 0, 38)
		createBtn.Position = UDim2.new(0, 15, 0, HEIGHT_COMPACT - 38 - 15)
		createBtn.BackgroundColor3 = Colors.Accent
		createBtn.TextColor3 = Color3.new(1,1,1)
		createBtn.Font = Enum.Font.GothamBold
		createBtn.TextSize = 14
		createBtn.AutoButtonColor = false
		createBtn.ZIndex = 102
		createBtn.Parent = win
		Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0, 8)

		local useCurrentPos = true

		local function selectCurrentPos()
			useCurrentPos = true
			coordsFrame.Visible = false
			TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, WIN_W, 0, HEIGHT_COMPACT)}):Play()
			createBtn.Position = UDim2.new(0, 15, 0, HEIGHT_COMPACT - 38 - 15)
			TweenService:Create(optCurrent, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Accent, TextColor3 = Color3.new(1,1,1)}):Play()
			TweenService:Create(optCustom, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG, TextColor3 = Colors.TextMain}):Play()
		end

		local function selectCustomCoords()
			useCurrentPos = false
			coordsFrame.Visible = true
			TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, WIN_W, 0, HEIGHT_EXPANDED)}):Play()
			createBtn.Position = UDim2.new(0, 15, 0, HEIGHT_EXPANDED - 38 - 15)
			pcall(function()
				local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart", 2)
				xBox.Text = tostring(math.floor(root.Position.X + 0.5))
				yBox.Text = tostring(math.floor(root.Position.Y + 0.5))
				zBox.Text = tostring(math.floor(root.Position.Z + 0.5))
			end)
			TweenService:Create(optCustom, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Accent, TextColor3 = Color3.new(1,1,1)}):Play()
			TweenService:Create(optCurrent, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ItemBG, TextColor3 = Colors.TextMain}):Play()
		end

		local function closeDialog(doCreate, name, x, y, z)
			_createDialogOpen = false
			local sc = win:FindFirstChildOfClass("UIScale")
			if sc then
				TweenService:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.88}):Play()
			end
			task.delay(0.15, function()
				win:Destroy()
				openUI()
				if doCreate then
					table.insert(savedWaypoints, {name = name, x = x, y = y, z = z})
					saveWaypoints()
					renderWaypoints()
					showNotification("Waypoint '" .. name .. "' criado!")
				end
			end)
		end

		optCurrent.MouseButton1Click:Connect(selectCurrentPos)
		optCustom.MouseButton1Click:Connect(selectCustomCoords)
		closeX.MouseButton1Click:Connect(function() closeDialog(false) end)

		closeX.MouseEnter:Connect(function()
			TweenService:Create(closeX, TweenInfo.new(0.11), {BackgroundColor3 = Color3.fromRGB(185, 45, 45)}):Play()
		end)
		closeX.MouseLeave:Connect(function()
			TweenService:Create(closeX, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Button}):Play()
		end)
		createBtn.MouseEnter:Connect(function()
			TweenService:Create(createBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.ButtonHover}):Play()
		end)
		createBtn.MouseLeave:Connect(function()
			TweenService:Create(createBtn, TweenInfo.new(0.11), {BackgroundColor3 = Colors.Accent}):Play()
		end)

		createBtn.MouseButton1Click:Connect(function()
			local name = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
			if name == "" then showNotification("Digite um nome!") return end
			local x, y, z
			if useCurrentPos then
				local ok, root = pcall(function()
					return LocalPlayer.Character:WaitForChild("HumanoidRootPart", 2)
				end)
				if ok and root then
					x, y, z = root.Position.X, root.Position.Y, root.Position.Z
				else
					showNotification("Personagem não encontrado!")
					return
				end
			else
				x = tonumber(xBox.Text) or 0
				y = tonumber(yBox.Text) or 0
				z = tonumber(zBox.Text) or 0
			end
			closeDialog(true, name, x, y, z)
		end)

		local sc = Instance.new("UIScale", win)
		sc.Scale = 0.88
		TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end

	-- Separa NPCs dos waypoints customizados
	local sepFrame2 = Instance.new("Frame")
	sepFrame2.Size = UDim2.new(1, -10, 0, 30)
	sepFrame2.BackgroundTransparency = 1
	sepFrame2.LayoutOrder = 90
	sepFrame2.Parent = mapPage

	local sepLine3 = Instance.new("Frame")
	sepLine3.Size = UDim2.new(0.2, 0, 0, 1)
	sepLine3.Position = UDim2.new(0, 0, 0.5, 0)
	sepLine3.BackgroundColor3 = Colors.HeaderLine
	sepLine3.BorderSizePixel = 0
	sepLine3.Parent = sepFrame2

	local sepLbl2 = Instance.new("TextLabel")
	sepLbl2.Text = "── WAYPOINTS CUSTOMIZADOS ──"
	sepLbl2.Size = UDim2.new(1, 0, 1, 0)
	sepLbl2.BackgroundTransparency = 1
	sepLbl2.TextColor3 = Colors.TextSub
	sepLbl2.Font = Enum.Font.GothamBold
	sepLbl2.TextSize = 11
	sepLbl2.TextXAlignment = Enum.TextXAlignment.Center
	sepLbl2.Parent = sepFrame2

	local sepLine4 = Instance.new("Frame")
	sepLine4.Size = UDim2.new(0.2, 0, 0, 1)
	sepLine4.Position = UDim2.new(0.8, 0, 0.5, 0)
	sepLine4.BackgroundColor3 = Colors.HeaderLine
	sepLine4.BorderSizePixel = 0
	sepLine4.Parent = sepFrame2

	renderWaypoints()

	createButton(mapPage, "Criar Waypoint", "Cria um novo waypoint na sua posição atual ou em coordenadas customizadas", function()
		openCreateDialog()
	end)

	-- Salva referência pra manter no final da lista
	local children = mapPage:GetChildren()
	for i = #children, 1, -1 do
		if children[i]:IsA("Frame") then
			createWaypointBtnWrapper = children[i]
			createWaypointBtnWrapper.LayoutOrder = 999
			break
		end
	end
end
