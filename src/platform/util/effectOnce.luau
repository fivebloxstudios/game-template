const charm = require("@game/ReplicatedStorage/packages/charm")

const function effectOnce(condition: () -> any?, fn: () -> ())
	if condition() then
		charm.untracked(fn)
		return function() end
	end

	local dispose
	dispose = charm.effect(function()
		if not condition() then
			return
		end

		if dispose then
			dispose()
			dispose = nil
		end

		charm.untracked(fn)
	end)

	return dispose
end

return effectOnce
