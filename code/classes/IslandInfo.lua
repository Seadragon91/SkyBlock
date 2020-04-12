-- Stores informations of an island

cIslandInfo = {}
cIslandInfo.__index = cIslandInfo

-- Create Island info
function cIslandInfo.new(a_IslandNumber)
	local self = setmetatable({}, cIslandInfo)

	self.m_IslandFile = PATH_PLUGIN_DATA .. "/islands/" .. a_IslandNumber .. ".ini"
	self.m_IslandNumber = tonumber(a_IslandNumber)
	self.m_Friends = {}
	self.m_Guests = {}
	self.m_HomeLocation = nil

	return self
end

function cIslandInfo:SetOwner(a_Player)
	self.m_OwnerUUID = a_Player:GetUUID()
	self.m_OwnerName = a_Player:GetName()
end

-- Add friend to list
function cIslandInfo:AddFriend(a_Player)
	if (self.m_Friends[a_Player:GetUUID()] == nil) then
		self.m_Friends[a_Player:GetUUID()] = a_Player:GetName():lower()
	end
end

-- Remove friend from list
function cIslandInfo:RemoveFriend(a_PlayerName)
	local hasUUID = ""
	for uuid, playerName in pairs(self.m_Friends) do
		if (playerName == a_PlayerName:lower()) then
			hasUUID = uuid
			break
		end
	end

	if (hasUUID == "") then
		return false
	end

	self.m_Friends[hasUUID] = nil
	return true
end

-- Check if player name is in list
function cIslandInfo:ContainsFriend(a_PlayerName)
	for _, playerName in pairs(self.m_Friends) do
		if (a_PlayerName:lower() == playerName) then
			return true
		end
	end
	return false
end

-- Saves the island info
function cIslandInfo:Save()
	local IslandInfoIni = cIniFile()

	IslandInfoIni:SetValueI("General", "IslandNumber", self.m_IslandNumber, true)
	IslandInfoIni:SetValue("General", "OwnerUUID", self.m_OwnerUUID, true)
	IslandInfoIni:SetValue("General", "OwnerName", self.m_OwnerName, true)
	if (self.m_HomeLocation ~= nil) then
		IslandInfoIni:SetValue("General", "HomeLocation", table.concat(self.m_HomeLocation, " "))
	end

	local amount = GetAmount(self.m_Friends)
	if (amount > 0) then
		local list = ""
		local counter = 0
		for uuid, playerName in pairs(self.m_Friends) do
			counter = counter + 1
			list = list .. uuid .. ":" .. playerName
			if (counter ~= amount) then
				list = list .. " "
			end
		end
		IslandInfoIni:SetValue("General", "Friends", list, true)
	end

	IslandInfoIni:WriteFile(self.m_IslandFile)
end

-- Load the island info
function cIslandInfo:Load()
	local IslandInfoIni = cIniFile()

	if (not IslandInfoIni:ReadFile(self.m_IslandFile)) then
		return false
	end

	self.m_OwnerUUID = IslandInfoIni:GetValue("General", "OwnerUUID")
	self.m_OwnerName = IslandInfoIni:GetValue("General", "OwnerName")

	local temp = IslandInfoIni:GetValue("General", "HomeLocation")
	if (temp ~= "") then
		self.m_HomeLocation = StringSplit(temp, " ")
	end

	temp = IslandInfoIni:GetValue("General", "Friends")
	if (temp ~= "") then
		temp = StringSplit(temp, " ")
		for i = 1, #temp do
			local player = StringSplit(temp[i], ":")
			self.m_Friends[player[1]] = player[2]
		end
	end
	return true
end
