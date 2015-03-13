function init(args)
	-- Make our object interactive (we can interract by 'Use')
	entity.setInteractive(true)
end	

function onInteraction(args)

	if not is_shipworld() then return 1 end
	
	-- YES! :) HIT!
	interactData = entity.configParameter("interactData");
	return {"OpenTeleportDialog",interactData}
end