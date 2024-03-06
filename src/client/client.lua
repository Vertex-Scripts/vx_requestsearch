local initiator = nil
local keybind

local function getPlayerFromPed(ped)
	local players = GetActivePlayers()
	for _, player in ipairs(players) do
		if GetPlayerPed(player) == ped then
			return player
		end
	end
end

local function requestSearch(data)
	local entity = data.entity
	local target = getPlayerFromPed(entity)
	local targetId = GetPlayerServerId(target)

	lib.callback.await("vx_requestsearch:sendRequest", false, targetId)
end

local function acceptSearchRequest()
	lib.callback.await("vx_requestsearch:acceptRequest", false, initiator)

	initiator = nil
	keybind:disable(true)
end

Citizen.CreateThread(function()
	exports.ox_target:addGlobalPlayer({
		label = locale("request_search"),
		icon = Config.targetIcon,
		onSelect = requestSearch
	})

	keybind = lib.addKeybind({
		name = "accept_request_search",
		description = "press Y to accept request search",
		defaultKey = "Y",
		onPressed = acceptSearchRequest
	})

	keybind:disable(true)
end)

lib.callback.register("vx_requestsearch:receiveRequest", function(from)
	vx.sendNotification("Fouilleer Verzoek", locale("press_to_accept", from))

	initiator = from
	keybind:disable(false)

	Citizen.CreateThread(function()
		Citizen.Wait(Config.requestExpiry)

		if initiator ~= nil then
			vx.sendNotification(locale("request_search"), locale("request_expired"))

			initiator = nil
			keybind:disable(true)
		end
	end)
end)
