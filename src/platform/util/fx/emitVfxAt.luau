-- Emits every ParticleEmitter in a vfx folder once (its Rate each) at `location`, and cleans up
-- once the longest-lived particle is gone. Returns the attachment, e.g. to add a light to it.
return function(vfxFolder: Instance, location: CFrame): Attachment
	const attachment = Instance.new("Attachment")
	attachment.WorldCFrame = location
	attachment.Parent = workspace.Terrain

	local lifetime = 0
	for _, particlePrefab in vfxFolder:GetChildren() do
		if not particlePrefab:IsA("ParticleEmitter") then
			continue
		end

		const particle = particlePrefab:Clone()
		particle.Parent = attachment
		particle:Emit(particle.Rate)
		lifetime = math.max(lifetime, particle.Lifetime.Max)
	end

	task.delay(lifetime, attachment.Destroy, attachment)
	return attachment
end
