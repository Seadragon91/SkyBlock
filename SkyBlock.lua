-- SkyBlock plugin for cuberite.
-- Before starting the server, you need to add a (configurable world name in Config.ini)
-- world in the settings.ini under the section [Worlds]
-- Example: World=skyblock


-- Load all lua files
-- Has to be called outside of the Initialize function
-- Because if Info.lua is called without the command files loaded
-- The variables Handler in Info.lua would be all nil
function LoadLuaFiles()
	local folders =  { "/code", "/code/classes", "/code/commands" }
	local localFolder = cPluginManager:GetCurrentPlugin():GetLocalFolder()

	for _, folder in pairs(folders) do
		local files = cFile:GetFolderContents(localFolder .. "/" .. folder)
		if (#files > 2) then
			for _, file in pairs(files) do
				if (string.sub(file, #file -3, #file) == ".lua") then
					dofile(localFolder .. folder .. "/" .. file)
				end
			end
		end
	end
end
LoadLuaFiles()


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
BLOCK_VALUES = nil -- Store the points of block / meta
LANGUAGES = nil -- Contains a list of languages
LANGUAGE_DEFAULT = nil -- Default language file
LANGUAGE_OTHERS = nil -- Enable other language files

function Initialize(Plugin)
	Plugin:SetName("SkyBlock")
	Plugin:SetVersion(3)

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
	BLOCK_VALUES = {}
	LANGUAGES = {}
	LANGUAGE_DEFAULT = "english.ini"
	LANGUAGE_OTHERS = 1

	-- Load Config file
	LoadConfiguration()

	-- Check for world <WORLD_NAME>
	SKYBLOCK = cRoot:Get():GetWorld(WORLD_NAME)
	if (SKYBLOCK == nil) then
		LOGWARNING("Plugin SkyBlock requires the world " .. WORLD_NAME .. ". Please add this line")
		LOGWARNING("World=" .. WORLD_NAME)
		LOGWARNING("to the section [Worlds] in the settings.ini.")
		LOGWARNING("Then stop and start the server again.")
		return false
	end

    -- Create language folder
	cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/languages/")
	LoadLanguageFiles()

	-- Load the points for block / meta
	LoadBlockValues()

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

	-- Info.lua
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function LoadConfiguration()
	-- Create players folder
	if (not cFile:IsFolder(PLUGIN:GetLocalFolder() .. "/players/")) then
		cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/players/")
	end

	-- Create islands folder
	if (not cFile:IsFolder(PLUGIN:GetLocalFolder() .. "/islands/")) then
		cFile:CreateFolder(PLUGIN:GetLocalFolder() .. "/islands/")
	end

	local configIni = cIniFile()
	configIni:ReadFile(CONFIG_FILE)
	ISLAND_NUMBER = configIni:GetValueI("Island", "Number")
	ISLAND_DISTANCE = configIni:GetValueI("Island", "Distance")
	ISLAND_SCHEMATIC = "schematics/" .. configIni:GetValue("Schematic", "Island")
	SPAWN_SCHEMATIC = "schematics/" .. configIni:GetValue("Schematic", "Spawn")
	WORLD_NAME = configIni:GetValue("General", "Worldname")
	SPAWN_CREATED = configIni:GetValueB("PluginValues", "SpawnCreated")
	LANGUAGE_DEFAULT = configIni:GetValue("Language", "Default")
	LANGUAGE_OTHERS = configIni:GetValueB("Language", "EnableOthers")

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
			if (cFile:IsFolder(PLUGIN:GetLocalFolder() .. "/islands/" .. playerInfo.m_IslandNumber .. ".ini")) then
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


function LoadBlockValues()
	local f = io.open(PLUGIN:GetLocalFolder() .. "/blockvalues.txt")

	while true do
		local line = f:read()
		if (line == nil) then break end
		local values = StringSplit(line, ":")
		local point = tonumber(values[2])
		if (string.find(values[1], "#") == nil) then
			local id = tonumber(values[1])
			BLOCK_VALUES[id] = {}
			BLOCK_VALUES[id][0] = point
		else
			local idMeta = StringSplit(values[1], "#")
			local id = tonumber(idMeta[1])
			local meta = tonumber(idMeta[2])
			if (BLOCK_VALUES[id] == nil) then
				BLOCK_VALUES[id] = {}
			end
			BLOCK_VALUES[id][meta] = point
		end
	end
end

function LoadLanguageFiles()
    local files = cFile:GetFolderContents(PLUGIN:GetLocalFolder() .. "/languages")
    if (#files == 2) then -- Write Default language file
        LANGUAGES["english.ini"] = cLanguage.new()
        return
    end

    if (LANGUAGE_OTHERS) then
        for i = 1, #files do
            if (cFile:IsFile(PLUGIN:GetLocalFolder() .. "/languages/" .. files[i])) then
                LANGUAGES[files[i]] = cLanguage.new(files[i])
            end
        end
    else
        LANGUAGES[LANGUAGE_DEFAULT] = cLanguage.new(LANGUAGE_DEFAULT)
    end
end
