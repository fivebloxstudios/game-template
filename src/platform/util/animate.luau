const RunService = game:GetService("RunService")

-- Calls `update` every frame for `duration` seconds with progress (0..1), ending on exactly 1. Yields.
return function(duration: number, update: (progress: number, deltaTime: number) -> ())
	local elapsed = 0
	while elapsed < duration do
		const deltaTime = RunService.RenderStepped:Wait()
		elapsed = math.min(elapsed + deltaTime, duration)
		update(elapsed / duration, deltaTime)
	end
end
