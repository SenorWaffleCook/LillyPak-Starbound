function init(virtual)
	if not virtual then
		entity.setInteractive(true);
	end
end

function onInteraction(args)
	if not is_shipworld() then return end

	local player_ID   = args["sourceId"]
	local player_race = world.entitySpecies(player_ID);

	-- spawn NPC of users race
	world.spawnMonster ("madtulip_blaze_small",entity.toAbsolutePosition({ 0.0, 2.0 }),{persistent = true});
	
	-- kill self
	entity.smash()
end