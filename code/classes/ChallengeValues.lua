-- Challenge class for island value

cChallengeValues = {}
cChallengeValues.__index = cChallengeValues

function cChallengeValues.new()
	local self = setmetatable({}, cChallengeValues)
	setmetatable(cChallengeValues, {__index = cChallengeInfo})
	
	self.m_Calculations = {}
	return self
end


function cChallengeValues:CalculateValue(a_Player)
	self.callback =
		function(a_World)
			local position = self.m_Calculations[a_Player:GetName()]["position"]
			local chunks = self.m_Calculations[a_Player:GetName()]["chunks"]
			local points = self.m_Calculations[a_Player:GetName()]["points"]
			local counter = 1

			while true do
				local cx = chunks[position + counter][1] * 16
				local cz = chunks[position + counter][2] * 16
				local blockArea = cBlockArea()
				blockArea:Read(a_Player:GetWorld(), cx, cx + 15, 0, 255, cz, cz + 15)

				-- Let's calculate
				for id, metaPoint in pairs(BLOCK_VALUES) do
					for meta, point in pairs(metaPoint) do
						local amount = blockArea:CountSpecificBlocks(id, meta)
						if (amount > 0) and (BLOCK_VALUES[id] ~= nil) then
							if BLOCK_VALUES[id][meta] == nil then
								points = points + (BLOCK_VALUES[id][0] * amount)
							else
								points = points + (BLOCK_VALUES[id][meta] * amount)
							end
						end
					end
				end

				if (position + counter) == #chunks then
					local value = round(self.m_Calculations[a_Player:GetName()]["points"] / 1000)
					self.m_Calculations[a_Player:GetName()] = nil
					if (value >= self.m_RequiredValue) then
						self:Complete(a_Player)
						return
					end
					a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "calculated", { ["%1"] = value, ["%2"] = self.m_RequiredValue}))
					return
				elseif counter == 1 then
					self.m_Calculations[a_Player:GetName()]["position"] = position + counter
					self.m_Calculations[a_Player:GetName()]["points"] = points
					a_Player:GetWorld():ScheduleTask(5, self.callback)
					return
				end
				counter = counter + 1
			end
		end
	a_Player:GetWorld():ScheduleTask(5, self.callback)
end



-- Override
function cChallengeValues:IsCompleted(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)
	
	if (self.m_Calculations[a_Player:GetName()] ~= nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "calculatingWait"))
		return
	end

	if (not self:HasRequirements(a_Player)) then
		return
	end
	
	local posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
	local chunks = GetChunks(posX, posZ, ISLAND_DISTANCE / 2)
	self.m_Calculations[a_Player:GetName()] = {}
	self.m_Calculations[a_Player:GetName()]["position"] = 0
	self.m_Calculations[a_Player:GetName()]["points"] = 0
	self.m_Calculations[a_Player:GetName()]["chunks"] = chunks
	
	a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "calculatingStarted"))
	self:CalculateValue(a_Player)
end


-- Override
function cChallengeValues:GetChallengeType()
	return "VALUES"
end


-- Override
function cChallengeValues:InfoText(a_Player)
	return GetLanguage(a_Player):Get(2, 4, "valueInfo")
end


-- Override
function cChallengeValues:ToString()
	return "cChallengeValues"
end


-- Override
function cChallengeValues:Load(a_LevelIni)
	self.m_RequiredValue = a_LevelIni:GetValueI(self.m_ChallengeName, "requiredValue")
end

