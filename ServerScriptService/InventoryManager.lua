local InventoryManager = {}
local itemData = {
	["Carrot"] = game.ReplicatedStorage.Carrot,
	["Wheat"] = game.ReplicatedStorage.Wheat,
	["Watermelon"] = game.ReplicatedStorage.Watermelon
}

function InventoryManager.giveItem(player, item, amount)
	local itemNeeded = itemData[item]
	local searchTerm = item.Name
	
	for _, backpackItem in pairs(player.Backpack:GetChildren()) do
		
		if string.find(backpackItem.Name, searchTerm) then
			local value = backpackItem:FindFirstChild("Value")
			value += 1
			backpackItem.Name = searchTerm .. "(x" .. value .. ")"
			break
			
		elseif not string.find(backpackItem.Name, searchTerm) then
			
			for _, storageItem in pairs(game.ReplicatedStorage:GetChildren()) do
				
				if string.find(storageItem.Name, searchTerm) then
					local newStorageItem = storageItem:Clone()
					newStorageItem.Parent = player.Backpack
					
					local value = backpackItem:FindFirstChild("Value")
					value += 1
					backpackItem.Name = searchTerm .. "(x" .. value .. ")"
				
				end
			end
		end
		
		break
		
	end
end
return InventoryManager
