return function(ctx)
	local createButton       = ctx.createButton
	local createToggle       = ctx.createToggle
	local createMultiDropdown = ctx.createMultiDropdown
	local showNotification   = ctx.showNotification
	local scriptPage         = ctx.scriptPage
	local LocalPlayer        = ctx.LocalPlayer
	local RunService         = ctx.RunService

	local RS  = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")

	-- ===================================================
	--          ESTADOS
	-- ===================================================

	local AutoBuySamEnabled     = false
	local AutoBuyPoppyEnabled   = false
	local AutoBuyGearsEnabled   = false
	local AutoBuyEggsEnabled    = false
	local AutoSellStevenEnabled = false
	local AutoSellAlanEnabled   = false
	local AutoEggHuntEnabled    = false

	local samSelected   = {}
	local poppySelected = {}
	local gearSelected  = {}
	local eggSelected   = {}

	table.insert(getgenv().__GGHub_Cleanup, function()
		AutoBuySamEnabled     = false
		AutoBuyPoppyEnabled   = false
		AutoBuyGearsEnabled   = false
		AutoBuyEggsEnabled    = false
		AutoSellStevenEnabled = false
		AutoSellAlanEnabled   = false
		AutoEggHuntEnabled    = false
	end)

	-- ===================================================
	--          HELPERS
	-- ===================================================

	local function getDataService()
		local ok, ds = pcall(require, RS.Modules.DataService)
		return ok and ds or nil
	end

	local function hasSelection(tbl)
		for _, v in pairs(tbl) do
			if v then return true end
		end
		return false
	end

	-- Teleporte instantâneo (sem animação para não causar lag)
	local function teleportTo(pos)
		pcall(function()
			local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local root = char:WaitForChild("HumanoidRootPart", 5)
			if root then
				root.CFrame = CFrame.new(pos)
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end)
	end

	-- Separador visual de seção
	local Colors = ctx.Colors
	local function createSectionHeader(parent, text)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -10, 0, 30)
		f.BackgroundTransparency = 1
		f.Parent = parent

		local line = Instance.new("Frame")
		line.Size = UDim2.new(0.35, 0, 0, 1)
		line.Position = UDim2.new(0, 0, 0.5, 0)
		line.BackgroundColor3 = Colors and Colors.HeaderLine or Color3.fromRGB(60, 60, 60)
		line.BorderSizePixel = 0
		line.Parent = f

		local lbl = Instance.new("TextLabel")
		lbl.Text = text
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Colors and Colors.TextSub or Color3.fromRGB(120, 120, 120)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.Parent = f

		local line2 = Instance.new("Frame")
		line2.Size = UDim2.new(0.35, 0, 0, 1)
		line2.Position = UDim2.new(0.65, 0, 0.5, 0)
		line2.BackgroundColor3 = Colors and Colors.HeaderLine or Color3.fromRGB(60, 60, 60)
		line2.BorderSizePixel = 0
		line2.Parent = f
	end

	-- ===================================================
	--    LISTAS DE ITENS
	-- ===================================================

	local SAM_SEEDS = {
		"Carrot","Strawberry","Blueberry","Buttercup","Tomato","Corn","Daffodil",
		"Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit",
		"Mango","Grape","Mushroom","Pepper","Cacao","Sunflower","Beanstalk",
		"Ember Lily","Sugar Apple","Burning Bud","Giant Pinecone","Elder Strawberry",
		"Romanesco","Crimson Thorn","Zebrazinkle","Octobloom","Alien Apple",
		"Eggsnapper","Broccoli","Potato",
	}

	local POPPY_SEEDS = {
		"Easter Candy Carrot","Easter Chocolate Berry","Easter Gumball",
		"Easter Liquorice","Chocolate Sprinkler","Easter Sugar Melon",
		"Easter Chocolate Coconut","Easter Gummy Cactus","Easter Egg Melon",
		"Easter Sour Lemon","Easter Eggfruit",
	}

	local GEARS = {
		"Watering Can","Trading Ticket","Trowel","Recall Wrench",
		"Basic Sprinkler","Advanced Sprinkler","Medium Toy","Pet Name Reroller",
		"Pet Lead","Medium Treat","Godly Sprinkler","Magnifying Glass",
		"Master Sprinkler","Cleaning Spray","Favorite Tool","Harvest Tool",
		"Friendship Pot","Grandmaster Sprinkler","Levelup Lollipop","Cleansing Pet Shard",
	}

	local EGGS = {
		"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg",
		"Mythical Egg","Bug Egg","Jungle Egg",
	}

	-- ===================================================
	--    SEÇÃO: BUY SEEDS (SAM)
	-- ===================================================

	createSectionHeader(scriptPage, "── BUY SEEDS ──")

	createMultiDropdown(scriptPage, "Seeds – Sam's Shop (Default)", SAM_SEEDS, function(sel)
		samSelected = sel
	end)

	createToggle(scriptPage, "Auto Buy Seeds (Sam)", "Compra automaticamente quando o estoque resetar (2x por precaução)", function(state)
		AutoBuySamEnabled = state
		if state then
			if not hasSelection(samSelected) then
				showNotification("Selecione pelo menos 1 seed primeiro!")
				AutoBuySamEnabled = false
				return
			end
			showNotification("Auto Buy Seeds (Sam) ativado!")
			task.spawn(function()
				local lastStockSnapshot = {}

				while AutoBuySamEnabled do
					pcall(function()
						if not hasSelection(samSelected) then return end

						local DS = getDataService()
						if not DS then return end
						local data = DS:GetData()
						if not data or not data.SeedStocks or not data.SeedStocks["Daily Deals"] then return end

						local stocks = data.SeedStocks["Daily Deals"].Stocks
						if not stocks then return end

						for seedName, sel in pairs(samSelected) do
							if sel then
								local sd = stocks[seedName]
								local currentStock = sd and sd.Stock or 0
								local prevStock    = lastStockSnapshot[seedName] or 0

								-- Detecta restock: stock voltou a ser > 0
								if currentStock > 0 and (prevStock == 0 or prevStock == nil or currentStock > prevStock) then
									-- Compra 2x por precaução
									for _ = 1, 2 do
										pcall(function()
											RS.GameEvents.BuyDailySeedShopStock:FireServer(seedName)
										end)
										task.wait(0.08)
									end
								end

								lastStockSnapshot[seedName] = currentStock
							end
						end
					end)
					task.wait(12)
				end
			end)
		else
			showNotification("Auto Buy Seeds (Sam) desativado!")
		end
	end)

	-- ===================================================
	--    SEÇÃO: BUY SEEDS (POPPY - EASTER)
	-- ===================================================

	createMultiDropdown(scriptPage, "Seeds – Poppy Easter Shop (Candy Shop)", POPPY_SEEDS, function(sel)
		poppySelected = sel
	end)

	createToggle(scriptPage, "Auto Buy Seeds (Poppy)", "Compra automaticamente seeds da Easter Shop quando o estoque resetar", function(state)
		AutoBuyPoppyEnabled = state
		if state then
			if not hasSelection(poppySelected) then
				showNotification("Selecione pelo menos 1 seed da Poppy primeiro!")
				AutoBuyPoppyEnabled = false
				return
			end
			showNotification("Auto Buy Seeds (Poppy) ativado!")
			task.spawn(function()
				local lastStockSnapshot = {}

				while AutoBuyPoppyEnabled do
					pcall(function()
						if not hasSelection(poppySelected) then return end

						local DS = getDataService()
						if not DS then return end
						local data = DS:GetData()
						if not data or not data.EventShopStock
							or not data.EventShopStock["Easter Seed Shop"] then return end

						local stocks = data.EventShopStock["Easter Seed Shop"].Stocks
						if not stocks then return end

						for seedName, sel in pairs(poppySelected) do
							if sel then
								local sd = stocks[seedName]
								local currentStock = sd and sd.Stock or 0
								local prevStock    = lastStockSnapshot[seedName] or 0

								if currentStock > 0 and (prevStock == 0 or prevStock == nil or currentStock > prevStock) then
									for _ = 1, 2 do
										pcall(function()
											RS.GameEvents.BuyEventShopStock:FireServer(seedName, "Easter Seed Shop")
										end)
										task.wait(0.08)
									end
								end

								lastStockSnapshot[seedName] = currentStock
							end
						end
					end)
					task.wait(12)
				end
			end)
		else
			showNotification("Auto Buy Seeds (Poppy) desativado!")
		end
	end)

	-- ===================================================
	--    SEÇÃO: BUY GEARS (ELOISE)
	-- ===================================================

	createSectionHeader(scriptPage, "── BUY GEARS & EGGS ──")

	createMultiDropdown(scriptPage, "Gears – Eloise (Green Stand)", GEARS, function(sel)
		gearSelected = sel
	end)

	createToggle(scriptPage, "Auto Buy Gears (Eloise)", "Compra automaticamente gears quando o estoque resetar", function(state)
		AutoBuyGearsEnabled = state
		if state then
			if not hasSelection(gearSelected) then
				showNotification("Selecione pelo menos 1 gear primeiro!")
				AutoBuyGearsEnabled = false
				return
			end
			showNotification("Auto Buy Gears (Eloise) ativado!")
			task.spawn(function()
				local lastStockSnapshot = {}

				while AutoBuyGearsEnabled do
					pcall(function()
						if not hasSelection(gearSelected) then return end

						local DS = getDataService()
						if not DS then return end
						local data = DS:GetData()
						if not data or not data.GearStock or not data.GearStock.Stocks then return end

						for gearName, sel in pairs(gearSelected) do
							if sel then
								local sd = data.GearStock.Stocks[gearName]
								local currentStock = sd and sd.Stock or 0
								local prevStock    = lastStockSnapshot[gearName] or 0

								if currentStock > 0 and (prevStock == 0 or prevStock == nil or currentStock > prevStock) then
									for _ = 1, 2 do
										pcall(function()
											RS.GameEvents.BuyGearStock:FireServer(gearName)
										end)
										task.wait(0.08)
									end
								end

								lastStockSnapshot[gearName] = currentStock
							end
						end
					end)
					task.wait(12)
				end
			end)
		else
			showNotification("Auto Buy Gears (Eloise) desativado!")
		end
	end)

	-- ===================================================
	--    SEÇÃO: BUY EGGS (RAPHAEL)
	-- ===================================================

	createMultiDropdown(scriptPage, "Eggs – Raphael (Yellow Stand)", EGGS, function(sel)
		eggSelected = sel
	end)

	createToggle(scriptPage, "Auto Buy Eggs (Raphael)", "Compra automaticamente pet eggs quando o estoque resetar (refresh 30min)", function(state)
		AutoBuyEggsEnabled = state
		if state then
			if not hasSelection(eggSelected) then
				showNotification("Selecione pelo menos 1 egg primeiro!")
				AutoBuyEggsEnabled = false
				return
			end
			showNotification("Auto Buy Eggs (Raphael) ativado!")
			task.spawn(function()
				local lastStockSnapshot = {}

				while AutoBuyEggsEnabled do
					pcall(function()
						if not hasSelection(eggSelected) then return end

						local DS = getDataService()
						if not DS then return end
						local data = DS:GetData()
						if not data or not data.PetEggStock or not data.PetEggStock.Stocks then return end

						-- PetEggStock.Stocks é um array com {EggName=..., Stock=...}
						for _, eggData in ipairs(data.PetEggStock.Stocks) do
							local eName = eggData.EggName
							if eName and eggSelected[eName] then
								local currentStock = eggData.Stock or 0
								local prevStock    = lastStockSnapshot[eName] or 0

								if currentStock > 0 and (prevStock == 0 or prevStock == nil or currentStock > prevStock) then
									for _ = 1, 2 do
										pcall(function()
											RS.GameEvents.BuyPetEgg:FireServer(eName)
										end)
										task.wait(0.08)
									end
								end

								lastStockSnapshot[eName] = currentStock
							end
						end
					end)
					task.wait(20)
				end
			end)
		else
			showNotification("Auto Buy Eggs (Raphael) desativado!")
		end
	end)

	-- ===================================================
	--    SEÇÃO: SELL AUTOMATION
	-- ===================================================

	createSectionHeader(scriptPage, "── SELL AUTOMATION ──")

	createToggle(scriptPage, "Auto Sell Everything (Steven)", "Vende automaticamente tudo a cada 5s no Steven (Default Sell)", function(state)
		AutoSellStevenEnabled = state
		if state then
			showNotification("Auto Sell (Steven) ativado!")
			task.spawn(function()
				while AutoSellStevenEnabled do
					pcall(function()
						RS.GameEvents.Sell_Inventory:FireServer()
					end)
					task.wait(5)
				end
			end)
		else
			showNotification("Auto Sell (Steven) desativado!")
		end
	end)

	createToggle(scriptPage, "Auto Sell Everything (Alan)", "Vende automaticamente tudo a cada 5s no Alan (Easter Sell)", function(state)
		AutoSellAlanEnabled = state
		if state then
			showNotification("Auto Sell (Alan Easter) ativado!")
			task.spawn(function()
				while AutoSellAlanEnabled do
					pcall(function()
						RS.GameEvents.EasterEvent.EasterSellInventoryRE:FireServer()
					end)
					task.wait(5)
				end
			end)
		else
			showNotification("Auto Sell (Alan Easter) desativado!")
		end
	end)

	-- ===================================================
	--    SEÇÃO: AUTO EGG HUNT
	-- ===================================================

	createSectionHeader(scriptPage, "── AUTO EGG HUNT ──")

	createToggle(scriptPage, "Auto Egg Hunt (Boppy)", "Espera o cooldown acabar, vai até o Boppy, inicia a hunt, coleta todos os 10 ovos e repete", function(state)
		AutoEggHuntEnabled = state
		if state then
			showNotification("Auto Egg Hunt ativado!")
			task.spawn(function()
				local BOPPY_POS = Vector3.new(-150, 3.0, -15)

				while AutoEggHuntEnabled do
					-- Aguarda cooldown zerar
					pcall(function()
						local remaining = LocalPlayer:GetAttribute("EasterEggHuntCooldownRemaining") or 0

						if remaining > 0 then
							-- Espera o tempo restante + 1s de margem
							task.wait(remaining + 1)
						end

						if not AutoEggHuntEnabled then return end

						-- Teleporta pro Boppy
						teleportTo(BOPPY_POS)
						task.wait(0.5)

						-- Inicia a hunt
						local msg, eggs = RS.GameEvents.Easter2026.EasterEventStartEggHunt:InvokeServer()

						if not eggs or not next(eggs) then
							-- Cooldown ainda ativo ou hunt não disponível
							showNotification("Egg Hunt não disponível: " .. tostring(msg or "aguardando..."))
							task.wait(10)
							return
						end

						showNotification("Egg Hunt iniciada! Coletando " .. #eggs .. " ovos...")

						-- Coleta cada ovo
						local collected = 0
						for eggID, eggPos in pairs(eggs) do
							if not AutoEggHuntEnabled then break end

							-- Teleporta até o ovo
							teleportTo(Vector3.new(eggPos.X, eggPos.Y, eggPos.Z))
							task.wait(0.3)

							-- Coleta
							local success = RS.GameEvents.Easter2026.CollectEasterEgg:InvokeServer(eggID)
							if success then
								collected += 1
							end
							task.wait(0.2)
						end

						showNotification("Egg Hunt concluída! " .. collected .. " ovos coletados.")

						-- Volta pro Boppy e aguarda próximo ciclo
						teleportTo(BOPPY_POS)
						task.wait(2)
					end)

					-- Aguarda um pouco antes de checar de novo
					task.wait(5)
				end
			end)
		else
			showNotification("Auto Egg Hunt desativado!")
		end
	end)

end
