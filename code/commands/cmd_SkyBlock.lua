-- Handle the skyblock command
function CommandSkyBlock(a_Split, a_Player)
	if (#a_Split == 1) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 2, "skyblock"))
		return true
	end

	-- Show the skyblock help
	if (a_Split[2] == "help") then
		a_Player:SendMessage("---" .. cChatColor.LightGreen .. GetLanguage(a_Player):Get(1, 3, "title") .. cChatColor.White .. " ---")
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "1"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "2"))

		-- cmd_Challenges.lua
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "3"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "4"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "5"))

		-- cmd_Island.lua
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "6"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "7"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "8"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "9"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "10"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "11"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "12"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 3, "13"))
		return true
	end

	-- Join the world
	if (a_Split[2] == "join") then
		TeleportToIsland(a_Player) -- spawn platform
		return true
	end

	if (a_Split[2] == "play") then
		local playerInfo = GetPlayerInfo(a_Player)
		if (playerInfo.m_IslandNumber == -1) then -- Player has no island
			local posX, posZ, islandNumber = ReserveIsland(-1)

			  SKYBLOCK:ChunkStay(
				{ unpack(GetChunks(posX, posZ, 16)) },
				nil,
				function()
					CreateIsland(a_Player, posX, posZ)
					playerInfo.m_IslandNumber = islandNumber

					local islandInfo = cIslandInfo.new(islandNumber)
					islandInfo:SetOwner(a_Player)
					islandInfo:Save()

					TeleportToIsland(a_Player, islandInfo)
					a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 5, "welcome"))
					playerInfo:Save()
				end
			)
			return true
		else -- Player has an island
			local islandInfo = GetIslandInfo(playerInfo.m_IslandNumber)
			TeleportToIsland(a_Player, islandInfo)
			return true
		end
	end

	-- Recreate spawn
	if (a_Split[2] == "recreate") then
		if (not a_Player:HasPermission("skyblock.admin.recreate")) then
			a_Player:SendMessageFailure(GetLanguage(a_Player):Get(1, 2, "noPermission"))
			return true
		end

		local area = cBlockArea()
		if (area:LoadFromSchematicFile(PLUGIN:GetLocalFolder() .. "/" .. SPAWN_SCHEMATIC)) then
			local weOffset = area:GetWEOffset()
			local wex = weOffset.x
			local wey = weOffset.y
			local wez = weOffset.z

			area:Write(SKYBLOCK, 0 - wex, 169 - wey, 0 - wez, 3) -- Paste the schematic
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 6, "recreatedSpawn"))
		else
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 6, "schematicError"))
		end
		return true
	end

    if (a_Split[2] == "language") then
        if (#a_Split == 2) then
            local amount = GetAmount(LANGUAGES)
            local counter = 0
            local list = ""
            for language, _ in pairs(LANGUAGES) do
                list = list .. language
                counter = counter + 1
                if (counter ~= amount) then
                   list = list .. ", "
                end
            end
            a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 7, "languageFiles", { ["%1"] = list }))
            return true
        end

        local language = a_Split[3]
        if (LANGUAGES[language] == nil) then
            a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 7, "unknownLanguage"))
            return true
        end

        local pi = GetPlayerInfo(a_Player)
        pi.language = language
        a_Player:SendMessageSuccess(GetLanguage(a_Player):Get(1, 7, "changedLanguage", { ["%1"] = language }))
        return true
    end

	a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 2, "unknownArg"))
	return true
end
