-- Air generator
function OnChunkGenerating(a_World, a_ChunkX, a_ChunkZ, a_ChunkDesc)
	if (a_World:GetName() == WORLD_NAME) then
		FillBlocks(a_ChunkDesc) -- fill entire chunk with air
	end
end

function FillBlocks(a_ChunkDesc)
	a_ChunkDesc:FillBlocks(E_BLOCK_AIR, 0)
	a_ChunkDesc:SetUseDefaultBiomes(false)
	a_ChunkDesc:SetUseDefaultHeight(false)
	a_ChunkDesc:SetUseDefaultComposition(false)
	a_ChunkDesc:SetUseDefaultFinish(false)
end

-- Player quits
function OnPlayerQuit(a_Player)
	RemovePlayer(a_Player, a_Player:GetWorld():GetName())
end


function RemovePlayer(a_Player, a_WorldName)
	if (a_WorldName == WORLD_NAME) then
		local playerInfo = GetPlayerInfo(a_Player)
		PLAYERS[a_Player:GetUUID()] = nil
		local islandNumber = playerInfo.m_IslandNumber
		RemoveIslandInfo(islandNumber)

		-- Try ro remove island info from ISLANDS list
		for player, _ in pairs(playerInfo.m_InFriendList) do
			RemoveIslandInfo(playerInfo.m_InFriendList[player][2])
		end
	end
end

-- Teleport player to island or spawn platform
function OnPlayerSpawn(a_Player)
	if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
		return
	end

	local playerInfo = GetPlayerInfo(a_Player)
	if (playerInfo.m_IslandNumber == -1) then -- no island
		local playerName = a_Player:GetName()
		
		local Callback = function(a_World)
			a_World:DoWithPlayer(playerName,
				function(a_FoundPlayer)
					a_FoundPlayer:TeleportToCoords(0, 170, 0)
				end)
			end

		a_Player:GetWorld():ScheduleTask(10, Callback)
	else
		-- Lets check players location
		if (playerInfo.m_IslandNumber == GetIslandNumber(a_Player:GetPosX(), a_Player:GetPosZ())) then
			return -- His island, return here then he gets to the last position
		end

		local posX, posZ = GetIslandPosition(playerInfo.m_IslandNumber)
		local playerName = a_Player:GetName()

		local Callback = function(a_World)
			a_World:DoWithPlayer(playerName,
				function(a_FoundPlayer)				
					a_FoundPlayer:TeleportToCoords(posX, 151, posZ)
				end)
			end

		a_Player:GetWorld():ScheduleTask(10, Callback)
	end
end

function OnPlayerChangedWorld(a_Entity, a_FromWorld)
	if (not a_Entity:IsPlayer()) then
		return
	end
	RemovePlayer(a_Entity, a_FromWorld:GetName())
end

-- Handle the spawn schematic
function OnWorldLoaded(a_World)
	if (a_World:GetName() ~= WORLD_NAME) then
		return
	end

	if (SPAWN_CREATED) then
		return
	end

	-- Load chunks for spawn tower
	SKYBLOCK:ChunkStay(
		{ {0,0}, {-1,0}, {-1,-1}, {0,-1} },
		nil,
		function()
			local area = cBlockArea()
			if (area:LoadFromSchematicFile(PLUGIN:GetLocalFolder() .. "/" .. SPAWN_SCHEMATIC)) then
				local weOffset = area:GetWEOffset()
				local wex = weOffset.x
				local wey = weOffset.y
				local wez = weOffset.z

				area:Write(SKYBLOCK, 0 - wex, 169 - wey, 0 - wez) -- Paste the schematic
				SPAWN_CREATED = true
				SaveConfiguration()
			else -- Error or no schematic found, create default spawn
				for x = -5,5 do
					for z = -5,5 do
						SKYBLOCK:SetBlock(x, 169, z, E_BLOCK_STONE, 0)
					end
				end
				SPAWN_CREATED = true
				SaveConfiguration()
			end
		end
	)
end

function OnBlockPlacing(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ, a_BlockType, a_BlockMeta)
	return CancelEvent(a_Player, a_BlockX, a_BlockZ)
end

function OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
	return CancelEvent(a_Player, a_BlockX, a_BlockZ)
end

function OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
	if (a_BlockFace == BLOCK_FACE_NONE) then
		if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
			return false
		end

		local posX = a_Player:GetPosX()
		local posZ = a_Player:GetPosZ()

		if(a_Player:GetEquippedItem().m_ItemType == 280) then
			local islandNumber = GetIslandNumber(posX, posZ)
			if (islandNumber == 0) then
				a_Player:SendMessageInfo(GetLanguage(a_Player):Get(4, 2, "spawnArea"))
				return true
			end

			local islandInfo = GetIslandInfo(islandNumber)
			if (islandInfo == nil) then
				a_Player:SendMessageInfo(GetLanguage(a_Player):Get(4, 2, "unknownArea"))
				return true
			end

			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(4, 2, "islandNumber", { ["%1"] = islandInfo.m_IslandNumber }))
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(4, 2, "islandOwner", { ["%1"] = islandInfo.m_OwnerName }))

			local friends = GetLanguage(a_Player):Get(4, 2, "friends")
			local amount = GetAmount(islandInfo.m_Friends)
			local counter = 0
			for _, playerName in pairs(islandInfo.m_Friends) do
				friends = friends .. playerName
				counter = counter + 1
				if (counter ~= amount) then
					friends = friends .. ", "
				end
			end

			a_Player:SendMessageInfo(friends)
			return true
		end
		return CancelEvent(a_Player, posX, posZ)
	end

	if (CancelEvent(a_Player, a_BlockX, a_BlockZ)) then
		return true
	end

	local playerInfo = GetPlayerInfo(a_Player)
	if (not playerInfo.m_ResetObsidian) then
		return false
	end

	if (a_Player:GetEquippedItem().m_ItemType ~= -1) then
		return false
	end

	if (a_Player:GetWorld():GetBlock(a_BlockX, a_BlockY, a_BlockZ) == E_BLOCK_OBSIDIAN) then
		a_Player:GetWorld():SetBlock(a_BlockX, a_BlockY, a_BlockZ, E_BLOCK_LAVA, 0)
		playerInfo.m_ResetObsidian = false
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(4, 2, "obsidianToLava"))
	end
end

function OnTakeDamage(a_Receiver, a_TDI)
	if (a_Receiver:GetWorld():GetName() ~= WORLD_NAME) then
		return true
	end

	if ((a_TDI.Attacker ~= nil) and (a_TDI.Attacker:IsA("cPlayer"))) then
		local player = tolua.cast(a_TDI.Attacker, "cPlayer")
		if (CancelEvent(player, player:GetPosX(), player:GetPosZ())) then
			return true
		end
	end
end
