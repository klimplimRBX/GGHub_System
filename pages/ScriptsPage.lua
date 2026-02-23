return function(ctx)
	local createButton = ctx.createButton
	local createToggle = ctx.createToggle
	local showNotification = ctx.showNotification
	local scriptPage = ctx.scriptPage
	local LocalPlayer = ctx.LocalPlayer
	local RunService = ctx.RunService
	local Workspace = game:GetService("Workspace")

	local AutoFarmDoomCoinEnabled = false
	local AutoPressDoomButtonEnabled = false
	local lastCollectedDoomCoin = nil
	table.insert(getgenv().__GGHub_Cleanup, function()
    AutoFarmDoomCoinEnabled = false
    AutoPressDoomButtonEnabled = false
    lastCollectedDoomCoin = nil
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
			local cx, cz = root.Position.X, root.Position.Z
			flyToPos(Vector3.new(cx, -25, cz), 1000)
			task.wait(0.01)
			flyToPos(Vector3.new(targetPos.X, -25, targetPos.Z), 1000)
			task.wait(0.01)
			flyToPos(Vector3.new(targetPos.X, heightOffset, targetPos.Z), 1000)
			task.wait(0.01)
		end)
		releaseMoveLock()

		if not ok then warn("[collectItem] Movement error: " .. tostring(err)) end
	end

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
												flyToPos(Vector3.new(pos.X, -25, pos.Z), 2000)
												task.wait(0.01)
												flyToPos(Vector3.new(pos.X, pos.Y + 3, pos.Z), 2000)
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

	local AutoDoomTowerRunning = false
	table.insert(getgenv().__GGHub_Cleanup, function()
		AutoDoomTowerRunning = false
		workspace.Gravity = 196.2
	end)

	createButton(scriptPage, "Auto Doom Tower", "Completes the Doom Tower Automatically for you", function()
		if AutoDoomTowerRunning then
			AutoDoomTowerRunning = false
			showNotification("Auto Doom Tower stopped.")
			workspace.Gravity = 196.2
			return
		end
		AutoDoomTowerRunning = true
		workspace.Gravity = 5
		task.spawn(function()

			local TOWER_POS = Vector3.new(4325, 6.3, -2.5)
			local TOWER_UNDER_Y = -20
			local BRAINROT_UNDER_Y = -20
			local BRAINROT_FLAT_Y = -0.5

			local flySpeed = 1200
			pcall(function()
				local val = LocalPlayer.PlayerGui:WaitForChild("BottomLeft", 5)
					:WaitForChild("JumpAndSpeed", 5)
					:WaitForChild("Container", 5)
					:WaitForChild("EventCurrency", 5)
					:WaitForChild("Value", 5)
				local speed = tonumber(val.Text)
				if speed then
					flySpeed = (speed * 2) - 50
				end
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
					if not AutoDoomTowerRunning then return false end
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

			local function underMapFlyTo(targetPos, underY, speed)
				local root = getCharacterRoots()
				if not root then return false end
				local ok = true
				ok = ok and towerFlyTo(Vector3.new(root.Position.X, underY, root.Position.Z), speed)
				task.wait(0.01)
				ok = ok and towerFlyTo(Vector3.new(targetPos.X, underY, targetPos.Z), speed)
				task.wait(0.01)
				ok = ok and towerFlyTo(targetPos, speed)
				return ok
			end

			local VirtualUser = game:GetService("VirtualUser")
			local UIS = game:GetService("UserInputService")

			local function switchToPC()
				pcall(function()
					LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
					LocalPlayer.DevComputerCameraMode = Enum.DevComputerCameraMode.Classic
				end)
			end

			local function pressE()
				VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end

			local function holdE(duration)
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0,0))
				local uis = game:GetService("UserInputService")
				local inputObject = InputObject.new(Enum.UserInputType.Keyboard, Enum.UserInputState.Begin, Enum.KeyCode.E)
				pcall(function() uis:InputBegan(inputObject, false) end)
				pcall(function()
					game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(duration or 2.5)
					game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end)
			end

			local function activateNearestInstant()
				local root = getCharacterRoots()
				if not root then return end
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("ProximityPrompt") and obj.Enabled then
						obj.HoldDuration = 0
						obj.MaxActivationDistance = 32
					end
				end
				local nearestPrompt, shortestDist = nil, math.huge
				for _, obj in ipairs(workspace:GetDescendants()) do
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
					switchToPC()
					task.wait(0.1)
					nearestPrompt.RequiresLineOfSight = false
					nearestPrompt.HoldDuration = 0
					nearestPrompt.MaxActivationDistance = 32
					game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
					pcall(fireproximityprompt, nearestPrompt)
					nearestPrompt:InputHoldBegin()
					task.wait(0.3)
					game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
					nearestPrompt:InputHoldEnd()
					pcall(fireproximityprompt, nearestPrompt)
				end
			end

			do
				local root = getCharacterRoots()
				if not root then showNotification("No character found!") AutoDoomTowerRunning = false return end

				if (root.Position - TOWER_POS).Magnitude >= 3 then
					acquireMoveLock()
					pcall(function()
						towerFlyTo(Vector3.new(root.Position.X, TOWER_UNDER_Y, root.Position.Z), flySpeed)
						task.wait(0.01)
						towerFlyTo(Vector3.new(TOWER_POS.X, TOWER_UNDER_Y, TOWER_POS.Z), flySpeed)
						task.wait(0.01)
						towerFlyTo(TOWER_POS, flySpeed)
					end)
					releaseMoveLock()
				end

				root = getCharacterRoots()
				if not root or (root.Position - TOWER_POS).Magnitude >= 3 then
					showNotification("Failed to reach tower position!")
					AutoDoomTowerRunning = false
					return
				end
			end

			local towerPrompt
			pcall(function()
				towerPrompt = workspace.GameObjects.PlaceSpecific.root.Tower.Main.Prompt.ProximityPrompt
			end)
			if not towerPrompt then
				showNotification("Tower prompt not found!")
				AutoDoomTowerRunning = false
				return
			end

			local function holdTowerPrompt()
				local root = getCharacterRoots()
				if not root then return false end
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
					game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(2.5)
					game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
					towerPrompt:InputHoldEnd()
					pcall(fireproximityprompt, towerPrompt)
					activated = true
				end)
				if root then root.Anchored = false end
				return activated
			end

			local activated = holdTowerPrompt()
			if not activated then
				showNotification("Failed to activate tower prompt!")
				AutoDoomTowerRunning = false
				return
			end

			task.wait(4)

			local trialBar
			pcall(function()
				trialBar = LocalPlayer.PlayerGui:WaitForChild("TowerTrialHUD", 15):WaitForChild("TrialBar", 15)
			end)
			if not trialBar then
				showNotification("TowerTrialHUD not found!")
				AutoDoomTowerRunning = false
				return
			end

			local requirementLabel = trialBar:FindFirstChild("Requirement")
			local depositsLabel = trialBar:FindFirstChild("Deposits")
			if not requirementLabel or not depositsLabel then
				showNotification("Trial HUD elements not found!")
				AutoDoomTowerRunning = false
				return
			end

			local keywords = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Cosmic", "Secret"}

			local foundKeyword
			local elapsed = 0
			while not foundKeyword and elapsed < 15 do
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
				showNotification("Could not identify Tower Trial keyword!")
				AutoDoomTowerRunning = false
				return
			end

			while AutoDoomTowerRunning do

				pcall(function()
					local val = LocalPlayer.PlayerGui.BottomLeft.JumpAndSpeed.Container.EventCurrency.Value
					local speed = tonumber(val.Text)
					if speed then flySpeed = (speed * 2) - 50 end
				end)

				local brainrotFolder = workspace:FindFirstChild("ActiveBrainrots")
				if not brainrotFolder then
					showNotification("ActiveBrainrots not found!")
					AutoDoomTowerRunning = false
					return
				end

				local keywordFolder = brainrotFolder:FindFirstChild(foundKeyword)
				if not keywordFolder then
					showNotification(foundKeyword .. " folder not found!")
					AutoDoomTowerRunning = false
					return
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
					local idx = math.random(1, #renderedList)
					local target = renderedList[idx]
					if not target or not target.Parent then
						table.remove(renderedList, idx)
						continue
					end
					local pos = getPosition(target)
					if not pos then continue end

					acquireMoveLock()
					pcall(function()
						local root = getCharacterRoots()
						if not root then return end
						towerFlyTo(Vector3.new(root.Position.X, BRAINROT_UNDER_Y, root.Position.Z), flySpeed)
						task.wait(0.01)
						towerFlyTo(Vector3.new(pos.X, BRAINROT_UNDER_Y, pos.Z), flySpeed)
						task.wait(0.01)
						towerFlyTo(Vector3.new(pos.X, BRAINROT_FLAT_Y, pos.Z), flySpeed)
					end)
					releaseMoveLock()

 
					if not target.Parent then continue end

					task.wait(0.5)

					local beforeParent = target.Parent
					pcall(activateNearestInstant)
					task.wait(0.3)

					if not target.Parent or target.Parent ~= beforeParent then
						collected = true
					end
				end

				if not collected then
					task.wait(0.5)
					continue
				end

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
					showNotification("Complete!")
					workspace.Gravity = 196.2
					AutoDoomTowerRunning = false
					return
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
		end) 
	end)
end
