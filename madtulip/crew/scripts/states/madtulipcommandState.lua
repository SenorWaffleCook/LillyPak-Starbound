madtulipcommandState = {};

function madtulipcommandState.enterWith(args)
	if args.Issue_Command == nil then return nil end
	if args.Issue_Command == true then
		-- command has been issued
		if args.Command == nil then return nil end
		-- switch command type
		if     (args.Command == "Set_Occupation") then
			-- set occupation
			if Set_Occupation(args.Occupation) then
				return {sourceId = args.sourceId,
						timer = entity.configParameter("converse.waitTime")}
			else
				return nil
			end
		elseif (args.Command == "toggle_crew_command") then
			-- set occupation
			if Toggle_Commands_based_on_occupation(args.command_nr) then
				return {sourceId = args.sourceId,
						timer = entity.configParameter("converse.waitTime")}
			else
				return nil
			end
			return nil -- TODO: implement toggle
		-- Different commmand types as elseif here.
		end
	end
	return nil
end

function madtulipcommandState.update(dt, stateData)
	-- face command issuing player
	local sourcePosition = world.entityPosition(stateData.sourceId)
	if sourcePosition == nil then return true end

	local toSource = world.distance(sourcePosition, mcontroller.position())
	controlFace(toSource[1])

	-- timeout ends state
	stateData.timer = stateData.timer - dt
	return (stateData.timer <= 0)
end