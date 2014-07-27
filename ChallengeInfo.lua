-- Contains all informations for a Challenge

cChallengeInfo = {}
cChallengeInfo.__index = cChallengeInfo

function cChallengeInfo.new(a_Challengename, a_ChallengesIni, a_Level)
    self = setmetatable({}, cChallengeInfo)
    
    self.challengeName = a_Challengename
    self.inLevel = a_Level
    self.Load(self, a_ChallengesIni)
    return self
end

function cChallengeInfo.IsCompleted(self, a_Player)
    local pi = PLAYERS[a_Player:GetName()]
    
    if (pi.completedChallenges[self.inLevel] == nil) then
        a_Player:SendMessageInfo("You don't have the level to complete that challenge.")
        return
    end
    
    local isLevel = GetLevelAsNumer(self, pi.isLevel)
    local needLevel = GetLevelAsNumer(self, self.inLevel)
    
    if (needLevel > isLevel) then
        a_Player:SendMessageInfo("You don't have the level to complete that challenge.")
        return
    end
    
    if (pi.completedChallenges[self.inLevel][self.challengeName] == true) then
        a_Player:SendMessageInfo("You have already completed that challenge.")
        return
    end

    for i = 1, #self.requiredItems do
        if (not a_Player:GetInventory():HasItems(self.requiredItems[i])) then
            a_Player:SendMessageFailure("You don't have the required items.")
            return
        end
    end
    
    for i = 1, #self.requiredItems do
        a_Player:GetInventory():RemoveItem(self.requiredItems[i])
    end
    
    for i = 1, #self.rewardItems do
        a_Player:GetInventory():AddItem(self.rewardItems[i])
    end
    
    pi.completedChallenges[self.inLevel][self.challengeName] = true
    a_Player:SendMessageSuccess("Congrats you completed the challenge " .. self.challengeName)
    
    local amountDone = GetAmount(self, pi.completedChallenges[pi.isLevel])
    local amountNeeded = GetAmount(self, LEVELS[GetLevelAsNumer(self, self.inLevel)].challenges)
    
    if (amountDone == amountNeeded) then
        if (isLevel == #LEVELS) then
            a_Player:SendMessageSuccess("You completed all levels and all challenges."); 
            return
        end
        
        pi.isLevel = LEVELS[isLevel + 1].levelName
        pi.completedChallenges[pi.isLevel] = {}
        a_Player:SendMessageSuccess("Congrats. You unlocked next level " .. LEVELS[isLevel + 1].levelName)
    end
end

function GetLevelAsNumer(self, a_Level)
    for i = 1, #LEVELS do
        if (LEVELS[i].levelName == a_Level) then
            return i
        end
    end
end

function GetAmount(self, a_List)
    local amount = 0
    for k,v in pairs(a_List) do
        amount = amount + 1
    end
    return amount
end

function cChallengeInfo.Load(self, a_ChallengesIni)
    self.description    = a_ChallengesIni:GetValue(self.challengeName, "description")
    self.requiredItems  = self.ParseStringToItem(self, a_ChallengesIni:GetValue(self.challengeName, "requiredItems"))   
    self.requiredText   = a_ChallengesIni:GetValue(self.challengeName, "requiredText")
    self.rewardItems    = self.ParseStringToItem(self, a_ChallengesIni:GetValue(self.challengeName, "rewardItems"))
    self.rewardText     = a_ChallengesIni:GetValue(self.challengeName, "rewardText")
end

function cChallengeInfo.ParseStringToItem(self, a_ToParse) -- Parses all elements from the string to items and returns a list
    local items = {}
    local list = StringSplit(a_ToParse, " ")
    for i = 1, #list do
        local values = StringSplit(list[i], ":")
        local item = cItem()
        
        if (StringToItem(values[1], item)) then -- Invalid item name
            local amount = tonumber(values[2])
            if (amount ~= nil) then -- Invalid number
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
