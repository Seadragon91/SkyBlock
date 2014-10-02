-- Air generator
function OnChunkGenerating(a_World, a_ChunkX, a_ChunkZ, a_ChunkDesc)
    if a_World:GetName() == WORLD_NAME then
        FillBlocks(a_ChunkDesc) -- fill entire chunk with air
    end
end

function FillBlocks(a_ChunkDesc)
    a_ChunkDesc:FillBlocks(E_BLOCK_AIR, 0)
    a_ChunkDesc:SetUseDefaultBiomes(false)
    a_ChunkDesc:SetUseDefaultHeight(false)
    a_ChunkDesc:SetUseDefaultComposition(false)
    a_ChunkDesc:SetUseDefaultFinish(false)
end

-- Player quits
function OnPlayerQuit(a_Player)
    if (a_Player:GetWorld():GetName() == WORLD_NAME) then
        PLAYERS[a_Player:GetUUID()] = nil -- Remove player from list
    end
end

-- Teleport player to island or spawn platform
function OnPlayerSpawn(a_Player)
    if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
        return
    end
    
    local pi = GetPlayerInfo(a_Player)
    if (pi.islandNumber == -1) then -- no island
        a_Player:TeleportToCoords(0, 170, 0)
    else
        -- Lets check players location
        if (pi.islandNumber == GetIslandNumber(a_Player:GetPosX(), a_Player:GetPosZ())) then
            return -- His island, return here then he gets to the last position
        end
    
        posX, posZ = GetIslandPosition(pi.islandNumber)
        a_Player:TeleportToCoords(posX, 151, posZ)
    end
end

-- Handle the spawn schematic
function OnWorldLoaded(a_World)
    if (a_World:GetName() ~= WORLD_NAME) then
        return
    end
    
    if (SPAWN_CREATED) then
        return
    end
    
    local area = cBlockArea()
    if (area:LoadFromSchematicFile(PLUGIN:GetLocalFolder() .. "/" .. SPAWN_SCHEMATIC)) then
        local weOffset = area:GetWEOffset()
        local wex = weOffset.x
        local wey = weOffset.y
        local wez = weOffset.z
        
        area:Write(SKYBLOCK, 0 - wex, 169 - wey, 0 - wez) -- Paste the schematic
        SPAWN_CREATED = true
        SaveConfiguration()
    else -- Error or no schematic found, create default spawn
        for x = -5,5 do
            for z = -5,5 do
                SKYBLOCK:SetBlock(x, 169, z, E_BLOCK_STONE, 0)
            end
        end
        SPAWN_CREATED = true
        SaveConfiguration()
    end
end

function OnBlockPlacing(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ, a_BlockType, a_BlockMeta)
    return CancelEvent(a_Player, a_BlockX, a_BlockZ)
end

function OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
    return CancelEvent(a_Player, a_BlockX, a_BlockZ)
end

function OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)    
    if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
        return false
    end

    local posX = 0
    local posY = 0
    local posZ = 0
    
    if (a_BlockX == -1) then
        posX = a_Player:GetPosX()
    else
        posX = a_BlockX
    end
    
    if (a_BlockY == -1) then
        posY = a_Player:GetPosY()
    else
        posY = a_BlockY
    end
    
    if (a_BlockZ == -1) then
        posZ = a_Player:GetPosZ()
    else
        posZ = a_BlockZ
    end

    
    if (a_BlockFace == BLOCK_FACE_NONE) then    
        if(a_Player:GetEquippedItem().m_ItemType == 280) then
            local islandNumber = GetIslandNumber(posX, posZ)
            if (islandNumber == 0) then
                a_Player:SendMessageInfo("This is the spawn area.")
                return true
            end
            
            local ii = GetIslandInfo(islandNumber)
            if (ii == nil) then
                a_Player:SendMessageInfo("Unknown area.")
                return true
            end
            
            a_Player:SendMessageInfo("Island number: " .. ii.islandNumber)
            a_Player:SendMessageInfo("Owner: " .. ii.ownerName)
            
            local friends = "Friends: "
            local amount = GetAmount(ii.friends)
            local counter = 0
            for uuid, playerName in pairs(ii.friends) do
                friends = friends .. playerName
                if (counter ~= amount) then
                    friends = friends .. ", "
                end
            end
            
            a_Player:SendMessageInfo(friends)
        end
        return true
    end
    
    if (CancelEvent(a_Player, posX, posZ) == false) then
        local pi = GetPlayerInfo(a_Player)
        if (pi.resetObsidian == false) then
            return false
        end
        
        if (a_Player:GetEquippedItem().m_ItemType ~= -1) then
            return false
        end
        
        if (a_Player:GetWorld():GetBlock(posX, posY, a_BlockZ) == E_BLOCK_OBSIDIAN) then
            a_Player:GetWorld():SetBlock(posX, posY, posZ, E_BLOCK_LAVA, 0)
            pi.resetObsidian = false
            a_Player:SendMessageInfo("Changed obsidian back to lava")        
        end
    else
        return true
    end
end
