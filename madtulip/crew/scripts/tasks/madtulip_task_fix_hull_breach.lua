madtulip_task_fix_hull_breach = {}

function madtulip_task_fix_hull_breach.can_PickTask(Task)
	-- this gets called by all NPCs that receive this task which are searching for a Task to do it.
	-- If this returns true the NPC will pick this Task and start to execute it.
	-- So here you should check for the currents NPC Occupation i.e. to see if hes able to do it.
	--world.logInfo("madtulip_task_fix_hull_breach.can_PickTask()")

	-- check if I have the command to do this tasks
	if not madtulip_task_fix_hull_breach.has_command_to_do_the_task(Task.Header.Name) then return false end -- kick out because performing this task is disabled


	-- Check if I have the right Occupation to do the job
	if not(   (Task.Header.Occupation == "all")
	       or (Task.Header.Occupation == storage.Occupation)
		   ) then
	   return false
   end
   
   -- ok we can pick that task

	--entity.setItemSlot("primary", "beamaxe")
	--entity.setItemSlot("alt", nil)
	
	madtulip_task_fix_hull_breach.is_init = nil
	
	return true
end

function madtulip_task_fix_hull_breach.main_Task(Task)
	-- the main of the Task which is called all the time until it return true (the task is done)
	--world.logInfo("Task main - start")

-- TODO: After finding a cluster we need to create a BB around that which consideres world wrap
--       Inside the BB we will use floodfill to find areas enclosed by the breaches conture.
--       Those Areas will also be filled with breaches. Afterwards the "place_foreground" will be added to the whole cluster.
--       This will correctly fill shapes like 3x3 breach in background wall.

-- TODO: The BB for the task is the BB around all breaches + a boarder of placement range. In that BB the player needs
--       to be able to stand somewhere to do the Task. If he cant stand there the Task is not solvable. Eigther not spawn it at all
--       or include NOT_SOLVABLE in the TASK variables so that crew doesnt try on and on and on.

	-- check if I STILL have the command to do this tasks
	if not madtulip_task_fix_hull_breach.has_command_to_do_the_task(Task.Header.Name) then return true end -- kick out because performing this task is disabled

	-- enforce to pick ROI state to navigate to target
	if not madtulip_task_fix_hull_breach.is_init then
		madtulip_task_fix_hull_breach.use_ROI_State_to_navigate_to_target_area(
			Task.Var.Breach_Cluster.BB,
			entity.configParameter("madtulipTS.Hull_Breach_place_Block_Range"),
			madtulip_task_fix_hull_breach.failed_Task)
		madtulip_task_fix_hull_breach.is_init = true
	end
	
	-- aim at target
	--entity.setAimPosition(target_position)
	
	-- find minimal distance to any breach in cluster
	local min_distance = math.huge
	for cur_breach = 1,Task.Var.Breach_Cluster.size,1 do
		local cur_distance = world.magnitude(world.distance(mcontroller.position(),Task.Var.Breach_Cluster.Cluster[cur_breach]))
		if cur_distance < min_distance then min_distance = cur_distance end
	end

	-- build ?
	if (min_distance <= entity.configParameter("madtulipTS.Hull_Breach_place_Block_Range", nil))then
		-- close enough to build -> BUILD ALL BLOCKS AT ONCE
		for cur_breach = 1,Task.Var.Breach_Cluster.size,1 do
			-- always place background
			world.placeMaterial(Task.Var.Breach_Cluster.Cluster[cur_breach], "background", "madtuip_rustymetal")
			-- optionally place foreground (if this is an outer wall towards "space")
			if (Task.Var.Breach_Cluster.place_foreground[cur_breach]) then
				world.placeMaterial(Task.Var.Breach_Cluster.Cluster[cur_breach], "foreground", "madtuip_rustymetal")
			end
		end
	end
	
	-- check if all breaches have been closed
	local all_breaches_closed = true
	for cur_breach = 1,Task.Var.Breach_Cluster.size,1 do
		-- check if background is placed
		if (world.material(Task.Var.Breach_Cluster.Cluster[cur_breach],"background") == false) then all_breaches_closed = false end
		-- check if foreground is placed
		if (Task.Var.Breach_Cluster.place_foreground[cur_breach]) then
			if (world.material(Task.Var.Breach_Cluster.Cluster[cur_breach],"foreground") == false) then all_breaches_closed = false end
		end
	end
	
	--world.logInfo("Task main - end")
	-- end task depending on all breaches being closed
	if all_breaches_closed then
		return true -- if done
	else
		return false -- if NOT done
	end
end

function madtulip_task_fix_hull_breach.end_Task()
	-- Called when the Task was completed
	-- eigther by me, or by someone else doing the same thing!
	--world.logInfo("madtulip_task_fix_hull_breach.end_Task()")
	
	entity.setItemSlot("primary", nil)
	entity.setItemSlot("alt", nil)
	
	-- Exit current state machine State
	self.state.endState()
	
	-- TODO: exit all current state machine states (before killing the task)
end

function madtulip_task_fix_hull_breach.failed_Task()
	-- hand the error back up to the Task scheduler, he will also call .end_Task()
	madtulip_TS.fail_my_current_Task()
end

function madtulip_task_fix_hull_breach.has_command_to_do_the_task(Task_Name)
	-- check if I have the command to do this tasks
	local has_cmd_to_do_the_task = false
	for _idx, _val in pairs(storage.Command_Task_Name) do
		if (storage.Command_Task_Name[_idx] == Task_Name) and (storage.Command_Perform[_idx]) then
			has_cmd_to_do_the_task = true
		end
	end
	return has_cmd_to_do_the_task
end

function madtulip_task_fix_hull_breach.use_ROI_State_to_navigate_to_target_area(Work_site_BB,work_range,fail_callback_fct)
	--world.logInfo("Init Task - start")
	local ROI_Parameters = {}
	
	ROI_Parameters.BB = Work_site_BB
	-- enlarge the BB to where the player can be while building
-- TODO: might need to be increased by jump hight
-- Problem would be if we move to a floor below the breach then
	ROI_Parameters.BB[1] = ROI_Parameters.BB[1] - work_range + 1
	ROI_Parameters.BB[2] = ROI_Parameters.BB[2] - work_range + 1
	ROI_Parameters.BB[3] = ROI_Parameters.BB[3] + work_range - 1
	ROI_Parameters.BB[4] = ROI_Parameters.BB[4] + work_range - 1
	
	ROI_Parameters.Anchor = {ROI_Parameters.BB[1],ROI_Parameters.BB[2]} -- bottom left of BB
	
	-- use Anchor as 0,0 point for the BB
	ROI_Parameters.BB[1] = ROI_Parameters.BB[1] - ROI_Parameters.Anchor[1]
	ROI_Parameters.BB[2] = ROI_Parameters.BB[2] - ROI_Parameters.Anchor[2]
	ROI_Parameters.BB[3] = ROI_Parameters.BB[3] - ROI_Parameters.Anchor[1]
	ROI_Parameters.BB[4] = ROI_Parameters.BB[4] - ROI_Parameters.Anchor[2]
	
	ROI_Parameters.Ground_the_Anchor = false
	
	ROI_Parameters.Pick_New_Target_after_old_is_reached = false
	
	ROI_Parameters.run = true
	
	ROI_Parameters.start_chats_on_the_way = false

	ROI_Parameters.Statename = "madtulipROIState"

	-- called if State decided that task is not solveable (i.e. not reachable)
	ROI_Parameters.Critical_Fail_Callback = fail_callback_fct
	
	--world.logInfo("State description: " .. self.state.stateDesc())
	self.state.endState() -- end current state, whatever that is
	self.state.pickState(ROI_Parameters)
	--world.logInfo("Init Task - end")
end