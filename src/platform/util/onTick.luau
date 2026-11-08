const RunService = game:GetService("RunService")

type cleanup = () -> ()

local prevTimestamp = 0
local callbacks: {[(number, cleanup) -> ()]: {rate: number, prev: number}} = {}

const function cleanupFactory(k: any): cleanup
	return function()
		callbacks[k] = nil
	end	
end

RunService.Heartbeat:Connect(function()
	const timestamp = math.round(workspace:GetServerTimeNow())
	if timestamp == prevTimestamp then
		return
	end
	
	prevTimestamp = timestamp
	
	for callback, info in callbacks do
		const diff = timestamp - info.prev
		if diff >= info.rate then
			info.prev = timestamp
			task.spawn(callback, timestamp, cleanupFactory(callback))
		end
	end
end)

return function(rate: number, callback: (number, cleanup) -> ())
	callbacks[callback] = { rate = math.max(rate, 1), prev = prevTimestamp }
	task.spawn(callback, prevTimestamp, cleanupFactory(callback))
	return cleanupFactory(callback)
end