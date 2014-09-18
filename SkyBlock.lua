-- SkyBlock plugin for the c++ MC Server.
-- Before starting the server, you need to add a (configurable world name in Config.ini) world in the settings.ini under the topic [Worlds]
-- Example: World=skyblock

PLUGIN = nil
ISLAND_NUMBER = nil -- Gets increased, before a new island is created
ISLAND_DISTANCE = nil -- Distance betweens the islands
ISLAND_SCHEMATIC = nil -- Schematic file for islands
SPAWN_SCHEMATIC = nil -- Schematic file for the spawn
SPAWN_CREATED = nil -- Check value, if spawn has already been created
SKYBLOCK = nil -- Instance of a world
PLAYERS = nil -- A table that contains player uuid and PlayerInfos
WORLD_NAME = nil -- The world that the plugin is using
LEVELS = nil -- Store all levels
CONFIG_FILE = nil -- Config file for SkyBlock

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
    CONFIG_FILE = PLUGIN:GetLocalFolder() .. "/Config.ini"
    
    -- Create players folder
    cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/players/")
    
    -- Create islands folder
    cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/islands/")
    
    -- Load Config file
    LoadConfiguration()
    
    -- Get instance of world skyblock
    SKYBLOCK = cRoot:Get():GetWorld(WORLD_NAME)
    
    -- Load all ChallengeInfos
    LoadAllLevels(PLUGIN:GetLocalFolder() .. "/challenges/Config.ini")
    
    -- Load all PlayerInfos from players who are in the world
    LoadPlayerInfos()
    
    -- register hooks
    cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating)
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
    -- Deprecated
    -- Save all PlayerInfos
    SaveAllPlayerInfos()
    
    LOG(PLUGIN:GetName() .. " is shutting down...")
end

function LoadConfiguration()
    local ConfigIni = cIniFile()
    ConfigIni:ReadFile(CONFIG_FILE)
    ISLAND_NUMBER = ConfigIni:GetValueI("Island", "Number")
    ISLAND_DISTANCE = ConfigIni:GetValueI("Island", "Distance")
    ISLAND_SCHEMATIC = ConfigIni:GetValue("Schematic", "Island")
    SPAWN_SCHEMATIC = ConfigIni:GetValue("Schematic", "Spawn")
    WORLD_NAME = ConfigIni:GetValue("General", "Worldname")
    SPAWN_CREATED = ConfigIni:GetValueB("PluginValues", "SpawnCreated")
    
    -- Reminder: Any new settings who gets added in new versions, should be added, to the config file, if not existent
end

-- Save settings who gets changed trough the plugin
function SaveConfiguration()
    local ConfigIni = cIniFile()
    ConfigIni:ReadFile(CONFIG_FILE)
    ConfigIni:SetValue("Island", "Number", ISLAND_NUMBER, true)
    ConfigIni:SetValueB("PluginValues", "SpawnCreated", SPAWN_CREATED, true)
    ConfigIni:WriteFile(CONFIG_FILE)
end

-- Only for the world that the plugin is using
function LoadPlayerInfos()
    cRoot:Get():ForEachPlayer(function(a_Player)
        if (a_Player:GetWorld():GetName() == WORLD_NAME) then
            PLAYERS[a_Player:GetUUID()] = cPlayerInfo.new(a_Player);
        end
    end);
end

function SaveAllPlayerInfos()
    for uuid, pi in pairs(PLAYERS) do
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
