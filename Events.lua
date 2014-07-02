function OnChunkGenerating(a_World, a_ChunkX, a_ChunkZ, a_ChunkDesc) -- Air generator
    if a_World:GetName() == "skyblock" then
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

function OnKilling(a_Victim, a_Killer) -- Fix for respawn bug, respawns and send player back to his island
    if (a_Victim:IsPlayer() == false) then
        return
    end
    
    if (a_Victim:GetWorld():GetName() ~= "skyblock") then
        return
    end
    
    local Player = tolua.cast(a_Victim,"cPlayer")
    Player:Respawn()
    
    local pi = PLAYERS[Player:GetName()]
    if (pi:GetIslandNumber() == -1) then -- no island
        Player:TeleportToCoords(0, 170, 0)
    else
        posX, posZ = GetIslandPosition(pi:GetIslandNumber())
        Player:TeleportToCoords(posX, 151, posZ)
    end
end

function OnWorldLoaded(a_World) -- Create Spawn in world skyblock
    if (a_World:GetName() ~= "skyblock") then
        return
    end
    
    if (a_World:GetBlock(0, 169, 0) == E_BLOCK_STONE) then
        return
    end
    
    for x = -5,5 do
        for z = -5,5 do
            a_World:SetBlock(x, 169, z, E_BLOCK_STONE, 0)
        end
    end
end
