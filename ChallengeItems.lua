-- Contains all informations for a Challenge

cChallengeItems = {}
cChallengeItems.__index = cChallengeItems

function cChallengeItems.new()
	local self = setmetatable({}, cChallengeItems)
	setmetatable(cChallengeItems, {__index = cChallengeInfo})
	return self
end

-- Override
function cChallengeItems:IsCompleted(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)

	if (not self:HasRequirements(a_Player)) then
		return
	end

	local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName] and self.m_IsRepeatable) then
		for i = 1, #self.m_RptRequiredItems do
			if (not a_Player:GetInventory():HasItems(self.m_RptRequiredItems[i])) then
				a_Player:SendMessageFailure("You don't have the required items.")
				return
			end
		end

		for i = 1, #self.m_RptRequiredItems do
			a_Player:GetInventory():RemoveItem(self.m_RptRequiredItems[i])
		end

		for i = 1, #self.m_RptRewardItems do
			a_Player:GetInventory():AddItem(self.m_RptRewardItems[i])
		end

		a_Player:SendMessageSuccess("Congrats you repeated the challenge " .. self.m_ChallengeName)
		return
	end

	for i = 1, #self.m_RequiredItems do
		if (not a_Player:GetInventory():HasItems(self.m_RequiredItems[i])) then
			a_Player:SendMessageFailure("You don't have the required items.")
			return
		end
	end

	for i = 1, #self.m_RequiredItems do
		a_Player:GetInventory():RemoveItem(self.m_RequiredItems[i])
	end

	for i = 1, #self.m_RewardItems do
		a_Player:GetInventory():AddItem(self.m_RewardItems[i])
	end

	playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName] = true
	a_Player:SendMessageSuccess("Congrats you completed the challenge " .. self.m_ChallengeName)

	local amountDone = GetAmount(playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel])
	local amountNeeded = GetAmount(LEVELS[GetLevelAsNumber(self.m_LevelName)].m_Challenges)

	if (amountDone == amountNeeded) then
		if (isLevel == #LEVELS) then
			a_Player:SendMessageSuccess("You completed all levels and all challenges.");
			playerInfo:Save()
			return
		end

		playerInfo.m_IsLevel = LEVELS[isLevel + 1].m_LevelName
		playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel] = {}
		a_Player:SendMessageSuccess("Congrats. You unlocked next level " .. LEVELS[isLevel + 1].m_LevelName)
	end

	playerInfo:Save()
end


-- Override
function cChallengeItems:GetChallengeType()
	return "ITEMS"
end


-- Override
function cChallengeInfo:ToString()
	return "cChallengeInfo"
end


-- Override
function cChallengeItems:Load(a_LevelIni)
	self.m_RequiredItems = ParseStringToItems(a_LevelIni:GetValue(self.m_ChallengeName, "RequiredItems"))
	self.m_RewardItems = ParseStringToItems(a_LevelIni:GetValue(self.m_ChallengeName, "RewardItems"))

	if (self.m_IsRepeatable) then
		self.m_RptRequiredItems = ParseStringToItems(a_LevelIni:GetValue(self.m_ChallengeName, "Rpt_RequiredItems"))
	end
end
