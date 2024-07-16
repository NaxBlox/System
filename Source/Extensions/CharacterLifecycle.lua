local Players = game:GetService("Players")

local CharacterLifecycle = {
	playerConnections = {},
}

local function PlayerAdded(player: Player, system)
	if not CharacterLifecycle.playerConnections[player] then
		CharacterLifecycle.playerConnections[player] = {}
	end

	if typeof(system.CharacterAdded) == "function" then
		table.insert(
			CharacterLifecycle.playerConnections[player],
			player.CharacterAdded:Connect(function(character)
				player.CharacterRemoving:Connect(function()
					system:CharacterRemoving(character, player)
				end)

				system:CharacterAdded(character, player)
			end)
		)
	end
end

local function PlayerRemoving(player)
	if CharacterLifecycle.playerConnections[player] then
		for _, connection in CharacterLifecycle.playerConnections[player] do
			connection:Disconnect()
		end
		CharacterLifecycle.playerConnections[player] = nil
	end
end

function CharacterLifecycle:AddTo(system, _module)
	if not system.CharacterAdded and not system.CharacterRemoving then
		return
	end

	Players.PlayerAdded:Connect(function(addingPlayer)
		PlayerAdded(addingPlayer, system)
	end)

	for _, player in Players:GetPlayers() do
		PlayerAdded(player, system)
	end

	Players.PlayerRemoving:Connect(function(removingPlayer)
		PlayerRemoving(removingPlayer)
	end)
end

return CharacterLifecycle
