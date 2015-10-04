-- Stores informations of the player

cPlayerInfo = {}
cPlayerInfo.__index = cPlayerInfo

function cPlayerInfo.new(a_Player)
	local self = setmetatable({}, cPlayerInfo)

	self.m_PlayerUUID = a_Player:GetUUID()
	self.m_PlayerName = a_Player:GetName()
	self.m_IslandNumber = -1 -- Set to -1 for no island
	self.m_PlayerFile = PLUGIN:GetLocalFolder() .. "/players/" .. a_Player:GetUUID() .. ".ini"
	self.m_IsLevel = LEVELS[1].m_LevelName -- Set first level
	self.m_CompletedChallenges = {}
	self.m_CompletedChallenges[self.m_IsLevel] = {}
	self.m_InFriendList = {}
	self.m_IsRestarting = false
	self.m_Language = ""

	self:Load(a_Player) -- Check if there is a player file, if yes load it
	if (self.m_IslandNumber ~= -1) then -- Load island file
		GetIslandInfo(self.m_IslandNumber)
	end
	return self
end

-- Check if player has completed the challenge
function cPlayerInfo:HasCompleted(a_LevelName, a_ChallengeName)
	if (self.m_CompletedChallenges[a_LevelName] == nil) then
		return false
	end

	if (self.m_CompletedChallenges[a_LevelName][a_ChallengeName] == nil) then
		return false
	end

	return true
end

-- Add the player to the friend list
function cPlayerInfo:AddEntry(a_IslandNumber, a_Player)
	local s = a_Player:GetName():lower()

	if (self.m_InFriendList[s] == nil) then
		self.m_InFriendList[s] = {}
		self.m_InFriendList[s][1] = a_Player:GetUUID()
		self.m_InFriendList[s][2] = a_IslandNumber
	end
end

-- Remove the player from the friend list
function cPlayerInfo:RemoveEntry(a_PlayerName)
	if (self.m_InFriendList[a_PlayerName:lower()] == nil) then
		return false
	end

	self.m_InFriendList[a_PlayerName] = nil
	return true
end

-- Check if the player can interact at the position
function cPlayerInfo:HasPermissionThere(a_BlockX, a_BlockZ)
	local islandNumber = GetIslandNumber(a_BlockX, a_BlockZ)
	if (islandNumber == 0) then
		return false
	end

	local islandInfo = GetIslandInfo(islandNumber)
	if (islandInfo == nil) then
		return false
	end

	if (islandInfo.m_OwnerUUID == self.m_PlayerUUID) then
		return true
	end

	if (islandInfo.m_Friends[self.m_PlayerUUID] == nil) then
		return false
	end

	return true
end

-- Save PlayerInfo
function cPlayerInfo:Save()
	if (self.m_IslandNumber == -1) then -- Only save player info, if he has or is on a friends island
		return
	end

	local PlayerInfoIni = cIniFile()
	PlayerInfoIni:SetValue("Player", "Name", self.m_PlayerName, true)
	PlayerInfoIni:SetValue("Island", "Number", self.m_IslandNumber, true)
	PlayerInfoIni:SetValue("Player", "Language", self.m_Language, true)

	for i = 1, #LEVELS do
		local res = ""
		local first = true
		if (self.m_CompletedChallenges[LEVELS[i].m_LevelName] == nil) then
			break
		end

		for index, _ in pairs(self.m_CompletedChallenges[LEVELS[i].m_LevelName]) do
			if (first) then
				first = false
			else
				res = res .. ":"
			end
			res = res .. index;
		end

		PlayerInfoIni:SetValue("Completed", LEVELS[i].m_LevelName, res, true)
	end
	PlayerInfoIni:SetValue("Player", "IsLevel", self.m_IsLevel, true)

	local amount = GetAmount(self.m_InFriendList)
	if (amount > 0) then
		local list = ""
		local counter = 0
		for player, _ in pairs(self.m_InFriendList) do
			list = list .. player .. ":" .. self.m_InFriendList[player][1] .. ":" .. self.m_InFriendList[player][2]
			if (counter ~= amount) then
				list = list .. " "
			end
		end
		PlayerInfoIni:SetValue("Player", "InFriendList", list, true)
	end

	PlayerInfoIni:WriteFile(self.m_PlayerFile)
end

-- Load PlayerInfo
function cPlayerInfo:Load(a_Player)
	local PlayerInfoIni = cIniFile()

	if (not PlayerInfoIni:ReadFile(self.m_PlayerFile)) then
		return
	end

	self.m_IslandNumber = PlayerInfoIni:GetValueI("Island", "Number")

	for level_index = 1, #LEVELS do
		self.m_CompletedChallenges[LEVELS[level_index].m_LevelName] = {}
		local list = PlayerInfoIni:GetValue("Completed", LEVELS[level_index].m_LevelName)
		if (list == nil) then
			break
		end

		local values = StringSplit(list, ":")
		for i = 1, #values do
			self.m_CompletedChallenges[LEVELS[level_index].m_LevelName][values[i]] = true
		end
	end

	self.m_IsLevel = PlayerInfoIni:GetValue("Player", "IsLevel")
	if (self.m_IsLevel == "") then
		self.m_IsLevel = LEVELS[1].m_LevelName
	end

	self.m_Language = PlayerInfoIni:GetValue("Player", "Language")
	if (self.m_Language == "") then
		self.m_Language = "english.ini"
	end

	local temp = PlayerInfoIni:GetValue("Player", "InFriendList")
	if (temp ~= "") then
		temp = StringSplit(temp, " ")
		for i = 1, #temp do
			local entry = StringSplit(temp[i], ":")
			self.m_InFriendList[entry[1]] = {}
			self.m_InFriendList[entry[1]][1] = entry[2]
			self.m_InFriendList[entry[1]][2] = entry[3]
		end
	end
end
