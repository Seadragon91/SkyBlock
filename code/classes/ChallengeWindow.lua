cChallengeWindow = {}
cChallengeWindow.__index = cChallengeWindow



function cChallengeWindow.Open(a_Player)
	local inv = cLuaWindow(cWindow.wtChest, 9, 4, GetLanguage(a_Player):Get("challenges.window.title"))
	inv:SetOnClicked(cChallengeWindow.OnChallengeWindowClick)

	cChallengeWindow.UpdateView(a_Player, inv:GetContents())

	a_Player:OpenWindow(inv)
end



function cChallengeWindow.UpdateView(a_Player, a_ItemGrid)
	local playerInfo = GetPlayerInfo(a_Player)

	-- Clear current item grid
	a_ItemGrid:Clear()

	local level = LEVELS[playerInfo.m_WinChallengePosition]

	level.m_DisplayItem.m_CustomName = GetLanguage(a_Player):Get("challenges.window.levelInfo", { ["%1"] = level.m_LevelName })
	a_ItemGrid:SetSlot(4, 0, level.m_DisplayItem)

	cChallengeWindow.AddItemBack(a_Player, a_ItemGrid, playerInfo)
	cChallengeWindow.AddItemForward(a_Player, a_ItemGrid, playerInfo)

	local x = 0
	local y = 1
	for challengeName, challengeInfo in pairs(level.m_Challenges) do
		local item
		if playerInfo:HasCompleted(level.m_LevelName, challengeName) then
			item = cChallengeWindow.CreateItem(a_Player, challengeInfo, true)
		else
			item = cChallengeWindow.CreateItem(a_Player, challengeInfo)
		end

		a_ItemGrid:SetSlot(x, y, item)

		if (x == 8) then
			x = 1
			y = y + 1
		else
			x = x + 1
		end
	end
end



function cChallengeWindow.CreateItem(a_Player, a_ChallengeInfo, a_Completed)
	local lore = {}

	if a_ChallengeInfo.m_IsRepeatable then
		table.insert(lore, GetLanguage(a_Player):Get("challenges.window.isRepeatable"))
	elseif a_Completed then
		local itemDisplay = cItem(a_ChallengeInfo.m_DisplayItem)
		itemDisplay.m_CustomName = cChatColor.Rose .. a_ChallengeInfo.m_ChallengeName
		itemDisplay.m_LoreTable =  { GetLanguage(a_Player):Get("challenges.window.isCompleted") }
		return itemDisplay
	end

	table.insert(lore, cChatColor.Blue .. a_ChallengeInfo.m_Description)

	if a_ChallengeInfo:GetChallengeType() == "ITEMS" then
		table.insert(lore, GetLanguage(a_Player):Get("challenges.window.requiredItems"))
	elseif a_ChallengeInfo:GetChallengeType() == "VALUES" then
		table.insert(lore, GetLanguage(a_Player):Get("challenges.window.requiredIslandValue"))
	elseif a_ChallengeInfo:GetChallengeType() == "BLOCKS" then
		-- TODO
		table.insert(lore, GetLanguage(a_Player):Get("challenges.window.requiredBlocks"))
	end

	local itemDisplay
	if a_Completed then
		itemDisplay = a_ChallengeInfo.m_DisplayItem
	else
		itemDisplay = cItem(E_BLOCK_STAINED_GLASS_PANE, 1, 4)
	end
	itemDisplay.m_CustomName = cChatColor.Rose .. a_ChallengeInfo.m_ChallengeName

	local arrLines
	if a_Completed then
		arrLines = cChallengeWindow.CreateInfo(a_Player, a_ChallengeInfo.m_Repeat)
	else
		arrLines = cChallengeWindow.CreateInfo(a_Player, a_ChallengeInfo.m_Default)
	end

	for _, line in ipairs(arrLines) do
		table.insert(lore, line)
	end

	itemDisplay.m_LoreTable = lore
	return itemDisplay
end


function cChallengeWindow.CreateInfo(a_Player, a_TbInfo)
	local tbRet = {}
	local textRequired = wrap(a_TbInfo.required.text, 40)
	for _, line in ipairs(StringSplit(textRequired, "\n")) do
		table.insert(tbRet, cChatColor.Rose .. line)
	end

	table.insert(tbRet, GetLanguage(a_Player):Get("challenges.window.reward"))
	local textReward = wrap(a_TbInfo.reward.text, 40)
	for _, line in ipairs(StringSplit(textReward, "\n")) do
		table.insert(tbRet, cChatColor.LightBlue .. line)
	end

	table.insert(tbRet, GetLanguage(a_Player):Get("challenges.window.clickToComplete"))
	return tbRet
end


function cChallengeWindow.AddItemBack(a_Player, a_ItemGrid, a_PlayerInfo)
	if a_PlayerInfo.m_WinChallengePosition == 1 then
		return
	end

	local itemBack = cItem(E_ITEM_WATER_BUCKET)
	itemBack.m_CustomName = GetLanguage(a_Player):Get("challenges.window.goBack")

	a_ItemGrid:SetSlot(3, 0, itemBack)
end



function cChallengeWindow.AddItemForward(a_Player, a_ItemGrid, a_PlayerInfo)
	if a_PlayerInfo.m_WinChallengePosition == #LEVELS then
		return
	end

	local itemForward = cItem(E_ITEM_LAVA_BUCKET)
	if a_PlayerInfo.m_WinChallengePosition + 1 > GetLevelAsNumber(a_PlayerInfo.m_IsLevel) then
		local amountDone = GetAmount(a_PlayerInfo.m_CompletedChallenges[a_PlayerInfo.m_IsLevel])
		local amountNeeded = LEVELS[a_PlayerInfo.m_WinChallengePosition].m_CompleteForNextLevel
		local missing = amountNeeded - amountDone
		itemForward.m_CustomName = GetLanguage(a_Player):Get("challenges.window.nextLevel",
			{ ["%1"] = LEVELS[a_PlayerInfo.m_WinChallengePosition + 1].m_LevelName })
		itemForward.m_LoreTable = { GetLanguage(a_Player):Get("challenges.window.moreToUnlock", { ["%1"] = missing }) }
	else
		itemForward.m_CustomName = GetLanguage(a_Player):Get("challenges.window.goForward")
	end
	a_ItemGrid:SetSlot(5, 0, itemForward)
end



function cChallengeWindow.OnChallengeWindowClick(a_Window, a_Player, a_SlotNum, a_ClickAction, a_ClickedItem)
	if a_ClickAction ~= 0 then
		-- Only left click allowed
		return true
	end

	if a_SlotNum >= a_Window:GetContents():GetNumSlots() then
		-- Not clicked in challenge window
		return true
	end

	local itemClicked = a_Window:GetContents():GetSlot(a_SlotNum)
	local playerInfo = GetPlayerInfo(a_Player)

	-- Forward
	if (a_SlotNum == 5) then
		if (itemClicked.m_ItemType ~= -1) then
			-- Check if player has level
			local currentLevel = GetLevelAsNumber(playerInfo.m_IsLevel)
			if playerInfo.m_WinChallengePosition + 1 > currentLevel then
				return true
			end

			playerInfo.m_WinChallengePosition = playerInfo.m_WinChallengePosition + 1
			cChallengeWindow.UpdateView(a_Player, a_Window:GetContents())
		end
		return true
	end

	-- Backward
	if (a_SlotNum == 3) then
		if (itemClicked.m_ItemType ~= -1) then
			playerInfo.m_WinChallengePosition = playerInfo.m_WinChallengePosition - 1
			cChallengeWindow.UpdateView(a_Player, a_Window:GetContents())
		end
		return true
	end
	-- Get challenge name
	-- TODO: Better solution...
	local challengeName = itemClicked.m_CustomName:gsub('%W','')
	challengeName = challengeName:sub(2, challengeName:len())

	-- Get challenge info
	local challengeInfo = GetChallenge(challengeName)
	if challengeInfo == nil then
		return true
	end

	if (not(challengeInfo.m_IsRepeatable) and playerInfo:HasCompleted(challengeInfo.m_LevelName, challengeName)) then
		-- cChallengeWindow.UpdateView(a_Player, a_Window:GetContents())
		local item = cChallengeWindow.CreateItem(a_Player, challengeInfo, true)
		a_Window:GetContents():SetSlot(a_SlotNum, item)
		return true
	end

	if not(challengeInfo:IsCompleted(a_Player)) then
		-- TODO: Update info with missing amount?
		return true
	end

	cChallengeWindow.AddItemForward(a_Player, a_Window:GetContents(), playerInfo)

	if itemClicked.m_ItemType ~= challengeInfo.m_DisplayItem then
		local item = cChallengeWindow.CreateItem(a_Player, challengeInfo, true)
		a_Window:GetContents():SetSlot(a_SlotNum, item)
	end
	return true
end

