function No_Gravity_In_Space_init()
	data = {};
	We_are_in_ZERO_gravity = false;
end

function Apply_Vacuum_Status()
	status.addEphemeralEffect("madtulip_vacuum_head");
	status.addEphemeralEffect("madtulip_vacuum_chest");
	status.addEphemeralEffect("madtulip_vacuum_legs");
end

function No_Gravity_In_Space_update(args)
	if not (We_are_in_ZERO_gravity) then
		-- try to get to ZERO gravity
		local Range = 4; -- range of blocks around the player that need to be void to be "in space"
		if (determine_if_ZERO_gravity(Range)) then
			We_are_in_ZERO_gravity = true;
			use_ZERO_gravity_movement();
			Apply_Vacuum_Status();
		end
	end
	
	if (We_are_in_ZERO_gravity) then
		-- try to get back to normal
		local Range = 3; -- range of blocks around the player that need to be void to be "in space"
		if (determine_if_ZERO_gravity_should_end(Range)) then
			We_are_in_ZERO_gravity = false;
		else
			use_ZERO_gravity_movement();
			Apply_Vacuum_Status();
		end
	end
	--return 0;
end

function No_Gravity_In_Space_input(args)
	data.holdingJump = false;
	data.holdingLeft = false;
	data.holdingRight = false;
	data.holdingUp = false;
	data.holdingDown = false;

	-- jump
	if args.moves["jump"] then data.holdingJump = true end
	--move left
	if args.moves["left"] then data.holdingLeft = true end
	--move right
	if args.moves["right"] then data.holdingRight = true end
	--move up
	if args.moves["up"] then data.holdingUp = true end
	--move down
	if args.moves["down"] then data.holdingDown = true end

	-- return 0;
end

function determine_if_ZERO_gravity_should_end(Range)
	-- we assume Zero gravity unless we find blocks in the vicinity
	local Zero_gravity_ends = true;
	local Origin = mcontroller.position();
	for cur_X = -Range, Range, 1 do
		for cur_Y = -Range, Range, 1 do
			local cur_abs_Position = {};
			-- X coordinate where to get data
			cur_abs_Position[1] = Origin[1] + cur_X;
			-- Y coordinate where to get data
			cur_abs_Position[2] = Origin[2] + cur_Y;
			
			if ((world.material(cur_abs_Position, "foreground") == false) and (world.material(cur_abs_Position, "background") == false)) then
				-- write the findings at this position to output variable
				Zero_gravity_ends = false;
			end
		end	
	end
	
	return Zero_gravity_ends;
end

function determine_if_ZERO_gravity(Range)
--[[
	-- dirty dirty workaround: This searches if a teleporter is at that very location
	-- this is the case for the fixed teleporter in the ship.
	-- i didn't know any other way to degine the ship world.
	local Teleporter_found = false;
	local TeleporterIds = world.entityQuery ({1000,1000}, 1);
	-- loop over one object, brilliant
	for _, TeleporterId in pairs(TeleporterIds) do
		if (world.entityName(TeleporterId) == "madtulip_teleporter") then
			Teleporter_found = true;
		end
	end
	if not(Teleporter_found) then
		-- on planet, ZERO gravity is not active
		return false;
	end
]]
	-- return if we are on a planet
	if not is_shipworld() then return false end
	
	-- we assume Zero gravity unless we find blocks in the vicinity
	local Zero_gravity = true;
	local Origin = mcontroller.position();
	for cur_X = -Range, Range, 1 do
		for cur_Y = -Range, Range, 1 do
			local cur_abs_Position = {};
			-- X coordinate where to get data
			cur_abs_Position[1] = Origin[1] + cur_X;
			-- Y coordinate where to get data
			cur_abs_Position[2] = Origin[2] + cur_Y;
			
			if not((world.material(cur_abs_Position, "foreground") == false) and (world.material(cur_abs_Position, "background") == false)) then
				-- write the findings at this position to output variable
				Zero_gravity = false;
			end
		end	
	end
	
	return Zero_gravity;
end

----- No Gravity only -----
function use_ZERO_gravity_movement()
	-- setup movement vector
	local v_x = 0;
	local v_y = 0;
	local a_x = 0;
	local a_y = 0;
	if data.holdingUp then
		v_y = 2;
	end
	if data.holdingDown then
		v_y = -2;
	end
	if data.holdingLeft then
		v_x = -2;
		a_x = 50;
	end
	if data.holdingRight then
		v_x = 2;
		a_x = 50;
	end

	-- execute movement vector
	mcontroller.controlApproachXVelocity(0+v_x, 0+a_x, false);
	mcontroller.controlApproachYVelocity(0+v_y, 100+a_y, false);
end