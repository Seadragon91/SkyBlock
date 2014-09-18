-- Store informations of an island

cIslandInfo = {}
cIslandInfo.__index = cIslandInfo

-- Create Island info
function cIslandInfo.new(a_IslandNumber)
    local self = setmetatable({}, cIslandInfo)
    
    self.islandFile = PLUGIN:GetLocalFolder() .. "/islands/" .. a_IslandNumber .. ".ini"
    self.islandNumber = a_IslandNumber
    self.homeLocation = nil
--    self.friends = {}
    
    self.Load(self, a_IslandNumber, a_Player) -- Load island file
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
        IslandInfoIni:SetValue("General", "HomeLocation", table.concat(self.homeLocation))
    end
    
    IslandInfoIni:WriteFile(self.islandFile)
end

-- -- Add friend to list
-- function cIslandInfo.AddFriend(self, a_Player)
--     for i = i, #self.friends do
--         if (self.friends[i] == a_Player:GetUUID()) then
--             return
--         end
--     end
-- 
--     table.insert(self.friends, a_Player:GetUUID())
-- end
-- 
-- -- Remove friend from list
-- function cIslandInfo.RemoveFriend(self, a_Player)
--     local index = 0
--     for i = 1, #self.friends do
--         if (self.friends[i] == a_Player:GetUUID()) then
--             index = i
--             break
--         end
--     end
--     
--     if (index == 0) then
--         return false
--     end
--     
--     table.remove(self.friends, index)
--     return true
-- end

-- Load the island info
function cIslandInfo.Load(self, a_IslandNumber)
    local IslandInfoIni = cIniFile()
    
    if (IslandInfoIni:ReadFile(self.islandFile) == false) then
        self.Save(self)
        return
    end

    local IslandInfoIni = cIniFile()
    self.islandNumber = a_IslandNumber
    self.ownerUUID = IslandInfoIni:GetValue("General", "OwnerUUID")
    self.ownerName = IslandInfoIni:GetValue("General", "OwnerName")
    
    local temp = IslandInfoIni:GetValue("General", "HomeLocation")
    if (temp ~= "") then
        self.homeLocation = StringSplit(temp, " ")
    end
    
    -- if (self.ownerName ~= a_Player:GetName()) then
    --     self.ownerName = a_Player:GetName()
    --     self.Save(self)
    -- end
end

