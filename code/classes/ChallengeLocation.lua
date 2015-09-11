-- Challenge class for locations

cChallengeLocation = {}
cChallengeLocation.__index = cChallengeLocation

function cChallengeLocation.new()
	local self = setmetatable({}, cChallengeLocation)
	setmetatable(cChallengeLocation, {__index = cChallengeInfo})
	return self
end


-- Override
function cChallengeLocation:IsCompleted(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)

	if (not self:HasRequirements(a_Player)) then
		return
	end

	local playerX = a_Player:GetPosX()
	local playerY = a_Player:GetPosY()
	local playerZ = a_Player:GetPosZ()

	local islandY = 150
	local islandX, islandZ = GetIslandPosition(playerInfo.m_IslandNumber)

	if ((playerX >= (islandX + self.m_StartX) and playerX <= (islandX + self.m_EndX)) and
		(playerY >= (islandY + self.m_StartY) and playerY <= (islandY + self.m_EndY)) and
		(playerZ >= (islandZ + self.m_StartZ) and playerZ <= (islandZ + self.m_EndZ))) then
		self:Complete(a_Player)
	else
		local locStart = (islandX + self.m_StartX) .. ":" .. (islandY + self.m_StartY) .. ":" .. (islandZ + self.m_StartZ)
		local locEnd = (islandX + self.m_EndX) .. ":" .. (islandY + self.m_EndY) .. ":" .. (islandZ + self.m_EndZ)
		a_Player:SendMessageInfo("You have to be between this two locations:" .. locStart .. " - " .. locEnd)
	end
end


-- Override
function cChallengeLocation:GetChallengeType()
	return "LOCATION"
end


-- Override
function cChallengeLocation:InfoText(a_Player)
	return GetLanguage(a_Player):Get(2, 4, "locationInfo")
end


-- Override
function cChallengeLocation:ToString()
	return "cChallengeLocation"
end


-- Override
function cChallengeLocation:GetRequiredText(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)
	local islandY = 150
	local islandX, islandZ = GetIslandPosition(playerInfo.m_IslandNumber)

	local ret = tostring(islandX + self.reachLocation[1]) .. ":"
	ret = ret .. tostring(islandY + self.reachLocation[2]) .. ":"
	ret = ret .. tostring(islandZ + self.reachLocation[3])
	return ret
end


-- Override
function cChallengeLocation:Load(a_LevelIni)
	-- The reach position is: islandX + reachX, 150 + reachY, islandZ + reachZ, with a redius of 2 blocks.
	self.reachLocation = StringToLocation(a_LevelIni:GetValue(self.m_ChallengeName, "reachLocation"))
	if (self.reachLocation == nil) then
		LOGERROR("In challenge " .. self.m_ChallengeName .. " is reachLocation not valid. Has to have the format x:y:z")
		return false
	end

	local radius = 2
	self.m_StartX = self.reachLocation[1] - radius
	self.m_StartY = self.reachLocation[2] - radius
	self.m_StartZ = self.reachLocation[3] - radius

	self.m_EndX = self.reachLocation[1]  + radius
	self.m_EndY = self.reachLocation[2]  + radius
	self.m_EndZ = self.reachLocation[3]  + radius

	return true
end
