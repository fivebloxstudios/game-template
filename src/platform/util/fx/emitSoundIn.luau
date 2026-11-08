return function(soundPrefab: Sound, target: Instance)
	local sound = soundPrefab:Clone()
	sound.Parent = target
	
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end