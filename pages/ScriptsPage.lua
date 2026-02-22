return function(ctx)
	local createButton = ctx.createButton
	local createToggle = ctx.createToggle
	local showNotification = ctx.showNotification
	local scriptPage = ctx.scriptPage
	local LocalPlayer = ctx.LocalPlayer
	local RunService = ctx.RunService

-- ===================================================
--       ⚡ SCRIPTS PAGE CONTENT - DOOM EVENT
-- ===================================================

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

	local function getCharacterRoots()
		local char = LocalPlayer.Character
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart")
	end

	local function flyToPos(targetPos, speed)
		local root = getCharacterRoots()
		if not root then return end
		while (root.Position - targetPos).Magnitude > 2 do
			local direction = (targetPos - root.Position).Unit
			local dt = RunService.Heartbeat:Wait()
			root.CFrame = root.CFrame + (direction * speed * dt)
			root.Velocity = Vector3.new(0, 0, 0)
		end
	end

	local doomCoinBusy = false

	RunService.Heartbeat:Connect(function()
		if not AutoFarmDoomCoinEnabled then return end
		if doomCoinBusy then return end

		local folder = workspace:FindFirstChild("DoomCoins") or workspace:FindFirstChild("Coins")
		if not folder then return end

		for _, coin in ipairs(folder:GetChildren()) do
			if coin and coin.Parent then
				local pos = getPosition(coin)
				if pos and coin ~= lastCollectedDoomCoin then
					doomCoinBusy = true
					acquireMoveLock()
					pcall(function()
						local root = getCharacterRoots()
						if root then
							flyToPos(Vector3.new(pos.X, -25, pos.Z), 2000)
							task.wait(0.01)
							flyToPos(Vector3.new(pos.X, pos.Y, pos.Z), 2000)
							task.wait(0.3)
							lastCollectedDoomCoin = coin
						end
					end)
					releaseMoveLock()
					doomCoinBusy = false
					task.wait(0.5)
					break
				end
			end
		end
	end)

	createToggle(scriptPage, "Auto Farm Doom Coins", "Automatically collects Doom event coins for you", function(state)
		AutoFarmDoomCoinEnabled = state
		if state then
			showNotification("Auto Farm Doom Coins Enabled")
		else
			showNotification("Auto Farm Doom Coins Disabled")
		end
	end)

	local doomButtonsBusy = false

	RunService.Heartbeat:Connect(function()
		if not AutoPressDoomButtonEnabled then return end
		if doomButtonsBusy then return end

		local folder = workspace:FindFirstChild("DoomButtons") or workspace:FindFirstChild("Buttons")
		if not folder then return end

		for _, button in ipairs(folder:GetDescendants()) do
			if button and button.Parent then
				local union = button:IsA("UnionOperation") and button or nil
				if not union then
					union = button:FindFirstChildWhichIsA("UnionOperation", true)
				end
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
	end)

	createToggle(scriptPage, "Auto press Doom buttons", "Auto presses Doom Buttons for you", function(state)
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
