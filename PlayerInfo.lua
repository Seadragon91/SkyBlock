-- Stores informations of the player

cPlayerInfo = {}
cPlayerInfo.__index = cPlayerInfo

function cPlayerInfo.new(a_PlayerName)
    local self = setmetatable({}, cPlayerInfo)
    
    self.playerName = a_PlayerName
    self.islandNumber = -1 -- Set to -1 for no island
    self.playerFile = PLUGIN:GetLocalDirectory() .. "/players/" .. a_PlayerName .. ".ini"
    self.completedChallenges = {}
    
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

function cPlayerInfo.SetIsRestarting(self, a_IsRestarting)
    self.isRestarting = a_IsRestarting
end

function cPlayerInfo.GetIsRestarting(self)
    return self.isRestarting
end

function cPlayerInfo.Save(self) -- Save PlayerInfo
    if (self.islandNumber == -1) then -- Only save player info, if he has an island
        return
    end

    local PlayerInfoIni = cIniFile()
    PlayerInfoIni:SetValue("Player", "Name", self.playerName, true)
    PlayerInfoIni:SetValue("Island", "Number", self.islandNumber, true)
    
    local res = ""
    local first = true
    for index, value in pairs(self.completedChallenges) do
        if (first) then
            first = false
        else
            res = res .. ":"
        end
        res = res .. index;
    end
    
    PlayerInfoIni:SetValue("Challenges", "Completed", res, true)
    PlayerInfoIni:WriteFile(self.playerFile)
end

function cPlayerInfo.Load(self) -- Load PlayerInfo
    local PlayerInfoIni = cIniFile()
    if (PlayerInfoIni:ReadFile(self.playerFile) == false) then
        return
    end
    
    self.islandNumber = PlayerInfoIni:GetValueI("Island", "Number")
    local list = PlayerInfoIni:GetValue("Challenges", "Completed")
    local values = StringSplit(list, ":")
    
    for i = 1, #values do
        self.completedChallenges[values[i]] = true
    end
end
