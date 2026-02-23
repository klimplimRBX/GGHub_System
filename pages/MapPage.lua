return function(ctx)
	local createButton = ctx.createButton
	local showNotification  = ctx.showNotification
	local mapPage = ctx.mapPage
	local LocalPlayer = ctx.LocalPlayer
	local RunService = ctx.RunService

	local function getEventCurrencySpeed()
		local speed = 1000
		pcall(function()
			local val = LocalPlayer.PlayerGui.BottomLeft.JumpAndSpeed.Container.EventCurrency.Value
			local v = tonumber(val.Text)
			if v then speed = v * 1.75 end
		end)
		return speed
	end

	local function flyThroughWaypoints(waypoints, speed)
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")

		speed = speed or getEventCurrencySpeed()

		local noclipConn = RunService.Stepped:Connect(function()
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)

		for i, targetPos in ipairs(waypoints) do
			while (root.Position - targetPos).Magnitude > 1.5 do
				local dt = RunService.Heartbeat:Wait()
				if not root or not root.Parent then break end
				local remaining = targetPos - root.Position
				local step = math.min(speed * dt, remaining.Magnitude)
				root.CFrame = root.CFrame + remaining.Unit * step
				root.AssemblyLinearVelocity = Vector3.zero
			end
			root.CFrame = CFrame.new(targetPos)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero

			if i < #waypoints then
				task.wait(0.01)
			end
		end

		noclipConn:Disconnect()
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
	end

	createButton(mapPage, "Go to celestial area", "Goes to the celestial area", function()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart")

		showNotification("Going to celestial area...")

		task.spawn(function()
			local waypoints = {
				Vector3.new(root.Position.X, -20, 0),
				Vector3.new(4025.0, -20, 0),
				Vector3.new(4025.0, -2.7, 0)
			}

			flyThroughWaypoints(waypoints, getEventCurrencySpeed())
			showNotification("Arrived at celestial area!")
		end)
	end)

	createButton(mapPage, "Go back to base", "Goes back to your base safely", function()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart")

		showNotification("Going back to base...")

		task.spawn(function()
			local waypoints = {
				Vector3.new(root.Position.X, -20, 0),
				Vector3.new(125, -20, 0),
				Vector3.new(125, 3.3, 0)
			}

			flyThroughWaypoints(waypoints, getEventCurrencySpeed())
			showNotification("Arrived at base!")
		end)
	end)
end
