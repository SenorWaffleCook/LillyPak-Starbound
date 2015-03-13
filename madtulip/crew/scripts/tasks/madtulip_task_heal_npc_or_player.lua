madtulip_Task_Heal_NPC_or_Player = {}

function madtulip_Task_Heal_NPC_or_Player.spot_Task()
	-- init variables
	local Tasks = {}
	local radius = entity.configParameter("madtulipTS.find_Heal_NPC_or_Player_range", nil)
	local Tasks_size = 0
	
	-- find damaged players
	for idx, PlayerId in pairs(world.playerQuery(mcontroller.position(), radius)) do
		local Player_health = world.entityHealth(PlayerId)
		-- health smaller 95% of max health
		if (Player_health[1] < 0.95* Player_health[2]) then
			-- spawn task
			Tasks_size = Tasks_size + 1;
			Tasks[Tasks_size] = {}
			Tasks[Tasks_size].Header = {}
			Tasks[Tasks_size].Header.Name = "Heal_Player"
			Tasks[Tasks_size].Header.Occupation = "Medic"
			Tasks[Tasks_size].Header.Target_ID = PlayerId
			Tasks[Tasks_size].Header.Fct_Task  = "madtulip_Task_Heal_NPC_or_Player"
			Tasks[Tasks_size].Header.Msg_on_discover_this_Task = "MEDIC!"
			Tasks[Tasks_size].Header.Msg_on_PickTask = "I`ll would stitch you up if there wasn`t hard coded invulnerability on the shipworld!"
			Tasks[Tasks_size].Global = {}
			Tasks[Tasks_size].Global.is_beeing_handled = false
			Tasks[Tasks_size].Global.is_done = false
			Tasks[Tasks_size].Global.revision = 1
			Tasks[Tasks_size].Const = {}
			Tasks[Tasks_size].Const.Timeout = 30
			Tasks[Tasks_size].Var = {}
			Tasks[Tasks_size].Var.Cur_Target_Position = nil
			Tasks[Tasks_size].Var.Cur_Target_Position_BB = nil
			
			--Tasks[Tasks_size].Const.Do_this_from  = os.time() + 5
			--Tasks[Tasks_size].Const.Do_this_until = os.time() + 10
		end
	end

	-- find damaged NPCs
	for idx, NPCId in pairs(world.npcQuery(mcontroller.position(), radius)) do
		local NPC_health = world.entityHealth(NPCId)
		-- health smaller 95% of max health
		if (NPC_health[1] < 0.95* NPC_health[2]) then
			-- spawn task
			Tasks_size = Tasks_size + 1;
			Tasks[Tasks_size] = {}
			Tasks[Tasks_size].Header = {}
			Tasks[Tasks_size].Header.Name = "Heal_Player"
			Tasks[Tasks_size].Header.Occupation = "Medic"
			Tasks[Tasks_size].Header.Target_ID = NPCId
			Tasks[Tasks_size].Header.Fct_Task  = "madtulip_Task_Heal_NPC_or_Player"
			Tasks[Tasks_size].Header.Msg_on_discover_this_Task = "MEDIC!!!"
			Tasks[Tasks_size].Header.Msg_on_PickTask = "I can handle that!"
			Tasks[Tasks_size].Global = {}
			Tasks[Tasks_size].Global.is_beeing_handled = false
			Tasks[Tasks_size].Global.is_done = false
			Tasks[Tasks_size].Global.revision = 1
			Tasks[Tasks_size].Const = {}
			Tasks[Tasks_size].Const.Timeout = 30
			Tasks[Tasks_size].Var = {}
			Tasks[Tasks_size].Var.Cur_Target_Position = nil
			Tasks[Tasks_size].Var.Cur_Target_Position_BB = nil
			
			--Tasks[Tasks_size].Const.Do_this_from  = os.time() + 5
			--Tasks[Tasks_size].Const.Do_this_until = os.time() + 10
		end
	end
	
	return Tasks;
end

function madtulip_Task_Heal_NPC_or_Player.can_PickTask(Task)
	-- this gets called by all NPCs that receive this task which are searching for a Task to do it.
	-- If this returns true the NPC will pick this Task and start to execute it.
	-- So here you should check for the currents NPC Occupation i.e. to see if hes able to do it.
	--world.logInfo("madtulip_Task_Heal_NPC_or_Player.can_PickTask()")
	
	-- check if I have the command to do this tasks
	if not madtulip_Task_Heal_NPC_or_Player.has_command_to_do_the_task(Task.Header.Name) then return false end -- kick out because performing this task is disabled
	
	-- Check if I have the right Occupation to do the job
	if not((Task.Header.Occupation == "all") or (Task.Header.Occupation == storage.Occupation)) then return false end

	-- equip necessary tool
	entity.setItemSlot("primary", "madtulip_bone_mender")
	entity.setItemSlot("alt", nil)

	madtulip_Task_Heal_NPC_or_Player.movement_is_init = nil	
	
	return true
end

function madtulip_Task_Heal_NPC_or_Player.main_Task(Task,dt)
	-- the main of the Task which is called all the time until it return true (the task is done)
	--world.logInfo("madtulip_Task_Heal_NPC_or_Player.main_Task(Task)")
	
	-- check if I STILL have the command to do this tasks, else kick out
	if not madtulip_Task_Heal_NPC_or_Player.has_command_to_do_the_task(Task.Header.Name) then return true end -- kick out because performing this task has just been disabled
	
	madtulip_Task_Heal_NPC_or_Player.update_timers(dt)
	
	-- check if target health smaller 95% of its max health
	if not madtulip_Task_Heal_NPC_or_Player.Task_is_fullfilled(Task) then
	
		local own_position = mcontroller.position()
		local target_position = world.entityPosition (Task.Header.Target_ID)
		local distance = world.magnitude(world.distance(own_position,target_position))

		-- Init new movement target
		if not madtulip_Task_Heal_NPC_or_Player.movement_is_init then
			-- set initial movement target area
			madtulip_Task_Heal_NPC_or_Player.use_ROI_State_to_navigate_to_target_area(
				 {target_position[1] - entity.configParameter("madtulipTS.use_bonemender_min_range"),
				  target_position[2] - entity.configParameter("madtulipTS.use_bonemender_min_range"),
				  target_position[1] + entity.configParameter("madtulipTS.use_bonemender_min_range"),
				  target_position[2] + entity.configParameter("madtulipTS.use_bonemender_min_range")},
				entity.configParameter("madtulipTS.use_bonemender_range")-entity.configParameter("madtulipTS.use_bonemender_min_range"),
				madtulip_Task_Heal_NPC_or_Player.failed_Task,
				madtulip_Task_Heal_NPC_or_Player.ROI_State_ended)
			madtulip_Task_Heal_NPC_or_Player.old_target_position = target_position
			
			madtulip_Task_Heal_NPC_or_Player.movement_is_init = true
		end
		
		-- Check if target changed position. If so, chase it.
		if (not(   (math.ceil(target_position[1]) == math.ceil(madtulip_Task_Heal_NPC_or_Player.old_target_position[1]))
		       and (math.ceil(target_position[2]) == math.ceil(madtulip_Task_Heal_NPC_or_Player.old_target_position[2]))))
		    and (madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer == nil) then
			-- entity.say("Target moved! Chasing.")
			madtulip_Task_Heal_NPC_or_Player.movement_is_init = false -- enforce new creation target and ROI state
			madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer = 0.5 -- allow next target_position adjustment in 1s
			--madtulip_Task_Heal_NPC_or_Player.old_target_position = target_position
		end

		-- Aim at target
		if     (distance <= entity.configParameter("madtulipTS.use_bonemender_range", nil))
		   and (distance >= entity.configParameter("madtulipTS.use_bonemender_min_range", nil)) then
			entity.setAimPosition(target_position)
			-- close enough to use bone mender --> fire
			entity.beginPrimaryFire()
		end
		
		return false -- if NOT done
	else
		return true -- if done
	end
end

function madtulip_Task_Heal_NPC_or_Player.end_Task()
	-- Called by Task scheduler when the Task ends
	-- I.e. when the task was completed by me or by someone else doing the same thing.
	--world.logInfo("madtulip_Task_Heal_NPC_or_Player.end_Task()")
	
	-- remove hand items
	entity.setItemSlot("primary", nil)
	entity.setItemSlot("alt", nil)
	
	self.state.endState() -- end current state, whatever that is
end

function madtulip_Task_Heal_NPC_or_Player.failed_Task()
	-- hand the error back up to the Task scheduler, he will also call my .end_Task() then
	madtulip_TS.fail_my_current_Task()
end

function madtulip_Task_Heal_NPC_or_Player.has_command_to_do_the_task(Task_Name)
	-- check if I have the command to do this tasks
	local has_cmd_to_do_the_task = false
	for _idx, _val in pairs(storage.Command_Task_Name) do
		if (storage.Command_Task_Name[_idx] == Task_Name) and (storage.Command_Perform[_idx]) then
			has_cmd_to_do_the_task = true
		end
	end
	return has_cmd_to_do_the_task
end

function madtulip_Task_Heal_NPC_or_Player.use_ROI_State_to_navigate_to_target_area(Work_site_BB,work_range,fail_callback_fct,state_end_callback_fct)
	-- Work_site_BB is a not standable BB around the target "construction site" (relative coors to anchor)
	-- work_range is a BB around the Work_site_BB in which the NPC can stand while working (relative coors to anchor)
	--world.logInfo("Init Task - start")
	local ROI_Parameters = {}

	ROI_Parameters.BB = copyTable(Work_site_BB)
	-- enlarge the BB to where the player can be while building
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
	
	local Additional_Blocked_Positions_BB = copyTable(Work_site_BB)
	-- use Anchor as 0,0 point for the BB
	-- X keepout area
	Additional_Blocked_Positions_BB[1] = Additional_Blocked_Positions_BB[1] - ROI_Parameters.Anchor[1]
	Additional_Blocked_Positions_BB[3] = Additional_Blocked_Positions_BB[3] - ROI_Parameters.Anchor[1]
	-- y keepout area is the same as for the work area
	Additional_Blocked_Positions_BB[2] = ROI_Parameters.BB[2]
	Additional_Blocked_Positions_BB[4] = ROI_Parameters.BB[4]
	ROI_Parameters.Additional_Blocked_Positions = {}
	for x = Additional_Blocked_Positions_BB[1],Additional_Blocked_Positions_BB[3],1 do
		for y = Additional_Blocked_Positions_BB[2],Additional_Blocked_Positions_BB[4],1 do
			-- all theese locations are marked as not passable
			ROI_Parameters.Additional_Blocked_Positions[#ROI_Parameters.Additional_Blocked_Positions+1] = {x,y}
		end
	end
	
	ROI_Parameters.Ground_the_Anchor = false
	
	ROI_Parameters.Pick_New_Target_after_old_is_reached = true
	
	ROI_Parameters.run = true
	
	ROI_Parameters.start_chats_on_the_way = false
	
	ROI_Parameters.Statename = "madtulipROIState"

	-- called if State decided that task is not solveable (i.e. not reachable)
	ROI_Parameters.Critical_Fail_Callback = fail_callback_fct

	-- called if State ended (i.e. by timeout)
	ROI_Parameters.State_End_Callback = state_end_callback_fct
	
	--world.logInfo("State description: " .. self.state.stateDesc())
	self.state.endState() -- end current state, whatever that is
	self.state.pickState(ROI_Parameters)
	--world.logInfo("Init Task - end")
end

function madtulip_Task_Heal_NPC_or_Player.Task_is_fullfilled(Task)
	local cur_health = world.entityHealth(Task.Header.Target_ID)
	-- if (cur_health[1] < 0.95* cur_health[2]) then return false else return true end
	if targetHealth ~= nil then
		return (cur_health[1] < 0.95* cur_health[2])
	else
		world.logInfo("/crew/scripts/tasks/madtulip_task_heal_npc_or_player.lua : Waning: Task.Header.Target_ID health is nil. Target_ID obsolete ???")
		return true
	end
end

function madtulip_Task_Heal_NPC_or_Player.ROI_State_ended()
	-- just mark it as not init so the call to main will init and start the ROI State again
	-- entity.say("ROI timeout")
	madtulip_Task_Heal_NPC_or_Player.movement_is_init = false
end

function madtulip_Task_Heal_NPC_or_Player.update_timers(dt)
	-- update Switch_Target_Inside_ROI_Timer timer
	if madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer ~= nil then
		madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer = madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer - dt
		if madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer < 0 then
			madtulip_Task_Heal_NPC_or_Player.Chase_Target_Timer = nil
		end
	end
end