--- Reserve the island
function ReserveIsland(a_IslandNumber)
	if (a_IslandNumber == -1) then -- New island for a player
		-- Increase island number
		ISLAND_NUMBER = ISLAND_NUMBER + 1
		local islandNumber = ISLAND_NUMBER

		-- Save Config file to save island number
		SaveConfiguration()
		-- Get island position
		local posX, posZ = GetIslandPosition(islandNumber)
		return posX, posZ, islandNumber
	else -- Use his island number
		local posX, posZ = GetIslandPosition(a_IslandNumber)
		return posX, posZ, a_IslandNumber
	end
end


-- Returns a list of chunk positions
function GetChunks(a_PosX, a_PosZ, a_Radius)
	local radius = a_Radius
	local list = {}

	for x = -radius, (radius - 16), 16 do
		local cx = (a_PosX + x) / 16
		for z = -radius, (radius - 16), 16 do
			local cz = (a_PosZ + z) / 16
			table.insert(list, {math.floor(cx), math.floor(cz)})
		end
	end
	return list
end


-- Creates a island for the player.
function CreateIsland(a_Player, a_PosX, a_PosZ)
	-- Check for schematic file, if exists use it
	if (ISLAND_AREA) then
		local weOffset = ISLAND_AREA:GetWEOffset()
		local wex = weOffset.x
		local wey = weOffset.y
		local wez = weOffset.z
		ISLAND_AREA:Write(SKYBLOCK, a_PosX - wex, 150 - wey, a_PosZ - wez, 3) -- Place the schematic at the island position

		-- Add items to player inventory
		a_Player:GetInventory():GetInventoryGrid():SetSlot(0, 0, cItem(E_ITEM_LAVA_BUCKET, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(1, 0, cItem(E_BLOCK_ICE, 2));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(2, 0, cItem(E_ITEM_MELON_SLICE, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(3, 0, cItem(E_BLOCK_CACTUS, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(4, 0, cItem(E_BLOCK_BROWN_MUSHROOM, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(5, 0, cItem(E_BLOCK_RED_MUSHROOM, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(6, 0, cItem(E_BLOCK_PUMPKIN, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(7, 0, cItem(E_ITEM_SUGARCANE, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(8, 0, cItem(E_ITEM_CARROT, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(0, 1, cItem(E_ITEM_POTATO, 1));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(1, 1, cItem(E_ITEM_BONE, 3));
		a_Player:GetInventory():GetInventoryGrid():SetSlot(2, 1, cItem(E_BLOCK_CHEST, 1));
	else -- no schematic found, use default island as fallback
		-- Create layers
		CreateLayer(a_PosX, 148, a_PosZ, E_BLOCK_DIRT)
		CreateLayer(a_PosX, 149, a_PosZ, E_BLOCK_DIRT)
		CreateLayer(a_PosX, 150, a_PosZ, E_BLOCK_GRASS)

		-- Plant a tree
		SKYBLOCK:GrowTreeFromSapling(5 + a_PosX, 151, a_PosZ, E_META_SAPLING_APPLE);

		-- Create a chest and add items
		SKYBLOCK:SetBlock(a_PosX, 151, 4 + a_PosZ, E_BLOCK_CHEST, 2)
		SKYBLOCK:DoWithChestAt(a_PosX, 151, 4 + a_PosZ,
			function(a_ChestEntity)
				a_ChestEntity:SetSlot(0, 0, cItem(E_ITEM_LAVA_BUCKET, 1));
				a_ChestEntity:SetSlot(1, 0, cItem(E_BLOCK_ICE, 2));
				a_ChestEntity:SetSlot(2, 0, cItem(E_ITEM_MELON_SLICE, 1));
				a_ChestEntity:SetSlot(3, 0, cItem(E_BLOCK_CACTUS, 1));
				a_ChestEntity:SetSlot(4, 0, cItem(E_BLOCK_BROWN_MUSHROOM, 1));
				a_ChestEntity:SetSlot(5, 0, cItem(E_BLOCK_RED_MUSHROOM, 1));
				a_ChestEntity:SetSlot(6, 0, cItem(E_BLOCK_PUMPKIN, 1));
				a_ChestEntity:SetSlot(7, 0, cItem(E_ITEM_SUGARCANE, 1));
				a_ChestEntity:SetSlot(8, 0, cItem(E_ITEM_CARROT, 1));
				a_ChestEntity:SetSlot(0, 1, cItem(E_ITEM_POTATO, 1));
				a_ChestEntity:SetSlot(1, 1, cItem(E_ITEM_BONE, 3));
			end
		);
	end
end


-- Creates a layer for the island
function CreateLayer(a_PosX, a_PosY, a_PosZ, a_Material)
	for x = -1,6 do
		local X = x + a_PosX
		for z = -1,1 do
			SKYBLOCK:SetBlock(X, a_PosY, z + a_PosZ, a_Material, 0)
		end
	end

	for x = -1,1 do
		local X = x + a_PosX
		for z = 2,4 do
			SKYBLOCK:SetBlock(X, a_PosY, z + a_PosZ, a_Material, 0)
		end
	end
end

-- Calculates with the island number the positions of the island. Returns x and z
function GetIslandPosition(n)
	if (n <= 0) then -- spawn platform
		return 0, 0
	end

	local distance = ISLAND_DISTANCE
	local posX, posZ
	local r = math.floor(0.5 + math.sqrt(n / 2.0 - 0.25))
	local nAufRing = n - 2 * r * (r - 1)
	local seite = math.ceil(nAufRing / r)
	local posSeite = nAufRing - (seite - 1) * r - 1

	if (seite == 1) then
		posX = (posSeite - r) * distance
		posZ = -posSeite * distance
	elseif (seite == 2) then
		posX = posSeite * distance
		posZ = (posSeite - r) * distance
	elseif (seite == 3) then
		posX = (r - posSeite) * distance
		posZ = posSeite * distance
	elseif (seite == 4) then
		posX = -posSeite * distance
		posZ = (r - posSeite) * distance
	else
		posX = 0
		posZ = 0
	end

	return posX, posZ
end

-- Required for function below
function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Calculates with the positions x and z an island number. Returns the island number
function GetIslandNumber(a_PosX, a_PosZ)
	assert(a_PosX ~= nil)
	assert(a_PosZ ~= nil)

	local px = a_PosX
	local pz = a_PosZ
	local distance = ISLAND_DISTANCE

	-- spawn platform
	if (px >= -(distance / 2.0) and px <= (distance / 2.0)) then
		if (pz >= -(distance / 2.0) and pz <= (distance / 2.0)) then
			return 0
		end
	end

	local xd = math.floor(round(px / (distance)))
	local zd = math.floor(round(pz / (distance)))
	local ring = math.abs(xd) + math.abs(zd)

	local seite, posSeite
	if (xd < 0 and zd <= 0) then
		seite = 1
		posSeite = -zd
	elseif (xd >= 0 and zd < 0) then
		seite = 2
		posSeite = xd
	elseif (xd > 0 and zd >= 0) then
		seite = 3
		posSeite = zd
	else
		seite = 4
		posSeite = -xd
	end
	local nAufRing = posSeite + 1 + (seite - 1) * ring
	local n = nAufRing + 2 * ring * (ring - 1)
	return n
end

-- Regenerates all chunks in the area
function RemoveIsland(a_PosX, a_PosZ)
	local radius = ISLAND_DISTANCE / 2

	for x = -radius,(radius - 16),16 do
		local cx = (a_PosX + x) / 16
		for z = -radius,(radius - 16),16 do
			local cz = (a_PosZ + z) / 16
			SKYBLOCK:RegenerateChunk(cx, cz)
		end
	end
end
