function CommandSkyBlock(a_Split, a_Player) -- Handle the command skyblock.
    if (#a_Split == 1) then
		a_Player:SendMessage("Command for the skyblock plugin. Type skyblock help for a list of arguments.")
		return true
	end
	
	if (a_Split[2] == "help") then -- Show the skyblock help
		a_Player:SendMessage("/skyblock join - Join the world skyblock and comes to a spawn platform.")
		a_Player:SendMessage("/skyblock play - Get an island and start playing.")
		return true
	end

	if (a_Split[2] == "join") then -- Join the world skyblock
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
       pi = PLAYERS[a_Player:GetName()]
       if (pi:GetIslandNumber() == -1) then -- Player has no island
            islandNumber, posX, posZ = CreateIsland()
            pi:SetIslandNumber(islandNumber)
            
            if (a_Player:GetWorld():GetName() ~= SKYBLOCK:GetName()) then
                a_Player:MoveToWorld("skyblock")
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessage("Welcome to your island. Do not fall and make no obsidian :-)")
            return true
        else -- Player has an island
            pi = PLAYERS[a_Player:GetName()]
            posX, posZ = GetIslandPosition(pi:GetIslandNumber())
            
            if (a_Player:GetWorld():GetName() ~= SKYBLOCK:GetName()) then
                a_Player:MoveToWorld("skyblock")
            end
            
            a_Player:TeleportToCoords(posX, 151, posZ)
            a_Player:SendMessage("Welcome back " .. a_Player:GetName())
            return true
        end
	end
end
