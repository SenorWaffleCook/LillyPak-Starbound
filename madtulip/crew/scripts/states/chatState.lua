-- NPC -> NPC conversation that uses emotes instead of text
chatState = {}

function chatState.initiateChat(startPoint, endPoint)
  local chatTargetIds = world.entityLineQuery(startPoint, endPoint, {includedTypes = {"npc"}, withoutEntityId = entity.id()})
  if #chatTargetIds > 0 then
    targetId = chatTargetIds[1]

    local conversation = entity.randomizeParameter("chat.conversations")

    local distance = world.magnitude(world.distance(startPoint, endPoint))
    if sendNotification("chat", { targetId = targetId, conversation = conversation }, distance) then
      self.state.pickState({ chatPartnerId = targetId, chatConversation = conversation  })
      return true
    end
  end
end

function chatState.enterWith(event)
  local partnerId = event.chatPartnerId
  local targetPosition = event.targetPosition
  local conversation = event.chatConversation
  local conversationEntryIndex = 0

  -- no chatting while on a task
  if madtulip_TS.Has_A_Task() then return nil end  
  
  if partnerId == nil then
    if event.notification == nil or
       event.notification.name ~= "chat" or
       event.notification.args.targetId ~= entity.id() or
       self.state.stateDesc() == "chatState" then
      return nil
    end

    partnerId = event.notification.sourceEntityId
    targetPosition = event.notification.args.targetPosition
    conversation = event.notification.args.conversation
    conversationEntryIndex = 1
  end

  return {
    partnerId = partnerId,
    timer = 0,
    targetPosition = targetPosition,
    conversation = conversation,
    conversationIndex = 1,
    conversationEntryIndex = conversationEntryIndex
  }
end

function chatState.update(dt, stateData)

	-- madtulip change
	-- Update debug info
	madtulip_crew_debug_out.state_info(dt,stateData)
	-- madtulip change end

  local partnerPosition = world.entityPosition(stateData.partnerId)
  local partnerState = world.callScriptedEntity(stateData.partnerId, "self.state.stateDesc")
  if partnerPosition == nil or partnerState ~= "chatState" or not entity.entityInSight(stateData.partnerId) then return true end

  local position = mcontroller.position()
  local toPartner = world.distance(partnerPosition, position)
  local direction = util.toDirection(toPartner[1])
  local distance = world.magnitude(toPartner)

  local distanceRange = entity.configParameter("chat.distanceRange")

  if math.abs(toPartner[2]) > distanceRange[1] + 1 then
    if not moveTo(partnerPosition, dt) then
      return true
    end
  elseif distance > distanceRange[2] then
    if not move(toPartner[1], dt) then
      return true
    end
  elseif distance < distanceRange[1] then
    if not move(-toPartner[1], dt) then
      return true
    end
  else
    controlFace(direction)

    stateData.timer = stateData.timer - dt
    if stateData.timer <= 0 then
      local conversationEntry = stateData.conversation[stateData.conversationIndex]
      if conversationEntry == nil then
        return true, entity.configParameter("chat.cooldown", nil)
      else
        stateData.conversationIndex = stateData.conversationIndex + 1
      end

      -- conversationEntry[1] is the time, [2] is first guy's emote, etc
      stateData.timer = conversationEntry[1]
      local emote = conversationEntry[2 + stateData.conversationEntryIndex]

      entity.emote(emote)
    end
  end

  return false
end

function chatState.leavingState()
  entity.emote("neutral")
end