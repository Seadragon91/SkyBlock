-- SkyBlock plugin for the c++ MC Server.
-- Before starting the server, you need to add a world named skyblock in the settings.ini under the topic [Worlds]
-- World=skyblock

PLUGIN = nil
ISLAND_NUMBER = nil -- Gets increased, before a new island is created
ISLAND_DISTANCE = nil -- Distance betweens the islands
ISLAND_SCHEMATIC = nil -- Schematic file for islands
SPAWN_SCHEMATIC = nil -- Schematic file for the spawn
SPAWN_CREATED = nil -- Check value, if spawn has already been created
SKYBLOCK = nil -- Instance of a world
PLAYERS = nil -- A table that contains player names and PlayerInfos
WORLD_NAME = nil -- The world that the plugin is using
LEVELS = nil -- Store all levels

function Initialize(Plugin)
    Plugin:SetName("SkyBlock")
    Plugin:SetVersion(1)

    PLUGIN = Plugin
    ISLAND_NUMBER = 0
    ISLAND_DISTANCE = 96
    ISLAND_SCHEMATIC = ""
    SPAWN_SCHEMATIC = ""
    SPAWN_CREATED = false
    PLAYERS = {}
    WORLD_NAME = "skyblock"
    LEVELS = {}
    
    -- Create players folder
    cFile:CreateFolder(PLUGIN:GetLocalDirectory() .. "/players/")
    
    -- Load Config file
    LoadConfiguration(PLUGIN:GetLocalDirectory() .. "/Config.ini")
    
    -- Get instance of world skyblock
    SKYBLOCK = cRoot:Get():GetWorld(WORLD_NAME)
    
    -- Load all ChallengeInfos
    LoadAllLevels(PLUGIN:GetLocalDirectory() .. "/challenges/Config.ini")
        
    -- Load all PlayerInfos from players who are online
    LoadAllPlayerInfos()
    
    -- register hooks
    cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED, OnPlayerJoin)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerQuit)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, OnPlayerSpawn)
    cPluginManager:AddHook(cPluginManager.HOOK_WORLD_STARTED, OnWorldLoaded)
    
    -- This below are required for checking the permission in the island area
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_PLACING_BLOCK, OnBlockPlacing)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK, OnPlayerLeftClick)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
    
    -- Command Bindings
    cPluginManager.BindCommand("/skyblock", "skyblock.command", CommandSkyBlock , " - Access to the skyblock plugin")
    cPluginManager.BindCommand("/challenges", "skyblock.command", CommandChallenges , " - Access to the challenges")
    
    LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
    return true
end

function OnDisable()
    -- Save configuration
    SaveConfiguration(PLUGIN:GetLocalDirectory() .. "/Config.ini")
    
    -- Save all PlayerInfos
    SaveAllPlayerInfos()
    
    LOG(PLUGIN:GetName() .. " is shutting down...")
end

function LoadConfiguration(a_Config)
    local ConfigIni = cIniFile()
    ConfigIni:ReadFile(a_Config)
    ISLAND_NUMBER = ConfigIni:GetValueI("Island", "Number")
    ISLAND_DISTANCE = ConfigIni:GetValueI("Island", "Distance")
    ISLAND_SCHEMATIC = ConfigIni:GetValue("Schematic", "Island")
    SPAWN_SCHEMATIC = ConfigIni:GetValue("Schematic", "Spawn")
    WORLD_NAME = ConfigIni:GetValue("General", "Worldname")
    SPAWN_CREATED = ConfigIni:GetValueB("PluginValues", "SpawnCreated")
end

function SaveConfiguration(a_Config)
    local ConfigIni = cIniFile()
    ConfigIni:ReadFile(a_Config)
    ConfigIni:SetValue("Island", "Number", ISLAND_NUMBER, true)
    ConfigIni:SetValue("Island", "Distance", ISLAND_DISTANCE, true)
    ConfigIni:SetValue("General", "Worldname", WORLD_NAME, true)
    ConfigIni:SetValueB("PluginValues", "SpawnCreated", SPAWN_CREATED, true)
    ConfigIni:WriteFile(a_Config)
end

function LoadAllPlayerInfos()
    cRoot:Get():ForEachPlayer(function(a_Player)
        PLAYERS[a_Player:GetName()] = cPlayerInfo.new(a_Player:GetName());
    end);
end

function SaveAllPlayerInfos()
    for player, pi in pairs(PLAYERS) do
        pi:Save()
    end
end

function LoadAllLevels(a_File)
    local ConfigIni = cIniFile()
    ConfigIni:ReadFile(a_File)

    local amount = ConfigIni:GetNumValues("Levels")    
    for i = 1, amount do
        local fileLevel = ConfigIni:GetValue("Levels", i)
        LEVELS[i] = cLevel.new(fileLevel)
    end
end
