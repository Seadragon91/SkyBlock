-- Store informations of an island

cIslandInfo = {}
cIslandInfo.__index = cIslandInfo

-- Create Island info
function cIslandInfo.new(a_IslandNumber)
    local self = setmetatable({}, cIslandInfo)
    
    self.islandFile = PLUGIN:GetLocalFolder() .. "/islands/" .. a_IslandNumber .. ".ini"
    self.islandNumber = a_IslandNumber
    self.friends = {}

    return self
end

function cIslandInfo.SetOwner(a_Player)
    self.ownerUUID = a_Player:GetUUID()
    self.ownerName = a_Player:GetName()
end

-- Save the island info
function cIslandInfo.Save(self)
    local IslandInfoIni = cIniFile()
    
    IslandInfoIni:SetValue("General", "IslandNumber", self.islandNumber, true)
    IslandInfoIni:SetValue("General", "OwnerUUID", self.ownerUUID, true)
    IslandInfoIni:SetValue("General", "OwnerName", self.ownerName, true)
    -- IslandInfoIni:SetValue("General", "Friends", table.concat(self.friends, " "), true)
    if (self.homeLocation ~= nil) then
        IslandInfoIni:SetValue("General", "HomeLocation", table.concat(self.homeLocation, " "))
    end
    
    IslandInfoIni:WriteFile(self.islandFile)
end

-- Add friend to list
function cIslandInfo.AddFriend(self, a_Player)
    if (self.friends[a_Player:GetUUID()] == nil) then
        self.friends[a_Player:GetUUID()] = a_Player:GetName()
        self.Save(self)
    end
end

-- Remove friend from list
function cIslandInfo.RemoveFriend(self, a_Player)
    if (self.friends[a_Player:GetUUID()] == nil) then
        return false
    end
    
    self.friends[a_Player:GetUUID()] = nil
    self.Save(self)
    return true
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
    return true
end

