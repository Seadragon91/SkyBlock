-- SkyBlock plugin for cuberite.
-- Before starting the server, you need to add a (configurable world name in Config.ini)
-- world in the settings.ini under the section [Worlds]
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
BLOCK_VALUES = nil -- Store the points of block / meta
LANGUAGES = nil -- Contains a list of languages
LANGUAGE_DEFAULT = nil -- Default language file
LANGUAGE_OTHERS = nil -- Enable other language files
ISLAND_AREA = nil -- The island file

ISLAND_RESTART_SCHEDULER = nil  -- Scheduler for restarting a island

PATH_PLUGIN_DATA = nil -- Folder to store players, islands folders and config file

ISLAND_GUESTS = nil -- Invite list for island guests

function Initialize(Plugin)
	Plugin:SetName("SkyBlock")
	Plugin:SetVersion(4)

	PLUGIN = Plugin
	PATH_PLUGIN_DATA = "PluginData/SkyBlock"
	ISLAND_NUMBER = 0
	ISLAND_DISTANCE = 96
	ISLAND_SCHEMATIC = ""
	SPAWN_SCHEMATIC = ""
	SPAWN_CREATED = false
	PLAYERS = {}
	ISLANDS = {}
	WORLD_NAME = "skyblock"
	LEVELS = {}
	CONFIG_FILE = PATH_PLUGIN_DATA .. "/Config.ini"
	BLOCK_VALUES = {}
	LANGUAGES = {}
	LANGUAGE_DEFAULT = "english.ini"
	LANGUAGE_OTHERS = 1
	ISLAND_GUESTS = {}

	-- Load all lua files
	LoadLuaFiles()

	if (not (cFile:IsFolder(PATH_PLUGIN_DATA))) then
		cFile:CreateFolderRecursive(PATH_PLUGIN_DATA)
	end

	-- Load Config file
	LoadConfiguration()

	-- Check for world <WORLD NAME>
	SKYBLOCK = cRoot:Get():GetWorld(WORLD_NAME)
	if (SKYBLOCK == nil) then
		LOGERROR("The plugin SkyBlock requires the world " .. WORLD_NAME .. ". Please add this line")
		LOGERROR("World=" .. WORLD_NAME)
		LOGERROR("to the section [Worlds] in the settings.ini.")
		LOGERROR("Then stop and start the server again.")
		return false
	end

	ISLAND_RESTART_SCHEDULER = cIslandRestartScheduler.new()

	ISLAND_AREA = cBlockArea()
	if not(ISLAND_AREA:LoadFromSchematicFile(PLUGIN:GetLocalFolder() .. "/" .. ISLAND_SCHEMATIC)) then
		ISLAND_AREA = nil
	end

	LoadLanguageFiles()

	-- Load the points for block / meta
	LoadBlockValues()

	-- Load all ChallengeInfos
	LoadAllLevels(PLUGIN:GetLocalFolder() .. "/challenges/Config.json")

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
	cPluginManager:BindCommand("/skyblock", "skyblock.command", CommandSkyBlock , " - Access to the skyblock plugin")
	cPluginManager:BindCommand("/sb", "skyblock.command", CommandSkyBlock , " - Access to the skyblock plugin")
	cPluginManager:BindCommand("/island", "skyblock.command", CommandIsland , " - Access to the island commands")
	cPluginManager:BindCommand("/is", "skyblock.command", CommandIsland , " - Access to the island commands")
	cPluginManager:BindCommand("/challenges", "skyblock.command",
		function(a_Split, a_Player)
			cChallengeWindow.Open(a_Player)
			return true
		end,
	" - Access to the challenges")

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function LoadConfiguration()
	-- Create players folder
	if (not cFile:IsFolder(PATH_PLUGIN_DATA .. "/players/")) then
		cFile:CreateFolder(PATH_PLUGIN_DATA .. "/players/")
	end

	-- Create islands folder
	if (not cFile:IsFolder(PATH_PLUGIN_DATA .. "/islands/")) then
		cFile:CreateFolder(PATH_PLUGIN_DATA .. "/islands/")
	end

	local configIni = cIniFile()
	configIni:ReadFile(CONFIG_FILE)
	ISLAND_NUMBER = configIni:GetValueSetI("Island", "Number", 0)
	ISLAND_DISTANCE = configIni:GetValueSetI("Island", "Distance", 96)
	ISLAND_SCHEMATIC = "schematics/" .. configIni:GetValueSet("Schematic", "Island", "island.schematic")
	SPAWN_SCHEMATIC = "schematics/" .. configIni:GetValueSet("Schematic", "Spawn", "spawn.schematic")
	WORLD_NAME = configIni:GetValueSet("General", "Worldname", "skyblock")
	SPAWN_CREATED = configIni:GetValueSetB("PluginValues", "SpawnCreated", false)
	LANGUAGE_DEFAULT = configIni:GetValueSet("Language", "Default", "english.ini")
	LANGUAGE_OTHERS = configIni:GetValueSetB("Language", "EnableOthers", true)
	configIni:WriteFile(CONFIG_FILE)
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
	SKYBLOCK:ForEachPlayer(
		function(a_Player)
			GetPlayerInfo(a_Player)
		end);
end

-- Loads all level challenges
function LoadAllLevels(a_File)
	local fileLevels = io.open(a_File, "rb")
	local content = fileLevels:read("*a")
	fileLevels:close()

	local jsonLevels = cJson:Parse(content)

	for counter = 1, #jsonLevels.levels do
		local levelName = jsonLevels.levels[counter]
		LEVELS[counter] = cLevel.new(levelName, jsonLevels[levelName])
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

	f:close()
end

function LoadLanguageFiles()
	if not cFile:IsFile(PATH_PLUGIN_DATA .. "/languages/english.ini") then
		if not cFile:IsFolder(PATH_PLUGIN_DATA .. "/languages/") then
			cFile:CreateFolder(PATH_PLUGIN_DATA .. "/languages/")
		end

		-- Copy other language files
		local files = cFile:GetFolderContents(PLUGIN:GetLocalFolder() .. "/languages")
		for _, file in pairs(files) do
			if (string.sub(file, #file -3, #file) == ".ini") then
				if not cFile:IsFile(PATH_PLUGIN_DATA .. "/languages/" .. file) then
					cFile:Copy(PLUGIN:GetLocalFolder() .. "/languages/" .. file, PATH_PLUGIN_DATA .. "/languages/" .. file)
				end
			end
		end

		-- Write english language file
		LANGUAGES["english.ini"] = cLanguage.new()

		if (LANGUAGE_DEFAULT ~= "english.ini") then
			LANGUAGES[LANGUAGE_DEFAULT] = cLanguage.new(LANGUAGE_DEFAULT)
		end
	    return
	end

	if (LANGUAGE_OTHERS) then
		local files = cFile:GetFolderContents(PATH_PLUGIN_DATA .. "/languages")
		for i = 1, #files do
	        if (cFile:IsFile(PATH_PLUGIN_DATA .. "/languages/" .. files[i])) then
	            LANGUAGES[files[i]] = cLanguage.new(files[i])
	        end
	    end
	else
	    LANGUAGES[LANGUAGE_DEFAULT] = cLanguage.new(LANGUAGE_DEFAULT)
	end
end

function LoadLuaFiles()
	local folders =  { "/code", "/code/classes", "/code/commands", "/code/API" }

	for _, folder in pairs(folders) do
		local files = cFile:GetFolderContents(PLUGIN:GetLocalFolder() .. folder)
		for _, file in pairs(files) do
			if (string.sub(file, #file -3, #file) == ".lua") then
				dofile(PLUGIN:GetLocalFolder() .. folder .. "/" .. file)
			end
		end
	end
end
