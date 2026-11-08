return function(particleCount: number, emitterPrefab: ParticleEmitter, parent: Instance)
	local emitter = emitterPrefab:Clone()
	emitter.Parent = parent
	
	emitter:Emit(particleCount)
	task.delay(emitter.Lifetime.Max, emitter.Destroy, emitter)
end