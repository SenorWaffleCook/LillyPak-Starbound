rushAttackState = {}

--This state is a basic "bull rush"
--If the target is on the same level and not adjacent, either rush them down throwing punches or back up to get some distance and then do so

function rushAttackState.enter()
  if stateInTesting and stateInTesting ~= "rushAttack" then return nil end
  if not hasTarget() or not self.targetSector then return nil end
  local p1 = tonumber(string.sub(self.sector, -1, -1))
  local p2 = tonumber(string.sub(self.targetSector, -1 ,-1))
  if string.sub(self.sector,1,3) == string.sub(self.targetSector,1,3) and 
    math.abs(p1 - p2) >= 2 then
    if p1 > p2 then
		return {["start"] = string.sub(self.sector, 1, -2).."5", ["goal"] = string.sub(self.sector, 1, -2).."1"}
	else
		return {["start"] = string.sub(self.sector, 1, -2).."1", ["goal"] = string.sub(self.sector, 1, -2).."5"}
	end
  else 
	return nil
  end
end

function rushAttackState.enteringState(stateData)
	debugPane = {["position"] = mcontroller.position()[1]}
end

function rushAttackState.update(dt, stateData)
	if not hasTarget() then return true end
	if self.sector ~= stateData.start then
		self.state.pickState({reposition = true,hostile = false,destination = stateData.start,stack = {reposition = true,hostile = false,veryHostile = true, destination = stateData.goal}})
	else
		self.state.pickState({reposition = true,hostile = false,veryHostile = true, destination = stateData.goal})
	end
end

function rushAttackState.leavingState(stateData)

end