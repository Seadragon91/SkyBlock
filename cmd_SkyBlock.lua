function CommandSkyBlock(a_Split, a_Player) -- Handle the command skyblock.
    if (#a_Split == 1) then
        a_Player:SendMessageInfo("Command for the skyblock plugin. Type skyblock help for a list of commands and arguments.")
        return true
    end
    
    if (a_Split[2] == "help") then -- Show the skyblock help
        a_Player:SendMessage("---"  .. cChatColor.LightGreen .. " Commands for the skyblock plugin " .. cChatColor.White .. " ---")
        a_Player:SendMessageInfo("/skyblock join - Join the world skyblock and comes to a spawn platform.")
        a_Player:SendMessageInfo("/skyblock play - Get an island and start playing.")
        a_Player:SendMessageInfo("/skyblock restart - Restart your island")
        a_Player:SendMessageInfo("/challenges - List all challenges")
        a_Player:SendMessageInfo("/challenges info <name> - Shows informations to the challenge")
        a_Player:SendMessageInfo("/challenges complete <name> -Complete the challenge")
        return true
    end
    
    if (a_Split[2] == "join") then -- Join the world
        if (a_Player:GetWorld():GetName() == WORLD_NAME) then -- Check if player is already in the world
            a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
            a_Player:SendMessageSuccess("Welcome back to the spawn platform.")
            return true
        end
    
        if (a_Player:MoveToWorld(WORLD_NAME)) then
            -- a_Player moved
            a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
            a_Player:SendMessageSuccess("Welcome to the world skyblock. Type /skyblock play to get an island.")
            return true
        else
            -- Didn't find the world
            a_Player:SendMessageFailure("Command failed. Couldn't find the world " .. WORLD_NAME .. ".")
            return true
        end
    end
    
    if (a_Split[2] == "play") then
        local pi = GetPlayerInfo(a_Player)
        if (pi.islandNumber == -1) then -- Player has no island
            local islandNumber = -1
            local posX = 0
            local posZ = 0
            
            islandNumber, posX, posZ = CreateIsland(a_Player, -1)
            pi.islandNumber = islandNumber
            
            if (a_Player:GetWorld():GetName() ~= SKYBLOCK:GetName()) then
                a_Player:MoveToWorld(WORLD_NAME)
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessageSuccess("Welcome to your island. Do not fall and make no obsidian :-)")
            return true
        else -- Player has an island            
            local posX = 0
            local posZ = 0
            
            posX, posZ = GetIslandPosition(pi.islandNumber)
            
            if (a_Player:GetWorld():GetName() ~= SKYBLOCK:GetName()) then
                a_Player:MoveToWorld(WORLD_NAME)
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessageSuccess("Welcome back " .. a_Player:GetName())
            return true
        end
    end
    
    if (a_Split[2] == "restart") then -- Let the player restarts his island
        local pi = GetPlayerInfo(a_Player)
        if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
            a_Player:SendMessageFailure("This command works only in the world skyblock.")
            return true
        end
        
        if (pi.islandNumber == -1) then
            a_Player:SendMessageFailure("You have no island.")
            return true
        end
        
        if (pi.isRestarting == true) then -- Avoid running the command multiple
            a_Player:SendMessageInfo("This command is running. Please wait...")
            return true
        end
        
        pi.isRestarting = true
        a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
        
        local posX = 0
        local posZ = 0
        
        posX, posZ = GetIslandPosition(pi.islandNumber)
        RemoveIsland(posX, posZ) -- Recreates all chunks in the area of the island

        a_Player:SendMessageInfo("Please wait 10s...");
        local playerName = a_Player:GetName()
        
        local Callback = function (a_World)
            a_World:DoWithPlayer(playerName, 
                function(a_FoundPlayer)                
                    a_FoundPlayer:GetInventory():Clear()
                    
                    local pi = GetPlayerInfo(a_Player)
                    local islandNumber = -1
                    local posX = 0
                    local posZ = 0
                
                    islandNumber, posX, posZ = CreateIsland(a_FoundPlayer, pi.islandNumber);
                    a_FoundPlayer:TeleportToCoords(posX, 151, posZ);
                    a_FoundPlayer:SetFoodLevel(20)
                    a_FoundPlayer:SetHealth(a_FoundPlayer:GetMaxHealth())
                    a_FoundPlayer:SendMessageSuccess("Good luck with your new island.");
                    pi.isRestarting  = false
                end)
            end
        
        a_Player:GetWorld():ScheduleTask(200, Callback)
        return true
    end
    
    a_Player:SendMessageFailure("Unknown argument.")
    return true
end
