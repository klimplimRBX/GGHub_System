return function(ctx)
	local createButton    = ctx.createButton
	local createToggle    = ctx.createToggle
	local showNotification = ctx.showNotification
	local homePage        = ctx.homePage
	local LocalPlayer     = ctx.LocalPlayer

	local RS = game:GetService("ReplicatedStorage")

	-- ===================================================
	--          ESTADO
	-- ===================================================

	local AutoCollectEnabled = false

	table.insert(getgenv().__GGHub_Cleanup, function()
		AutoCollectEnabled = false
	end)

	-- ===================================================
	--          HELPERS
	-- ===================================================

	local function getMyFarm()
		local farmFolder = workspace:FindFirstChild("Farm")
		if not farmFolder then return nil end
		for _, plot in ipairs(farmFolder:GetChildren()) do
			local imp = plot:FindFirstChild("Important")
			if imp then
				local data = imp:FindFirstChild("Data")
				if data then
					local owner = data:FindFirstChild("Owner")
					if owner and owner.Value == LocalPlayer.Name then
						return plot
					end
				end
			end
		end
		return nil
	end

	local function getDataService()
		local ok, ds = pcall(require, RS.Modules.DataService)
		return ok and ds or nil
	end

	-- ===================================================
	--          SELL ALL (STEVEN)
	-- ===================================================

	createButton(homePage, "Sell All", "Vende tudo no inventário no Steven (Default)", function()
		pcall(function()
			RS.GameEvents.Sell_Inventory:FireServer()
		end)
		showNotification("Sell All ativado!")
	end)

	-- ===================================================
	--          BUY ALL SEEDS (SAM + POPPY)
	-- ===================================================

	createButton(homePage, "Buy All Seeds", "Compra todos os seeds disponíveis no Sam e na Poppy", function()
		task.spawn(function()
			local DS = getDataService()
			if not DS then
				showNotification("Erro: DataService não encontrado!")
				return
			end

			local data = DS:GetData()
			if not data then
				showNotification("Erro: dados não disponíveis!")
				return
			end

			local bought = 0

			-- Sam (Daily Deals)
			pcall(function()
				if data.SeedStocks and data.SeedStocks["Daily Deals"] then
					local stocks = data.SeedStocks["Daily Deals"].Stocks
					if stocks then
						for seedName, stockData in pairs(stocks) do
							if stockData and (stockData.Stock or 0) > 0 then
								pcall(function()
									RS.GameEvents.BuyDailySeedShopStock:FireServer(seedName)
								end)
								bought += 1
								task.wait(0.06)
							end
						end
					end
				end
			end)

			-- Poppy (Easter Seed Shop)
			pcall(function()
				if data.EventShopStock and data.EventShopStock["Easter Seed Shop"] then
					local stocks = data.EventShopStock["Easter Seed Shop"].Stocks
					if stocks then
						for seedName, stockData in pairs(stocks) do
							if stockData and (stockData.Stock or 0) > 0 then
								pcall(function()
									RS.GameEvents.BuyEventShopStock:FireServer(seedName, "Easter Seed Shop")
								end)
								bought += 1
								task.wait(0.06)
							end
						end
					end
				end
			end)

			if bought > 0 then
				showNotification("Comprou " .. bought .. " tipo(s) de seed!")
			else
				showNotification("Nenhum seed em estoque no momento.")
			end
		end)
	end)

	-- ===================================================
	--          AUTO COLLECT
	-- ===================================================

	createToggle(homePage, "Auto Collect", "Coleta automaticamente todas as plantas maduras do seu jardim", function(state)
		AutoCollectEnabled = state
		if state then
			showNotification("Auto Collect ativado!")
			task.spawn(function()
				while AutoCollectEnabled do
					pcall(function()
						local farm = getMyFarm()
						if not farm then return end

						local plantsPhysical = farm.Important and farm.Important:FindFirstChild("Plants_Physical")
						if not plantsPhysical then return end

						local toCollect = {}
						for _, plant in ipairs(plantsPhysical:GetChildren()) do
							local fruits = plant:FindFirstChild("Fruits")
							if fruits then
								for _, fruit in ipairs(fruits:GetChildren()) do
									-- Um fruit pronto tem ProximityPrompt dentro
									if fruit:FindFirstChildWhichIsA("ProximityPrompt", true) then
										table.insert(toCollect, plant)
										break
									end
								end
							end
						end

						if #toCollect > 0 then
							RS.GameEvents.Crops.Collect:FireServer(toCollect)
						end
					end)
					task.wait(3)
				end
			end)
		else
			showNotification("Auto Collect desativado!")
		end
	end)
end
