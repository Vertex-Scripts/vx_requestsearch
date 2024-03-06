vx = {}

function vx.sendNotification(title, message)
	TriggerEvent("chat:addMessage", {
		color = { 255, 0, 0 },
		multiline = true,
		args = { "Request Search", title, message }
	})
end
