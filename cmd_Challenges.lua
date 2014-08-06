function CommandChallenges(a_Split, a_Player) -- Handle the command challenges.    
    if (#a_Split == 1) then -- List all challenge names, light gray for completed and light green for not
        local pi = PLAYERS[a_Player:GetName()]
        local isLevel = GetLevelAsNumer(pi.isLevel)
        local pos = -1
        
        for index, level in pairs(LEVELS) do
            -- Check if player has the level
            local needLevel = GetLevelAsNumer(level.levelName)
        
            if (needLevel > isLevel) then
                pos = index
                break 
            end
        
            a_Player:SendMessageInfo("--- Level: " .. level.levelName .. " ---")
            
            local first = true
            local list = ""
            for name, ci in pairs(level.challenges) do
                if (first) then
                    first = false
                else
                    list = list .. ", "
                end
                
                if (pi:HasCompleted(level.levelName, name)) then
                    list = list .. cChatColor.LightGray .. name
                else
                    list = list .. cChatColor.LightGreen .. name
                end
            end
            a_Player:SendMessageInfo(list)
        end
        
        if (pos ~= -1) then
            print("Start: " .. pos)
            local msg = "Locked levels: "
            local first = true
            for i = pos, #LEVELS do
                print("Pos: " .. i)
                if (first) then
                    first = false
                else
                    msg = msg .. ", "
                end
                
                if (LEVELS[i] ~= nil) then
                    msg  = msg .. LEVELS[i].levelName
                end
            end
            a_Player:SendMessageInfo(msg)
        end
        
        return true
    end
        
    if (a_Split[2] == "info") then -- List all infos to a challenge
        if (#a_Split == 2) then
            a_Player:SendMessageInfo("/challenges info <name>")
            return true
        end
        
        local ci = GetChallenge(a_Split[3])
        if (ci == nil) then
            a_Player:SendMessageFailure("There is no challenge with that name.")
            return true
        end
        a_Player:SendMessage("--- " .. cChatColor.Green .. ci.challengeName .. cChatColor.White .. " ---")
        a_Player:SendMessage(cChatColor.LightBlue .. ci.description)
        a_Player:SendMessage(cChatColor.LightGreen .. "Gather this items: " .. cChatColor.White .. ci.requiredText)
        a_Player:SendMessage(cChatColor.Gold .. "You get for completion: " .. cChatColor.White .. ci.rewardText)            
        return true
    end
    
    if (a_Split[2] == "complete") then -- Complete a challenge
        local pi = PLAYERS[a_Player:GetName()]
        if (pi.islandNumber == -1) then
            a_Player:SendMessageFailure("You have no island. Type /skyblock play first.")
            return true
        end
        if (#a_Split == 2) then
            a_Player:SendMessageInfo("/challenges complete <name>")
            return true
        end
        
        local ci = GetChallenge(a_Split[3])
        if (ci == nil) then
            a_Player:SendMessageFailure("There is no challenge with that name.")
            return true
        end
        
        ci:IsCompleted(a_Player)
        return true
    end
    
    a_Player:SendMessageFailure("Unknwown argument.")
    return true
end

