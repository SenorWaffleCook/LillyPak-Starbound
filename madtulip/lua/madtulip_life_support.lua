function LS_init()
	-- globals
	madtulip = {}
	madtulip.Stage_range = 100;
	
	madtulip.MSS_Range = {} -- range to scan for other vents around the master
	madtulip.MSS_Range[1] = {1,1} -- bottom left corner
	madtulip.MSS_Range[2] = {1102,1048} -- top right corner (size of the shipmap)
	madtulip.On_Off_State = 1; -- "1:ON,2:OFF"
	madtulip.ANY_Breach = 0;
	
	madtulip.scan_time_last_executiong = os.time()  --[s]
	
	LS_Init_Room_Breach_Scan_preallocated_memory(madtulip.Stage_range,1);
end

function LS_Init_Room_Breach_Scan_preallocated_memory(size_to_scan,Scan_8_method)
	-- create global Flood Data matrix which holds the room which is flooded
	madtulip.Flood_Data_Matrix                              = {}; -- nothing stored here
	-- data
	madtulip.Flood_Data_Matrix.Content                      = {}; -- stores at [x,y] the "color" of the block which tells if its background, foreground or open
	madtulip.Flood_Data_Matrix.Breaches                     = {}; -- stores {x,y} pairs of locations of breach
	madtulip.Flood_Data_Matrix.Object_Ids                   = {}; -- stroes IDs of Players that are in the area flooded by the current vent. we dont need to check them again.
	-- settings
	--madtulip.Flood_Data_Matrix.Origin                     = madtulip.Origin;
	madtulip.Flood_Data_Matrix.size_to_scan                 = size_to_scan;
	madtulip.Flood_Data_Matrix.Max_Iteration                = size_to_scan*size_to_scan; -- maximum room size. if the room is larger this will terminate early stating that the room is not closed
	madtulip.Flood_Data_Matrix.Scan_8_method                = Scan_8_method; -- if == 0 scan 4 surrounding blocks (W,N,E,S) else scan also the 4 diagonal corners
	madtulip.Flood_Data_Matrix.target_color                 = 1;
	madtulip.Flood_Data_Matrix.none_target_color            = 2;
	madtulip.Flood_Data_Matrix.replacement_color            = 3;
	-- counter
	madtulip.Flood_Data_Matrix.Area                         = 0; -- counts the area filled with flood
	madtulip.Flood_Data_Matrix.Cur_Iteration                = 0; -- counter for number of iterations done so far
	madtulip.Flood_Data_Matrix.Nr_of_Breaches               = 0; -- counter for number of breaches detected
	madtulip.Flood_Data_Matrix.Nr_of_Player_Ids             = 0; -- counts numbers of players in scanned area
	madtulip.Flood_Data_Matrix.Nr_of_Object_Ids             = 0; -- counts numbers of players in scanned area
	-- bools
	madtulip.Flood_Data_Matrix.Scan_Executed_Once           = false; -- bool
	madtulip.Flood_Data_Matrix.Stop_Iteration               = 0; -- bool
	madtulip.Flood_Data_Matrix.Room_is_not_enclosed         = 0; -- bool
	-- flags after breaking condition has been reached
	madtulip.Flood_Data_Matrix.Background_breach            = 0; -- not enclose due to hole in the back wall
	madtulip.Flood_Data_Matrix.Background_Breach_Location   = {};
	madtulip.Flood_Data_Matrix.Max_Nr_of_Iterations_happend = 0; -- enclosure couldn't be found in maximum number of iteration steps
	madtulip.Flood_Data_Matrix.Maximum_size_to_scan_reached = 0;
	
	madtulip.Flood_Data_Matrix.Vent_Found_In_Scanned_Area   = false; -- if any vent was found in the scanned area
		
	-- init data matrix memory for flood fill
	for cur_X = 1,(1+madtulip.Flood_Data_Matrix.size_to_scan*2),1 do
		madtulip.Flood_Data_Matrix.Content[cur_X] = {};
		for cur_Y = 1,(1+madtulip.Flood_Data_Matrix.size_to_scan*2),1 do
			madtulip.Flood_Data_Matrix.Content[cur_X][cur_Y] = 0;
		end
	end
end

function LS_Start_New_Room_Breach_Scan_preallocated_memory(Starting_Position)
	-- data
	madtulip.Flood_Data_Matrix.Breaches                     = {}; -- stores {x,y} pairs of locations of breach
	madtulip.Flood_Data_Matrix.Object_Ids                   = {}; -- stroes IDs of Players that are in the area flooded by the current vent. we dont need to check them again.
	-- settings
	madtulip.Flood_Data_Matrix.Origin                       = Starting_Position;
	-- counter
	madtulip.Flood_Data_Matrix.Area                         = 0; -- counts the area filled with flood
	madtulip.Flood_Data_Matrix.Cur_Iteration                = 0; -- counter for number of iterations done so far
	madtulip.Flood_Data_Matrix.Nr_of_Breaches               = 0; -- counter for number of breaches detected
	madtulip.Flood_Data_Matrix.Nr_of_Player_Ids             = 0; -- counts numbers of players in scanned area
	madtulip.Flood_Data_Matrix.Nr_of_Object_Ids             = 0; -- counts numbers of players in scanned area
	-- bools
	madtulip.Flood_Data_Matrix.Stop_Iteration               = 0; -- bool
	madtulip.Flood_Data_Matrix.Room_is_not_enclosed         = 0; -- bool
	-- flags after breaking condition has been reached
	madtulip.Flood_Data_Matrix.Background_breach            = 0; -- not enclose due to hole in the back wall
	madtulip.Flood_Data_Matrix.Background_Breach_Location   = {};
	madtulip.Flood_Data_Matrix.Max_Nr_of_Iterations_happend = 0; -- enclosure couldn't be found in maximum number of iteration steps
	madtulip.Flood_Data_Matrix.Maximum_size_to_scan_reached = 0;
	
	madtulip.Flood_Data_Matrix.Vent_Found_In_Scanned_Area   = false; -- if any vent was found in the scanned area
		
	-- init data matrix memory for flood fill
	for cur_X = 1,(1+madtulip.Flood_Data_Matrix.size_to_scan*2),1 do
		madtulip.Flood_Data_Matrix.Content[cur_X] = {};
		for cur_Y = 1,(1+madtulip.Flood_Data_Matrix.size_to_scan*2),1 do
			madtulip.Flood_Data_Matrix.Content[cur_X][cur_Y] = 0;
		end
	end
	
	-- test the area around the block where this is placed for beeing an enclosed room
	LS_Flood_Fill(madtulip.Flood_Data_Matrix.Origin,1,2,3);
	
	-- walk through detected ObjectID of the last scan to find a vent
	for _,ObjectId in ipairs(madtulip.Flood_Data_Matrix.Object_Ids) do
		if (world.entityName(ObjectId) == "madtulip_vent") then
			madtulip.Flood_Data_Matrix.Vent_Found_In_Scanned_Area = true;
		end
	end
	
	madtulip.Flood_Data_Matrix.Scan_Executed_Once = true;
end

function LS_Flood_Fill(cur_Position)
	--  ----- ITERATION BREAKING CONDITIONS: -----
	-- if some step of the iteration already determined to stop iteration
	if madtulip.Flood_Data_Matrix.Stop_Iteration == 1 then
		return;
	end
	
	-- if we leave assigned memory size
	-- THIS BLOCK IS DONE !!!!!!!!!!!!!!!!! EVER OTHER POSITION NEEDS TO BE REPLACED!
	if (current_position_to_data_matrix_position(cur_Position[1],1) < 1) then
		madtulip.Flood_Data_Matrix.Maximum_size_to_scan_reached = 1;
		madtulip.Flood_Data_Matrix.Stop_Iteration = 1;
		return;
	end
	if (current_position_to_data_matrix_position(cur_Position[1],1) > madtulip.Flood_Data_Matrix.size_to_scan*2+1) then
		madtulip.Flood_Data_Matrix.Maximum_size_to_scan_reached = 1;
		madtulip.Flood_Data_Matrix.Stop_Iteration = 1;
		return;
	end
	if (current_position_to_data_matrix_position(cur_Position[2],2) < 1) then
		madtulip.Flood_Data_Matrix.Maximum_size_to_scan_reached = 1;
		madtulip.Flood_Data_Matrix.Stop_Iteration = 1;
		return;
	end
	if (current_position_to_data_matrix_position(cur_Position[2],2) > madtulip.Flood_Data_Matrix.size_to_scan*2+1) then
		madtulip.Flood_Data_Matrix.Maximum_size_to_scan_reached = 1;
		madtulip.Flood_Data_Matrix.Stop_Iteration = 1;
		return;
	end

	-- if this block has already been scanned
	if madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] == madtulip.Flood_Data_Matrix.replacement_color then
		-- we have already been here
		return;
	end
	if madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] == madtulip.Flood_Data_Matrix.none_target_color then
		-- we have already been here
		return;
	end	
	
	-- if maximum number of iterations is reached
	if (madtulip.Flood_Data_Matrix.Cur_Iteration > madtulip.Flood_Data_Matrix.Max_Iteration) then
		-- iteration limit reached
		madtulip.Flood_Data_Matrix.Room_is_not_enclosed          = 1; -- set flag
		madtulip.Flood_Data_Matrix.Max_Nr_of_Iterations_happend  = 1; -- set flag
		madtulip.Flood_Data_Matrix.Stop_Iteration                = 1; -- break iteration
	end
	-- ----- so far we are good, take next step in the state machine -----
	-- increment iteration step
	madtulip.Flood_Data_Matrix.Cur_Iteration = madtulip.Flood_Data_Matrix.Cur_Iteration + 1;

	-- check if there is a Life Support System at "cur_Position"
	local objectIDs = world.objectQuery(cur_Position, 0)
	for _,ObjectId in ipairs(objectIDs) do
		-- check if that objectID was detected already
		local Objects_ID_is_already_listed = false;
		for _,knownObjectsId in ipairs(madtulip.Flood_Data_Matrix.Object_Ids) do
			if (ObjectId == knownObjectsId) then
				Objects_ID_is_already_listed = true;
			end
		end
		if(Objects_ID_is_already_listed == false) then
			-- add objectID to list
			madtulip.Flood_Data_Matrix.Nr_of_Object_Ids = madtulip.Flood_Data_Matrix.Nr_of_Object_Ids+1;-- inc counter
			madtulip.Flood_Data_Matrix.Object_Ids[madtulip.Flood_Data_Matrix.Nr_of_Object_Ids] = ObjectId;
		end
	end
	
	-- check if there is a foreground block which is not a platform
	--- OR a "door" which is closed
	--  ,if not then check if there is a background block
	--  ,if also not its a breach.
	-- write the gathered info to "madtulip.Flood_Data_Matrix.Content[x,y]" which is the data object used further on
	
	-- Next IF should be replaced by:
	--if     ((not world.material(cur_Position, "foreground") == false) and world.pointCollision(cur_Position, true))
	--    or (#world.entityQuery(cur_Position,0,{ includedTypes = {"object"}, callScript = "hasCapability", callScriptArgs = { "door" } }) > 0 and world.pointCollision(cur_Position, true))
	-- but that only works for techs and not for objects, for whatever reason
	if world.pointCollision(cur_Position, true) then
		-- an existing foreground block which is NOT a platform
		-- OR a "door" and collision in that block. for some reason just "closeddoor" querry doesnt cut it as thats larger then the actual collision box of the closed door
		--> its a none target
		--> we did hit the wall here, don`t spawn further searches from this block
		madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] = madtulip.Flood_Data_Matrix.none_target_color
	else
		-- nil foreground block found. This is our target.
		madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] = madtulip.Flood_Data_Matrix.target_color
		-- if this is also a nil background block we have a breach that we might or might not be aware of yet
		if  world.material(cur_Position, "background") == false then
		
			-- its a bachground breach that we have not been aware of!
			madtulip.Flood_Data_Matrix.Nr_of_Breaches = madtulip.Flood_Data_Matrix.Nr_of_Breaches+1;-- inc counter for breaches
			madtulip.Flood_Data_Matrix.Breaches[madtulip.Flood_Data_Matrix.Nr_of_Breaches] = cur_Position;-- store location of breach
			madtulip.Flood_Data_Matrix.Room_is_not_enclosed       = 1; -- set flag that the room is open
			madtulip.Flood_Data_Matrix.Background_breach          = 1; -- not enclose due to hole in the background
			
			-- we did hit a breach here, don`t spawn further searches from this block
			madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] = madtulip.Flood_Data_Matrix.none_target_color
			return;
		end
	end

	--  ----- 1. If the "color" of current node is not equal to target-color, return. -----
	if (madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] ~= madtulip.Flood_Data_Matrix.target_color) then
		-- the current block is not an open foreground space -> don`t spawn further searches from this block
		return;
	end
	
	-- ----- 2. Set the color of node to replacement-color. -----
	-- this block is an empty foreground block. we mark it as "processed" by putting the replacement color
	madtulip.Flood_Data_Matrix.Content[current_position_to_data_matrix_position(cur_Position[1],1)][ current_position_to_data_matrix_position(cur_Position[2],2)] = madtulip.Flood_Data_Matrix.replacement_color
	madtulip.Flood_Data_Matrix.Area = madtulip.Flood_Data_Matrix.Area + 1; -- increment flooded area (starts at 0)
	-- madtulip.Flood_Data_Matrix.Background_in_scanned_Area[madtulip.Flood_Data_Matrix.Area] = cur_Position;
	
	-- ----- 3. Spawn searches in the surrounding blocks -----
	--	Perform Flood-fill (one step to the west of node, target-color, replacement-color).
	if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- west
		LS_Flood_Fill({cur_Position[1] - 1,cur_Position[2]    });
	end
	if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- east
		LS_Flood_Fill({cur_Position[1] + 1,cur_Position[2]    });
	end
	if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- north
		LS_Flood_Fill({cur_Position[1]    ,cur_Position[2] + 1});
	end
	if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- south
		LS_Flood_Fill({cur_Position[1]    ,cur_Position[2] - 1});
	end
	
	if madtulip.Flood_Data_Matrix.Scan_8_method == 1 then
		if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- north west
			LS_Flood_Fill({cur_Position[1] - 1,cur_Position[2] + 1});
		end
		if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- north east
			LS_Flood_Fill({cur_Position[1] + 1,cur_Position[2] + 1});
		end
		if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- south east
			LS_Flood_Fill({cur_Position[1] + 1,cur_Position[2] - 1});
		end
		if madtulip.Flood_Data_Matrix.Stop_Iteration == 0 then -- south west
			LS_Flood_Fill({cur_Position[1] - 1,cur_Position[2] - 1});
		end
	end
end

function current_position_to_data_matrix_position(cur_pos,dim)
	return_pos = cur_pos - madtulip.Flood_Data_Matrix.Origin[dim] + madtulip.Flood_Data_Matrix.size_to_scan +1
	return return_pos
end
