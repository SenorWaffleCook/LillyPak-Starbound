function init()
	-- Make our object interactive (we can interract by 'Use')
	entity.setInteractive(true);
end	
	
function onInteraction(args)
	-- world.logInfo ("onInteraction called")
	if not is_shipworld() then return 1 end
	
	return "OpenAiInterface"
end