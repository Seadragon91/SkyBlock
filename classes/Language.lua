-- Lannguage file

cLanguage = {}
cLanguage.__index = cLanguage

-- Load language file
function cLanguage.new(a_Language)
	local self = setmetatable({}, cLanguage)

	self.Create(self)

	if (a_Language == nil) then
		self.m_Language = "english.ini"
	else
		self.m_Language = a_Language
	end
	self.Load(self)
	return self
end

function cLanguage:Create()
	self.m_Sentences = {}
	self.m_Indexes = {}

	-- cmd_SkyBlock.lua

	-- skyblock = 1
	self.m_Indexes[1] = {}
	self.m_Indexes[1][1] = "skyblock"
	self.m_Sentences[1] = {}

	-- General = 2
	self.m_Indexes[1][2] = "General"
	self.m_Sentences[1][2] = {}
	self.m_Sentences[1][2]["skyblock"] = "Command for the skyblock plugin. Type skyblock help for a list of commands and arguments."
	self.m_Sentences[1][2]["noPermission"] = "You don't have the permission for that command."
	self.m_Sentences[1][2]["unknownArg"] = "Unknown argument."

	-- Help = 3
	self.m_Indexes[1][3] = "Help"
	self.m_Sentences[1][3] = {}
	self.m_Sentences[1][3]["title"] = "--- Commands for the skyblock plugin ---"
	self.m_Sentences[1][3]["1"] = "/skyblock join - Join the world skyblock and comes to a spawn platform."
	self.m_Sentences[1][3]["2"] = "/skyblock play - Get an island and start playing."

	self.m_Sentences[1][3]["3"] = "/challenges - List all challenges"
	self.m_Sentences[1][3]["4"] = "/challenges info <name> - Shows informations to the challenge"
	self.m_Sentences[1][3]["5"] = "/challenges complete <name> - Complete the challenge"

	self.m_Sentences[1][3]["6"] = "/island home - Teleport back to your home location of the island"
	self.m_Sentences[1][3]["7"] = "/island home set - Change home location on island"
	self.m_Sentences[1][3]["8"] = "/island obsidian - Change obsidian backt to lava"
	self.m_Sentences[1][3]["9"] = "/island add <player> - Add player to your friend list"
	self.m_Sentences[1][3]["10"] = "/island remove <player> - Remove player from your friend list"
	self.m_Sentences[1][3]["11"] = "/island join <player> - Teleport to a friends island"
	self.m_Sentences[1][3]["12"] = "/island list - List your friends and islands who you can join"
	self.m_Sentences[1][3]["13"] = "/island restart - Start an new island"

	-- Join = 4
	self.m_Indexes[1][4] = "Join"
	self.m_Sentences[1][4] = {}
	self.m_Sentences[1][4]["welcomeBack"] = "Welcome back to the spawn platform."
	self.m_Sentences[1][4]["welcome"] = "Welcome to the world skyblock. Type /skyblock play to get an island."
	self.m_Sentences[1][4]["missingWorld"] = "Command failed. Couldn't find the world %1."

	-- Play = 5
	self.m_Indexes[1][5] = "Play"
	self.m_Sentences[1][5] = {}
	self.m_Sentences[1][5]["welcome"] = "Welcome to your island. Do not fall and make no obsidian :-)"
	self.m_Sentences[1][5]["welcomeBack"] = "Welcome back %1"
	self.m_Sentences[1][5]["welcomeTo"] = "Welcome to the island from %1!" -- functions.lua	

	-- Recreate = 6
	self.m_Indexes[1][6] = "Recreate"
	self.m_Sentences[1][6] = {}
	self.m_Sentences[1][6]["recreatedSpawn"] = "Recreated spawn from schematic file."
	self.m_Sentences[1][6]["schematicError"] = "Schematic not found or error occurred."

	-- Language = 7
	self.m_Indexes[1][7] = "Language"
	self.m_Sentences[1][7] = {}
	self.m_Sentences[1][7]["languageFiles"] = "Language files: %1"
	self.m_Sentences[1][7]["unknownLanguage"] = "There is no language file with that name."
	self.m_Sentences[1][7]["changedLanguage"] = "Changed language to %1."


	-- cmd_Challenges.lua

	-- challenges = 2.1
	self.m_Indexes[2] = {}
	self.m_Indexes[2][1] = "challenges"
	self.m_Sentences[2] = {}

	-- General = 2
	self.m_Indexes[2][2] = "General"
	self.m_Sentences[2][2] = {}
	self.m_Sentences[2][2]["level"] = "--- Level: %1 ---"
	self.m_Sentences[2][2]["lockedLevels"] = "Locked levels: "
	self.m_Sentences[2][2]["unknownName"] = "There is no challenge with that name."
	self.m_Sentences[2][2]["unknownArg"] = "Unknwown argument."

	-- Info = 3
	self.m_Indexes[2][3] = "Info"
	self.m_Sentences[2][3] = {}
	self.m_Sentences[2][3]["gatherItems"] = cChatColor.LightGreen .. "Gather this items: " .. cChatColor.White
	self.m_Sentences[2][3]["forCompletion"] = cChatColor.Gold .. "You get for completion: " .. cChatColor.White
	self.m_Sentences[2][3]["forRepeating"] = "For repeating:"

	-- Complete = 4
	self.m_Indexes[2][4] = "Complete"
	self.m_Sentences[2][4] = {}
	self.m_Sentences[2][4]["noIsland"] = "You have no island. Type /skyblock play first."
	self.m_Sentences[2][4]["unknownName"] = "Unknown challenge name."

	-- Check = 5
	self.m_Indexes[2][5] = "Check"
	self.m_Sentences[2][5] = {}
	self.m_Sentences[2][5]["noRepeatableItems"] = "This challenge has no repeatable items."
	self.m_Sentences[2][5]["gotRequiredItems"] = "You got the required items."
	self.m_Sentences[2][5]["gotRewardItems"] = "You got the reward items."

	-- ChallengeInfo.lua
	self.m_Sentences[2][4]["notLevel"] = "You don't have the level to complete that challenge."
	self.m_Sentences[2][4]["notRepeatable"] = "This challenge is not repeatable."
	self.m_Sentences[2][4]["repeated"] = "Congrats you repeated the challenge %1."
	self.m_Sentences[2][4]["completed"] = "Congrats you completed the challenge %1."
	self.m_Sentences[2][4]["allLevels"] = "You completed all levels and all challenges."
	self.m_Sentences[2][4]["nextLevel"] = "Congrats. You unlocked next level %1."

	-- ChallengeItems.lua
	self.m_Sentences[2][4]["notRequiredItems"] = "You don't have the required items."
	self.m_Sentences[2][4]["itemsInfo"] = "Gather this items: "

	-- ChallengeValues.lua
	self.m_Sentences[2][4]["calculated"] = "Your island value is %1, you need %2 for completing."
	self.m_Sentences[2][4]["calculatingWait"] = "Your island value is already calculating. Please wait..."
	self.m_Sentences[2][4]["calculatingStarted"] = "Your island value is calculating..."
	self.m_Sentences[2][4]["valueInfo"] = "Reach that island value: "


	-- cmd_Island.lua

	-- island = 3.1
	self.m_Indexes[3] = {}
	self.m_Indexes[3][1] = "island"
	self.m_Sentences[3] = {}

	-- General = 2
	self.m_Indexes[3][2] = "General"
	self.m_Sentences[3][2] = {}
	self.m_Sentences[3][2]["noIsland"] = "You have no island. Type /skyblock play first."
	self.m_Sentences[3][2]["unknownArg"] = "Unknown argument."
	self.m_Sentences[3][2]["notHere"] = "This command works only in the world %1."
	self.m_Sentences[3][2]["missingWorld"] = "Command failed. Couldn't find the world %1."
	self.m_Sentences[3][2]["noPlayer"] = "There is no player with that name."

	-- Home = 3
	self.m_Indexes[3][3] = "Home"
	self.m_Sentences[3][3] = {}
	self.m_Sentences[3][3]["set_ownIsland"] = "You can use this command only on your own island."
	self.m_Sentences[3][3]["set_changed"] = "Island home location changed."
	self.m_Sentences[3][3]["welcomeBack"] = "Welcome back %1."

	-- Obsidian = 4
	self.m_Indexes[3][4] = "Obsidian"
	self.m_Sentences[3][4] = {}
	self.m_Sentences[3][4]["right-Click"] = "Make now an right-click on the obsidian block without any items."

	-- Add = 5
	self.m_Indexes[3][5] = "Add"
	self.m_Sentences[3][5] = {}
	self.m_Sentences[3][5]["addedPlayer"] = "Added player %1 to your island."

	-- Remove = 6
	self.m_Indexes[3][6] = "Remove"
	self.m_Sentences[3][6] = {}
	self.m_Sentences[3][6]["removedPlayer"] = "Removed player from friend list."

	-- Join = 7
	self.m_Indexes[3][7] = "Join"
	self.m_Sentences[3][7] = {}
	self.m_Sentences[3][7]["notInFriendlist"] = "You are not in his friend list."
	self.m_Sentences[3][7]["removedFromFriendList"] = "You have been removed from his friend list."
	self.m_Sentences[3][7]["toIsland"] = "Teleported you to the island."

	-- List = 8
	self.m_Indexes[3][8] = "List"
	self.m_Sentences[3][8] = {}
	self.m_Sentences[3][8]["friends"] = "Your friends: "
	self.m_Sentences[3][8]["canEnter"] = "Islands you can enter: "

	-- Restart = 9
	self.m_Indexes[3][9] = "Restart"
	self.m_Sentences[3][9] = {}
	self.m_Sentences[3][9]["running"] = "This command is running. Please wait..."
	self.m_Sentences[3][9]["notOwner"] = "Restart not possible, you are not the real owner of this island. If you want to start an own one, type again /island restart."
	self.m_Sentences[3][9]["wait"] = "Please wait 10s..."
	self.m_Sentences[3][9]["newIsland"] = "Good luck with your new island."

	-- Events.lua
	self.m_Indexes[4] = {}
	self.m_Indexes[4][1] = "nocommand"
	self.m_Sentences[4] = {}

	self.m_Indexes[4][2] = "Messages"
	self.m_Sentences[4][2] = {}
	self.m_Sentences[4][2]["spawnArea"] = "This is the spawn area."
	self.m_Sentences[4][2]["unknownArea"] = "Unknown area."
	self.m_Sentences[4][2]["islandNumber"] = "Island number: %1"
	self.m_Sentences[4][2]["islandOwner"] = "Island owner: %1"
	self.m_Sentences[4][2]["friends"] = "Friends: "
	self.m_Sentences[4][2]["obsidianToLava"] = "Changed obsidian back to lava"
	self.m_Sentences[4][2]["languageCommand"] = "Use the command /skyblock language for a list of language files."
end

function cLanguage:WriteDefault()
	local languageIni = cIniFile()

	for cmd = 1, #self.m_Indexes do
		for arg = 2, #self.m_Indexes[cmd] do
			for path, sentence in pairs(self.m_Sentences[cmd][arg]) do
				languageIni:SetValue(self.m_Indexes[cmd][1] .. ":" .. self.m_Indexes[cmd][arg], path, sentence, true)
			end
		end
	end

	languageIni:WriteFile(PLUGIN:GetLocalFolder() .. "/languages/" .. self.m_Language)
end

function cLanguage:Load()
	local languageIni = cIniFile()
	if (languageIni:ReadFile(PLUGIN:GetLocalFolder() .. "/languages/" .. self.m_Language) == false) then
		self.WriteDefault(self)
		return
	end

	local toWrite = false
	for cmd = 1, #self.m_Indexes do
		for arg = 2, #self.m_Indexes[cmd] do
			for path, sentence in pairs(self.m_Sentences[cmd][arg]) do
				local temp = languageIni:GetValue(self.m_Indexes[cmd][1] .. ":" .. self.m_Indexes[cmd][arg], path)
				if (temp == "") then
					toWrite = true
					languageIni:SetValue(self.m_Indexes[cmd][1] .. ":" .. self.m_Indexes[cmd][arg], path, sentence, true)
				else
					self.m_Sentences[cmd][arg][path] = temp
				end
			end
		end
	end

	if (toWrite) then
		languageIni:WriteFile(PLUGIN:GetLocalFolder() .. "/languages/" .. self.m_Language)
	end
end

function cLanguage:Get(a_Command, a_Argument, a_Path, a_Replacement)
	if (a_Replacement == nil) then
		return self.m_Sentences[a_Command][a_Argument][a_Path]
	end

	local newSentence = self.m_Sentences[a_Command][a_Argument][a_Path]
	for find, replace in pairs(a_Replacement) do
		newSentence = string.gsub(newSentence, "%" .. find, replace)
	end

	return newSentence
end

function cLanguage:GetChatColor(a_Str)
	local char = string.sub(a_Str, 2, -1)
	if (char == "0") then
		return cChatColor.Black
	elseif (char == "1") then
		return cChatColor.Blue
	elseif (char == "2") then
		return cChatColor.Bold
	elseif (char == "3") then
		return cChatColor.DarkPurple
	elseif (char == "4") then
		return cChatColor.Gold
	elseif (char == "5") then
		return cChatColor.Gray
	elseif (char == "6") then
		return cChatColor.Green
	elseif (char == "7") then
		return cChatColor.Italic
	elseif (char == "8") then
		return cChatColor.LightBlue
	elseif (char == "9") then
		return cChatColor.LightGray
	elseif (char == "a") then
		return cChatColor.LightGreen
	elseif (char == "b") then
		return cChatColor.LightPurple
	elseif (char == "c") then
		return cChatColor.Navy
	elseif (char == "d") then
		return cChatColor.Purple
	elseif (char == "e") then
		return cChatColor.Random
	elseif (char == "f") then
		return cChatColor.Red
	elseif (char == "g") then
		return cChatColor.Rose
	elseif (char == "h") then
		return cChatColor.Strikethrough
	elseif (char == "i") then
		return cChatColor.Underlined
	elseif (char == "j") then
		return cChatColor.White
	elseif (char == "k") then
		return cChatColor.Yellow
	end
end


-- Chat colors
-- 0	Black
-- 1	Blue
-- 2	Bold
-- 3	DarkPurple
-- 4	Gold
-- 5	Gray
-- 6	Green
-- 7	Italic
-- 8	LightBlue
-- 9	LightGray
-- a	LightGreen
-- b	LightPurple
-- c	Navy
-- d	Purple
-- e	Random
-- f	Red
-- g	Rose
-- h	Strikethrough
-- i	Underlined
-- j	White
-- k	Yellow
