# System
This system package is a replacement for manually loading modules on runtime, and adds
the benefit of being able to specify load order through 'Priority', as well as 'Name' and 'Icon' which can be used for quick debugging.
None of the 3 passed in args (Priorty, Name, Icon) require being specfied and you can write your modules as they are!

This works as a "System" and will load with default Priorty of 0, no name, and no icon.
```lua
local MyModule = {}

return MyModule
```

All Systems also have their 'Init' method called by default!
```lua
local MyModule = {}

function MyModule:Init()
    print("This prints when the module is loaded")
end

return MyModule
```

Systems also have some built in time saving extensions showcased below!
(All of these except 'RenderStepped', will work on both client and server!)

# Examples of Built in Extensions
```lua
local SystemsInjextionExample = {
	Name = "SystemsInjextionExample",
	Priority = 1,
	Icon = "🥳",
}

function SystemsInjextionExample:PlayerAdded(_player: Player)
	print(`Player ${_player.Name} has joined the game!`)
end

function SystemsInjextionExample:PlayerRemoving(_player: Player)
	print(`Player ${_player.Name} has left the game!`)
end

function SystemsInjextionExample:Heartbeat(_deltaTime: number)
	print(`Heartbeat! ${_deltaTime}`)
end

function SystemsInjextionExample:RenderStepped(_deltaTime: number)
	print(`RenderStepped! ${_deltaTime}`, nil, false)
end

function SystemsInjextionExample:CharacterAdded(_character: Model, _player: Player)
	print(`Character ${_character.Name} has been added to the game by ${_player.Name}!`)
end

function SystemsInjextionExample:CharacterRemoving(_character: Model, _player: Player)
	print(`Character ${_character.Name} has been removed from the game by ${_player.Name}!`)
end

return SystemsInjextionExample
```
