
-- Returns the index of the level name
function GetLevelAsNumer(a_Level)
    for i = 1, #LEVELS do
        if (LEVELS[i].levelName == a_Level) then
            return i
        end
    end
end

-- Returns the amount of elements in the list
function GetAmount(a_List)
    local amount = 0
    for k,v in pairs(a_List) do
        amount = amount + 1
    end
    return amount
end

 -- Parses all elements from the string to items and returns a list
function ParseStringToItems(a_ToParse)
    local items = {}
    local list = StringSplit(a_ToParse, " ")
    for i = 1, #list do
        local values = StringSplit(list[i], ":")
        local item = cItem()
        
        if (StringToItem(values[1], item)) then -- Check if valid item name
            local amount = tonumber(values[2])
            if (amount ~= nil) then -- Check if valid number
                item.m_ItemCount = amount
                if (#values == 3) then
                    local dv = tonumber(values[3])
                    item.m_ItemDamage = dv
                end
                items[#items + 1] = item
            end
        end
    end
    return items
end

-- Checks if the player can interact at the position
function HasPermissionThereDontCancel(a_Player, a_BlockX, a_BlockZ)
    if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
        return false
    end
    
    local pi = GetPlayerInfo(a_Player)
    local islandNumber = GetIslandNumber(a_BlockX, a_BlockZ)
    if (a_Player:HasPermission("skyblock.admin.build")) then
        return false
    end
    
    if (pi.islandNumber == islandNumber) then
        return false
    end
    
    return true
end

-- Returns the challenge info for the challenge name
function GetChallenge(a_ChallengeName)
    for i = 1, #LEVELS do
        if (LEVELS[i].challenges[a_ChallengeName] ~= nil) then
            return LEVELS[i].challenges[a_ChallengeName]
        end
    end
    return nil
end

-- Returns and load cPlayerInfo if necessary, should never return nil
function GetPlayerInfo(a_Player)
    local pi = PLAYERS[a_Player:GetUUID()]
    if (pi == nil) then
        pi = cPlayerInfo.new(a_Player) -- Load or create new PlayerInfo
        PLAYERS[a_Player:GetUUID()] = pi
    end
    return pi
end

-- Return and load cIslandInfo if necessary, can return nil
function GetIslandInfo(a_IslandNumber)
    local ii = ISLANDS[a_IslandNumber)
    return ii
end
