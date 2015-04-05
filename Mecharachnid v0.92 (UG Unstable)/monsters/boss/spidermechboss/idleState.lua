idleState = {}

function idleState.enter()
  if hasTarget() then return nil end
  return {}
end

function idleState.enterWith(args)
  if hasTarget() then return nil end
  return {}
end

function idleState.enteringState(stateData)

end

function idleState.update(dt, stateData)
  if hasTarget() then return true end
  if status.resourcePercentage("health") < 1 then
	status.modifyResourcePercentage("health", 0.04*dt)
  end
  if self.sector ~= "upper5" and self.sector ~= "spawnBox" then
	self.state.pickState({reposition = true, destination = "upper5"})
  end
end

function idleState.leavingState(stateData)
	self.state.shuffleStates()
end