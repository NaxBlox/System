local Players = game:GetService("Players")

local PLAYER_ADDED = "PlayerAdded"
local PLAYER_REMOVING = "PlayerRemoving"

local PlayerLifecycle = {}

function PlayerLifecycle.PlayerAdded(system)
	Players.PlayerAdded:Connect(function(player)
		xpcall(system[PLAYER_ADDED], function(errorMessage: string)
			task.spawn(error, errorMessage)
		end, system, player)
	end)

	for _, player in Players:GetPlayers() do
		xpcall(system[PLAYER_ADDED], function(errorMessage: string)
			task.spawn(error, errorMessage)
		end, system, player)
	end
end

function PlayerLifecycle.PlayerRemoving(system)
	Players.PlayerRemoving:Connect(function(player)
		xpcall(system[PLAYER_REMOVING], function(errorMessage: string)
			task.spawn(error, errorMessage)
		end, system, player)
	end)
end

function PlayerLifecycle:AddTo(system, _module)
	if typeof(system[PLAYER_ADDED]) == "function" then
		PlayerLifecycle.PlayerAdded(system)
	end

	if typeof(system[PLAYER_REMOVING]) == "function" then
		PlayerLifecycle.PlayerRemoving(system)
	end
end

return PlayerLifecycle
