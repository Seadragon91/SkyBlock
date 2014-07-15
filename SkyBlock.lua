-- SkyBlock plugin for the c++ MC Server.
-- Before starting the server, you need to add a world named skyblock in the settings.ini under the topic [Worlds]
-- World=skyblock

PLUGIN = nil
ISLAND_NUMBER = nil -- Gets increased, before a new island is created
ISLAND_DISTANCE = nil -- Distance betweens the islands
ISLAND_SCHEMATIC = nil -- Schematic file for islands
SPAWN_SCHEMATIC = nil -- Schematic file for the spawn
SPAWN_CREATED = nil -- Check value, if spawn has already been created
SKYBLOCK = nil -- Instance of world skyblock
PLAYERS = nil -- A table that contains player names and PlayerInfos

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
    
    -- Create players folder
    cFile:CreateFolder(PLUGIN:GetLocalDirectory() .. "/players/")
    
    -- Load Config file
    LoadConfiguration(PLUGIN:GetLocalDirectory() .. "/Config.ini")
    
    -- Get instance of world skyblock
    SKYBLOCK = cRoot:Get():GetWorld("skyblock")
    
    -- Load all PlayerInfos from players who are online
    LoadAllPlayerInfos()
    
    -- register hooks
    cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED, OnPlayerJoin)
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerQuit)
    -- cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, OnPlayerSpawn)
    cPluginManager:AddHook(cPluginManager.HOOK_WORLD_STARTED, OnWorldLoaded)

    cPluginManager.AddHook(cPluginManager.HOOK_KILLING, OnKilling)
    
    -- Command Bindings
    cPluginManager.BindCommand("/skyblock", "skyblock", CommandSkyBlock , " - Access to the skyblock plugin")
    
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
    SPAWN_CREATED = ConfigIni:GetValueB("PluginValues", "SpawnCreated")
end

function SaveConfiguration(a_Config)
    local ConfigIni = cIniFile()
    ConfigIni:ReadFile(a_Config)
    ConfigIni:SetValue("Island", "Number", ISLAND_NUMBER, true)
    ConfigIni:SetValue("Island", "Distance", ISLAND_DISTANCE, true)
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
