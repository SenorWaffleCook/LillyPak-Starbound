function onInteraction(args)
	-- world.logInfo ("onInteraction called")
	if not is_shipworld() then return 1 end
	
	return "openCockpitInterface"
end