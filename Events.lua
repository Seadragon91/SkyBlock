function OnChunkGenerating(a_World, a_ChunkX, a_ChunkZ, a_ChunkDesc) -- Air generator
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

function OnPlayerJoin(a_Player) -- Load file and add PlayerInfo to list
    PLAYERS[a_Player:GetName()] = cPlayerInfo.new(a_Player:GetName())
end

function OnPlayerQuit(a_Player) -- Save file and remove PlayerInfo
    PLAYERS[a_Player:GetName()]:Save()
    PLAYERS[a_Player:GetName()] = nil
end

function OnPlayerSpawn(a_Player)
    if (a_Player:GetWorld():GetName() ~= WORLD_NAME) then
        return
    end    
    
    local pi = PLAYERS[a_Player:GetName()]
    if (pi:GetIslandNumber() == -1) then -- no island
        a_Player:TeleportToCoords(0, 170, 0)
    else
        posX, posZ = GetIslandPosition(pi:GetIslandNumber())
        a_Player:TeleportToCoords(posX, 151, posZ)
    end
end

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
    else -- Error or no schematic found, create default spawn
        for x = -5,5 do
            for z = -5,5 do
                SKYBLOCK:SetBlock(x, 169, z, E_BLOCK_STONE, 0)
            end
        end
        SPAWN_CREATED = false
    end
end

function OnBlockPlacing(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ, a_BlockType, a_BlockMeta)
    return HasPermissionThereDontCancel(a_Player, a_BlockX, a_BlockZ)
end

function OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
    return HasPermissionThereDontCancel(a_Player, a_BlockX, a_BlockZ)
end

function OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
    return HasPermissionThereDontCancel(a_Player, a_BlockX, a_BlockZ)
end
