-- Contains all informations for a Challenge

cChallengeInfo = {}
cChallengeInfo.__index = cChallengeInfo

function cChallengeInfo.new()
	local self = setmetatable({}, cChallengeInfo)
	return self
end


function cChallengeInfo:HasRequirements(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)

	if (playerInfo.m_CompletedChallenges[self.m_LevelName] == nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "notLevel"))
		return false
	end

	local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)
	local needLevel = GetLevelAsNumber(self.m_LevelName)

	if (needLevel > isLevel) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "notLevel"))
		return false
	end

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		if (not self.m_IsRepeatable) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "notRepeatable"))
			return false
		end
	end
	return true
end


function cChallengeInfo:Complete(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)
	local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		for i = 1, #self.m_RptRewardItems do
			a_Player:GetInventory():AddItem(self.m_RptRewardItems[i])
		end

		a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(2, 4, "repeated", { ["%1"] = self.m_ChallengeName}))
		return
	end

	for i = 1, #self.m_RewardItems do
		a_Player:GetInventory():AddItem(self.m_RewardItems[i])
	end

	playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName] = true
	a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(2, 4, "completed", { ["%1"] = self.m_ChallengeName}))

	local amountDone = GetAmount(playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel])
	local amountNeeded = GetAmount(LEVELS[GetLevelAsNumber(self.m_LevelName)].m_Challenges)

	if (amountDone == amountNeeded) then
		if (isLevel == #LEVELS) then
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(2, 4, "allLevels"))
			playerInfo:Save()
			return
		end

		playerInfo.m_IsLevel = LEVELS[isLevel + 1].m_LevelName
		playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel] = {}
		a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(2, 4, "nextLevel", { ["%1"] = LEVELS[isLevel + 1].m_LevelName}))
	end
	playerInfo:Save()
end


-- Overrided in the inheritanced classes
function cChallengeInfo:IsCompleted(a_Player)
	LOGERROR("cChallengeInfo:IsCompleted(): missing override in class " .. self:ToString())
end


-- Overrided in the inheritanced classes
function cChallengeInfo:GetChallengeType()
	LOGERROR("cChallengeInfo:GetChallengeType(): missing override in class " .. self:ToString())
end


-- Overrided in the inheritanced classes
function cChallengeInfo:Load(a_LevelIni)
	LOGERROR("cChallengeInfo:Load(): missing override in class " .. self:ToString())
end

-- Overrided in the inheritanced classes
function cChallengeInfo:InfoText()
	LOGERROR("cChallengeInfo:InfoText(): missing override in class " .. self:ToString())
end


-- Overrided. Returns the class name
function cChallengeInfo:ToString()
	return "cChallengeInfo"
end



-- Not bound to class
function LoadBasicInfos(a_ChallengeName, a_LevelIni, a_LevelName)	
	local challengeType = a_LevelIni:GetValue(a_ChallengeName, "challengeType")
	local challengeInfo = nil

	-- challenges with no key challengeType are from type ITEMS
	if ((challengeType == "ITEMS") or (challengeType == "")) then
		challengeInfo = cChallengeItems.new()
	elseif (challengeType == "VALUES") then
		challengeInfo = cChallengeValues.new()
	else
		LOGERROR("Unknown challengeType: " .. challengeType .. " in challenge " .. a_ChallengeName)
		return nil
	end

	challengeInfo.m_ChallengeName = a_ChallengeName
	challengeInfo.m_LevelName = a_LevelName
	challengeInfo.m_Description = a_LevelIni:GetValue(a_ChallengeName, "description")
	challengeInfo.m_RequiredText = a_LevelIni:GetValue(a_ChallengeName, "requiredText")
	challengeInfo.m_RewardText = a_LevelIni:GetValue(a_ChallengeName, "rewardText")
	challengeInfo.m_RewardItems = ParseStringToItems(a_LevelIni:GetValue(a_ChallengeName, "rewardItems"))

	-- Check if challenge is repeatable.
	local repeatable = a_LevelIni:GetValueB(a_ChallengeName, "repeatable")
	if (not repeatable) then
		challengeInfo.m_IsRepeatable = false
		return challengeInfo
	end

	challengeInfo.m_IsRepeatable = true
	challengeInfo.m_RptRequiredText = a_LevelIni:GetValue(a_ChallengeName, "rpt_requiredText")
	challengeInfo.m_RptRewardText = a_LevelIni:GetValue(a_ChallengeName, "rpt_rewardText")
	challengeInfo.m_RptRewardItems = ParseStringToItems(a_LevelIni:GetValue(a_ChallengeName, "rpt_rewardItems"))
	return challengeInfo
end
