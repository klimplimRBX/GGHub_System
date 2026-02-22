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

	createButton(scriptPage, "Auto Doom Tower", "Completes the Doom Tower Automatically for you", function()
		task.spawn(function()
			local function doomFlyTo(targetPos)
				local root = getCharacterRoots()
				if not root then return end
				flyToPos(Vector3.new(root.Position.X, -25, root.Position.Z), 2000)
				task.wait(0.01)
				flyToPos(Vector3.new(targetPos.X, -25, targetPos.Z), 2000)
				task.wait(0.01)
				flyToPos(targetPos, 2000)
			end

			local function activateNearestInstant()
				local root = getCharacterRoots()
				if not root then return end
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
				if nearestPrompt and shortestDist <= nearestPrompt.MaxActivationDistance then
					nearestPrompt.HoldDuration = 0
					nearestPrompt:InputHoldBegin()
					task.wait(0.05)
					nearestPrompt:InputHoldEnd()
				end
			end

			local function holdTowerPrompt(prompt)
				prompt:InputHoldBegin()
				task.wait(2)
				prompt:InputHoldEnd()
			end

			acquireMoveLock()
			pcall(doomFlyTo, Vector3.new(4319, 7.0, 0.3))
			releaseMoveLock()

			local towerPrompt
			pcall(function()
				towerPrompt = workspace.GameObjects.PlaceSpecific.root.Tower.Main.Prompt.ProximityPrompt
			end)
			if not towerPrompt then
				showNotification("Tower prompt not found!")
				return
			end

			pcall(holdTowerPrompt, towerPrompt)
			task.wait(5)

			local trialBar
			pcall(function()
				trialBar = LocalPlayer.PlayerGui:WaitForChild("TowerTrialHUD", 10):WaitForChild("TrialBar", 10)
			end)
			if not trialBar then
				showNotification("TowerTrialHUD not found!")
				return
			end

			local requirementLabel = trialBar:FindFirstChild("Requirement")
			local depositsLabel = trialBar:FindFirstChild("Deposits")
			if not requirementLabel or not depositsLabel then
				showNotification("Trial HUD elements not found!")
				return
			end

			local keywords = {"Rare", "Common", "Uncommon", "Secret", "Epic", "Legendary", "Mythical", "Cosmic"}
			local foundKeyword
			for _, kw in ipairs(keywords) do
				if requirementLabel.Text:find(kw) then
					foundKeyword = kw
					break
				end
			end
			if not foundKeyword then
				showNotification("Could not identify Tower Trial keyword!")
				return
			end

			local brainrotFolder = workspace:FindFirstChild("ActiveBrainrots")

			while true do
				if not brainrotFolder then showNotification("ActiveBrainrots not found!") return end

				local keywordFolder = brainrotFolder:FindFirstChild(foundKeyword)
				if not keywordFolder then showNotification(foundKeyword .. " folder not found!") return end

				local renderedList = {}
				for _, child in ipairs(keywordFolder:GetChildren()) do
					if child.Name == "RenderedBrainrot" then
						table.insert(renderedList, child)
					end
				end
				if #renderedList == 0 then showNotification("No RenderedBrainrot found!") return end

				local target = renderedList[math.random(1, #renderedList)]
				local pos = getPosition(target)
				if pos then
					local root = getCharacterRoots()
					if root then root.CFrame = CFrame.new(pos.X, pos.Y, pos.Z) end
					pcall(activateNearestInstant)
					root = getCharacterRoots()
					if root then root.CFrame = CFrame.new(root.Position.X, -25, root.Position.Z) end
				end

				acquireMoveLock()
				pcall(function()
					flyToPos(Vector3.new(4319.4, -25, 0.3), 2000)
					task.wait(0.01)
					flyToPos(Vector3.new(4319.4, 7.0, 0.3), 2000)
				end)
				releaseMoveLock()

				pcall(holdTowerPrompt, towerPrompt)
				task.wait(5)

				local current, max = depositsLabel.Text:match("(%d+)/(%d+)")
				current = tonumber(current) or 0
				max = tonumber(max) or 10

				if current >= max then
					showNotification("Complete! Grabbing Brainrot...")

					acquireMoveLock()
					pcall(doomFlyTo, Vector3.new(4310, 7.0, 0))
					releaseMoveLock()

					task.wait(5)

					local rewardFolders = {"Infinity", "Divine", "Celestial"}
					for _, folderName in ipairs(rewardFolders) do
						local rewardFolder = brainrotFolder:FindFirstChild(folderName)
						if rewardFolder then
							local rewardList = {}
							for _, child in ipairs(rewardFolder:GetChildren()) do
								if child.Name == "RenderedBrainrot" then
									table.insert(rewardList, child)
								end
							end
							if #rewardList > 0 then
								local closestPos, closestDist = nil, math.huge
								local r = getCharacterRoots()
								if r then
									for _, br in ipairs(rewardList) do
										local brPos = getPosition(br)
										if brPos then
											local dist = (r.Position - brPos).Magnitude
											if dist < closestDist then
												closestDist = dist
												closestPos = brPos
											end
										end
									end
								end
								if closestPos then
									local root = getCharacterRoots()
									if root then root.CFrame = CFrame.new(closestPos.X, closestPos.Y, closestPos.Z) end
									pcall(activateNearestInstant)
									acquireMoveLock()
									pcall(function()
										local root2 = getCharacterRoots()
										if root2 then
											flyToPos(Vector3.new(root2.Position.X, -25, 0), 2000)
											task.wait(0.01)
											flyToPos(Vector3.new(125, -25, 0), 2000)
											task.wait(0.01)
											flyToPos(Vector3.new(125, 3.3, 0), 2000)
										end
									end)
									releaseMoveLock()
									break
								end
							end
						end
					end

					showNotification("Everything was completed Successfully!")
					return
				end
			end
		end)
	end)
end
