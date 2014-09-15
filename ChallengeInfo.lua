-- Contains all informations for a Challenge

cChallengeInfo = {}
cChallengeInfo.__index = cChallengeInfo

function cChallengeInfo.new(a_Challengename, a_ChallengesIni, a_LevelName)
    local self = setmetatable({}, cChallengeInfo)
    
    self.challengeName = a_Challengename
    self.inLevel = a_LevelName
    self.Load(self, a_ChallengesIni)
    return self
end

function cChallengeInfo.IsCompleted(self, a_Player)
    local pi = GetPlayerInfo(a_Player)
        
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
        if (self.repeatable == false) then
            a_Player:SendMessageInfo("This challenge is not repeatable.")
            return
        end
        
        for i = 1, #self.rpt_requiredItems do
            if (not a_Player:GetInventory():HasItems(self.rpt_requiredItems[i])) then
                a_Player:SendMessageFailure("You don't have the required items.")
                return
            end
        end
        
        for i = 1, #self.rpt_requiredItems do
            a_Player:GetInventory():RemoveItem(self.rpt_requiredItems[i])
        end
        
        for i = 1, #self.rpt_rewardItems do
            a_Player:GetInventory():AddItem(self.rpt_rewardItems[i])
        end
        
        a_Player:SendMessageSuccess("Congrats you repeated the challenge " .. self.challengeName)
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
    self.requiredItems  = ParseStringToItems(a_ChallengesIni:GetValue(self.challengeName, "requiredItems"))
    self.requiredText   = a_ChallengesIni:GetValue(self.challengeName, "requiredText")
    self.rewardItems    = ParseStringToItems(a_ChallengesIni:GetValue(self.challengeName, "rewardItems"))
    self.rewardText     = a_ChallengesIni:GetValue(self.challengeName, "rewardText")
    
    -- Check if challenge is repeatable.
    self.repeatable = a_ChallengesIni:GetValueB(self.challengeName, "repeatable")
    if (self.repeatable == false) then
        return
    end
    
    self.rpt_requiredItems  = ParseStringToItems(a_ChallengesIni:GetValue(self.challengeName, "rpt_requiredItems"))
    self.rpt_requiredText   = a_ChallengesIni:GetValue(self.challengeName, "rpt_requiredText")
    self.rpt_rewardItems    = ParseStringToItems(a_ChallengesIni:GetValue(self.challengeName, "rpt_rewardItems"))
    self.rpt_rewardText     = a_ChallengesIni:GetValue(self.challengeName, "rpt_rewardText")
end
