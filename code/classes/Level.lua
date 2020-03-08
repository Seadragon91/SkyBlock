-- Contains all informations for a Level

cLevel = {}
cLevel.__index = cLevel


function cLevel.new(a_LevelName, a_Json)
	local self = setmetatable({}, cLevel)

	self.m_Challenges = {}
	self:Load(a_LevelName, a_Json)
	return self
end



function cLevel:Load(a_LevelName, a_Json)
	local fileChallenge = io.open(PLUGIN:GetLocalFolder() .. "/challenges/" .. a_Json.file, "rb")
	local content = fileChallenge:read("*a")
	fileChallenge:close()

	self.m_LevelName = a_LevelName

	-- Check if display item is valid
	local itemLevel = cItem()
	if not(StringToItem(a_Json.displayItem, itemLevel)) then
		assert(false, "This item name is not valid: " .. a_Json.displayItem)
	end
	self.m_DisplayItem = itemLevel

	if a_Json.completeForNextLevel ~= nil then
		self.m_CompleteForNextLevel = a_Json.completeForNextLevel or nil
	end

	local jsonChallenges = cJson:Parse(content)

	for challengeName, tbChallenge in pairs(jsonChallenges) do
		-- Default challengeType is items
		local challengeType = tbChallenge.challengeType or "items"

		local challengeInfo
		if challengeType == "items" then
			challengeInfo = cChallengeItems.new()
		elseif challengeType == "value" then
			challengeInfo = cChallengeValues.new()
		elseif challengeType == "blocks" then
			-- TODO:
			-- challengeInfo = cChallengeBlocks.new()
		else
			assert(false, "Unknown challengeType: " .. challengeType)
		end

		if challengeInfo ~= nil then
			challengeInfo:Load(self.m_LevelName, challengeName, tbChallenge)
			self.m_Challenges[challengeName] = challengeInfo
		end
	end

	local amount = GetAmount(self.m_Challenges)
	if self.m_CompleteForNextLevel == nil then
		self.m_CompleteForNextLevel = amount
	elseif self.m_CompleteForNextLevel > amount then
		self.m_CompleteForNextLevel = amount
	end
end
