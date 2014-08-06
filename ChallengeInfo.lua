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
    
    local isLevel = GetLevelAsNumer(pi.isLevel)
    local needLevel = GetLevelAsNumer(self.inLevel)
    
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
    
    local amountDone = GetAmount(pi.completedChallenges[pi.isLevel])
    local amountNeeded = GetAmount(LEVELS[GetLevelAsNumer(self.inLevel)].challenges)
    
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

function cChallengeInfo.Load(self, a_ChallengesIni)
    self.description    = a_ChallengesIni:GetValue(self.challengeName, "description")
    self.requiredItems  = self.ParseStringToItems(a_ChallengesIni:GetValue(self.challengeName, "requiredItems"))   
    self.requiredText   = a_ChallengesIni:GetValue(self.challengeName, "requiredText")
    self.rewardItems    = self.ParseStringToItems(a_ChallengesIni:GetValue(self.challengeName, "rewardItems"))
    self.rewardText     = a_ChallengesIni:GetValue(self.challengeName, "rewardText")
end
