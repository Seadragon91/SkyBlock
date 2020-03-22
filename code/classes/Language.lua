-- Language file

cLanguage = {}
cLanguage.__index = cLanguage

-- Load language file
function cLanguage.new(a_Language)
	local self = setmetatable({}, cLanguage)

	self:Create()

	if (a_Language == nil) then
		self.m_Language = "english.ini"
	else
		self.m_Language = a_Language
	end

	self:Load()
	return self
end

function cLanguage:Create()
	self.m_Sentences = {}
	self.m_Indexes = {}

	-- cmd_SkyBlock.lua

	-- skyblock
	self.m_Sentences.skyblock = {}

	self.m_Sentences.skyblock.general = {}
	self.m_Sentences.skyblock.general.skyblock = "Command for the skyblock plugin. Type /skyblock help for a list of commands and arguments."
	self.m_Sentences.skyblock.general.noPermission = "You don't have the permission for this command."
	self.m_Sentences.skyblock.general.unknownArg = "Unknown argument."

	-- Help
	self.m_Sentences.skyblock.help = {}
	self.m_Sentences.skyblock.help.title = "--- " .. cChatColor.Green .. "Commands for the skyblock plugin" .. cChatColor.White .. " ---"
	self.m_Sentences.skyblock.help.join = "/skyblock join - Teleports you to the spawn platform of the skyblock world."
	self.m_Sentences.skyblock.help.play = "/skyblock play - Get an island and start playing."

	self.m_Sentences.skyblock.help.isHome = "/island home - Teleport back to your island"
	self.m_Sentences.skyblock.help.isHomeSet = "/island home set - Change your island home location"
	self.m_Sentences.skyblock.help.isObsidian = "/island obsidian - Change obsidian back to lava"
	self.m_Sentences.skyblock.help.isAddFriend = "/island add <player> - Add a player to your friend list"
	self.m_Sentences.skyblock.help.isAddGuest = "/island inv <player> - Invite a player as a guest"
	self.m_Sentences.skyblock.help.isInviteAsk = "/island ask <player> - Ask the player if you can visit his island"
	self.m_Sentences.skyblock.help.IsRemove = "/island remove <player> - Remove a player from your friend list"
	self.m_Sentences.skyblock.help.IsJoin = "/island join <player> - Teleport to a friends island"
	self.m_Sentences.skyblock.help.isList = "/island list - List your friends and islands who you can join"
	self.m_Sentences.skyblock.help.isRestart = "/island restart - Start an new island"

	self.m_Sentences.skyblock.help.challenges = "/challenges - Opens the challenge window"

	-- Join
	self.m_Sentences.skyblock.join = {}
	self.m_Sentences.skyblock.join.welcomeBack = "Welcome back to the spawn platform."
	self.m_Sentences.skyblock.join.welcome = "Welcome to the world skyblock. Type /skyblock play to get an island."
	self.m_Sentences.skyblock.join.missingWorld = "Command failed. Couldn't find the world %1."

	-- Play
	self.m_Sentences.skyblock.play = {}
	self.m_Sentences.skyblock.play.welcome = "Welcome to your island. Do not fall and make no obsidian :-)"
	self.m_Sentences.skyblock.play.welcomeBack = "Welcome back %1"
	self.m_Sentences.skyblock.play.welcomeTo = "Welcome to the island from %1." -- functions.lua

	-- Recreate
	self.m_Sentences.skyblock.recreate = {}
	self.m_Sentences.skyblock.recreate.recreatedSpawn = "Recreated spawn from schematic file."
	self.m_Sentences.skyblock.recreate.schematicError = "Schematic not found or error occurred."

	-- Language
	self.m_Sentences.skyblock.language = {}
	self.m_Sentences.skyblock.language.languageFiles = "Language files: %1"
	self.m_Sentences.skyblock.language.unknownLanguage = "There is no language file with that name."
	self.m_Sentences.skyblock.language.changedLanguage = "Changed language to %1."

	-- challenges
	self.m_Sentences.challenges = {}

	-- ChallengeInfo.lua
	self.m_Sentences.challenges.info = {}
	self.m_Sentences.challenges.info.notLevel = "You don't have the level to complete that challenge."
	self.m_Sentences.challenges.info.repeated = "Congrats you repeated the challenge %1."
	self.m_Sentences.challenges.info.completed = "Congrats you completed the challenge %1."
	self.m_Sentences.challenges.info.allLevels = "You completed all levels and all challenges."
	self.m_Sentences.challenges.info.nextLevel = "Congrats. You unlocked next level %1."
	self.m_Sentences.challenges.info.itemsDropped = "Reward items dropped, as your inventory had not enough place."

	-- ChallengeWindow.lua
	self.m_Sentences.challenges.window = {}
	self.m_Sentences.challenges.window.title = cChatColor.Green .. "Challenges"
	self.m_Sentences.challenges.window.isRepeatable = cChatColor.LightBlue .. "This challenge is repeatable"
	self.m_Sentences.challenges.window.isCompleted = cChatColor.LightPurple .. "This challenge has been completed"
	self.m_Sentences.challenges.window.requiredItems = cChatColor.Yellow .. "This items are required:"
	self.m_Sentences.challenges.window.requiredIslandValue = cChatColor.Yellow .. "This island value is required:"
	self.m_Sentences.challenges.window.requiredBlocks = cChatColor.Gray .. "This blocks are required:"
	self.m_Sentences.challenges.window.reward = cChatColor.Green .. "Reward"
	self.m_Sentences.challenges.window.clickToComplete = cChatColor.Yellow .. "Click to complete this challenge"
	self.m_Sentences.challenges.window.goBack = cChatColor.LightBlue .. "Click to go back"
	self.m_Sentences.challenges.window.goForward = cChatColor.LightBlue .. "Click to go forward"
	self.m_Sentences.challenges.window.moreToUnlock = cChatColor.Yellow .. "Complete %1 more to unlock"
	self.m_Sentences.challenges.window.nextLevel = cChatColor.LightBlue .. "Next Level: " .. cChatColor.Green .. " %1"
	self.m_Sentences.challenges.window.levelInfo = cChatColor.LightBlue .. "Level: " .. cChatColor.Green .. "%1"

	-- ChallengeValues.lua
	self.m_Sentences.challenges.value = {}
	self.m_Sentences.challenges.value.calculated = "Your island value is %1, you need %2 for completing."
	self.m_Sentences.challenges.value.calculatingWait = "Calculating your island value already. Please wait..."
	self.m_Sentences.challenges.value.calculatingStarted = "Calculating your island value..."

	-- ChallengeBlocks.lua
	self.m_Sentences.challenges.blocks = {}
	self.m_Sentences.challenges.blocks.checkingStarted = "Checking the island for the blocks. Please wait..."
	self.m_Sentences.challenges.blocks.checkingWait = "Checking your island for the blocks already. Please wait..."
	self.m_Sentences.challenges.blocks.checked = "This blocks are missing: %1"

	-- ChallengeLocation.lua
	-- self.m_Sentences[2][4]["locationInfo"] = "Reach that location: "

	-- cmd_Island.lua

	-- island
	self.m_Sentences.island = {}

	-- General
	self.m_Sentences.island.general = {}
	self.m_Sentences.island.general.noIsland = "You have no island. Type /skyblock play first."
	self.m_Sentences.island.general.unknownArg = "This command is unknown. Type /skyblock help for a list of commands and arguments."
	self.m_Sentences.island.general.notHere = "This command only works in the world %1."
	self.m_Sentences.island.general.noPlayer = "There is no player with that name."

	-- Home
	self.m_Sentences.island.home = {}
	self.m_Sentences.island.home.set_ownIsland = "You can use this command only on your own island."
	self.m_Sentences.island.home.set_changed = "Your islands home location has been changed."
	self.m_Sentences.island.home.welcomeBack = "Welcome back %1."

	-- Obsidian
	self.m_Sentences.island.obsidian = {}
	self.m_Sentences.island.obsidian.right_Click = "Make now an right-click on the obsidian block without any items."

	-- Add
	self.m_Sentences.island.add = {}
	self.m_Sentences.island.add.addedPlayer = "Added player %1 to your island."

	-- Remove
	self.m_Sentences.island.remove = {}
	self.m_Sentences.island.remove.removedPlayer = "Removed player from friend list."

	-- Inv
	self.m_Sentences.island.inv = {}
	self.m_Sentences.island.inv.playerSend = "The player %1 has sent you a invite."
	self.m_Sentences.island.inv.inviteSend = "Send a invite to player %1."

	-- Req
	self.m_Sentences.island.ask = {}
	self.m_Sentences.island.ask.inviteAsk = "The player %1 wants to visit your island. Use /island inv <player> to invite him."

	-- Join
	self.m_Sentences.island.join = {}
	self.m_Sentences.island.join.notInFriendlist = "You are not invited or not in his friend list."
	self.m_Sentences.island.join.removedFromFriendList = "You have been removed from his friend list."
	self.m_Sentences.island.join.toIsland = "Teleported you to the island."

	-- List
	self.m_Sentences.island.list = {}
	self.m_Sentences.island.list.friends = "Your friends: "
	self.m_Sentences.island.list.canEnter = "Islands you can enter: "

	-- Restart
	self.m_Sentences.island.restart = {}
	self.m_Sentences.island.restart.running = "This command is running. Please wait..."
	self.m_Sentences.island.restart.notOwner = "Restart not possible, you are not the real owner of this island. If you want to start an own one, type again /island restart."
	self.m_Sentences.island.restart.wait = "Please wait up to %1s..."
	self.m_Sentences.island.restart.newIsland = "Good luck with your new island."

	-- Events.lua
	self.m_Sentences.nocommand = {}

	self.m_Sentences.nocommand.messages = {}
	self.m_Sentences.nocommand.messages.spawnArea = "This is the spawn area."
	self.m_Sentences.nocommand.messages.unknownArea = "Unknown area."
	self.m_Sentences.nocommand.messages.islandNumber = "Island number: %1"
	self.m_Sentences.nocommand.messages.islandOwner = "Island owner: %1"
	self.m_Sentences.nocommand.messages.friends = "Friends: "
	self.m_Sentences.nocommand.messages.obsidianToLava = "Changed obsidian back to lava"
	self.m_Sentences.nocommand.messages.languageCommand = "Use the command /skyblock language for a list of language files."

end

function cLanguage:WriteDefault()
	local languageIni = cIniFile()

	for baseKey, tbBaseSentences in pairs(self.m_Sentences) do
		for subKey, tbSentences in pairs(tbBaseSentences) do
			for path, sentence in pairs(tbSentences) do
				languageIni:SetValue(baseKey .. ":" .. subKey, path, sentence, true)
			end
		end
	end

	languageIni:WriteFile(PATH_PLUGIN_DATA .. "/languages/" .. self.m_Language)
end

function cLanguage:Load()
	local languageIni = cIniFile()
	if (not languageIni:ReadFile(PATH_PLUGIN_DATA .. "/languages/" .. self.m_Language)) then
		self:WriteDefault()
		return
	end

	local toWrite = false
	for baseKey, tbBaseSentences in pairs(self.m_Sentences) do
		for subKey, tbSentences in pairs(tbBaseSentences) do
			for path, sentence in pairs(tbSentences) do
				local temp = languageIni:GetValue(baseKey .. ":" .. subKey, path)
				if (temp == "") then
					toWrite = true
					languageIni:SetValue(baseKey .. ":" .. subKey, path, sentence, true)
				else
					self.m_Sentences[baseKey][subKey][path] = temp
				end
			end
		end
	end

	if (toWrite) then
		languageIni:WriteFile(PATH_PLUGIN_DATA .. "/languages/" .. self.m_Language)
	end
end

function cLanguage:Get(a_Path, a_Replacement)
	local arr = StringSplit(a_Path, ".")
	local baseKey = arr[1]
	local subKey = arr[2]
	local path = arr[3]

	if (a_Replacement == nil) then
		return self.m_Sentences[baseKey][subKey][path]
	end

	local newSentence = self.m_Sentences[baseKey][subKey][path]
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
