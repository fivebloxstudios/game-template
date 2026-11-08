return function(instance: Instance, attribute: string): Instance?
	const handle = instance:GetAttribute(attribute)
	return if typeof(handle) == "InstanceHandle" then handle:Get() else nil
end