 -- Handle the island command
function CommandIsland(a_Split, a_Player)
    if (#a_Split == 1) then
        -- List commands
        return true
    end
    
    local pi = GetPlayerInfo(a_Player)
    local ii = GetIslandInfo(pi.islandNumber)
    if (ii == nil) then
        a_Player:SendMessageInfo("You have no island. Type /skyblock play first.")
        return true
    end
    
    if (a_Split[2] == "home") then    
        if (#a_Split == 3) then
            if (a_Split[3] == "set") then
                local pi = GetPlayerInfo(a_Player)
                local ii = GetIslandInfo(pi.islandNumber)

                
                if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
                    a_Player:SendMessageInfo("You can use this command only in skyblock.")
                    return true
                end
                
                local x = a_Player:GetPosX()
                local y = a_Player:GetPosY()
                local z = a_Player:GetPosZ()
                local yaw = a_Player:GetHeadYaw()
                local pitch = a_Player:GetPitch()
                
                ii.homeLocation = { [1] = x, [2] = y, [3] = z, [4] = yaw, [5] = pitch }
                ii:Save()
                a_Player:SendMessageInfo("Home spawn location changed.")
                return true
            end
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
        local pi = GetPlayerInfo(a_Player)
        local ii = GetIslandInfo(pi.islandNumber)

        if (ii.homeLocation == nil) then
            local posX, posZ
            posX, posZ = GetIslandPosition(pi.islandNumber)
            a_Player:TeleportToCoords(posX, 151, posZ)
        else
            local x = ii.homeLocation[1]
            local y = ii.homeLocation[2]
            local z = ii.homeLocation[3]
            local yaw = ii.homeLocation[4]
            local pitch = ii.homeLocation[5]
        
            a_Player:TeleportToCoords(x, y, z)
            a_Player:SetYaw(yaw)
            a_Player:SetPitch(pitch)
        end
        a_Player:SendMessageSuccess("Welcome back " .. a_Player:GetName())
        return true        
    end
    
    if (a_Split[2] == "obsidian") then
        if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
            a_Player:SendMessageInfo("You can use this command only in skyblock.")
            return true
        end
        -- Reset obsidian
        local pi = GetPlayerInfo(a_Player)
        pi.resetObsidian = true
        a_Player:SendMessageInfo("Make now an right-click on the obsidian block without any items")
        return true
    end
    
    if (a_Split[2] == "add") then
        -- Add player
        return true
    end
    
    if (a_Split[2] == "remove") then
        -- Remove player
        return true
    end
    
    if (a_Split[2] == "join") then
        -- Join island
        return true
    end
    
    if (a_Split[2] == "list") then
        -- List friend from island and islands who player can access
        return true
    end
end
