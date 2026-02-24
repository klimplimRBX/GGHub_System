return function(ctx)
	local createButton = ctx.createButton
	local createToggle = ctx.createToggle
	local showNotification = ctx.showNotification
	local scriptPage = ctx.scriptPage
	local LocalPlayer = ctx.LocalPlayer
	local RunService = ctx.RunService
	local gui = ctx.gui
	local Colors = ctx.Colors
	local Workspace = game:GetService("Workspace")
	local VirtualInputManager = game:GetService("VirtualInputManager")
	local UIS = game:GetService("UserInputService")

	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

	local function getEventCurrencySpeed()
		local speed = 1000
		pcall(function()
			local val = LocalPlayer.PlayerGui.BottomLeft.JumpAndSpeed.Container.EventCurrency.Value
			local v = tonumber(val.Text)
			if v then speed = v * 1.75 end
		end)
		return speed
	end

	local AutoFarmDoomCoinEnabled = false
	local AutoPressDoomButtonEnabled = false
	local AutoCollectInfinityEnabled = false
	local AutoCollectDivineEnabled = false
	local AutoCollectCelestialEnabled = false
	local AutoDoomTowerEnabled = false
	local AutoDoomTowerRunning = false
	local lastCollectedDoomCoin = nil
	local towerPausedForCollector = false

	table.insert(getgenv().__GGHub_Cleanup, function()
		AutoFarmDoomCoinEnabled = false
		AutoPressDoomButtonEnabled = false
		AutoCollectInfinityEnabled = false
		AutoCollectDivineEnabled = false
		AutoCollectCelestialEnabled = false
		AutoDoomTowerEnabled = false
		AutoDoomTowerRunning = false
		lastCollectedDoomCoin = nil
		towerPausedForCollector = false
		workspace.Gravity = 196.2
	end)

	local moveLocked = false
	local function acquireMoveLock()
		while moveLocked do task.wait(0.02) end
		moveLocked = true
	end
	local function releaseMoveLock()
		moveLocked = false
	end

	LocalPlayer.CharacterAdded:Connect(function()
		moveLocked = false
		lastCollectedDoomCoin = nil
	end)

	local function getPosition(obj)
		if obj:IsA("BasePart") then
			return obj.Position
		elseif obj:IsA("Model") then
			if obj.PrimaryPart then return obj.PrimaryPart.Position end
			local part = obj:FindFirstChildWhichIsA("BasePart", true)
			if part then return part.Position end
		end
		return nil
	end

	local function isCharacterAlive(root, humanoid)
		if not root or not root.Parent then return false end
		if not humanoid or not humanoid.Parent then return false end
		if humanoid.Health <= 0 then return false end
		return true
	end

	local function getCharacterRoots()
		local character = LocalPlayer.Character
		if not character then return nil, nil end
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		return root, humanoid
	end

	local function waitForCharacterSafe()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 10)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not root or not humanoid then return nil, nil end
		local elapsed = 0
		while humanoid.Health <= 0 do
			local dt = RunService.Heartbeat:Wait()
			elapsed = elapsed + dt
			if elapsed > 10 then return nil, nil end
			if LocalPlayer.Character ~= character then return nil, nil end
		end
		task.wait(0.2)
		return root, humanoid
	end

	local function flyToPos(targetPos, speed)
		speed = speed or 4000
		local root, humanoid = getCharacterRoots()
		if not isCharacterAlive(root, humanoid) then return false end

		while (root.Position - targetPos).Magnitude > 1.5 do
			if not AutoPressDoomButtonEnabled and not AutoFarmDoomCoinEnabled then return false end
			local dt = RunService.Heartbeat:Wait()
			if not isCharacterAlive(root, humanoid) then return false end
			local remaining = (targetPos - root.Position)
			local step = math.min(speed * dt, remaining.Magnitude)
			root.CFrame = root.CFrame + remaining.Unit * step
			root.AssemblyLinearVelocity = Vector3.zero
		end

		if isCharacterAlive(root, humanoid) then
			root.CFrame = CFrame.new(targetPos)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		return true
	end

	local function collectItem(targetPos, heightOffset)
		local root = waitForCharacterSafe()
		if not root then return end

		acquireMoveLock()
		local ok, err = pcall(function()
			local spd = getEventCurrencySpeed()
			local cx, cz = root.Position.X, root.Position.Z
			flyToPos(Vector3.new(cx, -25, cz), spd)
			task.wait(0.01)
			flyToPos(Vector3.new(targetPos.X, -25, targetPos.Z), spd)
			task.wait(0.01)
			flyToPos(Vector3.new(targetPos.X, heightOffset, targetPos.Z), spd)
			task.wait(0.01)
		end)
		releaseMoveLock()

		if not ok then warn("[collectItem] Movement error: " .. tostring(err)) end
	end

	local function switchToPC()
		pcall(function()
			LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
			LocalPlayer.DevComputerCameraMode = Enum.DevComputerCameraMode.Classic
		end)
	end

	local function switchToMobile()
		pcall(function()
			LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.DynamicThumbstick
		end)
	end

	local function unequipTool()
		pcall(function()
			local character = LocalPlayer.Character
			if not character then return end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid:UnequipTools() end
		end)
	end

	local function unequipTool()
		pcall(function()
			local character = LocalPlayer.Character
			if not character then return end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid:UnequipTools() end
		end)
	end

	local function activateNearestInstant()
		local root = getCharacterRoots()
		if not root then return end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ProximityPrompt") and obj.Enabled then
				obj.HoldDuration = 0
				obj.MaxActivationDistance = 32
			end
		end
		local nearestPrompt, shortestDist = nil, math.huge
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ProximityPrompt") and obj.Enabled then
				local parent = obj.Parent
				if parent and parent:IsA("BasePart") then
					local dist = (root.Position - parent.Position).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						nearestPrompt = obj
					end
				end
			end
		end
		if nearestPrompt then
			pcall(function()
				switchToPC()
				task.wait(0.1)
				nearestPrompt.RequiresLineOfSight = false
				nearestPrompt.HoldDuration = 0
				nearestPrompt.MaxActivationDistance = 32
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
				pcall(fireproximityprompt, nearestPrompt)
				nearestPrompt:InputHoldBegin()
				task.wait(0.3)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				nearestPrompt:InputHoldEnd()
				pcall(fireproximityprompt, nearestPrompt)
			end)
		end
	end

	local HttpService = game:GetService("HttpService")
	local TOWER_SYS_PATH = "GGHub/TowerSys.json"
	local towerYesPos = nil

	pcall(function()
		if isfile(TOWER_SYS_PATH) then
			local data = HttpService:JSONDecode(readfile(TOWER_SYS_PATH))
			if data and data.yesX and data.yesY then
				towerYesPos = {x = data.yesX, y = data.yesY}
			end
		end
	end)

	local function saveTowerYesPos(x, y)
		pcall(function()
			if not isfolder("GGHub") then makefolder("GGHub") end
			writefile(TOWER_SYS_PATH, HttpService:JSONEncode({yesX = x, yesY = y}))
		end)
	end

	local towerYesLearning = false
	local towerYesConn = nil

	local function startLearningYesClick()
		towerYesLearning = true
		if towerYesConn then towerYesConn:Disconnect() end
		towerYesConn = UIS.InputBegan:Connect(function(input)
			if not towerYesLearning then
				towerYesConn:Disconnect()
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local pos = input.Position
				towerYesPos = {x = pos.X, y = pos.Y}
				saveTowerYesPos(pos.X, pos.Y)
				towerYesLearning = false
				towerYesConn:Disconnect()
				showNotification("Yes button position saved!")
			end
		end)
	end

	local towerStopScreenGui = nil
	local towerStopBtn = nil

	local function showStopButton(onStop)
		if towerStopScreenGui then towerStopScreenGui:Destroy() end
		local TweenService = game:GetService("TweenService")
		local sg = Instance.new("ScreenGui")
		sg.Name = "TowerStopGui"
		sg.ResetOnSpawn = false
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		pcall(function() sg.Parent = game:GetService("CoreGui") end)
		if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end
		local btn = Instance.new("TextButton")
		btn.Text = "STOP"
		btn.Size = UDim2.new(0, 90, 0, 36)
		btn.Position = UDim2.new(1, -105, 0, 10)
		btn.BackgroundColor3 = Color3.fromRGB(185, 45, 45)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.ZIndex = 10
		btn.Parent = sg
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = Color3.fromRGB(220, 70, 70)
		stroke.Thickness = 1.5
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(215, 60, 60)}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(185, 45, 45)}):Play()
		end)
		btn.MouseButton1Click:Connect(function()
			onStop()
		end)
		towerStopScreenGui = sg
		towerStopBtn = btn
	end

	local function hideStopButton()
		if towerStopScreenGui then
			towerStopScreenGui:Destroy()
			towerStopScreenGui = nil
			towerStopBtn = nil
		end
	end

	local function clickYesButton()
		if towerYesPos then
			local cx, cy = towerYesPos.x, towerYesPos.y
			if mousemoveabs then
				mousemoveabs(cx, cy)
				task.wait(0.08)
				mouse1click()
			end
			VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
			task.wait(0.05)
			VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
			return true
		end
		return false
	end

	local COLLECTOR_UNDER_Y = -20
	local COLLECTOR_FLAT_Y = -0.5
	local BASE_POS = Vector3.new(125, 3.3, 0)

	local function genericFlyTo(targetPos, speed)
		speed = speed or 1200
		local root = getCharacterRoots()
		if not root then return false end

		while (root.Position - targetPos).Magnitude > 1.5 do
			local dt = RunService.Heartbeat:Wait()
			root = getCharacterRoots()
			if not root then return false end
			local remaining = (targetPos - root.Position)
			local step = math.min(speed * dt, remaining.Magnitude)
			root.CFrame = root.CFrame + remaining.Unit * step
			root.AssemblyLinearVelocity = Vector3.zero
		end
		root = getCharacterRoots()
		if root then
			root.CFrame = CFrame.new(targetPos)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		return true
	end

	local function goToBase(speed)
		local root = getCharacterRoots()
		if not root then return end
		pcall(function()
			genericFlyTo(Vector3.new(root.Position.X, COLLECTOR_UNDER_Y, root.Position.Z), speed)
			task.wait(0.01)
			genericFlyTo(Vector3.new(BASE_POS.X, COLLECTOR_UNDER_Y, BASE_POS.Z), speed)
			task.wait(0.01)
			genericFlyTo(BASE_POS, speed)
		end)
	end

	local function getTargets(brainrotTier, luckyNames)
		local targets = {}

		local activeBrainrots = Workspace:FindFirstChild("ActiveBrainrots")
		if activeBrainrots then
			local tierFolder = activeBrainrots:FindFirstChild(brainrotTier)
			if tierFolder then
				for _, child in ipairs(tierFolder:GetChildren()) do
					if child.Name == "RenderedBrainrot" and child.Parent then
						local pos = getPosition(child)
						if pos then
							table.insert(targets, {obj = child, pos = pos})
						end
					end
				end
			end
		end

		local activeLuckyBlocks = Workspace:FindFirstChild("ActiveLuckyBlocks")
		if activeLuckyBlocks then
			for _, name in ipairs(luckyNames) do
				local folder = activeLuckyBlocks:FindFirstChild(name)
				if folder then
					for _, child in ipairs(folder:GetChildren()) do
						if child.Parent then
							local pos = getPosition(child)
							if pos then
								table.insert(targets, {obj = child, pos = pos})
							end
						end
					end
				end
			end
		end

		return targets
	end

	local INFINITY_LUCKY = {
		"NaturalSpawnLuckyBlock_Infinity",
		"EventSpawnLuckyBlock_Infinity",
		"AdminSpawnLuckyBlock_Infinity",
	}
	local DIVINE_LUCKY = {
		"NaturalSpawnLuckyBlock_Divine",
		"EventSpawnLuckyBlock_Divine",
		"AdminSpawnLuckyBlock_Divine",
	}
	local CELESTIAL_LUCKY = {
		"NaturalSpawnLuckyBlock_Celestial",
		"EventSpawnLuckyBlock_Celestial",
		"AdminSpawnLuckyBlock_Celestial",
	}

	local function getInfinityTargets() return getTargets("Infinity", INFINITY_LUCKY) end
	local function getDivineTargets() return getTargets("Divine", DIVINE_LUCKY) end
	local function getCelestialTargets() return getTargets("Celestial", CELESTIAL_LUCKY) end

	local function collectAndReturn(target, pos, speed)
		local root = getCharacterRoots()
		if not root then return false end

		local collected = false

		local noclipConn = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)

		workspace.Gravity = 5

		pcall(function()
			genericFlyTo(Vector3.new(root.Position.X, COLLECTOR_UNDER_Y, root.Position.Z), speed)
			task.wait(0.01)
			genericFlyTo(Vector3.new(pos.X, COLLECTOR_UNDER_Y, pos.Z), speed)
			task.wait(0.01)
			genericFlyTo(Vector3.new(pos.X, COLLECTOR_FLAT_Y, pos.Z), speed)
		end)

		local beforeParent = target.Parent
		local attempts = 0
		while attempts < 10 do
			attempts = attempts + 1
			pcall(activateNearestInstant)
			task.wait(0.15)
			if not target.Parent or target.Parent ~= beforeParent then
				collected = true
				break
			end
		end
		if not collected then
			pcall(function()
				local root = getCharacterRoots()
				if root then
					root.CFrame = CFrame.new(root.Position.X, -60, root.Position.Z)
					root.AssemblyLinearVelocity = Vector3.zero
				end
				task.wait(0.3)
				LocalPlayer:LoadCharacter()
			end)
			task.wait(3)
		end

		goToBase(speed)

		noclipConn:Disconnect()
		for _, part in ipairs((LocalPlayer.Character or {}):GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
				end
		end
		workspace.Gravity = 196.2

		task.wait(1)
		unequipTool()
		return collected
	end

	task.spawn(function()
		while true do
			task.wait(1)
			if AutoCollectInfinityEnabled then
				local targets = getInfinityTargets()
				if #targets > 0 then
					towerPausedForCollector = true
					acquireMoveLock()
					workspace.Gravity = 5
					local speed = getEventCurrencySpeed()
					local t = targets[math.random(1, #targets)]
					if t.obj.Parent then
						collectAndReturn(t.obj, t.pos, speed)
					end
					workspace.Gravity = 196.2
					releaseMoveLock()
					towerPausedForCollector = false
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			if AutoCollectDivineEnabled and not (AutoCollectInfinityEnabled and #getInfinityTargets() > 0) then
				local targets = getDivineTargets()
				if #targets > 0 then
					towerPausedForCollector = true
					acquireMoveLock()
					workspace.Gravity = 5
					local speed = getEventCurrencySpeed()
					local t = targets[math.random(1, #targets)]
					if t.obj.Parent then
						collectAndReturn(t.obj, t.pos, speed)
					end
					workspace.Gravity = 196.2
					releaseMoveLock()
					towerPausedForCollector = false
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			if AutoCollectCelestialEnabled
				and not (AutoCollectInfinityEnabled and #getInfinityTargets() > 0)
				and not (AutoCollectDivineEnabled and #getDivineTargets() > 0)
			then
				local targets = getCelestialTargets()
				if #targets > 0 then
					towerPausedForCollector = true
					acquireMoveLock()
					workspace.Gravity = 5
					local speed = getEventCurrencySpeed()
					local t = targets[math.random(1, #targets)]
					if t.obj.Parent then
						collectAndReturn(t.obj, t.pos, speed)
					end
					workspace.Gravity = 196.2
					releaseMoveLock()
					towerPausedForCollector = false
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			if AutoFarmDoomCoinEnabled then
				local root = getCharacterRoots()
				if root then
					local doomEventParts = Workspace:FindFirstChild("DoomEventParts")
					if doomEventParts then
						local coins = {}
						for _, coin in ipairs(doomEventParts:GetChildren()) do
							if coin.Name == "DoomCoin" and coin.Parent then
								local pos = getPosition(coin)
								if pos then
									table.insert(coins, {
										obj = coin,
										pos = pos,
										dist = (root.Position - pos).Magnitude
									})
								end
							end
						end

						if #coins > 0 then
							table.sort(coins, function(a, b) return a.dist < b.dist end)
							local target = nil
							if lastCollectedDoomCoin and coins[1] and coins[1].obj == lastCollectedDoomCoin and coins[2] then
								target = coins[2]
							elseif coins[1] then
								target = coins[1]
							end
							if target and target.obj.Parent then
								collectItem(target.pos, 3.3)
								lastCollectedDoomCoin = target.obj
							end
						else
							lastCollectedDoomCoin = nil
							task.wait(1)
						end
					end
				end
			end
			task.wait(0.02)
		end
	end)

	createToggle(scriptPage, "Auto Farm Doom Coins", "Auto Farms Doom Coins for ya", function(state)
		AutoFarmDoomCoinEnabled = state
		lastCollectedDoomCoin = nil
		if state then
			showNotification("Auto Farm Doom Coins Enabled")
		else
			showNotification("Auto Farm Doom Coins Disabled")
		end
	end)

	local doomButtonsBusy = false

	task.spawn(function()
		RunService.Heartbeat:Connect(function()
			if AutoPressDoomButtonEnabled and not doomButtonsBusy then
				local root = getCharacterRoots()
				if root then
					local pos = root.Position
					if pos.Y ~= -25 then
						root.CFrame = CFrame.new(pos.X, -25, pos.Z)
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end)
	end)

	task.spawn(function()
		while true do
			task.wait(0.3)
			if AutoPressDoomButtonEnabled then
				local doomButtons = Workspace:FindFirstChild("DoomEventButtons")
				if doomButtons then
					for _, button in ipairs(doomButtons:GetChildren()) do
						if button.Name == "Button" and button.Parent then
							local union = button:FindFirstChild("Union")
							if union then
								local prompt = union:FindFirstChild("ProximityPrompt")
								if prompt then
									local pos = getPosition(button)
									if pos then
										doomButtonsBusy = true
										acquireMoveLock()
										pcall(function()
											local root = getCharacterRoots()
											if root then
												local spd = getEventCurrencySpeed()
												flyToPos(Vector3.new(pos.X, -25, pos.Z), spd)
												task.wait(0.01)
												flyToPos(Vector3.new(pos.X, pos.Y + 3, pos.Z), spd)
												task.wait(0.5)
											end
											for _ = 1, 3 do
												local ok = pcall(fireproximityprompt, prompt)
												if ok then break end
												task.wait(0.3)
											end
										end)
										releaseMoveLock()
										doomButtonsBusy = false
										task.wait(1)
									end
								end
							end
						end
					end
				end
			end
		end
	end)

	createToggle(scriptPage, "Auto press Doom buttons", "Auto presses Doom event buttons for you", function(state)
		AutoPressDoomButtonEnabled = state
		if state then
			showNotification("Auto press Doom buttons Enabled")
		else
			showNotification("Auto press Doom buttons Disabled")
		end
	end)

	createToggle(scriptPage, "Auto Collect Infinity", "ye that will probably never happen but ok", function(state)
		AutoCollectInfinityEnabled = state
		if state then
			showNotification("Auto Collect Infinity Enabled")
		else
			showNotification("Auto Collect Infinity Disabled")
		end
	end)

	createToggle(scriptPage, "Auto Collect Divine", "Auto goes to any divine Brainrot/Lucky Block and collects it", function(state)
		AutoCollectDivineEnabled = state
		if state then
			showNotification("Auto Collect Divine Enabled")
		else
			showNotification("Auto Collect Divine Disabled")
		end
	end)

	createToggle(scriptPage, "Auto Collect Celestial", "Auto goes to any celestial and grabs it and returns to your base", function(state)
		AutoCollectCelestialEnabled = state
		if state then
			showNotification("Auto Collect Celestial Enabled")
		else
			showNotification("Auto Collect Celestial Disabled")
		end
	end)

	createButton(scriptPage, "Auto Complete Tower", "Completes the Tower Automatically for you", function()
		if AutoDoomTowerEnabled or AutoDoomTowerRunning then
			AutoDoomTowerEnabled = false
			AutoDoomTowerRunning = false
			workspace.Gravity = 196.2
			hideStopButton()
			showNotification("Auto Tower stopped.")
			return
		end

		AutoDoomTowerEnabled = true
		showNotification("Starting...")
		showStopButton(function()
			AutoDoomTowerEnabled = false
			AutoDoomTowerRunning = false
			workspace.Gravity = 196.2
			hideStopButton()
			showNotification("Auto Tower stopped.")
		end)

		task.spawn(function()
			while AutoDoomTowerEnabled do
				AutoDoomTowerRunning = true
				workspace.Gravity = 5

				local TOWER_POS = Vector3.new(4325, 6.3, -2.5)
				local TOWER_UNDER_Y = -20
				local BRAINROT_UNDER_Y = -20
				local BRAINROT_FLAT_Y = -0.5
				local flySpeed = 1200

				pcall(function()
					local val = LocalPlayer.PlayerGui.BottomLeft.JumpAndSpeed.Container.EventCurrency.Value
					local speed = tonumber(val.Text)
					if speed then flySpeed = (speed * 2.5) - 50 end
				end)

				local noclipConn
				noclipConn = RunService.Stepped:Connect(function()
					if not AutoDoomTowerRunning then
						noclipConn:Disconnect()
						return
					end
					local char = LocalPlayer.Character
					if char then
						for _, part in ipairs(char:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
							end
						end
					end
				end)
				table.insert(getgenv().__GGHub_Cleanup, function()
					if noclipConn then noclipConn:Disconnect() end
				end)

				local function towerFlyTo(targetPos, speed)
					speed = speed or 1200
					local root, humanoid = getCharacterRoots()
					if not isCharacterAlive(root, humanoid) then
						LocalPlayer.CharacterAdded:Wait()
						task.wait(1.5)
						root, humanoid = getCharacterRoots()
						if not isCharacterAlive(root, humanoid) then return false end
					end
					while (root.Position - targetPos).Magnitude > 1.5 do
						if not AutoDoomTowerRunning or towerPausedForCollector then return false end
						if not isCharacterAlive(root, humanoid) then
							LocalPlayer.CharacterAdded:Wait()
							task.wait(1.5)
							root, humanoid = getCharacterRoots()
							if not isCharacterAlive(root, humanoid) then return false end
						end
						local dt = RunService.Heartbeat:Wait()
						local remaining = (targetPos - root.Position)
						local step = math.min(speed * dt, remaining.Magnitude)
						root.CFrame = root.CFrame + remaining.Unit * step
						root.AssemblyLinearVelocity = Vector3.zero
					end
					if isCharacterAlive(root, humanoid) then
						root.CFrame = CFrame.new(targetPos)
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
					end
					return true
				end

				local cycleComplete = false
				local cycleError = false

				local function stopCycle(msg)
					AutoDoomTowerRunning = false
					workspace.Gravity = 196.2
					if noclipConn then noclipConn:Disconnect() end
					if msg then showNotification(msg) end
				end

				local function handlePauseForCollector()
					if not towerPausedForCollector then return true end
					releaseMoveLock()
					showNotification("Tower paused for priority collection...")
					while towerPausedForCollector and AutoDoomTowerEnabled do
						task.wait(0.5)
					end
					if not AutoDoomTowerEnabled then return false end
					showNotification("Tower resumed!")
					acquireMoveLock()
					local root = getCharacterRoots()
					if root then
						pcall(function()
							towerFlyTo(Vector3.new(root.Position.X, TOWER_UNDER_Y, root.Position.Z), flySpeed)
							task.wait(0.01)
							towerFlyTo(TOWER_POS, flySpeed)
						end)
					end
					releaseMoveLock()
					return true
				end

				do
					local root = getCharacterRoots()
					if not root then
						stopCycle("No character found!")
						cycleError = true
					else
						if (root.Position - TOWER_POS).Magnitude >= 3 then
							acquireMoveLock()
							local reached = false
							pcall(function()
								reached = towerFlyTo(Vector3.new(root.Position.X, TOWER_UNDER_Y, root.Position.Z), flySpeed)
								task.wait(0.01)
								if reached then reached = towerFlyTo(Vector3.new(TOWER_POS.X, TOWER_UNDER_Y, TOWER_POS.Z), flySpeed) end
								task.wait(0.01)
								if reached then reached = towerFlyTo(TOWER_POS, flySpeed) end
							end)
							releaseMoveLock()

							if not reached or not AutoDoomTowerRunning then
								stopCycle()
								cycleError = true
							else
								root = getCharacterRoots()
								if not root or (root.Position - TOWER_POS).Magnitude >= 3 then
									stopCycle("Failed to reach tower position!")
									cycleError = true
								end
							end
						end
					end
				end

				local towerPrompt
				if not cycleError then
					pcall(function()
						towerPrompt = workspace.GameObjects.PlaceSpecific.root.Tower.Main.Prompt.ProximityPrompt
					end)
					if not towerPrompt then
						stopCycle("Tower prompt not found!")
						cycleError = true
					end
				end

				if not cycleError then
					local root = getCharacterRoots()
					if not root then
						stopCycle("No character found!")
						cycleError = true
					else
						unequipTool()
						task.wait(1)
						switchToPC()
						root.CFrame = CFrame.new(TOWER_POS)
						root.AssemblyLinearVelocity = Vector3.zero
						task.wait(0.2)
						root = getCharacterRoots()
						if root then root.Anchored = true end
						local activated = false
						pcall(function()
							switchToPC()
							task.wait(0.1)
							towerPrompt.RequiresLineOfSight = false
							towerPrompt.MaxActivationDistance = 32
							pcall(fireproximityprompt, towerPrompt)
							task.wait(0.1)
							towerPrompt:InputHoldBegin()
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
							task.wait(2.5)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
							towerPrompt:InputHoldEnd()
							pcall(fireproximityprompt, towerPrompt)
							activated = true
						end)
						root = getCharacterRoots()
						if root then root.Anchored = false end
						if not activated then
							stopCycle("Failed to activate tower prompt!")
							cycleError = true
						end
					end
				end

				local trialBar, requirementLabel, depositsLabel, foundKeyword

				if not cycleError then
					task.wait(4)
					pcall(function()
						trialBar = LocalPlayer.PlayerGui:WaitForChild("TowerTrialHUD", 15):WaitForChild("TrialBar", 15)
					end)
					if not trialBar then
						stopCycle("Something went wrong")
						cycleError = true
					else
						requirementLabel = trialBar:FindFirstChild("Requirement")
						depositsLabel = trialBar:FindFirstChild("Deposits")
						if not requirementLabel or not depositsLabel then
							stopCycle("Something was not found")
							cycleError = true
						end
					end
				end

				if not cycleError then
					local keywords = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Cosmic", "Secret"}
					local elapsed = 0
					while not foundKeyword and elapsed < 3 do
						for _, kw in ipairs(keywords) do
							if requirementLabel.Text:find(kw) then
								foundKeyword = kw
								break
							end
						end
						if not foundKeyword then
							task.wait(0.5)
							elapsed = elapsed + 0.5
						end
					end
					if not foundKeyword then
						stopCycle("Could not identify Tower requirement")
						cycleError = true
					end
				end

				if not cycleError then
					local keywords = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Cosmic", "Secret"}

					while AutoDoomTowerRunning and AutoDoomTowerEnabled do
						pcall(function()
							local val = LocalPlayer.PlayerGui.BottomLeft.JumpAndSpeed.Container.EventCurrency.Value
							local speed = tonumber(val.Text)
							if speed then flySpeed = (speed * 2.5) - 50 end
						end)

						local pauseOk = handlePauseForCollector()
						if not pauseOk then break end

						local brainrotFolder = workspace:FindFirstChild("ActiveBrainrots")
						if not brainrotFolder then
							stopCycle("ActiveBrainrots not found!")
							break
						end

						local keywordFolder = brainrotFolder:FindFirstChild(foundKeyword)
						if not keywordFolder then
							showNotification(foundKeyword .. " folder not found!")
							stopCycle()
							break
						end

						local renderedList = {}
						for _, child in ipairs(keywordFolder:GetChildren()) do
							if child.Name == "RenderedBrainrot" then
								table.insert(renderedList, child)
							end
						end
						if #renderedList == 0 then
							showNotification("No RenderedBrainrot found for " .. foundKeyword .. "!")
							task.wait(1)
							continue
						end

						local collected = false
						local attempts = 0

						while not collected and AutoDoomTowerRunning and attempts < #renderedList do
							attempts = attempts + 1
							if towerPausedForCollector then break end

							local idx = math.random(1, #renderedList)
							local target = renderedList[idx]
							if not target or not target.Parent then
								table.remove(renderedList, idx)
								continue
							end
							local pos = getPosition(target)
							if not pos then continue end

							acquireMoveLock()
							local flyOk = false
							pcall(function()
								local root = getCharacterRoots()
								if not root then return end
								flyOk = towerFlyTo(Vector3.new(root.Position.X, BRAINROT_UNDER_Y, root.Position.Z), flySpeed)
								task.wait(0.01)
								if flyOk then flyOk = towerFlyTo(Vector3.new(pos.X, BRAINROT_UNDER_Y, pos.Z), flySpeed) end
								task.wait(0.01)
								if flyOk then flyOk = towerFlyTo(Vector3.new(pos.X, BRAINROT_FLAT_Y, pos.Z), flySpeed) end
							end)
							releaseMoveLock()

							if not flyOk or towerPausedForCollector then break end
							if not target.Parent then continue end

							task.wait(0.05)

							local beforeParent = target.Parent
							pcall(activateNearestInstant)
							task.wait(0.05)

							if not target.Parent or target.Parent ~= beforeParent then
								collected = true
							else
								pcall(activateNearestInstant)
								task.wait(0.05)
								if not target.Parent or target.Parent ~= beforeParent then
									collected = true
								end
							end
						end

						if not collected or towerPausedForCollector then
							task.wait(0.5)
							continue
						end

						acquireMoveLock()
						pcall(function()
							local root = getCharacterRoots()
							if not root then return end
							towerFlyTo(Vector3.new(root.Position.X, BRAINROT_UNDER_Y, root.Position.Z), flySpeed)
							task.wait(0.01)
							towerFlyTo(Vector3.new(4325, BRAINROT_UNDER_Y, -2.5), flySpeed)
							task.wait(0.01)
							towerFlyTo(TOWER_POS, flySpeed)
						end)
						releaseMoveLock()

						task.wait(0.5)
						local root = getCharacterRoots()
						if root then
							root.CFrame = CFrame.new(TOWER_POS)
							root.AssemblyLinearVelocity = Vector3.zero
							root.AssemblyAngularVelocity = Vector3.zero
						end
						task.wait(0.3)
						pcall(activateNearestInstant)

						task.wait(4)

						local current, max = depositsLabel.Text:match("(%d+)/(%d+)")
						current = tonumber(current) or 0
						max = tonumber(max) or 10

						if current >= max then
							cycleComplete = true
							AutoDoomTowerRunning = false
							workspace.Gravity = 196.2
							if noclipConn then noclipConn:Disconnect() end

							task.wait(3)

							local root2 = getCharacterRoots()
							if root2 then
								root2.CFrame = CFrame.new(TOWER_POS)
								root2.AssemblyLinearVelocity = Vector3.zero
							end

							pcall(function()
								towerPrompt.RequiresLineOfSight = false
								towerPrompt.MaxActivationDistance = 32
								pcall(fireproximityprompt, towerPrompt)
								task.wait(0.3)
								towerPrompt:InputHoldBegin()
								task.wait(0.5)
								towerPrompt:InputHoldEnd()
								pcall(fireproximityprompt, towerPrompt)
							end)

							task.wait(0.5)

							if not towerYesPos then
								showNotification("Tower done! Click the YES button now to save its position.")
								startLearningYesClick()
								local elapsed = 0
								while towerYesLearning and elapsed < 30 do
									task.wait(0.1)
									elapsed = elapsed + 0.1
								end
								towerYesLearning = false
							else
								for i = 1, 10 do
									if clickYesButton() then break end
									task.wait(0.3)
								end
							end

							if isMobile then
								switchToMobile()
							end

							hideStopButton()
							showNotification("Tower complete! Cooldown: 5:15")
							break
						end

						local newKeyword
						for _, kw in ipairs(keywords) do
							if requirementLabel.Text:find(kw) then
								newKeyword = kw
								break
							end
						end
						if newKeyword and newKeyword ~= foundKeyword then
							foundKeyword = newKeyword
						end

						task.wait(0.1)
					end
				end

				if not cycleComplete then
					hideStopButton()
					AutoDoomTowerEnabled = false
					break
				end

				task.wait(315)

				if AutoDoomTowerEnabled then
					showNotification("Restarting Auto Tower...")
				end
			end
		end)
	end)

	local note = Instance.new("TextLabel")
	note.Text = "Note: Use the auto collect functions to auto collect your rewards, If this is your first time using it, wait until It finishes since It needs your help to define a function, also in mobile It changes to keyboard, so change that on the Roblox settings when you din't want to farm anymore. Also make sure the tower is avaiable when you activate the auto doom tower for the first time, then it auto does it."
	note.Size = UDim2.new(1, -20, 0, 40)
	note.BackgroundTransparency = 1
	note.TextColor3 = Color3.fromRGB(250, 250, 250)
	note.Font = Enum.Font.Gotham
	note.TextSize = 10
	note.TextWrapped = true
	note.TextXAlignment = Enum.TextXAlignment.Left
	note.TextYAlignment = Enum.TextYAlignment.Top
	note.Parent = scriptPage
end
