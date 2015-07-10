-- Challenge class for items

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

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		for i = 1, #self.m_RptRequiredItems do
			if (not a_Player:GetInventory():HasItems(self.m_RptRequiredItems[i])) then
				a_Player:SendMessageInfo("You don't have the required items.")
				return
			end
		end

		for i = 1, #self.m_RptRequiredItems do
			a_Player:GetInventory():RemoveItem(self.m_RptRequiredItems[i])
		end

		self:Complete(a_Player)
		return
	end

	for i = 1, #self.m_RequiredItems do
		if (not a_Player:GetInventory():HasItems(self.m_RequiredItems[i])) then
			a_Player:SendMessageInfo("You don't have the required items.")
			return
		end
	end

	for i = 1, #self.m_RequiredItems do
		a_Player:GetInventory():RemoveItem(self.m_RequiredItems[i])
	end

	self:Complete(a_Player)
	playerInfo:Save()
end


-- Override
function cChallengeItems:GetChallengeType()
	return "ITEMS"
end


-- Override
function cChallengeItems:InfoText()
	return "Gather this items: "
end


-- Override
function cChallengeItems:ToString()
	return "cChallengeItems"
end


-- Override
function cChallengeItems:Load(a_LevelIni)
	self.m_RequiredItems = ParseStringToItems(a_LevelIni:GetValue(self.m_ChallengeName, "requiredItems"))

	if (self.m_IsRepeatable) then
		self.m_RptRequiredItems = ParseStringToItems(a_LevelIni:GetValue(self.m_ChallengeName, "rpt_requiredItems"))
	end
end
