-- Handle the command skyblock
function CommandSkyBlock(a_Split, a_Player)
    if (#a_Split == 1) then
        a_Player:SendMessageInfo("Command for the skyblock plugin. Type skyblock help for a list of commands and arguments.")
        return true
    end
    
    -- Show the skyblock help
    if (a_Split[2] == "help") then
        a_Player:SendMessage("---"  .. cChatColor.LightGreen .. " Commands for the skyblock plugin " .. cChatColor.White .. " ---")
        a_Player:SendMessageInfo("/skyblock join - Join the world skyblock and comes to a spawn platform.")
        a_Player:SendMessageInfo("/skyblock play - Get an island and start playing.")
        
        -- cmd_Challenges.lua
        a_Player:SendMessageInfo("/challenges - List all challenges")
        a_Player:SendMessageInfo("/challenges info <name> - Shows informations to the challenge")
        a_Player:SendMessageInfo("/challenges complete <name> -Complete the challenge")
        
        -- cmd_Island.lua
        a_Player:SendMessageInfo("/island home - Teleport back to your home location of the island")
        a_Player:SendMessageInfo("/island home set - Change home location on island")
        a_Player:SendMessageInfo("/island obsidian - Change obsidian backt to lava")
        a_Player:SendMessageInfo("/island add <player> - Add player to your friend list")
        a_Player:SendMessageInfo("/island remove <player> - Remove player from your friend list")
        a_Player:SendMessageInfo("/island join <player> - Teleport to a friends island")
        a_Player:SendMessageInfo("/island list - List your friends and islands who you can join")
        a_Player:SendMessageInfo("/island restart - Start an new island")
        return true
    end
    
    -- Join the world
    if (a_Split[2] == "join") then
        if (a_Player:GetWorld():GetName() == WORLD_NAME) then
            a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
            a_Player:SendMessageSuccess("Welcome back to the spawn platform.")
            return true
        end
    
        if (a_Player:MoveToWorld(WORLD_NAME)) then
            a_Player:TeleportToCoords(0, 170, 0) -- spawn platform
            a_Player:SendMessageSuccess("Welcome to the world skyblock. Type /skyblock play to get an island.")
            return true
        else
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
            
            local ii = cIslandInfo.new(islandNumber)
            ii:SetOwner(a_Player)
            ii:Save()
            
            if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
                a_Player:MoveToWorld(WORLD_NAME)
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessageSuccess("Welcome to your island. Do not fall and make no obsidian :-)")
            
            pi:Save()
            return true
        else -- Player has an island
            if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
                a_Player:MoveToWorld(WORLD_NAME)
            end
            
            local ii = GetIslandInfo(pi.islandNumber)
            if (ii.homeLocation == nil) then
                local posX = 0
                local posZ = 0
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
    end
    
    -- Recreate spawn
    if (a_Split[2] == "recreate") then
        if (a_Player:HasPermission("skyblock.admin.recreate") == false) then
            a_Player:SendMessageFailure("You don't have the permission for that command.")
            return true
        end
        
        local area = cBlockArea()
        if (area:LoadFromSchematicFile(PLUGIN:GetLocalFolder() .. "/" .. SPAWN_SCHEMATIC)) then
            local weOffset = area:GetWEOffset()
            local wex = weOffset.x
            local wey = weOffset.y
            local wez = weOffset.z
            
            area:Write(SKYBLOCK, 0 - wex, 169 - wey, 0 - wez) -- Paste the schematic
            a_Player:SendMessageSuccess("Recreated spawn from schematic file.")
        else
            a_Player:SendMessageInfo("Schematic not found or error occured.")
        end
        return true
    end
    
    a_Player:SendMessageFailure("Unknown argument.")
    return true
end
