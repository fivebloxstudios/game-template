return function(model: Model)
	if model.PrimaryPart then
		return model.PrimaryPart
	else
		local primaryPart = Instance.new("Part")
		primaryPart:PivotTo(model:GetPivot())
		primaryPart.CanCollide = false
		primaryPart.CanQuery = false
		primaryPart.CanTouch = false
		primaryPart.AudioCanCollide = false
		primaryPart.EnableFluidForces = false
		primaryPart.CastShadow = false
		primaryPart.Size = Vector3.one
		primaryPart.Transparency = 1
		primaryPart.Parent = model
		model.PrimaryPart = primaryPart

		for _, descendant in model:GetDescendants() do
			if not descendant:IsA("BasePart") then
				continue
			end

			descendant.Anchored = false
			const weld = Instance.new("WeldConstraint")
			weld.Name = descendant.Name
			weld.Part0 = primaryPart
			weld.Part1 = descendant
			weld.Parent = primaryPart
		end

		return primaryPart
	end
end