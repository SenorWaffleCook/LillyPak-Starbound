sitState = {}

function sitState.enter()
  if not isTimeFor("sit.timeOfDayRanges") then
    return nil, entity.configParameter("sit.cooldown")
  end

  -- madtulip change
  -- randomize the order the states are beeing executed in
  self.state.shuffleStates()
  -- madtulip change end
  
  local chairId = sitState.findChair()
  if chairId == nil then
    return nil, entity.configParameter("sit.cooldown")
  end

  return {
    targetId = chairId,
    moveTimer = entity.configParameter("sit.moveTimeLimit"),
    timer = entity.randomizeParameterRange("sit.timeRange")
  }
end

function sitState.update(dt, stateData)

	-- madtulip change
	-- Update debug info
	madtulip_crew_debug_out.state_info(dt,stateData)
	-- madtulip change end

  if not entity.isLounging() then
    if world.loungeableOccupied(stateData.targetId) then
      return true, entity.configParameter("sit.cooldown")
    end

    local targetPosition = world.entityPosition(stateData.targetId)
    if targetPosition == nil then
      return true, entity.configParameter("sit.cooldown")
    else
      targetPosition[2] = targetPosition[2] + 1.0
    end

    local position = mcontroller.position()

    local toTarget = world.distance(targetPosition, position)
    if world.magnitude(toTarget) < entity.configParameter("sit.sitRadius") and not world.lineCollision(position, targetPosition, true) then
      entity.setLounging(stateData.targetId)
    else
      stateData.moveTimer = stateData.moveTimer - dt
      if stateData.moveTimer < 0 then
        return true, entity.configParameter("sit.cooldown")
      end
      
      if moveTo(targetPosition, dt) then
        controlFace(self.pathing.deltaX or toTarget[1])
      end
    end
  else
    stateData.timer = stateData.timer - dt
    if stateData.timer < 0 then
      return true, entity.configParameter("sit.cooldown")
    end
  end

  return false
end

function sitState.leavingState()
  entity.resetLounging()
end

function sitState.findChair()
  local position = mcontroller.position()
  local chairIds = world.loungeableQuery(storage.spawnPosition, entity.configParameter("sit.searchRadius"), { orientation = "sit" })

  local nearestChairId, nearestChairDistance = nil, nil
  for _, chairId in pairs(chairIds) do
    if not world.loungeableOccupied(chairId) then
      local distance = world.magnitude(position, world.entityPosition(chairId))
      if nearestChairDistance == nil or distance < nearestChairDistance then
        nearestChairId = chairId
      end
    end
  end

  return nearestChairId
end

function debug_out_state_info()
	local State_Name = "sitState"
	local State_Name_Offset = 3
	
	world.debugText(State_Name, {mcontroller.position()[1], mcontroller.position()[2] + State_Name_Offset}, "green")
	--world.debugText("pos: %d,%d", doorPosition[1], doorPosition[2], {mcontroller.position()[1], mcontroller.position()[2] + 3}, "black")
end