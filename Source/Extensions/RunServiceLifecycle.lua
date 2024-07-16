local RunService = game:GetService("RunService")

local RunServiceLifecycle = {}

function RunServiceLifecycle.Heartbeat(system)
	RunService.Heartbeat:Connect(function(deltaTime)
		system:Heartbeat(deltaTime)
	end)
end

function RunServiceLifecycle.RenderStepped(system, moduleName)
	if RunService:IsServer() then
		print(`[RunServiceLifecycle] RenderStepped is not supported on the server! Module:"{moduleName}"`)
		return
	end

	RunService.RenderStepped:Connect(function(deltaTime)
		system:RenderStepped(deltaTime)
	end)
end

function RunServiceLifecycle:AddTo(system, module)
	if typeof(system.Heartbeat) == "function" then
		RunServiceLifecycle.Heartbeat(system)
	end

	if typeof(system.RenderStepped) == "function" then
		RunServiceLifecycle.RenderStepped(system, module.Name)
	end
end

return RunServiceLifecycle
