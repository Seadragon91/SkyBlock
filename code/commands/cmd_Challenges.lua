-- Handle the command challenges
function CommandChallenges(a_Split, a_Player) 
	-- List all challenge names:
	--	 light gray for completed
	--	 light blue for repeatable 
	--	 light green for not completed
	if (#a_Split == 1) then
		local playerInfo = GetPlayerInfo(a_Player)
		local isLevel = GetLevelAsNumber(playerInfo.m_IsLevel)
		local pos = -1

		for index, level in pairs(LEVELS) do
			-- Check if player has the required level
			local needLevel = GetLevelAsNumber(level.m_LevelName)
			if (needLevel > isLevel) then
				pos = index
				break
			end

			a_Player:SendMessageInfo("--- Level: " .. level.m_LevelName .. " ---")
			local first = true
			local list = ""
			for challengeName, challengeInfo in pairs(level.m_Challenges) do
				if (first) then
					first = false
				else
					list = list .. ", "
				end

				if (playerInfo:HasCompleted(level.m_LevelName, challengeName)) then
					if (challengeInfo.m_IsRepeatable) then
						list = list .. cChatColor.LightBlue .. challengeName
					else
						list = list .. cChatColor.LightGray .. challengeName
					end
				else
					list = list .. cChatColor.LightGreen .. challengeName
				end
			end
			a_Player:SendMessageInfo(list)
		end

		if (pos ~= -1) then
			local msg = "Locked levels: "
			local first = true
			for i = pos, #LEVELS do
				if (first) then
					first = false
				else
					msg = msg .. ", "
				end

				if (LEVELS[i] ~= nil) then
					msg  = msg .. LEVELS[i].m_LevelName
				end
			end
			a_Player:SendMessageInfo(msg)
		end

		return true
	end

	-- List all infos to a challenge
	if (a_Split[2] == "info") then
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/challenges info <name>")
			return true
		end
		local challengeInfo = GetChallenge(a_Split[3])
		if (challengeInfo == nil) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "unknownName"))
			return true
		end

		a_Player:SendMessage("--- " .. cChatColor.Green .. challengeInfo.m_ChallengeName .. cChatColor.White .. " ---")
		a_Player:SendMessage(cChatColor.LightBlue .. challengeInfo.m_Description)
		a_Player:SendMessage(cChatColor.LightGreen .. challengeInfo:InfoText(a_Player) .. cChatColor.White .. challengeInfo:GetRequiredText(a_Player))
		a_Player:SendMessage(cChatColor.Gold .. GetLanguage(a_Player):Get(2, 3, "forCompletion") .. cChatColor.White .. challengeInfo.m_RewardText)

		if (challengeInfo.m_IsRepeatable) then
			a_Player:SendMessage(cChatColor.Blue .. GetLanguage(a_Player):Get(2, 3, "forRepeating"))
			a_Player:SendMessage(cChatColor.LightGreen .. challengeInfo:InfoText(a_Player) .. cChatColor.White .. challengeInfo:GetRptRequiredText(a_Player))
			a_Player:SendMessage(cChatColor.Gold .. GetLanguage(a_Player):Get(2, 3, "forCompletion") .. cChatColor.White .. challengeInfo.m_RptRewardText)
		end

		return true
	end

	if (a_Split[2] == "complete") then -- Complete a challenge
		local playerInfo = GetPlayerInfo(a_Player)
		if (playerInfo.m_IslandNumber == -1) then
			a_Player:SendMessageInfo("You have no island. Type /skyblock play first.")
			return true
		end
		if (#a_Split == 2) then
			a_Player:SendMessageInfo("/challenges complete <name>")
			return true
		end

		local challengeInfo = GetChallenge(a_Split[3])
		if (challengeInfo == nil) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "unknownName"))
			return true
		end

		challengeInfo:IsCompleted(a_Player)
		return true
	end

	-- For checking a challenge
	if (a_Split[2] == "check") then
		if (not a_Player:HasPermission("challenges.admin.check")) then
			a_Player:SendMessageFailure(GetLanguage(a_Player):Get(1, 2, "noPermission"))
			return true
		end

		if (#a_Split < 4) then
			a_Player:SendMessageInfo("/challenges check <name> <req,rew> [rpt]")
			return true
		end

		local challengeInfo = GetChallenge(a_Split[3])
		if (challengeInfo == nil) then
			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 4, "unknownName"))
			return true
		end

		 if (a_Split[4] == "req") then
			if (#a_Split == 5 and a_Split[5] == "rpt") then
				if (not challengeInfo.m_IsRepeatable) then
					a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 5, "noRepeatableItems"))
					return true
				end

				for i = 1, #challengeInfo.m_RptRequiredItems do
					a_Player:GetInventory():AddItem(challengeInfo.m_RptRequiredItems[i])
				end
			else
				for i = 1, #challengeInfo.m_RequiredItems do
					a_Player:GetInventory():AddItem(challengeInfo.m_RequiredItems[i])
				end
			end

			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 5, "gotRequiredItems"))
			return true
		end

		if (a_Split[4] == "rew") then
			if (#a_Split == 5 and a_Split[5] == "rpt") then
				if (not challengeInfo.m_IsRepeatable) then
					a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 5, "noRepeatableItems"))
					return true
				end

				for i = 1, #challengeInfo.m_RptRewardItems do
					a_Player:GetInventory():AddItem(challengeInfo.m_RptRewardItems[i])
				end
			else
				for i = 1, #challengeInfo.m_RewardItems do
					a_Player:GetInventory():AddItem(challengeInfo.m_RewardItems[i])
				end
			end

			a_Player:SendMessageInfo(GetLanguage(a_Player):Get(2, 5, "gotRewardItems"))
			return true
		end
	end

	a_Player:SendMessageInfo(GetLanguage(a_Player):Get(1, 2, "unknownArg"))
	return true
end
