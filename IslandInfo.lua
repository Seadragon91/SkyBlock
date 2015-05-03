-- Stores informations of an island

cIslandInfo = {}
cIslandInfo.__index = cIslandInfo

-- Create Island info
function cIslandInfo.new(a_IslandNumber)
    local self = setmetatable({}, cIslandInfo)
    
    self.islandFile = PLUGIN:GetLocalFolder() .. "/islands/" .. a_IslandNumber .. ".ini"
    self.islandNumber = tonumber(a_IslandNumber)
    self.friends = {}

    return self
end

function cIslandInfo.SetOwner(self, a_Player)
    self.ownerUUID = a_Player:GetUUID()
    self.ownerName = a_Player:GetName()
end

-- Add friend to list
function cIslandInfo.AddFriend(self, a_Player)
    if (self.friends[a_Player:GetUUID()] == nil) then
        self.friends[a_Player:GetUUID()] = a_Player:GetName():lower()
    end
end

-- Remove friend from list
function cIslandInfo.RemoveFriend(self, a_PlayerName)
    local hasUUID = ""
    for uuid, playerName in pairs(self.friends) do
        if (playerName == a_PlayerName:lower()) then
            hasUUID = uuid
            break
        end
    end
    
    if (hasUUID == "") then
        return false
    end
    
    self.friends[hasUUID] = nil
    return true
end

-- Check if player name is in list
function cIslandInfo.ContainsFriend(self, a_PlayerName)
    for _, playerName in pairs(self.friends) do
        if (a_PlayerName:lower() == playerName) then
            return true
        end
    end
    return false
end

-- Saves the island info
function cIslandInfo.Save(self)
    local IslandInfoIni = cIniFile()
    
    IslandInfoIni:SetValueI("General", "IslandNumber", self.islandNumber, true)
    IslandInfoIni:SetValue("General", "OwnerUUID", self.ownerUUID, true)
    IslandInfoIni:SetValue("General", "OwnerName", self.ownerName, true)
    if (self.homeLocation ~= nil) then
        IslandInfoIni:SetValue("General", "HomeLocation", table.concat(self.homeLocation, " "))
    end

    local amount = GetAmount(self.friends)
    if (amount > 0) then
        local list = ""
        local counter = 0
        for uuid, playerName in pairs(self.friends) do
            counter = counter + 1
            list = list .. uuid .. ":" .. playerName
            if (counter ~= amount) then
                list = list .. " "
            end
        end
        IslandInfoIni:SetValue("General", "Friends", list, true)
    end
    
    IslandInfoIni:WriteFile(self.islandFile)
end

-- Load the island info
function cIslandInfo.Load(self)
    local IslandInfoIni = cIniFile()
    
    if (IslandInfoIni:ReadFile(self.islandFile) == false) then
        return false
    end

    self.ownerUUID = IslandInfoIni:GetValue("General", "OwnerUUID")
    self.ownerName = IslandInfoIni:GetValue("General", "OwnerName")
    
    local temp = IslandInfoIni:GetValue("General", "HomeLocation")
    if (temp ~= "") then
        self.homeLocation = StringSplit(temp, " ")
    end
    
    temp = IslandInfoIni:GetValue("General", "Friends")
    if (temp ~= "") then
        temp = StringSplit(temp, " ")
        for i = 1, #temp do
            local player = StringSplit(temp[i], ":")
            self.friends[player[1]] = player[2]
        end
    end
    return true
end

