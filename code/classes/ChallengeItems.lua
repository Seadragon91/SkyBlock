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
		return false
	end

	if (playerInfo.m_CompletedChallenges[self.m_LevelName][self.m_ChallengeName]) then
		local tbItems = CollectItems(self.m_Repeat.required.items)

		for id, metaAmount in pairs(tbItems) do
			for meta, amount in pairs(metaAmount) do
				if a_Player:GetInventory():HowManyItems(cItem(id, meta)) < amount then
					return false
				end
			end
		end

		for _, item in pairs(self.m_Repeat.required.items) do
			a_Player:GetInventory():RemoveItem(item)
		end

		self:Complete(a_Player)
		return true
	end

	local tbItems = CollectItems(self.m_Default.required.items)

	for id, metaAmount in pairs(tbItems) do
		for meta, amount in pairs(metaAmount) do
			if a_Player:GetInventory():HowManyItems(cItem(id, meta)) < amount then
				return false
			end
		end
	end

	for _, item in pairs(self.m_Default.required.items) do
		a_Player:GetInventory():RemoveItem(item)
	end

	self:Complete(a_Player)
	return true
end


-- Override
function cChallengeItems:GetChallengeType()
	return "ITEMS"
end


-- Override
function cChallengeItems:InfoText(a_Player)
	return GetLanguage(a_Player):Get("challenges.info.itemsInfo")
end


-- Override
function cChallengeItems:ToString()
	return "cChallengeItems"
end


-- Override
function cChallengeItems:Load(a_LevelName, a_ChallengeName, a_Json)
	-- Read basic info from challenge
	cChallengeInfo.Load(self, a_LevelName, a_ChallengeName, a_Json)

	self.m_Default.required.items = ParseStringToItems(a_Json.required.items)

	if self.m_IsRepeatable then
		self.m_Repeat.required.items = ParseStringToItems(a_Json.repeatable.required.items)
	end
end
