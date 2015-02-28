madtulipLocation = {}
-- The Box around a Block above Floor which is checked for clearance to determine "standable" property
madtulipLocation.Standable = {}
madtulipLocation.Standable.BB = {}
madtulipLocation.Standable.BB[1] = -1 -- X1
madtulipLocation.Standable.BB[2] =  0 -- Y1
madtulipLocation.Standable.BB[3] =  1 -- X2
madtulipLocation.Standable.BB[4] =  3 -- Y2 (hight of player)

function madtulipLocation.get_next_target_inside_ROI(ROI)
	-- return if parameters are bad
	if (ROI == nil) then return nil end
	if (ROI.Pathable_Moveable_Standable_Positions == nil) then return nil end
	if (ROI.Pathable_Moveable_Standable_Positions_size == nil) then return nil end
	if (ROI.Pathable_Moveable_Standable_Positions_size < 1) then return nil end
	
	-- for now just pick a random target
	return ROI.Pathable_Moveable_Standable_Positions[math.random (#ROI.Pathable_Moveable_Standable_Positions)]
end

function madtulipLocation.get_next_full_background_target_inside_ROI(ROI)
	-- return if parameters are bad
	if (ROI == nil) then return nil end
	if (ROI.Pathable_Moveable_Standable_FullBackground_Positions == nil) then return nil end
	if (ROI.Pathable_Moveable_Standable_FullBackground_Positions_size == nil) then return nil end
	if (ROI.Pathable_Moveable_Standable_FullBackground_Positions_size < 1) then return nil end
	-- for now just pick a random target
	return ROI.Pathable_Moveable_Standable_FullBackground_Positions[math.random (ROI.Pathable_Moveable_Standable_FullBackground_Positions_size)]
end

function madtulipLocation.ground_Around(Anchor)
	--world.logInfo("Testing ROI anchor")
	if (Anchor == nil) then return nil end
	--world.logInfo("initial ROI anchor valid")
	
	-- shift the anchor down to walkable floor in case the attractor objects anchor is above floor
	local max_distance = 15; -- maximum depth under anchor to search for walkable floor
	Anchor = madtulipLocation.Find_Block_above_floor(Anchor,max_distance)
	-- check if floor could be found, else return
	if (Anchor == nil) then
		--world.logInfo("NO floor under Anchor found !!!")
		return nil
	end
	--world.logInfo("floor under Anchor found X: " .. Anchor[1] .. " Y: " .. Anchor[2])
	
	return Anchor
end

function madtulipLocation.create_ROI_around_anchor(ROI_anchor_position,BB,Additional_Blocked_Positions)
	-- transform from relative to anchor to world coordinates
	local tmp_BB = {}
	tmp_BB[1] = ROI_anchor_position[1] + BB[1]
	tmp_BB[2] = ROI_anchor_position[2] + BB[2]
	tmp_BB[3] = ROI_anchor_position[1] + BB[3]
	tmp_BB[4] = ROI_anchor_position[2] + BB[4]
	if (Additional_Blocked_Positions ~= nil) then
		for cur_idx = 1,#Additional_Blocked_Positions,1 do
			--world.logInfo("x: " .. Additional_Blocked_Positions[cur_idx][1] .. " y: " .. Additional_Blocked_Positions[cur_idx][2])
			Additional_Blocked_Positions[cur_idx] = {Additional_Blocked_Positions[cur_idx][1] + ROI_anchor_position[1],
													 Additional_Blocked_Positions[cur_idx][2] + ROI_anchor_position[2]}
			--world.logInfo("x: " .. Additional_Blocked_Positions[cur_idx][1] .. " y: " .. Additional_Blocked_Positions[cur_idx][2])
		end
	end
	
	-- find all those blocks which have enough space above them so the payer could be here without collision
	local Pathable_Positions_Data = madtulipLocation.Find_Pathable_Positions_in_BB(tmp_BB,Additional_Blocked_Positions)
	--world.logInfo("Find_Pathable_Positions_in_BB found : " .. Pathable_Positions_Data.size)
	if (Pathable_Positions_Data.size < 1) then return nil end

	-- now the player doesnt want to target the floor where he can stand, but an offset in hip hight instead,
	-- so we shift them all up a bit to make them "moveable"
	local Pathable_Moveable_Positions = {}
	local Pathable_Moveable_Positions_size = Pathable_Positions_Data.size -- just rename it
	--world.logInfo("Pathable_Moveable_Positions")
	for idx_cur_Pathable_Position = 1,Pathable_Positions_Data.size,1 do
		Pathable_Moveable_Positions[idx_cur_Pathable_Position] = madtulipLocation.Shift_Above_Floor_to_Moveable_Position(Pathable_Positions_Data.Positions[idx_cur_Pathable_Position])
		--world.logInfo("x: " .. Pathable_Moveable_Positions[idx_cur_Pathable_Position][1] .. " y:" .. Pathable_Moveable_Positions[idx_cur_Pathable_Position][2])
	end
	--world.logInfo("Shift_Above_Floor_to_Moveable_Position successful")
	
	-- find all those blocks which have enough space above them so the payer could be here without collision
	-- they also need to have a floor directly under them
	local Pathable_Above_Floor_Positions_Data = madtulipLocation.Find_Pathable_Above_Floor_Positions_in_BB(tmp_BB,Additional_Blocked_Positions)
	if (Pathable_Above_Floor_Positions_Data.size < 1) then return nil end
	--world.logInfo("Find_Pathable_Above_Floor_Positions_in_BB(tmp_BB) successful")
	
	-- now the player doesnt want to target the floor where he can stand, but an offset in hip hight instead,
	-- so we shift them all up a bit to make them "moveable"
	local Pathable_Moveable_Standable_Positions = {}
	local Pathable_Moveable_Standable_Positions_size = Pathable_Above_Floor_Positions_Data.size -- just rename it
	--world.logInfo("Pathable_Moveable_Standable_Positions")
	for idx_cur_Pathable_Standable_Position = 1,Pathable_Above_Floor_Positions_Data.size,1 do
		Pathable_Moveable_Standable_Positions[idx_cur_Pathable_Standable_Position] = madtulipLocation.Shift_Above_Floor_to_Moveable_Position(Pathable_Above_Floor_Positions_Data.Positions[idx_cur_Pathable_Standable_Position])
		--world.logInfo("x: " .. Pathable_Moveable_Standable_Positions[idx_cur_Pathable_Standable_Position][1] .. " y:" .. Pathable_Moveable_Standable_Positions[idx_cur_Pathable_Standable_Position][2])
	end
	--world.logInfo("Pathable_Above_Floor_Positions_Data build successful" .. Pathable_Above_Floor_Positions_Data.size)
	
	local Pathable_Moveable_Standable_FullBackground_Positions = {}
	local Pathable_Moveable_Standable_FullBackground_Positions_size = 0
	for idx_cur_pos = 1,Pathable_Moveable_Standable_Positions_size,1 do
		if (madtulipLocation.Position_has_Player_sized_Background (Pathable_Moveable_Standable_Positions[idx_cur_pos])) then
			Pathable_Moveable_Standable_FullBackground_Positions_size = Pathable_Moveable_Standable_FullBackground_Positions_size + 1
			Pathable_Moveable_Standable_FullBackground_Positions[Pathable_Moveable_Standable_FullBackground_Positions_size] = Pathable_Moveable_Standable_Positions[idx_cur_pos]
		end
	end
	
	--world.logInfo("ROI build successful")
	local ROI = {}
	ROI.anchor_pos                                = ROI_anchor_position
	ROI.BB                                        = tmp_BB
	-- these are with floor block directly below them and enought clear space above them
	-- still you cant move here as a move order is performed to a position above floor (hip hight)
	ROI.Pathable_Above_Floor_Positions            = Pathable_Above_Floor_Positions_Data.Positions
	ROI.Pathable_Above_Floor_Positions_size       = Pathable_Above_Floor_Positions_Data.size
	
	-- these can be used as a movement target (hip hight):
	-- these are pathable
	ROI.Pathable_Moveable_Positions                = Pathable_Moveable_Positions
	ROI.Pathable_Moveable_Positions_size           = Pathable_Moveable_Positions_size
	-- these are pathable and standable (a move to will result in the NPC standing on some floor)
	ROI.Pathable_Moveable_Standable_Positions      = Pathable_Moveable_Standable_Positions
	ROI.Pathable_Moveable_Standable_Positions_size = Pathable_Moveable_Standable_Positions_size

	-- these in addition also have full background behind the player, which is a good indication for "inside the spaceship"
	ROI.Pathable_Moveable_Standable_FullBackground_Positions      = Pathable_Moveable_Standable_FullBackground_Positions
	ROI.Pathable_Moveable_Standable_FullBackground_Positions_size = Pathable_Moveable_Standable_FullBackground_Positions_size	
--[[
	world.logInfo("--- ROI created! ---")
	world.logInfo("ROI.Anchor X: " .. ROI.anchor_pos[1] .. " Y: " .. ROI.anchor_pos[2])
	world.logInfo("ROI.Pathable_Above_Floor_Positions_size: " .. ROI.Pathable_Above_Floor_Positions_size)
	world.logInfo("ROI.Pathable_Moveable_Positions_size: " .. ROI.Pathable_Moveable_Positions_size)
	world.logInfo("ROI.Pathable_Moveable_Standable_Positions_size: " .. ROI.Pathable_Moveable_Standable_Positions_size)
	world.logInfo("ROI.Pathable_Moveable_Standable_FullBackground_Positions_size: " .. ROI.Pathable_Moveable_Standable_FullBackground_Positions_size)
	world.logInfo("--------------------")
	for i = 1,ROI.Pathable_Moveable_Standable_FullBackground_Positions_size,1 do
		world.logInfo("x: " .. ROI.Pathable_Moveable_Standable_FullBackground_Positions[i][1] .. " y:" .. ROI.Pathable_Moveable_Standable_FullBackground_Positions[i][2])
	end
--]]
	return ROI
end

function madtulipLocation.Position_has_Player_sized_Background(Position)

	local cur_pos = {}
	local cur_position_has_Player_sized_Background = true
	-- check clearance boundary box
	for X = madtulipLocation.Standable.BB[1], madtulipLocation.Standable.BB[3], 1 do
		for Y = madtulipLocation.Standable.BB[2], madtulipLocation.Standable.BB[4], 1 do
			-- check for foreground at this position
			cur_pos[1] = Position[1] + X
			cur_pos[2] = Position[2] + Y
			-- world.logInfo("X:" .. cur_pos[1] .. "Y:" .. cur_pos[2])
			cur_mat = world.material(cur_pos,"background")
			if (cur_mat == false) then
				-- world.logInfo("BLOCKED: " .. cur_mat)
				cur_position_has_Player_sized_Background = false
			end
		end
	end
	return cur_position_has_Player_sized_Background
end

function madtulipLocation.get_empty_ROI()
	ROI = {}
	ROI.anchor_pos                                 = nil
	ROI.BB                                         = nil

	ROI.Pathable_Above_Floor_Positions             = nil
	ROI.Pathable_Above_Floor_Positions_size        = nil
	ROI.Pathable_Moveable_Positions                = nil
	ROI.Pathable_Moveable_Positions_size           = nil
	ROI.Pathable_Moveable_Standable_Positions      = nil
	ROI.Pathable_Moveable_Standable_Positions_size = nil
	return ROI
end

function madtulipLocation.Shift_Above_Floor_to_Moveable_Position(position)
	-- a standable position is one block above floor
	-- a pathable position is at hip hight or higher. apply that offset
	local return_position = {}
	return_position[1] = position[1] + 0
	return_position[2] = position[2] + 2
	return return_position
end

function madtulipLocation.Find_Pathable_Positions_in_BB(BB,Additional_Blocked_Positions)
	-- a player can stand at a location with this box around him beeing free of foreground blocks
	-- we want to check every position in BB against this box

	-- find all those positions in the BB which have a floor under them and are without foreground block themselves
	--world.logInfo("Find_Pathable_Positions_in_BB(BB,Additional_Blocked_Positions)")
	local Pathable_Positions = {}
	local Pathable_Positions_size = 0
	local cur_position = {};
	local cur_mat = nil
	local cur_mat_pos = {};
	local cur_position_is_Pathable = nil
	for X = BB[1], BB[3], 1 do
		for Y = BB[2], BB[4], 1 do
			--world.logInfo("-X:" .. X .. "Y:" .. Y)
			cur_position_is_Pathable = true
			-- check clearance boundary box
			for X_BB = madtulipLocation.Standable.BB[1], madtulipLocation.Standable.BB[3], 1 do
				for Y_BB = madtulipLocation.Standable.BB[2], madtulipLocation.Standable.BB[4], 1 do
					--world.logInfo("-X_BB:" .. X_BB .. "Y_BB:" .. Y_BB)
					-- check for foreground at this position
					cur_mat_pos = {}
					cur_mat_pos[1] = X+X_BB
					cur_mat_pos[2] = Y+Y_BB
					cur_mat = world.material(cur_mat_pos,"foreground")
					if (cur_mat ~= false) then
						--world.logInfo("--BLOCKED at X:" .. cur_mat_pos[1] .. "Y:" .. cur_mat_pos[2] .. "mat: " .. cur_mat)
						cur_position_is_Pathable = false
					end
					-- Check if Positions defined in the Additional_Blocked_Positions apply
					if (Additional_Blocked_Positions ~= nil) then
						for _, cur_Blocked_Location in pairs(Additional_Blocked_Positions) do
							if (cur_mat_pos[1] == cur_Blocked_Location[1]) and (cur_mat_pos[2] == cur_Blocked_Location[2]) then
								--world.logInfo("--BLOCKED at X:" .. cur_mat_pos[1] .. "Y:" .. cur_mat_pos[2])
								cur_position_is_Pathable = false
							end
						end
					end
				end
			end
			if (cur_position_is_Pathable) then
				-- add it to the list
				Pathable_Positions_size = Pathable_Positions_size + 1;
				Pathable_Positions[Pathable_Positions_size] = {X,Y}
				--world.logInfo("--Pathable_Positions: X:" .. Pathable_Positions[Pathable_Positions_size][1] .. " Y:" .. Pathable_Positions[Pathable_Positions_size][2])
			end
		end
	end
	--world.logInfo("-Pathable_Positions_size = " .. Pathable_Positions_size)	
	
	return {
		Positions = Pathable_Positions,
		size = Pathable_Positions_size
		}
end

function madtulipLocation.Find_Pathable_Above_Floor_Positions_in_BB(BB,Additional_Blocked_Positions)
	-- a player can stand at a location with this box around him beeing free of foreground blocks
	-- we want to check every position in BB against this box

	-- find all those positions in the BB which have a floor under them and are without foreground block themselves
	local size = 0
	local Positions_with_Floor_under_them = {}
	for X = BB[1], BB[3], 1 do
		for Y = BB[2], BB[4], 1 do
			--world.logInfo("X:" .. X .. "Y:" .. Y)
			if (madtulipLocation.Find_Block_above_floor({X,Y},0) ~= nil) then
				size = size +1
				Positions_with_Floor_under_them[size] = {X,Y}
				--world.logInfo("cur_position above floor X:" .. Positions_with_Floor_under_them[size][1] .. "Y:" .. Positions_with_Floor_under_them[size][2])
			end
		end
	end
	--world.logInfo("NR_Positions_with_Floor_under_them = " .. size)	
	
	-- under those positions where you could stand because it has a floor,
	-- we want to check for open space above the floor now.
	local Pathable_Above_Floor_Positions = {}
	local Pathable_Above_Floor_Positions_size = 0
	local cur_position = {};
	local cur_pos = {}
	local cur_mat = nil
	for idx_cur_pos = 1, size, 1 do
	--world.logInfo("----")	
		cur_position[1] = Positions_with_Floor_under_them[idx_cur_pos][1]
		cur_position[2] = Positions_with_Floor_under_them[idx_cur_pos][2]
		--world.logInfo("cur_position:" .. cur_position[1] .. "," .. cur_position[2])
		local cur_position_is_Pathable_Above_Floor = true
		-- check clearance boundary box
		for X = madtulipLocation.Standable.BB[1], madtulipLocation.Standable.BB[3], 1 do
			for Y = madtulipLocation.Standable.BB[2], madtulipLocation.Standable.BB[4], 1 do
				-- check for foreground at this position
				cur_pos[1] = cur_position[1] + X
				cur_pos[2] = cur_position[2] + Y
				--world.logInfo("X:" .. cur_pos[1] .. "Y:" .. cur_pos[2])
				cur_mat = world.material(cur_pos,"foreground")
				if (cur_mat ~= false) then
					--world.logInfo("BLOCKED: " .. cur_mat)
					cur_position_is_Pathable_Above_Floor = false
				end
				-- Check if Positions defined in the Additional_Blocked_Positions apply
				if (Additional_Blocked_Positions ~= nil) then
					for _, cur_Blocked_Location in pairs(Additional_Blocked_Positions) do
						if (cur_pos[1] == cur_Blocked_Location[1]) and (cur_pos[2] == cur_Blocked_Location[2]) then
							--world.logInfo("--BLOCKED at X:" .. cur_pos[1] .. "Y:" .. cur_pos[2])
							cur_position_is_Pathable_Above_Floor = false
						end
					end
				end
			end
		end
		if (cur_position_is_Pathable_Above_Floor) then
			-- add it to the list
			Pathable_Above_Floor_Positions_size = Pathable_Above_Floor_Positions_size + 1;
			Pathable_Above_Floor_Positions[Pathable_Above_Floor_Positions_size] = Positions_with_Floor_under_them[idx_cur_pos]
			--world.logInfo("-Pathable_Above_Floor_Positions: X:" .. Pathable_Above_Floor_Positions[Pathable_Above_Floor_Positions_size][1] .. " Y:" .. Pathable_Above_Floor_Positions[Pathable_Above_Floor_Positions_size][2])
		end
	end
	--world.logInfo("-Pathable_Above_Floor_Positions_size = " .. Pathable_Above_Floor_Positions_size)	
	
	return {
		Positions = Pathable_Above_Floor_Positions,
		size = Pathable_Above_Floor_Positions_size
		}
end

function madtulipLocation.Find_Block_above_floor(position,max_distance)
	-- starts at position and searches down until something was found or max_distance reached
	-- searched for a file that has foreground under it and no foreground AT its position
	-- (a tile one could stand on)
	-- returns the position above the block to stand on
	
	--world.logInfo("Find_Block_above_floor(position[" .. position[1] .. "," .. position[2] .. "],max_distance[" .. max_distance .. "])")
	local offset = {0,0}
	local below_offset = {0,0}
	local pos_mat_at_offset = {}
	local mat_at_offset = nil
	local pos_mat_at_belowoffset = {}
	local mat_at_belowoffset = nil
	local return_position = {}
	for Y = 0,max_distance,1 do
		offset[2]       = -Y
		below_offset[2] = offset[2] -1
		--world.logInfo("-Y:" .. Y .. " offset[" .. offset[1] .. "," .. offset[2] .. "]")
		pos_mat_at_offset[1]      = position[1] + offset[1]
		pos_mat_at_offset[2]      = position[2] + offset[2]
		pos_mat_at_belowoffset[1] = position[1] + below_offset[1]
		pos_mat_at_belowoffset[2] = position[2] + below_offset[2]
		mat_at_offset      = world.material(pos_mat_at_offset     ,"foreground")
		mat_at_belowoffset = world.material(pos_mat_at_belowoffset,"foreground")
		--if (mat_at_offset ~= nil) then      world.logInfo("-mat_at_offset" .. mat_at_offset) end
		--if (mat_at_belowoffset ~= nil) then world.logInfo("-mat_at_belowoffset" .. mat_at_belowoffset) end
		if mat_at_offset == false and mat_at_belowoffset ~= false then
			-- we have found a block above floor
			-- return its coordinates
			return_position[1] = position[1] + offset[1]
			return_position[2] = position[2] + offset[2]
			return return_position
		end
	end
	-- no floor could be found
	return nil
end
