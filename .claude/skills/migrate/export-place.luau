-- Reads a saved place file and writes every script to .migration/export, plus a manifest
-- saying which scripts can move into src/. It only reads the place. Used once, by /migrate.

const fs = require("@lune/fs")
const process = require("@lune/process")
const roblox = require("@lune/roblox")
const serde = require("@lune/serde")

const Enum = roblox.Enum

const OUTPUT_FOLDER = ".migration/export"
const MANIFEST_PATH = ".migration/manifest.json"

const EXTENSIONS = {
	Script = ".server.luau",
	LocalScript = ".client.luau",
	ModuleScript = ".luau",
}

-- Places where rogen can put code. Anything else stays in Studio.
const MOVABLE_ROOTS = {
	ServerScriptService = true,
	ServerStorage = true,
	ReplicatedStorage = true,
	["StarterPlayer/StarterPlayerScripts"] = true,
}

-- Names the new project owns. An existing child with one of these names would be overwritten by Rojo.
const RESERVED_PATHS = {
	{ "ReplicatedStorage", "shared" },
	{ "ReplicatedStorage", "packages" },
	{ "ServerScriptService", "server" },
	{ "ServerScriptService", "packages" },
	{ "StarterPlayer", "StarterPlayerScripts", "client" },
}

const placePath = process.args[1] or ".migration/place.rbxl"
if not fs.isFile(placePath) then
	error(`Could not find the saved place at {placePath}`)
end

const game = roblox.deserializePlace(fs.readFile(placePath))

if fs.isDir(OUTPUT_FOLDER) then
	fs.removeDir(OUTPUT_FOLDER)
end

const scripts = {}
const usedFileNames: { [string]: boolean } = {}

const function isScript(instance): boolean
	return EXTENSIONS[instance.ClassName] ~= nil
end

const function safeName(name: string): string
	return (string.gsub(string.gsub(name, '[<>:"/\\|%?%*%c]', "_"), "[%. ]+$", "_"))
end

const function getRootKey(path: { string }): string
	if path[1] == "StarterPlayer" and path[2] == "StarterPlayerScripts" then
		return "StarterPlayer/StarterPlayerScripts"
	end
	return path[1]
end

const function uniqueFilePath(folder: string, name: string, extension: string): string
	local candidate = `{folder}/{name}{extension}`
	local attempt = 1
	while usedFileNames[string.lower(candidate)] do
		attempt += 1
		candidate = `{folder}/{name}__{attempt}{extension}`
	end
	usedFileNames[string.lower(candidate)] = true
	return candidate
end

-- Place files may store either property, and reading one that is absent throws.
const function isDisabled(instance): boolean
	const hasDisabled, disabled = pcall(function()
		return instance.Disabled
	end)
	const hasEnabled, enabled = pcall(function()
		return instance.Enabled
	end)
	return (hasDisabled and disabled == true) or (hasEnabled and enabled == false)
end

const function classify(instance, path: { string }, blockedBy: string?): (string, string?)
	const rootKey = getRootKey(path)
	if not MOVABLE_ROOTS[rootKey] then
		return "stay", `lives in {rootKey}, which rogen does not route to`
	end
	if blockedBy then
		return "stay", `sits inside {blockedBy}`
	end
	if instance.ClassName == "Script" and rootKey ~= "ServerScriptService" then
		return "stay", "a Script here does not run on its own, so it is probably cloned at runtime"
	end
	if instance.ClassName == "LocalScript" and rootKey ~= "StarterPlayer/StarterPlayerScripts" then
		return "stay", "a LocalScript here does not run on its own, so it is probably cloned at runtime"
	end
	if instance.ClassName == "Script" and instance.RunContext ~= Enum.RunContext.Legacy then
		return "review", "uses a custom RunContext"
	end
	if instance.ClassName ~= "ModuleScript" and isDisabled(instance) then
		return "review", "is disabled"
	end
	for _, child in instance:GetChildren() do
		if not isScript(child) then
			return "review", `has a non-script child: {child.Name} ({child.ClassName})`
		end
	end
	return "move", nil
end

const function visit(instance, path: { string }, folder: string, blockedBy: string?)
	for _, child in instance:GetChildren() do
		const childPath = table.clone(path)
		table.insert(childPath, child.Name)
		const childFolder = `{folder}/{safeName(child.Name)}`

		if isScript(child) then
			const status, reason = classify(child, childPath, blockedBy)
			const file = uniqueFilePath(folder, safeName(child.Name), EXTENSIONS[child.ClassName])
			fs.writeDir(folder)
			fs.writeFile(file, child.Source)
			table.insert(scripts, {
				path = childPath,
				className = child.ClassName,
				file = file,
				sourceLength = #child.Source,
				status = status,
				reason = reason,
			})
			visit(child, childPath, childFolder, blockedBy)
		elseif child.ClassName == "Folder" then
			visit(child, childPath, childFolder, blockedBy)
		else
			visit(child, childPath, childFolder, blockedBy or `{child.Name} ({child.ClassName})`)
		end
	end
end

for _, service in game:GetChildren() do
	const path = { service.Name }
	if service.Name == "StarterPlayer" then
		for _, container in service:GetChildren() do
			visit(container, { service.Name, container.Name }, `{OUTPUT_FOLDER}/{service.Name}/{container.Name}`, nil)
		end
	else
		visit(service, path, `{OUTPUT_FOLDER}/{service.Name}`, nil)
	end
end

const collisions = {}
for _, path in RESERVED_PATHS do
	local current = game
	for _, name in path do
		current = current and current:FindFirstChild(name)
	end
	if current then
		table.insert(collisions, table.concat(path, "."))
	end
end

const counts = { move = 0, stay = 0, review = 0 }
for _, entry in scripts do
	counts[entry.status] += 1
end

fs.writeFile(
	MANIFEST_PATH,
	serde.encode("json", {
		counts = counts,
		collisions = collisions,
		scripts = scripts,
	}, true)
)

print(`Exported {#scripts} scripts: {counts.move} can move, {counts.review} need review, {counts.stay} stay in Studio.`)
if #collisions > 0 then
	print(`STOP: these names are already used and Rojo would overwrite them: {table.concat(collisions, ", ")}`)
end
