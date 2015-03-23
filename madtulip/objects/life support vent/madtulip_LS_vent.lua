function init()
	-- Make our object interactive (we can interract by 'Use')
	entity.setInteractive(true);
	-- Change animation for state "normal_operation"
	entity.setAnimationState("DisplayState", "normal_operation");

	-- Init for life support functions
	LS_init();
	
	madtulip.maximum_particle_fountains = entity.configParameter("madtulip_maximum_particle_fountains_per_spawn", 10)
	madtulip.scan_intervall_time = entity.configParameter("madtulip_scan_intervall_time", 1)
	madtulip.beep_intervall_time = entity.configParameter("madtulip_beep_intervall_time", 1)
	madtulip.spawn_projectile_intervall_time = entity.configParameter("madtulip_spawn_projectile_intervall_time", 1)
	
	madtulip.beep_time_last_execution = os.time() --[s]
	madtulip.spawn_projectile_time_last_execution = os.time() --[s]
	
	madtulip.Old_Task_Broadcast = {}
	
	-- spawn a new main calculation thread
	co = coroutine.create(function ()
		-- Automatic Hull Breach Scans for all Vents in the Area
		main_threaded();
	 end)
end

function onInteraction(args)
	-- if clicked by middle mouse or "e"
	
	-- here you can switch the main unit and all slaves off
	if(madtulip.On_Off_State == 1) then
		-- deactivated until suit can detect that state
		--[[
		madtulip.On_Off_State = 2;
		entity.setAnimationState("DisplayState", "offline");
		--]]
	else
		madtulip.On_Off_State = 1;
		--entity.setAnimationState("DisplayState", "no_vent");
		entity.setAnimationState("DisplayState", "normal_operation");
	end
end

function update(dt)
	--main_threaded();
	if (coroutine.status(co) == "suspended") then
		-- start thread
		coroutine.resume(co);
	elseif (coroutine.status(co) == "dead") then
		-- spawn a new main calculation thread
		co = coroutine.create(function ()
			-- Automatic Hull Breach Scans for all Vents in the Area
			main_threaded();
		 end)
	elseif (coroutine.status(co) == "running") then
		-- nothing
	end
end

function main_threaded()
	-- only works on ship, not on planet
	if not is_shipworld() then return false end
	
	-- grafic update
	if(os.time() >= madtulip.spawn_projectile_time_last_execution + madtulip.spawn_projectile_intervall_time) then
		-- check for system beeing offline
		if (madtulip.On_Off_State ~= 1) then
			-- offline
			entity.setAnimationState("DisplayState", "offline");
		else
			if (madtulip.Flood_Data_Matrix ~= nil) then
				-- online
				-- own graphics
				if (madtulip.Flood_Data_Matrix.Room_is_not_enclosed == 1) then
					-- set animation state of master wall panel to breach
					entity.setAnimationState("DisplayState", "breach");
					entity.setAllOutboundNodes(false)
				else
					-- set animation state to normal operation
					entity.setAnimationState("DisplayState", "normal_operation");
					entity.setAllOutboundNodes(true)
					
					-- spawn life support status projectiles on players in scanned area
					--[[
					// working but no longer needed
					for _,knownplayerId in ipairs(madtulip.Flood_Data_Matrix.Player_Ids) do
						spawn_life_support_status_projectile(world.entityPosition(knownplayerId))
					end
					--]]
				end
				
				-- spawn breach grafics
				local counter_breaches = 0;
				local breach_pos = {}
				-- save states of the currently checked vent
				for _, Breach_Location in pairs(madtulip.Flood_Data_Matrix.Breaches) do
					counter_breaches = counter_breaches +1;
					breach_pos[counter_breaches] = Breach_Location;
				end
				-- Spawn a Task for each breach
				Broadcast_Hull_Breach_Task(breach_pos,counter_breaches)
				-- limit theire number
				if (counter_breaches > madtulip.maximum_particle_fountains) then
					-- spawn them (limited amount)
					for cur_particle_fountain_to_generate = 1,madtulip.maximum_particle_fountains,1 do
						world.spawnProjectile("madtulip_breach", breach_pos[math.random(counter_breaches)]);
					end
				else
					-- spawn them (all)
					for cur_counter_breaches = 1,counter_breaches,1 do
						world.spawnProjectile("madtulip_breach", breach_pos[cur_counter_breaches]);
					end
				end
			end	
		end		
		madtulip.spawn_projectile_time_last_execution = os.time() --[s]
	end
	
	-- sound
	if(os.time() >= madtulip.beep_time_last_execution + madtulip.beep_intervall_time) then
		-- check for system beeing offline
		if (madtulip.On_Off_State ~= 1) then
			-- offline
		else
			-- online
			if (madtulip.Flood_Data_Matrix ~= nil) then
				if (madtulip.Flood_Data_Matrix.Room_is_not_enclosed == 1) then
					-- play a meeping warning sound
					entity.playSound("Breach_Warning_Sound");
				end
			end
		end
		madtulip.beep_time_last_execution = os.time() --[s]
	end
	
	-- area scan
	if(os.time() >= madtulip.scan_time_last_executiong + madtulip.scan_intervall_time) then
		LS_Start_New_Room_Breach_Scan_preallocated_memory(entity.toAbsolutePosition({ 0.0, 0.0 }));
		madtulip.scan_time_last_executiong = os.time()
	end
end

function Broadcast_Hull_Breach_Task(breach_pos,counter_breaches)
	local radius = 50 -- TODO: parameter or line of sight or something instead

	-- check if there are any new breaches.
	-- If that is the case we need to cancel all old tasks we gave and update with the new information.
	-- This might be new clusters which have been formed.
	if (madtulip.Old_Task_Broadcast.exists) then
		-- check for new breaches
		local there_are_new_breaches = false
		for cur_new_breach_idx = 1,counter_breaches,1 do
			local new_breach_was_known = false
			for cur_old_breach_idx = 1,madtulip.Old_Task_Broadcast.counter_breaches,1 do
				local new_pixel = madtulip.Old_Task_Broadcast.breach_pos[cur_old_breach_idx]
				local old_pixel = breach_pos[cur_new_breach_idx]
				if (new_pixel[1] == old_pixel[1]) and (new_pixel[2] == old_pixel[2]) then
					new_breach_was_known = true
				end
			end
			if not (new_breach_was_known) then
				there_are_new_breaches = true
			end
		end
		for cur_old_breach_idx = 1,madtulip.Old_Task_Broadcast.counter_breaches,1 do
			local new_breach_was_known = false
			for cur_new_breach_idx = 1,counter_breaches,1 do
				local new_pixel = madtulip.Old_Task_Broadcast.breach_pos[cur_old_breach_idx]
				local old_pixel = breach_pos[cur_new_breach_idx]
				if (new_pixel[1] == old_pixel[1]) and (new_pixel[2] == old_pixel[2]) then
					new_breach_was_known = true
				end
			end
			if not (new_breach_was_known) then
				there_are_new_breaches = true
			end
		end
		-- act based on new breaches or not (eighter broadcast the old stuff or mark the old stuff as obsolete and broadcast the new stuff)
		if not (there_are_new_breaches) then
			-- just continue to broadcast the old stuff. we need to do that in case someone didnt hear the task so far. (sirens are still on :))
			world.npcQuery(entity.position(), radius, {callScript = "madtulip_TS.Offer_Tasks", callScriptArgs = {madtulip.Old_Task_Broadcast.Tasks_Announced}})
			return
		else
			-- cancel the old tasks we did announce
			for cur_Task = 1,#madtulip.Old_Task_Broadcast.Tasks_Announced.Tasks,1 do
				-- we mark them as done so people stop doing them and they forget about them
				madtulip.Old_Task_Broadcast.Tasks_Announced.Tasks[cur_Task].Global.is_done = true
			end
			-- we broadcast that they are all done
			world.npcQuery(entity.position(), radius, {callScript = "madtulip_TS.Offer_Tasks", callScriptArgs = {madtulip.Old_Task_Broadcast.Tasks_Announced}})
			-- and delete them from memory and all history about broadcasting from memory as we start over now.
			madtulip.Old_Task_Broadcast = {}
		end
	end

	-- cluster the breaches
	local Cluster_Data = pixel_array_to_clusters(breach_pos,counter_breaches)
	
	-- add information where to place fore and background in order to close the breach
	for cur_breach_cluster_nr = 1,Cluster_Data.Clusters.size,1 do
		Cluster_Data.Clusters[cur_breach_cluster_nr].place_foreground = Add_Breach_fixing_Info_to_Cluster(Cluster_Data.Clusters[cur_breach_cluster_nr].Cluster)
	end
	
	-- Assemble the Tasks
	local New_Tasks = {}
	New_Tasks.Tasks = {}
	New_Tasks.size = 0

	for cur_breach_cluster_nr = 1,Cluster_Data.Clusters.size,1 do
		-- spawn task
		-- New_Tasks.size = New_Tasks.size + 1; -- one task for all clusters
		New_Tasks.size = 1 -- one task per cluster
		New_Tasks.Tasks[New_Tasks.size] = {}
		New_Tasks.Tasks[New_Tasks.size].Header = {}
		New_Tasks.Tasks[New_Tasks.size].Header.Name = "Fix_Hull_Breach"
		New_Tasks.Tasks[New_Tasks.size].Header.Occupation = "Engineer"
		New_Tasks.Tasks[New_Tasks.size].Header.Fct_Task  = "madtulip_task_fix_hull_breach"
		New_Tasks.Tasks[New_Tasks.size].Header.Msg_on_discover_this_Task = "HULL BREACHED!"
		New_Tasks.Tasks[New_Tasks.size].Header.Msg_on_PickTask = "I`ll fix that hull breach!"
		-- The header of the Task is used in total as key to check if the task is known.
		-- We put all breaches in the header to make this unique.
		for cur_breach = 1,#Cluster_Data.Clusters[cur_breach_cluster_nr].Cluster,1 do
			New_Tasks.Tasks[New_Tasks.size].Header["Breach_" .. cur_breach .. "_x"] = Cluster_Data.Clusters[cur_breach_cluster_nr].Cluster[cur_breach][1]
			New_Tasks.Tasks[New_Tasks.size].Header["Breach_" .. cur_breach .. "_y"] = Cluster_Data.Clusters[cur_breach_cluster_nr].Cluster[cur_breach][2]
		end
		New_Tasks.Tasks[New_Tasks.size].Global = {}
		New_Tasks.Tasks[New_Tasks.size].Global.is_beeing_handled = false
		New_Tasks.Tasks[New_Tasks.size].Global.is_done = false
		New_Tasks.Tasks[New_Tasks.size].Global.revision = 1
		New_Tasks.Tasks[New_Tasks.size].Const = {}
		New_Tasks.Tasks[New_Tasks.size].Const.Timeout = 30
		New_Tasks.Tasks[New_Tasks.size].Var = {}
		New_Tasks.Tasks[New_Tasks.size].Var.Cur_Target_Position = nil
		New_Tasks.Tasks[New_Tasks.size].Var.Cur_Target_Position_BB = nil
		New_Tasks.Tasks[New_Tasks.size].Var.Breach_Cluster = copyTable(Cluster_Data.Clusters[cur_breach_cluster_nr]) -- here the breach locations are stored (again, apart from the stupid formating in the header ("640kb should be enough for everyone.")
		
		world.npcQuery(entity.position(), radius, {callScript = "madtulip_TS.Offer_Tasks", callScriptArgs = {New_Tasks}}) -- one task per cluster
	end
	
	-- save breaches to be able to check for new breaches on next execution
	if (madtulip.Old_Task_Broadcast == nil) then madtulip.Old = {} end
	madtulip.Old_Task_Broadcast.exists           = true
	madtulip.Old_Task_Broadcast.breach_pos       = breach_pos
	madtulip.Old_Task_Broadcast.counter_breaches = counter_breaches
	madtulip.Old_Task_Broadcast.Tasks_Announced  = New_Tasks
end

function pixel_array_to_clusters(pixels,pixel_size)
	-- we have all currently known breaches and need to structure them a bit
	-- so lets first cluster them.:
	-- for all pixels
		-- cur_pixels_cluster_list = {}
		-- cur_pixels_cluster_list_size = 0
		-- if cur pixel is next to any member of any existing cluster
			-- cur_pixels_cluster_list_size = cur_pixels_cluster_list_size + 1
			-- add that clusters label to cur_pixels_cluster_list
		-- end
		-- if cur_pixels_cluster_list_size == 0
			-- create new cluster
		-- elseif cur_pixels_cluster_list_size == 1
			-- add pixel to that one cluster
		-- else
			-- merge all those clusters in the list
		-- end
	-- end
	
	--world.logInfo ("Initial number of pixels : " .. pixel_size)
	
	local Clusters = {}
	Clusters.size = 0
	local cur_pixel = {}

	local cur_pixels_cluster_list = {}
	local cur_pixels_cluster_list_size = 0	
	
	-- for all pixels
	--world.logInfo ("----- START OF CLUSTERING -----")
	for cur_idx_pixel = 1,pixel_size,1 do
		-- get cur breach
		cur_pixel = pixels[cur_idx_pixel]	
		--world.logInfo ("cur_pixel nr" .. cur_idx_pixel .. " (x: " .. cur_pixel[1] .. " y: " .. cur_pixel[2] .. ")")
		cur_pixels_cluster_list = {}
		cur_pixels_cluster_list_size = 0
		-- if cur pixel is next to any member of any existing cluster
		for cur_Cluster = 1,Clusters.size,1 do
			-- for all pixels in the cur cluster
			for cur_pixel_in_cur_cluster = 1,Clusters[cur_Cluster].size,1 do
				-- if cur pixel is next to that pixel in the cluster
				if (pixels_next_to_eachother(cur_pixel,Clusters[cur_Cluster].Cluster[cur_pixel_in_cur_cluster])) then
					-- get that clusters label
					-- add those cluster labels to cur_pixels_cluster_list
					--world.logInfo ("cur_Cluster " .. cur_Cluster .. " is next to cur_pixel nr: " .. cur_idx_pixel .. " (x: " .. cur_pixel[1] .. " y: " .. cur_pixel[2] .. ")")
					-- only if cur_Cluster is not already in the cur_pixels_cluster_list list
					local cluster_is_knwon_already = false
					for cur_list_idx = 1,cur_pixels_cluster_list_size,1 do
						if (cur_pixels_cluster_list[cur_list_idx] == cur_Cluster) then
							cluster_is_knwon_already = true
						end
					end
					if not(cluster_is_knwon_already) then
						cur_pixels_cluster_list_size = cur_pixels_cluster_list_size + 1
						cur_pixels_cluster_list[cur_pixels_cluster_list_size] = cur_Cluster
					end
				end
			end
		end
		if cur_pixels_cluster_list_size == 0 then
			-- create new cluster
			Clusters.size = Clusters.size +1
			Clusters[Clusters.size] = {}
			Clusters[Clusters.size].Cluster = {}
			Clusters[Clusters.size].size = 0
			-- add cur pixel
			Clusters[Clusters.size].size = Clusters[Clusters.size].size +1
			Clusters[Clusters.size].Cluster[Clusters[Clusters.size].size] = cur_pixel
			
			--world.logInfo ("No neighbour, creating new cluster nr: " .. Clusters.size .. " for cur_pixel nr: " .. cur_idx_pixel .. " (x: " .. cur_pixel[1] .. " y: " .. cur_pixel[2] .. ")")
		elseif cur_pixels_cluster_list_size == 1 then
			-- add pixel to that one cluster
			Clusters[cur_pixels_cluster_list[1] ].size = Clusters[cur_pixels_cluster_list[1] ].size +1
			Clusters[cur_pixels_cluster_list[1] ].Cluster[Clusters[cur_pixels_cluster_list[1] ].size] = cur_pixel
			--world.logInfo ("One neighbour. adding to cluster nr: " .. cur_pixels_cluster_list[1] .. " for cur_pixel nr: " .. cur_idx_pixel .. " (x: " .. cur_pixel[1] .. " y: " .. cur_pixel[2] .. ")")
		else
			-- add pixel to the first cluster
			Clusters[cur_pixels_cluster_list[1] ].size = Clusters[cur_pixels_cluster_list[1] ].size +1
			Clusters[cur_pixels_cluster_list[1] ].Cluster[Clusters[cur_pixels_cluster_list[1] ].size] = cur_pixel
			
			-- merge all clusters in cur_pixels_cluster_list into the first
			--world.logInfo ("Multiple neighbours. Merging for cur_pixel nr: " .. cur_idx_pixel .. " (x: " .. cur_pixel[1] .. " y: " .. cur_pixel[2] .. ")")
			for i = 2,cur_pixels_cluster_list_size,1 do
				local a = cur_pixels_cluster_list[1] -- cluster to merge into
				local b = cur_pixels_cluster_list[i] -- cluster to merge
				--world.logInfo ("Clusters[a].size: " .. Clusters[a].size .. " Clusters[b].size : " .. Clusters[b].size)
				for cur_idx_b = 1,Clusters[b].size,1 do
					-- move pixel from b to a
					--world.logInfo ("Copy Pixel b (x: " .. Clusters[b].Cluster[cur_idx_b][1] .. " y: " .. Clusters[b].Cluster[cur_idx_b][2] .. ") to a")
					Clusters[a].size = Clusters[a].size+1
					Clusters[a].Cluster[Clusters[a].size] = Clusters[b].Cluster[cur_idx_b]
					Clusters[b].Cluster[cur_idx_b] = nil
				end
				--world.logInfo ("Clusters[a].size after merge: " .. Clusters[a].size)
				Clusters[b].size = 0 -- cluster has been fully merged into a
			end
			-- resize the cluster label so that there are no gaps
			local new_cluster_size = 0
			for i = 1,Clusters.size,1 do
				if (Clusters[i].size ~= 0) then
					new_cluster_size = new_cluster_size+1
					if (i ~= new_cluster_size) then
						Clusters[new_cluster_size] = Clusters[i]
					end
				end
			end
			Clusters.size = new_cluster_size
			--world.logInfo ("Number of Clusters after merge: " .. Clusters.size)
		end
	end

	-- sort the clusters in size
	local tmp_Clusters = copyTable(Clusters)
	local cur_max_size = 0
	local cur_max_size_cluster_idx = nil
	for cur_write_cluster = 1,Clusters.size,1 do
		cur_max_size = 0
		cur_max_size_cluster_idx = nil
		for cur_read_cluster = 1,tmp_Clusters.size,1 do
			if (tmp_Clusters[cur_read_cluster].size > cur_max_size) then
				cur_max_size = tmp_Clusters[cur_read_cluster].size
				cur_max_size_cluster_idx = cur_read_cluster
			end
		end
		-- write cur largest cluster first
		Clusters[cur_write_cluster] = tmp_Clusters[cur_max_size_cluster_idx]
		Clusters[cur_write_cluster].size = tmp_Clusters[cur_max_size_cluster_idx].size
		-- clear data
		tmp_Clusters[cur_max_size_cluster_idx] = {}
		tmp_Clusters[cur_max_size_cluster_idx].size = 0
	end

	local BB = {}
	for cur_cluster = 1,Clusters.size,1 do
		BB = {math.huge,math.huge,-math.huge,-math.huge}
		-- min
		for i = 1,Clusters[cur_cluster].size,1 do
			local pos = Clusters[cur_cluster].Cluster[i]
			if (pos[1] < BB[1]) then BB[1] = pos[1] end
		end
		for i = 1,Clusters[cur_cluster].size,1 do
			local pos = Clusters[cur_cluster].Cluster[i]
			if (pos[2] < BB[2]) then BB[2] = pos[2] end
		end
		-- max
		for i = 1,Clusters[cur_cluster].size,1 do
			local pos = Clusters[cur_cluster].Cluster[i]
			if (pos[1] > BB[3]) then BB[3] = pos[1] end
		end
		for i = 1,Clusters[cur_cluster].size,1 do
			local pos = Clusters[cur_cluster].Cluster[i]
			if (pos[2] > BB[4]) then BB[4] = pos[2] end
		end
		Clusters[cur_cluster].BB = copyTable(BB)
	end
--[[
	world.logInfo ("----- END OF CLUSTERING -----")
	world.logInfo ("Number of Breach Clusters detected : " .. Clusters.size)
	for cur_cluster = 1,Clusters.size,1 do
		world.logInfo ("Cluster Nr: " .. cur_cluster .. " has a size of : " .. Clusters[cur_cluster].size)
		for cur_pixel = 1,Clusters[cur_cluster].size,1 do
			world.logInfo ("-Pixel Nr: " .. cur_pixel .. " X: " .. Clusters[cur_cluster].Cluster[cur_pixel][1] .. " Y: " .. Clusters[cur_cluster].Cluster[cur_pixel][2])
		end
	end
--]]
	return {
	Clusters = Clusters,
	size = Clusters.size
	}
end

function Add_Breach_fixing_Info_to_Cluster(Cluster)

	local cur_pos = {}
	local has_space_next_to_it = false
	
	local place_foreground = {}
	for cur_pixel = 1,#Cluster,1 do
		for X = -1,1,1 do
			for Y = -1,1,1 do

				cur_pos[1] = Cluster[cur_pixel][1] + X
				cur_pos[2] = Cluster[cur_pixel][2] + Y
				-- check if cur_pos is part of cluster
				local cur_pos_is_part_of_cluster = false
				for i = 1,#Cluster,1 do
					if (Cluster[i][1] == cur_pos[1]) and (Cluster[i][2] == cur_pos[2]) then
						cur_pos_is_part_of_cluster = true
					end
				end
				-- if no fore, no back and not part of cluster then its space.
				if ((world.material(cur_pos,"foreground") == false) and
				    (world.material(cur_pos,"background") == false) and
				    (cur_pos_is_part_of_cluster == false)) then
				   has_space_next_to_it = true
			   end

			end
		end
		if (has_space_next_to_it) then
			-- blocks next to space need to place foreground
			place_foreground[cur_pixel] = true
		else
			place_foreground[cur_pixel] = false
		end
		-- all breached blocks need to place background anyway so thats not recorded
	end
	
	return place_foreground
end

function pixels_next_to_eachother(a,b)
	local c = world.distance(a,b)
	if (math.abs(c[1]) <= 1) and (math.abs(c[2]) <= 1) then return true end
	return false
end

-- Currently not in use projectile spawning was uncommented
function spawn_life_support_status_projectile(position)
    local projectile = entity.configParameter("projectileOptions")
	world.spawnProjectile(projectile.projectileType, position, entity.id(), { 0, 0 }, true)
end