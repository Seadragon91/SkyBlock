-- Handle the island command
function CommandIsland(a_Split, a_Player)
	if (#a_Split == 1) then
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)
	if (islandInfo == nil) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.noIsland"))
		return true
	end

	if (a_Split[2] == "home") then
		if (#a_Split == 3) then
			if (a_Split[3] == "set") then
				if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
					a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.notHere", { ["%1"] = WORLD_NAME }))
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
					a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.home.set_ownIsland"))
					return true
				end

				islandInfo.m_HomeLocation = { x, y, z, yaw, pitch }
				islandInfo:Save()
				a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("island.home.set_changed"))
				return true
			end

			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.unknownArg"))
			return true
		end

		TeleportToIsland(a_Player, islandInfo)
		return true
	end

	if (a_Split[2] == "obsidian") then
		if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.notHere", { ["%1"] = WORLD_NAME }))
			return true
		end
		-- Reset obsidian
		playerInfo.m_ResetObsidian = true

		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.obsidian.right_Click"))
		return true
	end

	if (a_Split[2] == "add") then
		-- Add player
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/island.add <player>")
			return true
		end

		if (a_Player:GetName():lower() == a_Split[3]:lower()) then
			return true
		end

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

				a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("island.add.addedPlayer", { ["%1"] = toAdd }))
				return true
			end)

		if (not islandInfo:ContainsFriend(toAdd)) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.noPlayer"))
			return true
		end

		return true
	end

	-- Remove player
	if (a_Split[2] == "remove") then
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/island.remove <player>")
			return true
		end

		if (not islandInfo:RemoveFriend(a_Split[3])) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.noPlayer"))
		else
			islandInfo:Save()
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("island.remove.removedPlayer"))
		end

		return true
	end

	-- Join island
	if (a_Split[2] == "join") then
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/island.join <player>")
			return true
		end

		local toJoin = a_Split[3]
		if (playerInfo.m_InFriendList[toJoin:lower()] == nil) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.join.notInFriendlist"))
			return true
		end

		local islandInfoFriend = GetIslandInfo(playerInfo.m_InFriendList[toJoin:lower()][2])
		if (islandInfoFriend.m_Friends[a_Player:GetUUID()] == nil) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.join.removedFromFriendList"))
			return true
		end

		TeleportToIsland(a_Player, islandInfoFriend)
		return true
	end

	-- List friends from island and islands who player can access
	if (a_Split[2] == "list") then
		local hasFriends = GetLanguage(a_Player):Get("island.list.friends")
		local amount = GetAmount(islandInfo.m_Friends)
		local counter = 0
		for _, playerName in pairs(islandInfo.m_Friends) do
			hasFriends = hasFriends .. playerName
			counter = counter + 1
			if (counter ~= amount) then
				hasFriends = hasFriends .. ", "
			end
		end

		local canJoin = GetLanguage(a_Player):Get("island.list.canEnter")
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

	-- Restart island
	if (a_Split[2] == "restart") then
		if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.notHere", { ["%1"] = WORLD_NAME }))
			return true
		end

		if (playerInfo.m_IsRestarting) then -- Avoid running the command multiple
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.restart.running"))
			return true
		end

		-- Check if player is the real owner
		if (islandInfo.m_OwnerUUID ~= a_Player:GetUUID() and playerInfo.m_IsRestarting ~= nil) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.restart.notOwner"))
			playerInfo.m_IsRestarting = nil -- Player wants to start an own island.
			return true
		end

		if (playerInfo.m_IsRestarting == nil) then
			playerInfo.m_IsRestarting = false
			local posX, posZ, islandNumber = ReserveIsland(playerInfo.m_IslandNumber)

			SKYBLOCK:ChunkStay(
				{ unpack(GetChunks(posX, posZ, 16)) },
				nil,
				function()
					CreateIsland(a_Player, posX, posZ)

					local islandInfo = cIslandInfo.new(islandNumber)
					islandInfo:SetOwner(a_Player)
					islandInfo:Save()

					if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
						a_Player:ScheduleMoveToWorld(SKYBLOCK, Vector3d(posX, 151, posZ))
					end

					a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("skyblock.play.welcome"))
					playerInfo:Save()
				end
			)
			return true
		end

		playerInfo.m_IsRestarting = true
		TeleportToIsland(a_Player) -- spawn platform

		local posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
		RemoveIsland(posX, posZ) -- Recreates all chunks in the area of the island

		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.restart.wait"));
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
							a_FoundPlayer:SendMessageSuccess(GetLanguage(a_Player):Get("island.restart.newIsland"))

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

	a_Player:SendMessageInfo(GetLanguage(a_Player):Get("island.general.unknownArg"))
	return true
end
