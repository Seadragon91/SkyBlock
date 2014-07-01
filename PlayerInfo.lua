-- Stores informations of the player

cPlayerInfo = {}
cPlayerInfo.__index = cPlayerInfo

function cPlayerInfo.new(a_PlayerName)
	local self = setmetatable({}, cPlayerInfo)
	
	self.playerName = a_PlayerName
    self.islandNumber = -1 -- Set to -1 for no island
    self.playerFile = PLUGIN:GetLocalDirectory() .. "/players/" .. a_PlayerName .. ".ini"
    
    self.Load(self) -- Check if there is a player file, if yes load it
	return self
end

function cPlayerInfo.GetPlayerName(self)
	return self.playerName
end

function cPlayerInfo.SetIslandNumber(self, a_IslandNumber)
    self.islandNumber = a_IslandNumber
end

function cPlayerInfo.GetIslandNumber(self)
	return self.islandNumber
end

function cPlayerInfo.Save(self) -- Save PlayerInfo
    local PlayerInfoIni = cIniFile()
	PlayerInfoIni:SetValue("Player", "Name", self.playerName, true)
	PlayerInfoIni:SetValue("Island", "Number", self.islandNumber, true)
	PlayerInfoIni:WriteFile(self.playerFile)
end

function cPlayerInfo.Load(self) -- Load PlayerInfo
    local PlayerInfoIni = cIniFile()
	if (PlayerInfoIni:ReadFile(self.playerFile) == false) then
        return
    end
    
	self.islandNumber = PlayerInfoIni:GetValueI("Island", "Number")
end
