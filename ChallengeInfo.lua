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
		a_Player:SendMessageInfo("You don't have the level to complete that challenge.")
		return false
	end

	local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)
	local needLevel = GetLevelAsNumber(self.m_LevelName)

	if (needLevel > isLevel) then
		a_Player:SendMessageInfo("You don't have the level to complete that challenge.")
		return false
	end

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		if (not self.m_IsRepeatable) then
			a_Player:SendMessageInfo("This challenge is not repeatable.")
			return false
		end
	end
	return true
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


-- Overrided. Returns the class as string
function cChallengeInfo:ToString()
	return "cChallengeInfo"
end


-- Not bound to class
function LoadBasicInfos(a_ChallengeName, a_LevelIni, a_LevelName)	
	local challengeType = a_LevelIni:GetValue(a_ChallengeName, "ChallengeType")
	local challengeInfo = nil

	-- challenges with no key challengeType are from type ITEMS
	if ((challengeType == "ITEMS") or (challengeType == "")) then
		challengeInfo = cChallengeItems.new(a_ChallengeName, a_LevelIni, a_LevelName)
	else
		LOGERROR("Unknown challengeType: " .. challengeType .. " in challenge " .. a_ChallengeName)
		return
	end

	challengeInfo.m_ChallengeName = a_ChallengeName
	challengeInfo.m_LevelName = a_LevelName
	challengeInfo.m_Description = a_LevelIni:GetValue(a_ChallengeName, "Description")
	challengeInfo.m_RequiredText = a_LevelIni:GetValue(a_ChallengeName, "RequiredText")
	challengeInfo.m_RewardText = a_LevelIni:GetValue(a_ChallengeName, "RewardText")
	challengeInfo.m_RewardItems = ParseStringToItems(a_LevelIni:GetValue(a_ChallengeName, "RewardItems"))

	-- Check if challenge is repeatable.
	local repeatable = a_LevelIni:GetValueB(a_ChallengeName, "Repeatable")
	if (not repeatable) then
		challengeInfo.m_IsRepeatable = false
		return challengeInfo
	end

	challengeInfo.m_IsRepeatable = true
	challengeInfo.m_RptRequiredText = a_LevelIni:GetValue(a_ChallengeName, "Rpt_RequiredText")
	challengeInfo.m_RptRewardText = a_LevelIni:GetValue(a_ChallengeName, "Rpt_RewardText")
	challengeInfo.m_RptRewardItems = ParseStringToItems(a_LevelIni:GetValue(a_ChallengeName, "Rpt_RewardItems"))
	return challengeInfo
end
