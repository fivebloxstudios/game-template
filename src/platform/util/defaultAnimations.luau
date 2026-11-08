local function waitPath(instance: Instance, path: string, timeOut: number?): Instance?
	local found: Instance? = instance
	local separated = path:split(".")

	for _, segment in separated do
		if not found then
			return nil
		end

		found = if timeOut then found:WaitForChild(segment, timeOut) else found:WaitForChild(segment)
	end

	return found
end

local function findPath(instance: Instance, path: string): Instance?
	local found: Instance? = instance
	local separated = path:split(".")

	for _, segment in separated do
		if not found then
			return nil
		end

		found = found:FindFirstChild(segment)
	end

	return found
end

type characterAnimation =
	"cheer" |
	"climb" |
	"dance1animation1" |
	"dance1animation2" |
	"dance1animation3" |
	"dance2animation1" |
	"dance2animation2" |
	"dance2animation3" |
	"dance3animation1" |
	"dance3animation2" |
	"dance3animation3" |
	"fall" |
	"idleanimation1" |
	"idleanimation2" |
	"jump" |
	"laugh" |
	"point" |
	"sit" |
	"toollunge" |
	"toolnone" |
	"toolslash" |
	"wave" |
	"run" |
	"swim" |
	"swimidle" |
	"walk" |
	"mood"


local nameToPath: {[characterAnimation]: string} = {
	["cheer"] = "Animate.cheer.CheerAnim",
	["climb"] = "Animate.climb.ClimbAnim",
	["dance1animation1"] = "Animate.dance.Animation1",
	["dance1animation2"] = "Animate.dance.Animation2",
	["dance1animation3"] = "Animate.dance.Animation3",
	["dance2animation1"] = "Animate.dance2.Animation1",
	["dance2animation2"] = "Animate.dance2.Animation2",
	["dance2animation3"] = "Animate.dance2.Animation3",
	["dance3animation1"] = "Animate.dance3.Animation1",
	["dance3animation2"] = "Animate.dance3.Animation2",
	["dance3animation3"] = "Animate.dance3.Animation3",
	["fall"] = "Animate.fall.FallAnim",
	["idleanimation1"] = "Animate.idle.Animation1",
	["idleanimation2"] = "Animate.idle.Animation2",
	["jump"] = "Animate.jump.JumpAnim",
	["laugh"] = "Animate.laugh.LaughAnim",
	["point"] = "Animate.point.PointAnim",
	["sit"] = "Animate.sit.SitAnim",
	["toollunge"] = "Animate.toollunge.ToolLungeAnim",
	["toolnone"] = "Animate.toolnone.ToolNoneAnim",
	["toolslash"] = "Animate.toolslash.ToolSlashAnim",
	["wave"] = "Animate.wave.WaveAnim",
	["run"] = "Animate.run.RunAnim",
	["swim"] = "Animate.swim.Swim",
	["swimidle"] = "Animate.swimidle.SwimIdle",
	["walk"] = "Animate.walk.WalkAnim",
	["mood"] = "Animate.mood.Animation1",
}


return {
	find = function(player: Player, name: characterAnimation): string?
		local character = player.Character
		if not character then
			return nil
		end
		
		local animation = findPath(character, nameToPath[name])
		if not animation or not animation:IsA("Animation") then
			return nil
		end
		
		return animation.AnimationId
	end,
	
	waitFor = function(player: Player, name: characterAnimation, timeOut: number?): string?
		local character = player.Character
		if not character then
			return nil
		end

		local animation = waitPath(character, nameToPath[name], timeOut)
		if not animation or not animation:IsA("Animation") then
			return nil
		end

		return animation.AnimationId
	end,
	
	tryUpdate = function(player: Player, name: characterAnimation, animationId: string, wait: boolean?)
		local character = player.Character
		if not character then
			return
		end
		
		local path = nameToPath[name]
		if not path then
			return
		end

		local animation = wait and  waitPath(character, nameToPath[name]) or findPath(character, nameToPath[name])
		if not animation or not animation:IsA("Animation") then
			return
		end
		
		animation.AnimationId = animationId
	end,
}