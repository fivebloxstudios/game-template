return function(animator: Animator, animation: Animation | string | number)
	local id = if typeof(animation) == "Instance" then animation.AnimationId else `rbxassetid://{tostring(animation):match("%d+")}`
	local instance = if typeof(animation) == "Instance" then animation else Instance.new("Animation")
	instance.AnimationId = id
	return animator:LoadAnimation(instance)
end