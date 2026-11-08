return function(particleCount: number, emitterPrefab: ParticleEmitter, location: CFrame)
	local attachment = Instance.new("Attachment")
	attachment.WorldCFrame = location
	attachment.Parent = workspace.Terrain
	
	local emitter = emitterPrefab:Clone()
	emitter.Parent = attachment
	
	emitter:Emit(particleCount)
	task.delay(emitter.Lifetime.Max, attachment.Destroy, attachment)
end