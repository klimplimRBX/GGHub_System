return function(ctx)
	local createButton = ctx.createButton
	local createDropdown = ctx.createDropdown
	local createToggle = ctx.createToggle
	local showNotification = ctx.showNotification
	local homePage = ctx.homePage
	local LocalPlayer = ctx.LocalPlayer
	local shadersl = ctx.shaders

	-- ===================================================
	--         🏠 HOME PAGE CONTENT
	-- ===================================================

	createDropdown(homePage, "Select Shader", {"Default", "Daytime", "Sunset", "Night", "Cloudy", "Shore"}, function(selected)
		if selected == "Default" then shaders.applyDefaultShader()
		elseif selected == "Daytime" then shaders.applyDaytime()
		elseif selected == "Sunset" then shaders.applySunset()
		elseif selected == "Night" then shaders.applyNight()
		elseif selected == "Cloudy" then shaders.applyCloudy()
		elseif selected == "Shore" then shaders.applyShore()
		end
		showNotification("Shader: " .. selected)
	end)

	createButton(homePage, "Activate Shield", "Makes you survive tsunamis and death waves 1 or 2 times", function()
		local player = LocalPlayer
		local SAFE_HP = 1e6

		local function makeImmortal(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.BreakJointsOnDeath = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			humanoid.MaxHealth = SAFE_HP
			humanoid.Health = SAFE_HP
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 1 then
					humanoid.Health = SAFE_HP
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)
			humanoid.Died:Connect(function()
				humanoid.Health = SAFE_HP
				humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end)
		end

		if player.Character then makeImmortal(player.Character) end
		player.CharacterAdded:Connect(makeImmortal)
		showNotification("Shield Activated!")
	end)

	createButton(homePage, "Instant Actions", "Makes so you don't need to hold to use things, useful for getting brainrots", function()
		local function makeInstant(prompt)
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
			end
		end
		for _, prompt in ipairs(game:GetDescendants()) do
			makeInstant(prompt)
		end
		game.DescendantAdded:Connect(makeInstant)
		showNotification("Instant Prompts Enabled!")
	end)

	createButton(homePage, "Delete VIP Walls", "Who needs to pay to survive some tsunamis when you have this?", function()
		for _, part in ipairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and (part.Name == "VIP" or part.Name == "VIP_PLUS") then
				part:Destroy()
			end
		end
		showNotification("VIP Walls Destroyed!")
	end)

	local removingBases = false

	createToggle(homePage, "Remove All Bases", "Resets you, saves your base and removes the other ones for a huge FPS boost", function(state)
		removingBases = state
		if state then
			showNotification("Resetting character...")

			task.spawn(function()
				local player = LocalPlayer
				if player.Character then
					local hum = player.Character:FindFirstChild("Humanoid")
					if hum then
						hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
						hum.Health = 0
					end
				end

				player.CharacterAdded:Wait()
				task.wait(0.5)

				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local folder = workspace:FindFirstChild("Bases")
				local savedBase = nil

				if hrp and folder then
					local closestDist = math.huge
					for _, base in ipairs(folder:GetChildren()) do
						if base:IsA("Model") or base:IsA("BasePart") then
							local pos = base:IsA("Model") and base:GetPivot().Position or base.Position
							local dist = (hrp.Position - pos).Magnitude
							if dist < closestDist then
								closestDist = dist
								savedBase = base
							end
						end
					end
				end

				if savedBase then
					showNotification("Saved: " .. savedBase.Name)
				else
					showNotification("No base found to save!")
					removingBases = false
					return
				end

				local function clearOtherBases()
					if not folder or not folder.Parent then return end
					for _, base in ipairs(folder:GetChildren()) do
						if base ~= savedBase and base.Parent then
							base:Destroy()
						end
					end
				end

				clearOtherBases()

				while removingBases do
					clearOtherBases()
					task.wait(2)
				end
			end)
		else
			showNotification("Base Removal Stopped")
		end
	end)
end
