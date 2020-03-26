-- Island restart scheduler

cIslandRestartScheduler = {}
cIslandRestartScheduler.__index = cIslandRestartScheduler

-- Create the island restart scheduler
function cIslandRestartScheduler.new()
	local self = setmetatable({}, cIslandRestartScheduler)

    self.m_Islands =  {}
    self.m_IsRunning = false

    return self
end



function cIslandRestartScheduler:AddIslandNumber(a_IslandNumber)
    table.insert(self.m_Islands, a_IslandNumber)
end



function cIslandRestartScheduler:RemoveIslandNumber(a_IslandNumber)
    table.remove(self.m_Islands, a_IslandNumber)
end



function cIslandRestartScheduler:Start()
    if (self.m_IsRunning) then
        -- Already running
        return
    end

    -- Start scheduler
    self.m_IsRunning = true
    self:ScheduleRestart()
end



function cIslandRestartScheduler:ScheduleRestart()
    if (#self.m_Islands == 0) then
        self.m_IsRunning = false
        -- Stop the scheduler, no need to run forever
        -- if a player schedules a island restart, the scheduler will be started if not running
        return
    end

    local islandInfo = GetIslandInfo(self.m_Islands[1])

    -- local posX, posZ = GetIslandPosition(islandInfo.m_IslandNumber)
    -- RemoveIsland(posX, posZ) -- Recreates all chunks in the area of the island
    local posX, posZ, islandNumber = ReserveIsland(-1)

    local playerName = islandInfo.m_OwnerName

    local Callback = function (a_World)
        self:RemoveIslandNumber(1)
        ISLAND_RESTART_SCHEDULER:ScheduleRestart()

        a_World:DoWithPlayer(playerName,
            function(a_FoundPlayer)
                local playerInfo = GetPlayerInfo(a_FoundPlayer)
                CreateIsland(a_FoundPlayer, posX, posZ)

                SKYBLOCK:ChunkStay(
                    { unpack(GetChunks(posX, posZ, 16)) },
                    nil,
                    function()
                        CreateIsland(a_FoundPlayer, posX, posZ)
                        playerInfo.m_IslandNumber = islandNumber
                        playerInfo:Save()

                        local islandInfo = cIslandInfo.new(islandNumber)
                        islandInfo:SetOwner(a_FoundPlayer)
                        islandInfo:Save()

                        TeleportToIsland(a_FoundPlayer, islandInfo)
                        -- a_Player:SendMessageSuccess(GetLanguage(a_Player):Get("skyblock.play.welcome"))

                        a_FoundPlayer:TeleportToCoords(posX, 151, posZ);
                        a_FoundPlayer:SetFoodLevel(20)
                        a_FoundPlayer:SetHealth(a_FoundPlayer:GetMaxHealth())
                        a_FoundPlayer:SendMessageSuccess(GetLanguage(a_FoundPlayer):Get("island.restart.newIsland"))

                        playerInfo.m_IsRestarting  = false
                    end
                )
            end)
        end

    SKYBLOCK:ScheduleTask(200, Callback)
    return true
end