return function(soundPrefab: Sound, location: CFrame)
	local attachment = Instance.new("Attachment")
	attachment.WorldCFrame = location
	attachment.Parent = workspace.Terrain
	
	local sound = soundPrefab:Clone()
	sound.Parent = attachment
	
	sound:Play()
	sound.Ended:Once(function()
		attachment:Destroy()
	end)
end