local RunService = game:GetService("RunService")

local INIT_FUNCTION_NAME = "Init"
local METHOD_TIMEOUT_SECONDS = 5

local debugPriority = true
local onlyShowDebugInStudio = true

local extensionsFolder = script:WaitForChild("Extensions", 10)

export type System = {
	Icon: string?,
	Name: string,
	Priority: number,
	[any]: any,
}

local addedSystems: { { system: System, failedOnce: boolean } } = {}
local errors: { [string]: { { system: System, response: string } } } = {}

local System = {}

local function prioritySortAddedSystems()
	table.sort(addedSystems, function(a, b)
		return a.system.Priority < b.system.Priority
	end)

	if debugPriority then
		if onlyShowDebugInStudio and not RunService:IsStudio() then
			return
		end

		warn(`[System] {RunService:IsServer() and "Server" or "Client"} load order:`)
		for loadOrder, system in addedSystems do
			local iconString = system.system.Icon and `{system.system.Icon} ` or "🔴"
			print(`{loadOrder} - [{iconString}{system.system.Name}] :: {system.system.Priority}`)
		end
	end
end

local function initializeSystemMethod(methodName: string)
	methodName = if typeof(methodName) == "string" then methodName else INIT_FUNCTION_NAME

	if not errors[methodName] then
		errors[methodName] = {}
	end

	for _, data in addedSystems do
		if data.failedOnce then
			continue
		end

		local success, errorMessage = pcall(function()
			local yieldCoroutine = coroutine.create(function()
				task.spawn(function()
					if typeof(data.system[methodName]) == "function" then
						data.system[methodName](data.system)
					end

					if not extensionsFolder then
						return
					end

					for _, extension in extensionsFolder:GetChildren() do
						local extensionModule = require(extension)
						if typeof(extensionModule.AddTo) ~= "function" then
							warn(`[System] {extension.Name} is missing a public AddTo method.`)
							continue
						end
						extensionModule:AddTo(data.system, data.module)
					end
				end)
			end)

			local yieldTime = 0

			local executed, message = coroutine.resume(yieldCoroutine)
			if not executed then
				error(message, 2)
			end

			while coroutine.status(yieldCoroutine) == "suspended" do
				yieldTime += task.wait(1)

				if yieldTime > METHOD_TIMEOUT_SECONDS then
					warn(
						`[System] Module {data.system.Name}:{methodName} took more than {METHOD_TIMEOUT_SECONDS} seconds to initialize.`
					)
					data.failedOnce = true
					return
				end
			end

			if coroutine.status(yieldCoroutine) == "dead" and not executed then
				error(message)
			end
		end)

		if not success then
			table.insert(errors[methodName], { system = data.system, response = errorMessage })
			warn(
				`[System] Module {data.system.Name}:{methodName} failed to initialize: {errorMessage}\n{debug.traceback()}`
			)
		end
	end
end

local function ModuleWithSameNameExists()
	local systemNames = {}

	for _, data in addedSystems do
		if systemNames[data.system.Name] then
			warn(`[System] {data.system.Name} is already in the systems list.`)
		end

		systemNames[data.system.Name] = true
	end
end

local function AddSystem(systemModule: ModuleScript)
	if not systemModule:IsA("ModuleScript") then
		return
	end

	if ModuleWithSameNameExists() then
		warn(`[System] {systemModule.Name} is already in the systems list. Are you double Loading!?`)
		return
	end

	local success, errorMessage = pcall(function()
		local newlyAddedSystem = require(systemModule)

		newlyAddedSystem.Icon = newlyAddedSystem.Icon or "🔴"
		newlyAddedSystem.Name = newlyAddedSystem.Name or `{systemModule:GetFullName()}`
		newlyAddedSystem.Priority = newlyAddedSystem.Priority or math.huge

		table.insert(addedSystems, { system = newlyAddedSystem, failedOnce = false, module = systemModule })
	end)

	if not success then
		warn(`[System] Failed to add {systemModule.Name} to systems: {errorMessage}\n{debug.traceback()}`)
	end
end

--[[
	Add a folder that contains children that are systems to be initialized.
	Note that systems without a priority are processed last.

	@param folder Folder should contain children that are modules.
]]
function System:AddSystemsFolder(instance: Folder)
	for _, systemModule in instance:GetChildren() do
		AddSystem(systemModule)
	end
end

--[[
	Add a table of systems to be initialized.
	Note that systems without a priority are processed last.

	@param systems Table of modules.
]]
function System:AddSystemsTable(systems: { ModuleScript })
	for _, systemModule in systems do
		AddSystem(systemModule)
	end
end

--[[
	Set whether or not to print debug information.

	@param bool Boolean value to set debug print.
]]
function System:SetDebugPrint(bool: boolean)
	debugPriority = bool
end

--[[
	Set whether or not to only show debug information in studio.

	@param bool Boolean value to set debug print.
]]
function System:SetOnlyShowDebugInStudio(bool: boolean)
	onlyShowDebugInStudio = bool
end

--[[
	Call only after you've added any folders containing modules that you wish to become systems.

	@return table errors can return a table of errors thrown during initialization.
]]
function System:Start(): { [string]: { { system: System, response: string } } }
	System.RuntimeStart = os.clock()

	prioritySortAddedSystems()

	initializeSystemMethod(INIT_FUNCTION_NAME)

	for _, methodErrorGroup in errors do
		if #methodErrorGroup > 0 then
			for methodName, errorMessage in methodErrorGroup do
				warn(`[System] {errorMessage.system.Name}:{methodName} failed to initialize: {errorMessage.response}`)
			end
		end
	end

	return errors
end

return System
