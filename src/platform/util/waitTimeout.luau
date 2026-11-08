const function waitTimeout(signal: RBXScriptSignal, timeout: number)
	const thread = coroutine.running()

	task.defer(function()
		local queued: thread, connection: RBXScriptConnection
		
		queued = task.delay(timeout, function()
			connection:Disconnect()
			coroutine.resume(thread, false)
		end)

		connection = signal:Once(function()
			task.cancel(queued)
			coroutine.resume(thread, true)
		end)
	end)

	return coroutine.yield(thread)
end

return waitTimeout