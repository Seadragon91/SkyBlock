-- Stores informations of the player

cPlayerInfo = {}
cPlayerInfo.__index = cPlayerInfo

function cPlayerInfo.new(a_Player)
    local self = setmetatable({}, cPlayerInfo)
    
    self.playerUUID = a_Player:GetUUID()
    self.playerName = a_Player:GetName()
    self.islandNumber = -1 -- Set to -1 for no island
    self.playerFile = PLUGIN:GetLocalFolder() .. "/players/" .. a_Player:GetUUID() .. ".ini"
    self.isLevel = LEVELS[1].levelName -- Set first level
    self.completedChallenges = {}
    self.completedChallenges[self.isLevel] = {}
    self.inFriendList = {}
        
    self.Load(self, a_Player) -- Check if there is a player file, if yes load it
    return self
end

function cPlayerInfo.HasCompleted(self, a_Level, a_ChallengeName)
    if (self.completedChallenges[a_Level] == nil) then
        return false
    end
    
    if (self.completedChallenges[a_Level][a_ChallengeName] == nil) then
        return false
    end
    
    return true
end

function cPlayerInfo.AddEntry(self, a_IslandNumber, a_Player)
    local s = a_Player:GetName():lower()

    if (self.inFriendList[s] == nil) then
        self.inFriendList[s] = {}
        self.inFriendList[s][1] = a_Player:GetUUID()
        self.inFriendList[s][2] = a_IslandNumber
    end
end

function cPlayerInfo.RemoveEntry(self, a_PlayerName)
    if (self.inFriendList[a_PlayerName:lower()] == nil) then
        return false
    end
    
    self.inFriendList[a_PlayerName] = nil
    return true
end

function cPlayerInfo.HasPermissionThere(self, a_BlockX, a_BlockZ)
    local islandNumber = GetIslandNumber(a_BlockX, a_BlockZ)
    if (islandNumber == 0) then
        return false
    end
    
    local ii = GetIslandInfo(islandNumber)
    if (ii == nil) then
        return false
    end
    
    if (ii.ownerUUID == self.playerUUID) then
        return true
    end
    
    if (ii.friends[self.playerUUID] == nil) then
        return false
    end
    
    return true
end

function cPlayerInfo.Save(self) -- Save PlayerInfo
    if (self.islandNumber == -1) then -- Only save player info, if he has or is on a friends island
        return
    end

    local PlayerInfoIni = cIniFile()
    PlayerInfoIni:SetValue("Player", "Name", self.playerName, true)
    PlayerInfoIni:SetValue("Island", "Number", self.islandNumber, true)
    
    for i = 1, #LEVELS do
        local res = ""
        local first = true
        if (self.completedChallenges[LEVELS[i].levelName] == nil) then
            break
        end
        
        for index, value in pairs(self.completedChallenges[LEVELS[i].levelName]) do
            if (first) then
                first = false
            else
                res = res .. ":"
            end
            res = res .. index;
        end
        
        PlayerInfoIni:SetValue("Completed", LEVELS[i].levelName, res, true)
    end
    PlayerInfoIni:SetValue("Player", "IsLevel", self.isLevel, true)
    
    local amount = GetAmount(self.inFriendList)
    if (amount > 0) then
        local list = ""
        local counter = 0
        for player, info in pairs(self.inFriendList) do
            list = list .. player .. ":" .. self.inFriendList[player][1] .. ":" .. self.inFriendList[player][2]
            if (counter ~= amount) then
                list = list .. " "
            end
        end
        PlayerInfoIni:SetValue("Player", "InFriendList", list, true)
    end
    
    PlayerInfoIni:WriteFile(self.playerFile)
end

function cPlayerInfo.Load(self, a_Player) -- Load PlayerInfo
    local PlayerInfoIni = cIniFile()
    
    -- Check for old file, backward compatibility
    if (cFile:Exists(PLUGIN:GetLocalFolder() .. "/players/" .. a_Player:GetName() .. ".ini")) then -- Rename file if exists
        cFile:Rename(PLUGIN:GetLocalFolder() .. "/players/" .. a_Player:GetName() .. ".ini", self.playerFile)
    end
    
    if (PlayerInfoIni:ReadFile(self.playerFile) == false) then
        return
    end
    
    self.islandNumber = PlayerInfoIni:GetValueI("Island", "Number")
    
    for level_index = 1, #LEVELS do
        self.completedChallenges[LEVELS[level_index].levelName] = {}
        local list = PlayerInfoIni:GetValue("Completed", LEVELS[level_index].levelName)
        if (list == nil) then
            break
        end
            
        local values = StringSplit(list, ":")
    
        for i = 1, #values do
            self.completedChallenges[LEVELS[level_index].levelName][values[i]] = true
        end
    end
    
    self.isLevel = PlayerInfoIni:GetValue("Player", "IsLevel")
    if (self.isLevel == "") then
        self.isLevel = LEVELS[1].levelName
    end
    
    local temp = PlayerInfoIni:GetValue("Player", "InFriendList")
    if (temp ~= "") then
        temp = StringSplit(temp, " ")
        for i = 1, #temp do
            local entry = StringSplit(temp[i], ":")
            self.inFriendList[entry[1]] = {}
            self.inFriendList[entry[1]][1] = entry[2]
            self.inFriendList[entry[1]][2] = entry[3]
        end
    end
end
