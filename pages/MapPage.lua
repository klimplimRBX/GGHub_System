return function(ctx)
	local createButton = ctx.createButton
	local showNotification  = ctx.showNotification
	local mapPage = ctx.mapPage
	local LocalPlayer = ctx.LocalPlayer
	local RunService = ctx.RunService

	-- ===================================================
	--         🗺️ MAP PAGE CONTENT
	-- ===================================================

	local function flyThroughWaypoints(waypoints, speed)
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart")

		speed = speed or 1000
		local noclip = true

		local noclipConn = RunService.Stepped:Connect(function()
			if noclip and character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)

		for i, targetPos in ipairs(waypoints) do
			while (root.Position - targetPos).Magnitude > 2 do
				local direction = (targetPos - root.Position).Unit
				local dt = RunService.Heartbeat:Wait()
				root.CFrame = root.CFrame + (direction * speed * dt)
				root.Velocity = Vector3.new(0, 0, 0)
			end

			if i < #waypoints then
				task.wait(0.25)
			end
		end

		noclip = false
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

			flyThroughWaypoints(waypoints, 1000)
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

			flyThroughWaypoints(waypoints, 1000)
			showNotification("Arrived at base!")
		end)
	end)
end
