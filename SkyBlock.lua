-- SkyBlock plugin for cuberite.
-- Before starting the server, you need to add a (configurable world name in Config.ini) world in the settings.ini under the toplayerInfoc [Worlds]
-- Example: World=skyblock

PLUGIN = nil
ISLAND_NUMBER = nil -- Gets increased, before a new island is created
ISLAND_DISTANCE = nil -- Distance betweens the islands
ISLAND_SCHEMATIC = nil -- Schematic file for islands
SPAWN_SCHEMATIC = nil -- Schematic file for the spawn
SPAWN_CREATED = nil -- Check value, if spawn has already been created
SKYBLOCK = nil -- Instance of a world
PLAYERS = nil -- A table that contains player uuid and PlayerInfos
ISLANDS = nil -- A table contains island numbers and IslandInfo
WORLD_NAME = nil -- The world that the plugin is using
LEVELS = nil -- Store all levels
CONFIG_FILE = nil -- Config file for SkyBlock

function Initialize(Plugin)
	Plugin:SetName("SkyBlock")
	Plugin:SetVersion(2)

	PLUGIN = Plugin
	ISLAND_NUMBER = 0
	ISLAND_DISTANCE = 96
	ISLAND_SCHEMATIC = ""
	SPAWN_SCHEMATIC = ""
	SPAWN_CREATED = false
	PLAYERS = {}
	ISLANDS = {}
	WORLD_NAME = "skyblock"
	LEVELS = {}
	CONFIG_FILE = PLUGIN:GetLocalFolder() .. "/Config.ini"

	-- Create players folder
	cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/players/")

	-- Create islands folder
	cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/islands/")

	-- Load Config file
	LoadConfiguration()

	-- Get instance of world <WORLD_NAME>
	SKYBLOCK = cRoot:Get():GetWorld(WORLD_NAME)

	-- Load all ChallengeInfos
	LoadAllLevels(PLUGIN:GetLocalFolder() .. "/challenges/Config.ini")

	-- Load all PlayerInfos and IslandInfos from players who are in the world
	LoadPlayerInfos()

	-- Register hooks
	cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerQuit)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, OnPlayerSpawn)
	cPluginManager:AddHook(cPluginManager.HOOK_WORLD_STARTED, OnWorldLoaded)
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE, OnTakeDamage)
	cPluginManager:AddHook(cPluginManager.HOOK_ENTITY_CHANGED_WORLD, OnPlayerChangedWorld)

	-- This below are required for checking the permission in the island area
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_PLACING_BLOCK, OnBlockPlacing)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK, OnPlayerLeftClick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)

	-- Command Bindings
	cPluginManager.BindCommand("/skyblock", "skyblock.command", CommandSkyBlock , " - Access to the skyblock plugin")
	cPluginManager.BindCommand("/challenges", "skyblock.command", CommandChallenges , " - Access to the challenges")
	cPluginManager.BindCommand("/island", "skyblock.command", CommandIsland , " - Access to the island commands")

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function LoadConfiguration()
	local configIni = cIniFile()
	configIni:ReadFile(CONFIG_FILE)
	ISLAND_NUMBER = configIni:GetValueI("Island", "Number")
	ISLAND_DISTANCE = configIni:GetValueI("Island", "Distance")
	ISLAND_SCHEMATIC = configIni:GetValue("Schematic", "Island")
	SPAWN_SCHEMATIC = configIni:GetValue("Schematic", "Spawn")
	WORLD_NAME = configIni:GetValue("General", "Worldname")
	SPAWN_CREATED = configIni:GetValueB("PluginValues", "SpawnCreated")
	
	-- Reminder: Any new settings who gets added in new versions, should be added, to the config file trough the plugin, if not existent
end

-- Save settings who gets changed trough the plugin
function SaveConfiguration()
	local configIni = cIniFile()
	configIni:ReadFile(CONFIG_FILE)
	configIni:SetValue("Island", "Number", ISLAND_NUMBER, true)
	configIni:SetValueB("PluginValues", "SpawnCreated", SPAWN_CREATED, true)
	configIni:WriteFile(CONFIG_FILE)
end

-- Only for the world that the plugin is using
function LoadPlayerInfos()
	cRoot:Get():ForEachPlayer(function(a_Player)
		if (a_Player:GetWorld():GetName() == WORLD_NAME) then
			local playerInfo = cPlayerInfo.new(a_Player)
			if (cFile:Exists(PLUGIN:GetLocalFolder() .. "/islands/" .. playerInfo.m_IslandNumber .. ".ini")) then
				GetIslandInfo(playerInfo.m_IslandNumber)
			end

			PLAYERS[a_Player:GetUUID()] = playerInfo
		end
	end);
end

-- Loads all level challenges
function LoadAllLevels(a_File)
	local configIni = cIniFile()
	configIni:ReadFile(a_File)

	local amount = configIni:GetNumValues("Levels")
	for i = 1, amount do
		local fileLevel = configIni:GetValue("Levels", i)
		LEVELS[i] = cLevel.new(fileLevel)
	end
end
