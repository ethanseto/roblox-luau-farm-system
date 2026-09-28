------------------------------------------------------------------------ VARIABLES ------------------------------------------------------------------------

local farmEvent = game.ReplicatedStorage:WaitForChild("FarmEvent")
local seedFolder = game.Workspace:FindFirstChild("Seeds")
local tilledTiles = {}
local wateredTiles = {}
local seededTiles = {}
local growingTiles = {}
local harvestableTiles = {}
local playerWheatCount = {}
local occupiedTiles = {}
local playerPlotKey = {}
local plotData = {}

local InventoryManager = require(game.ReplicatedStorage.InventoryManager)


farmEvent.OnServerEvent:Connect(function(player, action, target, X, Y, Z)
	print(target, target.Name, target.Parent)
	
	local randomRotation = math.random(-100, 100)
	local randomScale = math.random(90, 110)/100
	local randomDeviationX = math.random(-10, 10)/100
	local randomDeviationZ = math.random(-10, 10)/100
---------------------------------------------------------------------- FAILSAFE CHECK --------------------------------------------------------------------
	
	local playerbusy = player:FindFirstChild("playerbusy")
	if playerbusy.Value == true then
		print("Player is currently busy!")
		return
	end

	if not target then return end
	
---------------------------------------------------------------------- RAYCASTING --------------------------------------------------------------------

	-- 1. Create a Raycast Parameter setting
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = {workspace.Terrain} -- Only care about hitting Terrain

	-- 2. Fire a ray from 5 studs above the position straight down 10 studs
	local rayOrigin = Vector3.new(X, Y + 5, Z)
	local rayDirection = Vector3.new(0, -6, 0)

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	-- 3. Grab the material if it hit something
	local currentMaterial = nil
	if raycastResult then
		currentMaterial = raycastResult.Material
	end
	
---------------------------------------------------------------------- PLOTKEYS --------------------------------------------------------------------

	local gridSize = 3
	
	local plotKeyX = math.round(X / gridSize) * gridSize
	local plotKeyY = math.floor(Y / 10) * 10	
	local plotKeyZ = math.round(Z / gridSize) * gridSize
	local plotKey = plotKeyX .. "_" .. plotKeyY .. "_" .. plotKeyZ
	
	plotData.plot = plotKey
	
	plotData[plotKey] = plotData[plotKey] or {}------------------------------@*$(*@($*UQ(@*U$@$)))
	
---------------------------------------------------------------------- TILLING --------------------------------------------------------------------
	
	if action == "Till" and currentMaterial == Enum.Material.Grass and plotData[plotKey].status == nil then

		print("tilling...")
		player.playerbusy.Value = true

		--task.wait(1)
		local tileSize = Vector3.new(1.5, 0.01, 1.5) 
		local tilePosition = Vector3.new(X, Y, Z)
		workspace.Terrain:FillBlock(CFrame.new(tilePosition), tileSize, Enum.Material.Ground)
		
		tilledTiles[plotKey] = true
		player.playerbusy.Value = false
		
		plotData[plotKey].status = "tilled"
		--plotData[plotKey].owner = player.Name
		
---------------------------------------------------------------------- WATERING --------------------------------------------------------------------

	elseif action == "Water" then
			
		print("watering...")

		player.playerbusy.Value = true

		--task.wait(1)

		local tilePosition = Vector3.new(X, Y, Z)
		local minPoint = tilePosition - Vector3.new(1.5, 3, 1.5)
		local maxPoint = tilePosition + Vector3.new(1.5, 1, 1.5)
		local region3 = Region3.new(minPoint, maxPoint)
		local region3Int = region3:ExpandToGrid(4)
		workspace.Terrain:ReplaceMaterial(region3Int, 4, Enum.Material.Ground, Enum.Material.Mud)
		
		wateredTiles[plotKey] = true
		player.playerbusy.Value = false
		
		plotData[plotKey].status = "watered"
		--plotData[plotKey].owner = player.Name

------------------------------------------------------------------- SEEDING WHEAT --------------------------------------------------------------------

	elseif action == "SeedWheat" then
		
		print(plotData[plotKey].status, currentMaterial, plotKey)
		if currentMaterial == Enum.Material.Mud then
		
			if occupiedTiles[plotKey] == true then
				print("This tile is already occupied!")
				return
			end
			
			occupiedTiles[plotKey] = true

			-- SETS THE PLAYER'S STATUS TO BUSY
			player.playerbusy.Value = true	
			plotData[plotKey].status = "growing"
			plotData[plotKey].owner = player.Name


			local wheat1 = game.ReplicatedStorage.CropModels.Wheat1
			local wheat2 = game.ReplicatedStorage.CropModels.Wheat2
			local wheat3 = game.ReplicatedStorage.CropModels.Wheat3
			
			print(randomDeviationX, randomDeviationZ, randomRotation, randomScale)
			-- CREATING THE WHEAT MODELS
			local newWheat1 = wheat1:Clone()
			local newWheat2 = wheat2:Clone()
			local newWheat3 = wheat3:Clone()
			
			newWheat1:ScaleTo(randomScale)		
			newWheat2:ScaleTo(randomScale)
			newWheat3:ScaleTo(randomScale)

			growingTiles[plotKey] = {}

			print("Planting wheat seed")

			newWheat1:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) * CFrame.Angles(0, math.rad(randomRotation), 0))
			newWheat2:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) * CFrame.Angles(0, math.rad(randomRotation), 0))
			newWheat3:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) *  CFrame.Angles(0, math.rad(randomRotation), 0))

			-- STAGE 1
			newWheat1.Parent = game.Workspace.Crops
			local stage1 = growingTiles[plotKey]
			local plotKey1 = plotKey
			stage1.VisualModel = newWheat1

			-- STAGE 2
			task.wait(1)
			local stage2 = stage1
			local plotKey2 = plotKey1
			stage2.VisualModel:Destroy()
			newWheat2.Parent = game.Workspace.Crops
			stage2.VisualModel = newWheat2
			player.playerbusy.Value = false

			-- STAGE 3
			task.wait(1)
			local stage3 = stage2
			local plotKey3 = plotKey2
			stage3.VisualModel:Destroy()
			newWheat3.Parent = game.Workspace.Crops
			stage3.VisualModel = newWheat3
			harvestableTiles[plotKey] = true
			plotData[plotKey3].status = "grownWheat"
			
		end
		
	elseif action == "SeedCarrot" then --                                        CARROT CROP

		print(plotData[plotKey].status, currentMaterial, plotKey)
		if currentMaterial == Enum.Material.Mud then

			if occupiedTiles[plotKey] == true then
				print("This tile is already occupied!")
				return
			end

			occupiedTiles[plotKey] = true

			-- SETS THE PLAYER'S STATUS TO BUSY
			player.playerbusy.Value = true	
			plotData[plotKey].status = "growing"
			plotData[plotKey].owner = player.Name


			local carrot1 = game.ReplicatedStorage.CropModels.Carrot1
			local carrot2 = game.ReplicatedStorage.CropModels.Carrot2
			local carrot3 = game.ReplicatedStorage.CropModels.Carrot3

			print(randomDeviationX, randomDeviationZ, randomRotation, randomScale)
			-- CREATING THE CARROT MODELS
			local newCarrot1 = carrot1:Clone()
			local newCarrot2 = carrot2:Clone()
			local newCarrot3 = carrot3:Clone()

			newCarrot1:ScaleTo(randomScale)		
			newCarrot2:ScaleTo(randomScale)
			newCarrot3:ScaleTo(randomScale)

			growingTiles[plotKey] = {}

			print("Planting carrot seed")

			newCarrot1:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) * CFrame.Angles(0, math.rad(randomRotation), 0))
			newCarrot2:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) * CFrame.Angles(0, math.rad(randomRotation), 0))
			newCarrot3:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) *  CFrame.Angles(0, math.rad(randomRotation), 0))

			-- STAGE 1
			newCarrot1.Parent = game.Workspace.Crops
			local stage1 = growingTiles[plotKey]
			local plotKey1 = plotKey
			stage1.VisualModel = newCarrot1

			-- STAGE 2
			task.wait(1)
			local stage2 = stage1
			local plotKey2 = plotKey1
			stage2.VisualModel:Destroy()
			newCarrot2.Parent = game.Workspace.Crops
			stage2.VisualModel = newCarrot2
			player.playerbusy.Value = false

			-- STAGE 3
			task.wait(1)
			local stage3 = stage2
			local plotKey3 = plotKey2
			stage3.VisualModel:Destroy()
			newCarrot3.Parent = game.Workspace.Crops
			stage3.VisualModel = newCarrot3
			harvestableTiles[plotKey] = true
			plotData[plotKey3].status = "grownCarrot"
		end

	elseif action == "SeedWatermelon" then --                                 WATERMELON CROP

		print(plotData[plotKey].status, currentMaterial, plotKey)
		if currentMaterial == Enum.Material.Mud then

			if occupiedTiles[plotKey] == true then
				print("This tile is already occupied!")
				return
			end

			occupiedTiles[plotKey] = true

			-- SETS THE PLAYER'S STATUS TO BUSY
			player.playerbusy.Value = true	
			plotData[plotKey].status = "growing"
			plotData[plotKey].owner = player.Name


			local watermelon1 = game.ReplicatedStorage.CropModels.Watermelon1
			local watermelon2 = game.ReplicatedStorage.CropModels.Watermelon2
			local watermelon3 = game.ReplicatedStorage.CropModels.Watermelon3
			
			print(randomDeviationX, randomDeviationZ, randomRotation, randomScale)
			-- CREATING THE WATERMELON MODELS
			local newWatermelon1 = watermelon1:Clone()
			local newWatermelon2 = watermelon2:Clone()
			local newWatermelon3 = watermelon3:Clone()

			newWatermelon1:ScaleTo(randomScale)		
			newWatermelon2:ScaleTo(randomScale)
			newWatermelon3:ScaleTo(randomScale)

			growingTiles[plotKey] = {}

			print("Planting watermelon seed")

			newWatermelon1:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) * CFrame.Angles(0, math.rad(randomRotation), 0))
			newWatermelon2:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) * CFrame.Angles(0, math.rad(randomRotation), 0))
			newWatermelon3:PivotTo(CFrame.new(X + randomDeviationX, Y, Z + randomDeviationZ) *  CFrame.Angles(0, math.rad(randomRotation), 0))

			-- STAGE 1
			newWatermelon1.Parent = game.Workspace.Crops
			local stage1 = growingTiles[plotKey]
			local plotKey1 = plotKey
			stage1.VisualModel = newWatermelon1

			-- STAGE 2
			task.wait(1)
			local stage2 = stage1
			local plotKey2 = plotKey1
			stage2.VisualModel:Destroy()
			newWatermelon2.Parent = game.Workspace.Crops
			stage2.VisualModel = newWatermelon2
			player.playerbusy.Value = false

			-- STAGE 3
			task.wait(1)
			local stage3 = stage2
			local plotKey3 = plotKey2
			stage3.VisualModel:Destroy()
			newWatermelon3.Parent = game.Workspace.Crops
			stage3.VisualModel = newWatermelon3
			harvestableTiles[plotKey] = true
			plotData[plotKey3].status = "grownWatermelon"

		end
---------------------------------------------------------------------- HARVESTING --------------------------------------------------------------------

	elseif action == "Harvest" and plotData[plotKey].status == "grownWheat" then
		
		if plotData[plotKey].owner == player.Name then

			local finalHarvestKey = plotKey
			local wheatModel = target.Parent
			
			wheatModel:Destroy()
			InventoryManager.giveItem(player, "Wheat", 1)
			plotData[plotKey].status = nil

			
			--[[if harvestableTiles[finalHarvestKey] == true or string.match(target.Name, "Wheat") then
				local foundItem = false
				local wheatItem = nil
				
				for _, item in pairs(player.Backpack:GetChildren()) do
					print(item)
					if item:FindFirstChild("Wheat Value") then
						foundItem = true
						wheatItem = item
						break

					else

						foundItem = false
					end
				end

				if foundItem == false then
					local wheat = game.ReplicatedStorage.Wheat:Clone()
					wheat.Parent = player.Backpack

					local wheatnumber = player.Backpack:FindFirstChild("Wheat"):FindFirstChild("Wheat Value")
					wheatnumber.Value = 0
					print("Tool not found")
					
					for _, item in pairs(player.Backpack:GetChildren()) do
						if item:FindFirstChild("Wheat Value") then
							wheatItem = item
							break
						else
							print("tool still not found somehow")
						end
					end
				
				end
				
				--for _, item in pairs(player.Backpack:GetChildren()) do

				if string.match(target.Parent.Name, "Wheat") then
					print("Harvesting wheat!")

					local wheatModel = target.Parent
					local wheatnumber = wheatItem:FindFirstChild("Wheat Value")

					wheatnumber.Value += 1
					wheatItem.Name = "Wheat (x" .. wheatnumber.Value .. ")"

					wheatModel:Destroy()

					harvestableTiles[finalHarvestKey] = false
					occupiedTiles[finalHarvestKey] = false
					
					plotData[plotKey].status = nil
					plotData[plotKey].owner = player.Name
				
				elseif wheatItem:FindFirstChild("Wheat Value") then
					print("Harvesting wheat!")

					growingTiles[finalHarvestKey].VisualModel:Destroy()

					local wheatnumber = wheatItem:FindFirstChild("Wheat Value")

					wheatnumber.Value += 1
					wheatItem.Name = "Wheat (x" .. wheatnumber.Value .. ")"
					harvestableTiles[finalHarvestKey] = false
					occupiedTiles[finalHarvestKey] = false
					
					plotData[plotKey].status = nil
					plotData[plotKey].owner = player.Name

				else
					print("idk")
						
				end
			end]]
		end
-----------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif action == "Harvest" and plotData[plotKey].status == "grownCarrot" then

		if plotData[plotKey].owner == player.Name then

			local finalHarvestKey = plotKey
			
			if harvestableTiles[finalHarvestKey] == true or string.match(target.Parent.Name, "Carrot") then
				local foundItem = false
				local carrotItem = nil
				--local carrotExists = player.Backpack:FindFirstChild("Carrot")
				local carrot = game.ReplicatedStorage:FindFirstChild("Carrot")
				local foundItem = false

				local carrot = game.ReplicatedStorage.Carrot
				local newCarrot = carrot:Clone()
				local carrotValue = carrot:FindFirstChild("Carrot Value")
				local carrotItem = nil

				for _, item in pairs(player.Backpack:GetChildren()) do
					print(item)
					carrotItem = item
					if item:FindFirstChild("Carrot Value") then
						foundItem = true
						carrotValue = item:FindFirstChild("Carrot Value")
					end
				end

				if not foundItem then
					local carrotModel = target.Parent
					carrotModel:Destroy()

					newCarrot.Parent = player.Backpack
					carrotValue = player.Backpack:FindFirstChild("Carrot"):FindFirstChild("Carrot Value")
					carrotValue.Value += 1
					newCarrot.Name = "Carrot (x" .. carrotValue.Value .. ")"

				else
		--[[print(carrotItem)
		print(newCarrot)
		print(carrotValue)]]
					--[[print(carrotValue.Value)
					carrotValue.Value += 1
					print(carrotValue.Value)
					carrotItem.Name = "Carrot (x" .. carrotValue.Value .. ")"
				
				--[[for _, item in pairs(player.Backpack:GetChildren()) do
					print(item)
					if item:FindFirstChild("Carrot Value") then
						foundItem = true
						carrotItem = item
						break

					else

						foundItem = false
					end
				end

				if foundItem == false then
					local carrot = game.ReplicatedStorage.Carrot:Clone()
					carrot.Parent = player.Backpack

					local carrotnumber = player.Backpack:FindFirstChild("Carrot"):FindFirstChild("Carrot Value")
					carrotnumber.Value = 0
					print("Tool not found")

					for _, item in pairs(player.Backpack:GetChildren()) do
						if item:FindFirstChild("Carrot Value") then
							carrotItem = item
							break
						else
							print("tool still not found somehow")
						end
					end
				end]]

				--for _, item in pairs(player.Backpack:GetChildren()) do

					if string.match(target.Parent.Name, "Carrot") then
						print("Harvesting carrot!")

						local carrotModel = target.Parent
						local carrotnumber = carrotItem:FindFirstChild("Carrot Value")

						carrotnumber.Value += 1
						carrotItem.Name = "Carrot (x" .. carrotnumber.Value .. ")"

						carrotModel:Destroy()

						harvestableTiles[finalHarvestKey] = false
						occupiedTiles[finalHarvestKey] = false

						plotData[plotKey].status = nil
						plotData[plotKey].owner = player.Name

					elseif carrotItem:FindFirstChild("Carrot Value") then
						print("Harvesting carrot!")

						growingTiles[finalHarvestKey].VisualModel:Destroy()

						local carrotnumber = carrotItem:FindFirstChild("Carrot Value")

						carrotValue.Value += 1
						--carrotnumber.Value += w1
						carrotItem.Name = "Carrot (x" .. carrotValue.Value .. ")"
						--carrotItem.Name = "Carrot (x" .. carrotnumber.Value .. ")"
						harvestableTiles[finalHarvestKey] = false
						occupiedTiles[finalHarvestKey] = false

						plotData[plotKey].status = nil
						plotData[plotKey].owner = player.Name

					else
						print("idk")
					end
				end
			end
		else
			print("This plot is not yours")
		end
---------------------------------------------------------------------------------------------------------------------------------------------------
	elseif action == "Harvest" and plotData[plotKey].status == "grownWatermelon" then

		if plotData[plotKey].owner == player.Name then

			local finalHarvestKey = plotKey

			if harvestableTiles[finalHarvestKey] == true or string.match(target.Parent.Name, "Watermelon") then
				local foundItem = false
				local watermelonItem = nil

				for _, item in pairs(player.Backpack:GetChildren()) do
					print(item)
					if item:FindFirstChild("Watermelon Value") then
						foundItem = true
						watermelonItem = item
						break

					else

						foundItem = false
					end
				end

				if foundItem == false then
					local watermelon = game.ReplicatedStorage.Watermelon:Clone()
					watermelon.Parent = player.Backpack

					local watermelonnumber = player.Backpack:FindFirstChild("Watermelon"):FindFirstChild("Watermelon Value")
					watermelonnumber.Value = 0
					print("Tool not found")

					for _, item in pairs(player.Backpack:GetChildren()) do
						if item:FindFirstChild("Watermelon Value") then
							watermelonItem = item
							break
						else
							print("tool still not found somehow")
						end
					end
				end

				--for _, item in pairs(player.Backpack:GetChildren()) do

				if string.match(target.Parent.Name, "Watermelon") then
					print("Harvesting watermelon!")

					local watermelonModel = target.Parent
					local watermelonnumber = watermelonItem:FindFirstChild("Watermelon Value")

					watermelonnumber.Value += 1
					watermelonItem.Name = "Watermelon (x" .. watermelonnumber.Value .. ")"

					watermelonModel:Destroy()

					harvestableTiles[finalHarvestKey] = false
					occupiedTiles[finalHarvestKey] = false

					plotData[plotKey].status = nil
					plotData[plotKey].owner = player.Name

				elseif watermelonItem:FindFirstChild("Watermelon Value") then
					print("Harvesting watermelon!")

					growingTiles[finalHarvestKey].VisualModel:Destroy()

					local watermelonnumber = watermelonItem:FindFirstChild("Watermelon Value")

					watermelonnumber.Value += 1
					watermelonItem.Name = "Watermelon (x" .. watermelonnumber.Value .. ")"
					harvestableTiles[finalHarvestKey] = false
					occupiedTiles[finalHarvestKey] = false

					plotData[plotKey].status = nil
					plotData[plotKey].owner = player.Name

				else
					print("idk")
				end
			end
		else
			print("This plot is not yours")
		end
	end
end)
