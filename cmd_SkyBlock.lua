function CommandSkyBlock(a_Split, a_Player) -- Handle the command skyblock.
    if (#a_Split == 1) then
        a_Player:SendMessage("Command for the skyblock plugin. Type skyblock help for a list of arguments.")
        return true
    end
    
    if (a_Split[2] == "help") then -- Show the skyblock help
        a_Player:SendMessage("/skyblock join - Join the world skyblock and comes to a spawn platform.")
        a_Player:SendMessage("/skyblock play - Get an island and start playing.")
        a_Player:SendMessage("/skyblock restart - Restart your island")
        return true
    end
    
    if (a_Split[2] == "join") then -- Join the world skyblock
        if (a_Player:GetWorld():GetName() == "skyblock") then -- Check if player is already in world skyblock
            a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
            a_Player:SendMessage("Welcome back to the spawn platform.")
            return true
        end
    
        if (a_Player:MoveToWorld("skyblock")) then
            -- a_Player moved
            a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
            a_Player:SendMessage("Welcome to the world skyblock. Type /skyblock play to get an island.")
            return true
        else
            -- No world named skyblock found :-(
            a_Player:SendMessage("Command failed. Couldn't find the world skyblock.")
            return true
        end
    end
    
    if (a_Split[2] == "play") then
        local pi = PLAYERS[a_Player:GetName()]
        if (pi:GetIslandNumber() == -1) then -- Player has no island
            local islandNumber = -1
            local posX = 0
            local posZ = 0
            
            islandNumber, posX, posZ = CreateIsland(a_Player, -1)
            pi:SetIslandNumber(islandNumber)
            
            if (a_Player:GetWorld():GetName() ~= SKYBLOCK:GetName()) then
                a_Player:MoveToWorld("skyblock")
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessage("Welcome to your island. Do not fall and make no obsidian :-)")
            return true
        else -- Player has an island            
            local posX = 0
            local posZ = 0
            
            posX, posZ = GetIslandPosition(pi:GetIslandNumber())
            
            if (a_Player:GetWorld():GetName() ~= SKYBLOCK:GetName()) then
                a_Player:MoveToWorld("skyblock")
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessage("Welcome back " .. a_Player:GetName())
            return true
        end
    end
    
    if (a_Split[2] == "restart") then -- Let the player restarts his island
        local pi = PLAYERS[a_Player:GetName()]
        if (a_Player:GetWorld():GetName() ~= "skyblock") then
            a_Player:SendMessage("This command works only in the world skyblock.")
            return true
        end
        
        if (pi:GetIslandNumber() == -1) then
            a_Player:SendMessage("You have no island.")
            return true
        end
        
        if (pi:GetIsRestarting() == true) then -- Avoid running the command multiple
            a_Player:SendMessage("This command is running. Please wait...")
            return true
        end
        
        pi:SetIsRestarting(true)
        a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
        
        local posX = 0
        local posZ = 0
        
        posX, posZ = GetIslandPosition(pi:GetIslandNumber())
        RemoveIsland(posX, posZ) -- Recreates all chunks in the area of the island
        
        local playerName = a_Player:GetName()
        a_Player:SendMessage("Please wait 10s...");
        
        a_Player:GetWorld():ScheduleTask(200, function() -- Run task 10s later for chunk regenerating
            if (PLAYERS[playerName] == nil) then -- Avoid self termination, if Player has logged out
                return
            end
            
            a_Player:GetInventory():Clear()
            
            local islandNumber = -1
            local posX = 0
            local posZ = 0
            
            islandNumber, posX, posZ = CreateIsland(a_Player, pi:GetIslandNumber());
            a_Player:TeleportToCoords(posX, 151, posZ);
            a_Player:SendMessage("Good luck with your new island.");
            pi:SetIsRestarting(false)
        end);
        
        return true
    end
end
