local currentInventories = {}

lib.callback.register("vx_requestsearch:sendRequest", function(source, target)
	lib.callback.await("vx_requestsearch:receiveRequest", target, source, target)
end)

lib.callback.register("vx_requestsearch:acceptRequest", function(source, target)
	table.insert(currentInventories, { from = source, to = target })
	exports.ox_inventory:forceOpenInventory(target, "player", source)
end)

exports.ox_inventory:registerHook("swapItems", function(payload)
	local fromInventory = payload.fromInventory
	local toInventory = payload.toInventory
	local found = false
	for _, inventory in pairs(currentInventories) do
		if (inventory.from == fromInventory and inventory.to == toInventory)
				or (inventory.from == toInventory and inventory.to == fromInventory) then
			found = true
			break
		end
	end

	return not found
end)

AddEventHandler("ox_inventory:closedInventory", function(playerId, inventoryId)
	for index, inventory in pairs(currentInventories) do
		if inventory.to == playerId and inventory.from == inventoryId then
			table.remove(currentInventories, index)
			break
		end
	end
end)
