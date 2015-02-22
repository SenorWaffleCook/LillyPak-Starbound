-- use position of teleporter of initial ship, which is locked down in place at 1025,1025
function is_shipworld()
	-- world.logInfo ("is_shipworld:");
	local teleporter_position_in_our_shipworld = {1025,1025};
	local Teleporter_found = false;
	local TeleporterIds = world.entityQuery (teleporter_position_in_our_shipworld, 1);-- (position, radius)
	-- loop over one object, brilliant!
	for _, TeleporterId in pairs(TeleporterIds) do
		-- world.logInfo("Name of Entity.TeleporterID" .. world.entityName(TeleporterId));
		if (world.entityName(TeleporterId) == "madtulip_teleporter") or
			(world.entityName(TeleporterId) == "madtulip_Apex1_teleporter") or
			(world.entityName(TeleporterId) == "Madtulip_avian1_teleporter") or
			(world.entityName(TeleporterId) == "Madtulip_floran1_teleporter") or
			(world.entityName(TeleporterId) == "Madtulip_glitch1_teleporter") or
			(world.entityName(TeleporterId) == "madtulip_human1_teleporter") or
			(world.entityName(TeleporterId) == "madtulip_hylotl1_teleporter") or
			(world.entityName(TeleporterId) == "madtulip_novakid1_teleporter")
		then
			-- world.logInfo("Teleporter found!")
			Teleporter_found = true;
		end
	end
	if Teleporter_found then
		-- world.logInfo("is_shipworld = true")
		return true;
	end
	
	-- world.logInfo("is_shipworld = false")
	return false;
end

--[[
-- players are by default only invincible on shipworld? so we can use that property.
function is_shipworld()
	if (world.getProperty("invinciblePlayers")) then
		-- shipworld
		return true
	else
		-- planet
		return false
	end
end
--]]