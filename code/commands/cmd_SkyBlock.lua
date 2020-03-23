-- Handle the skyblock command
function CommandSkyBlock(a_Split, a_Player)
	if (#a_Split == 1) then
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.general.skyblock"))
		return true
	end

	-- Show the skyblock.help
	if (a_Split[2] == "help") then
		a_Player:SendMessage(GetLanguage(a_Player):Get("skyblock.help.title"))

		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.join"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.play"))

		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isHome"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isHomeSet"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isObsidian"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isAddFriend"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isAddGuest"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.IsRemove"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.IsJoin"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isList"))
		a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.help.isRestart"))
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
					a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("skyblock.play.welcome"))
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
			a_Player:SendMessageFailure(GetLanguage(a_Player):Get("skyblock.general.noPermission"))
			return true
		end

		local area = cBlockArea()
		if (area:LoadFromSchematicFile(PLUGIN:GetLocalFolder() .. "/" .. SPAWN_SCHEMATIC)) then
			local weOffset = area:GetWEOffset()
			local wex = weOffset.x
			local wey = weOffset.y
			local wez = weOffset.z

			area:Write(SKYBLOCK, 0 - wex, 169 - wey, 0 - wez, 3) -- Paste the schematic
			a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("skyblock.recreate.recreatedSpawn"))
		else
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.recreate.schematicError"))
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
	        a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.language.languageFiles", { ["%1"] = list }))
	        return true
	    end

		local language = a_Split[3]
	    if (LANGUAGES[language] == nil) then
	        a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.language.unknownLanguage"))
	        return true
	    end

	    local pi = GetPlayerInfo(a_Player)
		pi.m_Language = language
		pi:Save()
	    a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("skyblock.language.changedLanguage", { ["%1"] = language }))
	    return true
	end

	a_Player:SendMessageInfo(GetLanguage(a_Player):Get("skyblock.general.unknownArg"))
	return true
end
