const gt = require("@game/ReplicatedStorage/packages/GreenTea")
const RemoteWrapper = require("../platform/RemoteWrapper")

-- Server and client build remotes in this module's order, so every remote must be declared here.
return {
	CharmSync = {
		Payload = RemoteWrapper.event(gt.tuple(gt.array(gt.struct({
			data = gt.dictionary(gt.string(), gt.any()),
			type = gt.any(),
		})))),
	},
}
