-- Contains all informations for a Challenge

cChallengeInfo = {}
cChallengeInfo.__index = cChallengeInfo

function cChallengeInfo.new()
	local self = setmetatable({}, cChallengeInfo)
	return self
end


-- TODO: "Dead code"
function cChallengeInfo:HasRequirements(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)

	if (playerInfo.m_CompletedChallenges[self.m_LevelName] == nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("challenges.info.notLevel"))
		return false
	end

	local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)
	local needLevel = GetLevelAsNumber(self.m_LevelName)

	if (needLevel > isLevel) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("challenges.info.notLevel"))
		return false
	end

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		if (not self.m_IsRepeatable) then
			return false
		end
	end
	return true
end


function cChallengeInfo:Complete(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)
	local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		for i = 1, #self.m_Repeat.reward.items do
			a_Player:GetInventory():AddItem(self.m_Repeat.reward.items[i])
		end

		a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("challenges.info.repeated", { ["%1"] = self.m_ChallengeName}))
		return
	end

	for i = 1, #self.m_Default.reward.items do
		a_Player:GetInventory():AddItem(self.m_Default.reward.items[i])
	end

	playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName] = true
	a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("challenges.info.completed", { ["%1"] = self.m_ChallengeName}))

	local amountDone = GetAmount(playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel])
	local amountNeeded = LEVELS[GetLevelAsNumber(self.m_LevelName)].m_CompleteForNextLevel

	if (amountDone >= amountNeeded) then
		if (isLevel == #LEVELS) then
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("challenges.info.allLevels"))
			playerInfo:Save()
			return
		end

		playerInfo.m_IsLevel = LEVELS[isLevel + 1].m_LevelName
		playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel] = {}
		a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("challenges.info.nextLevel", { ["%1"] = LEVELS[isLevel + 1].m_LevelName}))
	end
	playerInfo:Save()
end


-- Overridden in inherited classes
function cChallengeInfo:IsCompleted(a_Player)
	LOGERROR("cChallengeInfo:IsCompleted(): missing override in class " .. self:ToString())
end


-- Overridden in inherited classes
function cChallengeInfo:GetChallengeType()
	LOGERROR("cChallengeInfo:GetChallengeType(): missing override in class " .. self:ToString())
end


-- Overridden in inherited classes
function cChallengeInfo:Load(a_LevelIni)
	LOGERROR("cChallengeInfo:Load(): missing override in class " .. self:ToString())
end


-- Overridden in inherited classes
function cChallengeInfo:InfoText(a_Player)
	LOGERROR("cChallengeInfo:InfoText(): missing override in class " .. self:ToString())
end


-- Can be overridden in inherited classes
function cChallengeInfo:GetRequiredText(a_Player)
	return self.m_RequiredText
end


-- Can be overridden in inherited classes
function cChallengeInfo:GetRptRequiredText(a_Player)
	return self.m_RptRequiredText
end


-- Overridden. Returns the class name
function cChallengeInfo:ToString()
	return "cChallengeInfo"
end


function cChallengeInfo:Extract(a_Json)
	local tbRet = {}

	tbRet.required = {}
	tbRet.required.text = a_Json.required.text

	tbRet.reward = {}
	tbRet.reward.text = a_Json.reward.text
	tbRet.reward.items = ParseStringToItems(a_Json.reward.items)
	tbRet.reward.xp = a_Json.reward.xp or 0

	return tbRet
end


-- Can be overridden in inherited classes
function cChallengeInfo:Load(a_LevelName, a_ChallengeName, a_Json)
	-- print("cChallengeInfo.Load()")
	-- print("Reading challenge: " ..a_ChallengeName)

	self.m_LevelName = a_LevelName
	self.m_ChallengeName = a_ChallengeName
	self.m_Description = a_Json.description
	self.m_DisplayItem = a_Json.displayItem

	self.m_Default = self:Extract(a_Json)

	if (a_Json.repeatable ~= nil) then
		-- If repeatable.enabled is missing, default true otherwise false
		if (a_Json.repeatable.enabled == nil or
			a_Json.repeatable.enabled == true)
		then
			self.m_IsRepeatable = true
			self.m_Repeat = self:Extract(a_Json.repeatable)
		else
			self.m_IsRepeatable = false
		end
	end
end
