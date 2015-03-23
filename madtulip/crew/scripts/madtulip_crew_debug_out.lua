madtulip_crew_debug_out = {}

function madtulip_crew_debug_out.state_info(dt, stateData)
	if self.debug then
	
		local State_Name_Offset  = 4
		local State_Timer_Offset = 3
		local State_2nd_Timer_Offset = 2
		
		-- Name of State
		world.debugText(self.state.stateDesc(), {mcontroller.position()[1], mcontroller.position()[2] + State_Name_Offset}, "green")
		--world.debugText("pos: %d,%d", doorPosition[1], doorPosition[2], {mcontroller.position()[1], mcontroller.position()[2] + 3}, "black")
		
		-- 1st Timer of State
		if self.state.stateDesc() == "chatState" then
			world.debugText("Time 1: %d", stateData.timer, {mcontroller.position()[1], mcontroller.position()[2] + State_Timer_Offset}, "green")
		elseif self.state.stateDesc() == "converseState" then
			world.debugText("Time 1: %d", stateData.timer, {mcontroller.position()[1], mcontroller.position()[2] + State_Timer_Offset}, "green")
		elseif self.state.stateDesc() == "madtulipcommandState" then
			world.debugText("Time 1: %d", stateData.timer, {mcontroller.position()[1], mcontroller.position()[2] + State_Timer_Offset}, "green")
		elseif self.state.stateDesc() == "madtulipROIState" then
			world.debugText("Time 1: %d", stateData.timer, {mcontroller.position()[1], mcontroller.position()[2] + State_Timer_Offset}, "green")
		elseif self.state.stateDesc() == "sitState" then
			world.debugText("Time 1: %d", stateData.timer, {mcontroller.position()[1], mcontroller.position()[2] + State_Timer_Offset}, "green")
		elseif self.state.stateDesc() == "sleepState" then
			world.debugText("Time 1: %d", stateData.moveTimer, {mcontroller.position()[1], mcontroller.position()[2] + State_Timer_Offset}, "green")
		end
		
		if self.state.stateDesc() == "madtulipROIState" then
			world.debugText("Time 2: %d", madtulipROIState.Movement.Switch_Target_Inside_ROI_Timer, {mcontroller.position()[1], mcontroller.position()[2] + State_2nd_Timer_Offset}, "green")
		end
	end
end