local SellEvent = game.ReplicatedStorage:WaitForChild("SellEvent")

valueList = {
	["Carrot"] = 8,
	["Wheat"] = 10,
	["Watermelon"] = 12,
}
SellEvent.OnServerEvent:Connect(function(player, crop)
	--print(crop)
	if not crop or not crop:IsA("Tool") then return end
	if crop.Parent ~= player.Character then return end
	
	local cropvalue = crop:findFirstChildOfClass("IntValue")

	if cropvalue then
		if cropvalue.Value >= 1 then
			cropvalue.Value -= 1

			local cropID = crop:findFirstChildOfClass("StringValue")
			crop.Name = cropID.Value .. "(x" .. cropvalue.Value .. ")"
			--print("sold")
			
			local price = valueList[cropID]
			local leaderstats = player:WaitForChild("leaderstats")
			local playermoney = leaderstats:WaitForChild("Money")
			local moneyGUI = player.PlayerGui.ScreenGui:WaitForChild("MoneyNumber")

			playermoney.Value += price
			moneyGUI.Text = playermoney.Value

			if cropvalue.Value == 0 or cropvalue.Value < 0 then
				crop:Destroy()
				--print("Crop destroyed")
			end
		else
			print("Error: crop value is 0 or negative")
		end
	end
end)

	
	
	
	
	--[[-- Checks for validation to prevent hackers
	if not crop or not crop:IsA("Tool") then return end
	if crop.Parent ~= player.Character then return end
	
	local cropvalue = crop:findFirstChildOfClass("IntValue")

	if cropvalue then
		if cropvalue.Value >= 1 then
			cropvalue.Value -= 1

			local cropID = crop:findFirstChildOfClass("StringValue")
			crop.Name = cropID.Value .. "(x" .. cropvalue.Value .. ")"
			--print("sold")
			
			local price = crop:findFirstChild("Price")
			local leaderstats = player:WaitForChild("leaderstats")
			local playermoney = leaderstats:WaitForChild("Money")
			local moneyGUI = player.PlayerGui.ScreenGui:WaitForChild("MoneyNumber")
			
			playermoney.Value += price.Value
			moneyGUI.Text = playermoney.Value
			
			if cropvalue.Value == 0 or cropvalue.Value < 0 then
				crop:Destroy()
				--print("Crop destroyed")
			end
		else
			print("Error: crop value is 0 or negative")
		end
	end
end)]]

