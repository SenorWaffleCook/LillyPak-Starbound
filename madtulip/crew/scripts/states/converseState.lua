converseState = {}

function converseState.enterWith(args)
  if args.interactArgs == nil then return nil end
  if args.interactArgs.sourceId == 0 then return nil end

  if not converseState.sayToTarget("converse.WorkDialog", args.interactArgs.sourceId) then
    return nil
  end

  return {
    sourceId = args.interactArgs.sourceId,
    timer = entity.configParameter("converse.waitTime")
  }
end

function converseState.update(dt, stateData)
  local sourcePosition = world.entityPosition(stateData.sourceId)
  if sourcePosition == nil then return true end

  local toSource = world.distance(sourcePosition, entity.position())
  setFacingDirection(toSource[1])

  stateData.timer = stateData.timer - dt
  return stateData.timer <= 0
end

function converseState.sayToTarget(dialogType, targetId, tags)
  local dialog = nil

  local withOccupation = dialogType .. "." .. storage.Occupation
  
  dialog = entity.randomizeParameter(withOccupation)

  if dialog ~= nil then
    return entity.say(dialog, tags)
  end

  return false
end