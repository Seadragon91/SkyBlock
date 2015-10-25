-- Handle the island command

function HandleIslandHome(a_Split, a_Player)
	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)
	if (islandInfo == nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "noIsland"))
		return true
	end

	if (#a_Split == 3) then
		if (a_Split[3] == "set") then
			if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
				a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "notHere", { ["%1"] = WORLD_NAME }))
				return true
			end

			local x = a_Player:GetPosX()
			local y = a_Player:GetPosY()
			local z = a_Player:GetPosZ()
			local yaw = a_Player:GetHeadYaw()
			local pitch = a_Player:GetPitch()

			-- Check if player is in his island area
			local islandNumber = GetIslandNumber(x, z)
			if (playerInfo.m_IslandNumber ~= islandNumber) then
				a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 3, "set_ownIsland"))
				return true
			end

			islandInfo.m_HomeLocation = { x, y, z, yaw, pitch }
			islandInfo:Save()
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(3, 3, "set_changed"))
			return true
		end

		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "unknownArg"))
		return true
	end

	TeleportToIsland(a_Player, islandInfo)
	return true
end



function HandleIslandObsidian(a_Split, a_Player)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "notHere", { ["%1"] = WORLD_NAME }))
		return true
	end

	-- Reset obsidian
	local playerInfo = GetPlayerInfo(a_Player)
	playerInfo.m_ResetObsidian = true

	a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 4, "right-Click"))
	return true
end



function HandleIslandAdd(a_Split, a_Player)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "notHere", { ["%1"] = WORLD_NAME }))
		return true
	end

	if (#a_Split == 2) then
		a_Player:SendMessageInfo("/island add <player>")
		return true
	end

	if (a_Player:GetName():lower() == a_Split[3]:lower()) then
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)

	local toAdd = a_Split[3]
	a_Player:GetWorld():DoWithPlayer(toAdd,
		function (a_FoundPlayer)
			islandInfo:AddFriend(a_FoundPlayer)
			islandInfo:Save()

			-- Add Entry to inFriendList
			local playerInfo_Added = GetPlayerInfo(a_FoundPlayer)
			playerInfo_Added:AddEntry(islandInfo.m_IslandNumber, a_Player)

			-- Check if player has no island, if yes set first added as default
			if (playerInfo_Added.m_IslandNumber == -1) then
				playerInfo_Added.m_IslandNumber = islandInfo.m_IslandNumber
			end
			playerInfo_Added:Save()

			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(3, 5, "addedPlayer", { ["%1"] = toAdd }))
			return true
		end)

	if (not islandInfo:ContainsFriend(toAdd)) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "noPlayer"))
	end
	return true
end



function HandleIslandRemove(a_Split, a_Player)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "notHere", { ["%1"] = WORLD_NAME }))
		return true
	end

	if (#a_Split == 2) then
		a_Player:SendMessageInfo("/island remove <player>")
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)

	if (not islandInfo:RemoveFriend(a_Split[3])) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "noPlayer"))
	else
		islandInfo:Save()
		a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(3, 6, "removedPlayer"))
	end
    return true
end



function HandleIslandJoin(a_Split, a_Player)
	if (#a_Split == 2) then
		a_Player:SendMessageInfo("/island join <player>")
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)

	local toJoin = a_Split[3]
	if (playerInfo.m_InFriendList[toJoin:lower()] == nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 7, "notInFriendlist"))
		return true
	end

	local islandInfoFriend = GetIslandInfo(playerInfo.m_InFriendList[toJoin:lower()][2])
	if (islandInfoFriend.m_Friends[a_Player:GetUUID()] == nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 7, "removedFromFriendList"))
		return true
	end

	TeleportToIsland(a_Player, islandInfoFriend)
	return true
end



function HandleIslandList(a_Split, a_Player)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "notHere", { ["%1"] = WORLD_NAME }))
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)

	-- List friends from island and islands who player can access
	local hasFriends = GetLanguage(a_Player):Get(3, 8, "friends")
	local amount = GetAmount(islandInfo.m_Friends)
	local counter = 0
	for _, playerName in pairs(islandInfo.m_Friends) do
		hasFriends = hasFriends .. playerName
		counter = counter + 1
		if (counter ~= amount) then
			hasFriends = hasFriends .. ", "
		end
	end

	local canJoin = GetLanguage(a_Player):Get(3, 8, "canEnter")
	amount = GetAmount(playerInfo.m_InFriendList)
	counter = 0
	for playerName, _ in pairs(playerInfo.m_InFriendList) do
		canJoin = canJoin .. playerName
		counter = counter + 1
		if (counter ~= amount) then
			canJoin = canJoin .. ", "
		end
	end

	a_Player:SendMessageInfo(hasFriends)
	a_Player:SendMessageInfo(canJoin)
	return true
end



function HandleIslandRestart(a_Split, a_Player)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 2, "notHere", { ["%1"] = WORLD_NAME }))
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)

	if (playerInfo.m_IsRestarting) then -- Avoid running the command multiple
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 9, "running"))
		return true
	end

	-- Check if player is the real owner
	if (islandInfo.m_OwnerUUID ~= a_Player:GetUUID() and playerInfo.m_IsRestarting ~= nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(3, 9, "notOwner"))
		playerInfo.m_IsRestarting = nil -- Player wants to start an own island.
		return true
	end

	if (playerInfo.m_IsRestarting == nil) then
		playerInfo.m_IsRestarting = false
		local islandNumber = -1
		local posX, posZ, islandNumber = ReserveIsland(islandNumber)

		SKYBLOCK:ChunkStay(
			{ unpack(GetChunks(posX, posZ, 16)) },
			nil,
			function()
				CreateIsland(a_Player, posX, posZ)

				local islandInfo = cIslandInfo.new(islandNumber)
				islandInfo:SetOwner(a_Player)
				islandInfo:Save()

				if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
					a_Player:MoveToWorld(WORLD_NAME)
				end

				a_Player:TeleportToCoords(posX, 151, posZ)
				a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 5, "welcome"))
				playerInfo:Save()
			end
		)
		return true
	end

	playerInfo.m_IsRestarting = true
	TeleportToIsland(a_Player) -- spawn platform

	local posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
	RemoveIsland(posX, posZ) -- Recreates all chunks in the area of the island

	a_Player:SendMessageInfo("Please wait 10s...");
	local playerName = a_Player:GetName()

	local Callback = function (a_World)
		a_World:DoWithPlayer(playerName,
			function(a_FoundPlayer)
				a_FoundPlayer:GetInventory():Clear()
				local playerInfo = GetPlayerInfo(a_Player)
				CreateIsland(a_FoundPlayer, posX, posZ)

				SKYBLOCK:ChunkStay(
					{ unpack(GetChunks(posX, posZ, 16)) },
					nil,
					function()
						a_FoundPlayer:TeleportToCoords(posX, 151, posZ);
						a_FoundPlayer:SetFoodLevel(20)
						a_FoundPlayer:SetHealth(a_FoundPlayer:GetMaxHealth())
						a_FoundPlayer:SendMessageSuccess(GetLanguage(a_Player):Get(3, 9, "newIsland"))

						playerInfo.m_IsRestarting  = false
						playerInfo.m_IsLevel = LEVELS[1].m_LevelName
						playerInfo.m_CompletedChallenges = {}
						playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel] = {}
						playerInfo:Save()
					end
				)
			end)
		end

	a_Player:GetWorld():ScheduleTask(200, Callback)
	return true
end
