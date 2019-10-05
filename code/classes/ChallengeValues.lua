-- Challenge class for island value

cChallengeValues = {}
cChallengeValues.__index = cChallengeValues

function cChallengeValues.new()
	local self = setmetatable({}, cChallengeValues)
	setmetatable(cChallengeValues, {__index = cChallengeInfo})

	self.m_Calculations = {}
	-- self.m_BlocksCounted = {}
	return self
end


function cChallengeValues:CalculateValue(a_PlayerName)
	self.callback =
		function(a_World)
			local foundPlayer = SKYBLOCK:DoWithPlayer(a_PlayerName, function() end)
			if not(foundPlayer) then
				-- Player left the skyblock world, abort calculating
				return
			end

			local position = self.m_Calculations[a_PlayerName].position
			local chunks = self.m_Calculations[a_PlayerName].chunks
			local points = self.m_Calculations[a_PlayerName].points
			local counter = 1

			while true do
				local cx = chunks[position + counter][1] * 16
				local cz = chunks[position + counter][2] * 16
				local blockArea = cBlockArea()

				blockArea:Read(SKYBLOCK, cx, cx + 15, 0, 255, cz, cz + 15, 3)

				-- Let's calculate
				if blockArea:CountNonAirBlocks() > 0 then

					-- ## Very slow... (35 to 62ms)
					-- local sw = cStopWatch.new()
					-- sw:Start()
					-- local tbCounted = {}
					-- local maxX, maxY, maxZ = blockArea:GetSize()
					-- for x = 0, maxX - 1 do
					-- 	for y = 0, maxY - 1 do
					-- 		for z = 0, maxZ - 1 do
					-- 			local id, meta = blockArea:GetRelBlockTypeMeta(x, y, z)
					-- 			if id ~= 0 then
					-- 				if tbCounted[id] == nil then
					-- 					tbCounted[id] = {}
					-- 				end
					--
					-- 				if tbCounted[id][meta] == nil then
					-- 					tbCounted[id][meta] = 1
					-- 				else
					-- 					tbCounted[id][meta] = tbCounted[id][meta] + 1
					-- 				end
					-- 			end
					-- 		end
					-- 	end
					-- end
					-- print("Calc: ", sw:GetElapsedMilliseconds())

					-- for id, metaAmount in pairs(tbCounted) do
					-- 	for meta, amount in pairs(metaAmount) do
					-- 		if BLOCK_VALUES[id] ~= nil then
					-- 			if BLOCK_VALUES[id][meta] == nil then
					-- 				points = points + (BLOCK_VALUES[id][0] * amount)
					-- 			else
					-- 				points = points + (BLOCK_VALUES[id][meta] * amount)
					-- 			end
					-- 		end
					-- 	end
					-- end



					-- ## Fastest solution: Needs extra code in cuberite (PC: 0 to 3ms, PI: 1 to 3 ms)
					-- local blocksCounted = blockArea:CountAllNonAirBlocksAndMetas()
					-- for idMeta, amount in pairs(blocksCounted) do
					-- 	local tbIdMeta = StringSplit(idMeta, "-")
					-- 	local id = tonumber(tbIdMeta[1])
					-- 	local meta = tonumber(tbIdMeta[2])
--
					-- 	if (BLOCK_VALUES[id] ~= nil) then
					-- 		if BLOCK_VALUES[id][meta] == nil then
					-- 			points = points + (BLOCK_VALUES[id][0] * amount)
					-- 		else
					-- 			points = points + (BLOCK_VALUES[id][meta] * amount)
					-- 		end
					-- 	end
					-- end



					-- ## Faster, but still slow (13 to 20 ms)
					-- local sw = cStopWatch.new()
					-- sw:Start()
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
				end

				if (position + counter) == #chunks then
					local value = round(self.m_Calculations[a_PlayerName].points / 1000)
					self.m_Calculations[a_PlayerName] = nil
					if (value >= self.m_Default.required.value) then
						SKYBLOCK:DoWithPlayer(a_PlayerName,
							function(a_Player)
								self:Complete(a_Player)
							end)
						return
					end
					SKYBLOCK:DoWithPlayer(a_PlayerName,
						function(a_Player)
							a_Player:SendMessageInfo(GetLanguage(a_Player):Get("challenges.value.calculated", { ["%1"] = value, ["%2"] = self.m_Default.required.value}))
						end)

					return
				elseif counter == 1 then
					self.m_Calculations[a_PlayerName].position = position + counter
					self.m_Calculations[a_PlayerName].points = points
					SKYBLOCK:ScheduleTask(5, self.callback)
					return
				end
				counter = counter + 1
			end
		end
	SKYBLOCK:ScheduleTask(5, self.callback)
end


-- Override
function cChallengeValues:IsCompleted(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)

	if (self.m_Calculations[a_Player:GetName()] ~= nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("challenges.value.calculatingWait"))
		return
	end

	if (not self:HasRequirements(a_Player)) then
		return
	end

	local posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
	local chunks = GetChunks(posX, posZ, ISLAND_DISTANCE / 2)
	self.m_Calculations[a_Player:GetName()] = {}
	self.m_Calculations[a_Player:GetName()].position = 0
	self.m_Calculations[a_Player:GetName()].points = 0
	self.m_Calculations[a_Player:GetName()].chunks = chunks

	a_Player:SendMessageInfo(GetLanguage(a_Player):Get("challenges.value.calculatingStarted"))
	self:CalculateValue(a_Player:GetName())
end


-- Override
function cChallengeValues:GetChallengeType()
	return "VALUES"
end


-- Override
function cChallengeValues:InfoText(a_Player)
	return GetLanguage(a_Player):Get("challenges.info.valueInfo")
end


-- Override
function cChallengeValues:ToString()
	return "cChallengeValues"
end


-- Override
function cChallengeValues:Load(a_LevelName, a_ChallengeName, a_Json)
	-- Read basic info from challenge
	cChallengeInfo.Load(self, a_LevelName, a_ChallengeName, a_Json)

	self.m_Default.required.value = tonumber(a_Json.required.value)
end
