 -- Handle the command challenges
function CommandChallenges(a_Split, a_Player) 
    if (#a_Split == 1) then -- List all challenge names, light gray for completed, light blue for repeatable and light green for not
        local pi = GetPlayerInfo(a_Player)
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
                    if (ci.repeatable == true) then
                        list = list .. cChatColor.LightBlue .. name
                    else
                        list = list .. cChatColor.LightGray .. name
                    end
                else
                    list = list .. cChatColor.LightGreen .. name
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
        
        if (ci.repeatable) then
            a_Player:SendMessage(cChatColor.Blue .. "For repeating:")
            a_Player:SendMessage(cChatColor.LightGreen .. "Gather this items: " .. cChatColor.White .. ci.rpt_requiredText)
            a_Player:SendMessage(cChatColor.Gold .. "You get for completion: " .. cChatColor.White .. ci.rpt_rewardText)
        end
                
        return true
    end
    
    if (a_Split[2] == "complete") then -- Complete a challenge
        local pi = GetPlayerInfo(a_Player)
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
    
    if (a_Split[2] == "check") then -- For checking a challenge.
        if (a_Player:HasPermission("challenges.admin.check") == false) then
            a_Player:SendMessageFailure("You don't have the permission for that command.")
            return true
        end
        
    
        if (#a_Split < 4) then
            a_Player:SendMessageInfo("/challenges check <name> <req,rew> [rpt]")
            return true
        end
        
        local ci = GetChallenge(a_Split[3])
        if (ci == nil) then
            a_Player:SendMessageFailure("There is no challenge with that name.")
            return true
        end
        
         if (a_Split[4] == "req") then
            if (#a_Split == 5 and a_Split[5] == "rpt") then
                if (ci.repeatable == false) then
                    a_Player:SendMessageInfo("This challenge has no repeatable items.")
                    return true
                end
            
                for i = 1, #ci.rpt_requiredItems do
                    a_Player:GetInventory():AddItem(ci.rpt_requiredItems[i])
                end
            else
                for i = 1, #ci.requiredItems do
                    a_Player:GetInventory():AddItem(ci.requiredItems[i])
                end
            end
            
            a_Player:SendMessageInfo("You got the required items.")
            return true
        end
        
        if (a_Split[4] == "rew") then
            if (#a_Split == 5 and a_Split[5] == "rpt") then
                if (ci.repeatable == false) then
                    a_Player:SendMessageInfo("This challenge has no repeatable items.")
                    return true
                end
                
                for i = 1, #ci.rpt_rewardItems do
                    a_Player:GetInventory():AddItem(ci.rpt_rewardItems[i])
                end
            else
                for i = 1, #ci.rewardItems do
                    a_Player:GetInventory():AddItem(ci.rewardItems[i])
                end
            end
            
            a_Player:SendMessageInfo("You got the reward items.")
            return true
        end
    end
    
    a_Player:SendMessageFailure("Unknwown argument.")
    return true
end
