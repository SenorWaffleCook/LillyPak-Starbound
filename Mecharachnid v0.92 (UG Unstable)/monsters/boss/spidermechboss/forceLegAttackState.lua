forceLegAttackState = {}

--This is the "run up and punch them" state

function forceLegAttackState.enter()
  if stateInTesting and stateInTesting ~= "forceLegAttack" then return nil end
  if not hasTarget() then return nil end
  return {}
end

function forceLegAttackState.enteringState(stateData)
	debugPane = {["position"] = mcontroller.position()[1]}
end

--Either we will run up and punch them, or just punch them, depending on how far away they are

function forceLegAttackState.update(dt, stateData)
	if not hasTarget() then return true end
	if self.targetSector == self.sector then 
		if not self.state.pickState({legAttack = true}) then 
			local goal = nil
			if math.random() <= 0.5 then goal = sectorClockwise[self.sector] else goal = sectorCounterClockwise[self.sector] end
			self.state.pickState({reposition = true, hostile = true, destination = goal})
		end
		return true, 1
	else
		if not self.state.pickState({reposition = true, destination = self.targetSector, hostile = true}) then return true, 1 end
	end
end

function forceLegAttackState.leavingState(stateData)
	
end