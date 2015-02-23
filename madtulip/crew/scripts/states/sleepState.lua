sleepState = {}

function sleepState.enter()
  if not isTimeFor("sleep.timeOfDayRanges") then
    return nil
  end
  -- onyl change by madtulip in this vanilla file:
  -- randomize the order the states are beeing executed in
  self.state.shuffleStates()
  -- onyl change by madtulip in this vanilla file END

  local bedId = sleepState.findUnoccupiedBed()
  if bedId == nil then
    return nil, entity.configParameter("sleep.cooldown")
  end

  return {
    bedId = bedId,
    moveTimer = entity.configParameter("sleep.moveToBedTimeLimit")
  }
end

function sleepState.update(dt, stateData)
  if not entity.isLounging() then
    -- Make sure we've still got a bed to sleep in
    if world.loungeableOccupied(stateData.bedId) then
      stateData.bedId = sleepState.findUnoccupiedBed()
      stateData.moveTimer = entity.configParameter("sleep.moveToBedTimeLimit")

      if stateData.bedId == nil then
        return true
      end
    end

    local bedPosition = vec2.add(world.entityPosition(stateData.bedId), { 0, 1 })
    local toTarget = world.distance(bedPosition, entity.position())
    if world.magnitude(toTarget) < entity.configParameter("sleep.lieDownRadius") then
      entity.setLounging(stateData.bedId)
    else
      stateData.moveTimer = stateData.moveTimer - dt
      if stateData.moveTimer < 0 then
        return true, entity.configParameter("sleep.cooldown")
      end

      moveTo(bedPosition, dt)
    end
  end

  if isTimeFor("sleep.timeOfDayRanges") then
    return false
  else
    return true, entity.configParameter("sleep.cooldown")
  end
end

function sleepState.findUnoccupiedBed()
  local entityIds = world.loungeableQuery(storage.spawnPosition, entity.configParameter("sleep.searchRadius"), { orientation = "lay", order = "nearest" })
  for _, entityId in pairs(entityIds) do
    if not world.loungeableOccupied(entityId) then
      return entityId
    end
  end

  return nil
end

function sleepState.leavingState()
  entity.resetLounging()
end


