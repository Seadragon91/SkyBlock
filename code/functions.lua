-- Returns the index of the level name
function GetLevelAsNumber(a_LevelName)
	for i = 1, #LEVELS do
		if (LEVELS[i].m_LevelName == a_LevelName) then
			return i
		end
	end
end

-- Returns the amount of elements in the list
function GetAmount(a_List)
	local amount = 0
	for _,_ in pairs(a_List) do
		amount = amount + 1
	end
	return amount
end

 -- Parses all elements from the string to items and returns a list
function ParseStringToItems(a_ToParse)
	local items = {}
	local list = StringSplit(a_ToParse, " ")
	for i = 1, #list do
		local values = StringSplit(list[i], ":")
		local item = cItem()

		if (StringToItem(values[1], item)) then -- Check if valid item name
			local amount = tonumber(values[2])
			if (amount ~= nil) then -- Check if valid number
				item.m_ItemCount = amount
				if (#values == 3) then
					local dv = tonumber(values[3])
					item.m_ItemDamage = dv
				end
				items[#items + 1] = item
			end
		end
	end
	return items
end

-- Checks if the player can interact at the position
function CancelEvent(a_Player, a_BlockX, a_BlockZ)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		return false
	end

	local playerInfo = GetPlayerInfo(a_Player)
	if (a_Player:HasPermission("skyblock.admin.build")) then
		return false
	end

	if (playerInfo:HasPermissionThere(a_BlockX, a_BlockZ)) then
		return false
	end

	return true
end

-- Returns the challenge info for the challenge name
function GetChallenge(a_ChallengeName)
	for i = 1, #LEVELS do
		if (LEVELS[i].m_Challenges[a_ChallengeName] ~= nil) then
			return LEVELS[i].m_Challenges[a_ChallengeName]
		end
	end
	return nil
end

-- Return and load cPlayerInfo if necessary, should never return nil
function GetPlayerInfo(a_Player)
	local playerInfo = PLAYERS[a_Player:GetUUID()]
	if (playerInfo == nil) then
		playerInfo = cPlayerInfo.new(a_Player) -- Load or create new cPlayerInfo
		PLAYERS[a_Player:GetUUID()] = playerInfo
	end
	return playerInfo
end

-- Return and load cIslandInfo if necessary, can return nil
function GetIslandInfo(a_IslandNumber)
	local islandInfo = ISLANDS[a_IslandNumber]
	if (islandInfo == nil) then
		islandInfo = cIslandInfo.new(a_IslandNumber)
		if (not islandInfo:Load()) then -- Load cIslandInfo if exists
			return nil
		end
		ISLANDS[a_IslandNumber] = islandInfo
	end
	return islandInfo
end


-- Remove the island info from ISLAND list
function RemoveIslandInfo(a_IslandNumber)
	local islandInfo = ISLANDS[a_IslandNumber]

	if (islandInfo == nil) then
		return
	end

	if (PLAYERS[islandInfo.m_OwnerUUID] ~= nil) then
		return
	end

	for uuid, _ in pairs(islandInfo.m_Friends) do
		if (PLAYERS[uuid] ~= nil) then
			return
		end
	end

	ISLANDS[a_IslandNumber] = nil
end


function TeleportToIsland(a_Player, a_IslandInfo)
	local playerInfo = GetPlayerInfo(a_Player)
	local posX, posY, posZ, yaw, pitch
	if (a_IslandInfo == nil) then
		posX = 0
		posZ = 0
	elseif (a_IslandInfo.m_HomeLocation == nil) then
		posX, posZ = GetIslandPosition(a_IslandInfo.m_IslandNumber)
		posY = 151
	else
		posX = a_IslandInfo.m_HomeLocation[1]
		posY = a_IslandInfo.m_HomeLocation[2]
		posZ = a_IslandInfo.m_HomeLocation[3]
		yaw = a_IslandInfo.m_HomeLocation[4]
		pitch = a_IslandInfo.m_HomeLocation[5]
	end

	SKYBLOCK:ChunkStay(
		{ unpack(GetChunks(posX, posZ, 16)) },
		nil,
		function()
			if (a_IslandInfo == nil) then
				local valid, posYHeight = SKYBLOCK:TryGetHeight(posX, posZ)
				assert(valid, "TryGetHeight is not valid.") -- Should never occur

				if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
					a_Player:ScheduleMoveToWorld(SKYBLOCK, Vector3d(posX, posY, posZ))
					a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 4, "welcome"))
				else
					a_Player:TeleportToCoords(posX, posYHeight - 16, posZ)
					a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 4, "welcomeBack"))
				end
				return
			end

			a_Player:TeleportToCoords(posX, posY, posZ)
			if (yaw ~= nil) then
				a_Player:SendRotation(yaw, pitch)
			end

			local playerX = a_Player:GetPosX()
			local playerZ = a_Player:GetPosZ()
			local currentIslandNumber = GetIslandNumber(playerX, playerZ)

			-- Don't send message, if player is already in the island area
			if (currentIslandNumber == a_IslandInfo.m_IslandNumber) then
				return
			end

			if (playerInfo.m_IslandNumber == a_IslandInfo.m_IslandNumber) then
				a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 5, "welcomeBack", { ["%1"] = a_Player:GetName() }))
				return
			end
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 5, "welcomeTo", { ["%1"] = a_IslandInfo.m_OwnerName }))
		end
	)
end


function GetLanguage(a_Player)
	local playerInfo = GetPlayerInfo(a_Player)
	if (playerInfo.m_Language == "") then
		return LANGUAGES[LANGUAGE_DEFAULT]
	end
	return LANGUAGES[playerInfo.m_Language]
end


function StringToLocation(a_Location)
	local posX, posZ, posY
	local arrLoc = StringSplit(a_Location, ":")

	if (#arrLoc ~= 3) then
		return nil
	end
	posX = arrLoc[1]
	posY = arrLoc[2]
	posZ = arrLoc[3]
	return { posX, posY, posZ }
end


-- For debugging
function DEBUG(s)
	print("[DEBUG] " .. s)
end
