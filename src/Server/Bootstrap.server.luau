local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

local Core = ServerScriptService.Server.Core
local Features = ServerScriptService.Server.Features

Loader.SpawnAll(Loader.LoadDescendants(Core, Loader.MatchesName("Service$")), "OnStart")
Loader.SpawnAll(Loader.LoadDescendants(Features, Loader.MatchesName("Service$")), "OnStart")
Loader.LoadDescendants(Features, Loader.MatchesName("Component$"))
