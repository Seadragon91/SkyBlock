-- Handle the island command
function CommandIsland(a_Split, a_Player)
	if (#a_Split == 1) then
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)
	if (islandInfo == nil) then
		a_Player:SendMessageInfo("You have no island. Type /skyblock play first.")
		return true
	end

	if (a_Split[2] == "home") then
		if (#a_Split == 3) then
			if (a_Split[3] == "set") then
				if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
					a_Player:SendMessageInfo("You can use this command only in world " + WORLD_NAME)
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
					a_Player:SendMessageInfo("You can use this command only on your own island.")
					return true
				end

				islandInfo.homeLocation = { x, y, z, yaw, pitch }
				islandInfo:Save()
				a_Player:SendMessageSuccess("Island home location changed.")
				return true
			end

			a_Player:SendMessageFailure("Unknown argument.")
			return true
		end

		if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
			if (a_Player:MoveToWorld(WORLD_NAME) == false) then
				-- Didn't find the world
				a_Player:SendMessageFailure("Command failed. Couldn't find the world " .. WORLD_NAME .. ".")
				return true
			end
		end

		-- Send player home, check home location
		if (islandInfo.homeLocation == nil) then
			local posX, posZ
			posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
			a_Player:TeleportToCoords(posX, 151, posZ)
		else
			local x = islandInfo.homeLocation[1]
			local y = islandInfo.homeLocation[2]
			local z = islandInfo.homeLocation[3]
			local yaw = islandInfo.homeLocation[4]
			local pitch = islandInfo.homeLocation[5]

			a_Player:TeleportToCoords(x, y, z)
			a_Player:SetYaw(yaw)
			a_Player:SetPitch(pitch)
		end
		a_Player:SendMessageSuccess("Welcome back " .. a_Player:GetName())
		return true
	end

	if (a_Split[2] == "obsidian") then
		if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
			a_Player:SendMessageInfo("You can use this command only in " .. WORLD_NAME .. ".")
			return true
		end
		-- Reset obsidian
		local playerInfo = GetPlayerInfo(a_Player)
		playerInfo.m_ResetObsidian = true
		a_Player:SendMessageInfo("Make now an right-click on the obsidian block without any items")
		return true
	end

	if (a_Split[2] == "add") then
		-- Add player
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/island add <player>")
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

				a_Player:SendMessageSuccess("Added player " .. a_FoundPlayer:GetName() .. " to your island.")
				return true
			end)

		if (islandInfo:ContainsFriend(toAdd) == false) then
			a_Player:SendMessageInfo("There is no player with that name.")
			return true
		end

		return true
	end

	-- Remove player
	if (a_Split[2] == "remove") then
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/island remove <player>")
			return true
		end

		if (islandInfo:RemoveFriend(a_Split[3]) == false) then
			a_Player:SendMessageInfo("There is no player with that name.")
		else
			islandInfo:Save()
			a_Player:SendMessageSuccess("Removed player from friend list.")
		end

		return true
	end

	-- Join island
	if (a_Split[2] == "join") then
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/island join <player>")
			return true
		end

		local toJoin = a_Split[3]
		if (playerInfo.m_InFriendList[toJoin:lower()] == nil) then
			a_Player:SendMessageInfo("You are not in his friend list.")
			return true
		end

		local islandInfoFriend = GetIslandInfo(playerInfo.m_InFriendList[toJoin:lower()][2])
		if (islandInfoFriend.m_Friends[a_Player:GetUUID()] == nil) then
			a_Player:SendMessageInfo("You have been removed from his friend list.")
			return true
		end

		if (islandInfoFriend.homeLocation == nil) then
			local posX, posZ
			posX, posZ = GetIslandPosition(islandInfoFriend.m_IslandNumber)
			a_Player:TeleportToCoords(posX, 151, posZ)
		else
			local x = islandInfoFriend.homeLocation[1]
			local y = islandInfoFriend.homeLocation[2]
			local z = islandInfoFriend.homeLocation[3]
			local yaw = islandInfoFriend.homeLocation[4]
			local pitch = islandInfoFriend.homeLocation[5]
		
			a_Player:TeleportToCoords(x, y, z)
			a_Player:SetYaw(yaw)
			a_Player:SetPitch(pitch)
		end

		a_Player:SendMessageSuccess("Teleported you to the island.")
		return true
	end

	-- List friends from island and islands who player can access
	if (a_Split[2] == "list") then
		local hasFriends = "Your friends: "
		local amount = GetAmount(islandInfo.m_Friends)
		local counter = 0
		for _, playerName in pairs(islandInfo.m_Friends) do
			hasFriends = hasFriends .. playerName
			counter = counter + 1
			if (counter ~= amount) then
				hasFriends = hasFriends .. ", "
			end
		end

		local canJoin = "Islands you can enter: "
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
			a_Player:SendMessageFailure("This command works only in the world " + WORLD_NAME)
			return true
		end

		if (playerInfo.m_IslandNumber == -1) then
			a_Player:SendMessageFailure("You have no island.")
			return true
		end

		if (playerInfo.m_IsRestarting ~= nil and playerInfo.m_IsRestarting) then -- Avoid running the command multiple
			a_Player:SendMessageInfo("This command is running. Please wait...")
			return true
		end

		-- Check if player is the real owner
		if (islandInfo.m_OwnerUUID ~= a_Player:GetUUID() and playerInfo.m_IsRestarting ~= nil) then
			a_Player:SendMessageInfo("Restart not possible, you are not the real owner of this island. If you want to start an own one, type again /island restart.")
			playerInfo.m_IsRestarting = nil -- Player wants to start an own island.
			return true
		end

		if (playerInfo.m_IsRestarting == nil) then
			playerInfo.m_IsRestarting = false
			local islandNumber = -1
			local posX = 0
			local posZ = 0

			islandNumber, posX, posZ = CreateIsland(a_Player, -1)
			playerInfo.m_IslandNumber = islandNumber

			local islandInfo = cIslandInfo.new(islandNumber)
			islandInfo:SetOwner(a_Player)
			islandInfo:Save()
			
			if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
				a_Player:MoveToWorld(WORLD_NAME)
			end

			a_Player:TeleportToCoords(posX, 151, posZ)
			a_Player:SendMessageSuccess("Welcome to your island. Do not fall and make no obsidian :-)")
			playerInfo:Save()
			return true
		end

		playerInfo.m_IsRestarting = true
		a_Player:TeleportToCoords(0, 170, 0) -- spawn platform

		local posX = 0
		local posZ = 0

		posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
		RemoveIsland(posX, posZ) -- Recreates all chunks in the area of the island

		a_Player:SendMessageInfo("Please wait 10s...");
		local playerName = a_Player:GetName()

		local Callback = function (a_World)
			a_World:DoWithPlayer(playerName, 
				function(a_FoundPlayer)				
					a_FoundPlayer:GetInventory():Clear()

					local playerInfo = GetPlayerInfo(a_Player)
					local islandNumber = -1
					local posX = 0
					local posZ = 0

					islandNumber, posX, posZ = CreateIsland(a_FoundPlayer, playerInfo.m_IslandNumber);
					a_FoundPlayer:TeleportToCoords(posX, 151, posZ);
					a_FoundPlayer:SetFoodLevel(20)
					a_FoundPlayer:SetHealth(a_FoundPlayer:GetMaxHealth())
					a_FoundPlayer:SendMessageSuccess("Good luck with your new island.")

					playerInfo.m_IsRestarting  = false
					playerInfo.m_IsLevel = LEVELS[1].m_LevelName
					playerInfo.m_CompletedChallenges = {}
					playerInfo.m_CompletedChallenges[playerInfo.m_IsLevel] = {}
					playerInfo:Save()
				end)
			end

		a_Player:GetWorld():ScheduleTask(200, Callback)
		return true
	end

	a_Player:SendMessageFailure("Unknown argument.")
	return true
end
