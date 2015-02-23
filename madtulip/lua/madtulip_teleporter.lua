function onInteraction(args)
	-- world.logInfo ("onInteraction called")
	if not is_shipworld() then return 1 end
	
	-- YES! :) HIT!
	interactData = entity.configParameter("interactData");
	return {"OpenTeleportDialog",interactData}
end