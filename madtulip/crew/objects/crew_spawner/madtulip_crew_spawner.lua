function init(virtual)
	if not virtual then
		entity.setInteractive(true);
	end
end

function onInteraction(args)
	if not is_shipworld() then return end

	local player_ID   = args["sourceId"]
	local player_race = world.entitySpecies(player_ID);
	if not(   (player_race == "apex")
	       or (player_race == "avian")
	       or (player_race == "floran")
	       or (player_race == "glitch")
	       or (player_race == "human")
	       or (player_race == "hylotl")) then
		-- default none vanilla to human
		player_race = "human"
	end

	-- spawn NPC of users race
	world.spawnNpc(entity.toAbsolutePosition({ 0.0, 2.0 }),
				   player_race,
				   "madtulip_normal_crew",
				   entity.level());
	-- kill self
	entity.smash()
end