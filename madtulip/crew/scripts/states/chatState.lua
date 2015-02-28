-- NPC -> NPC conversation that uses emotes instead of text
chatState = {}

function chatState.initiateChat(startPoint, endPoint)
  local chatTargetIds = world.npcLineQuery(startPoint, endPoint)
  if #chatTargetIds > 1 then
    local selfId = entity.id()
    local targetId
    if chatTargetIds[1] == selfId then
      targetId = chatTargetIds[2]
    else
      targetId = chatTargetIds[1]
    end

    local conversation = entity.randomizeParameter("chat.conversations")

    local distance = world.magnitude(world.distance(startPoint, endPoint))
    if sendNotification("chat", { targetId = targetId, conversation = conversation }, distance) then
      self.state.pickState({ chatPartnerId = targetId, chatConversation = conversation })
      return true
    end
  end
end

function chatState.enterWith(event)
  local partnerId = event.chatPartnerId
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
    conversation = event.notification.args.conversation
    conversationEntryIndex = 1
  end

  return {
    partnerId = partnerId,
    timer = 0,
    conversation = conversation,
    conversationIndex = 1,
    conversationEntryIndex = conversationEntryIndex
  }
end

function chatState.update(dt, stateData)
  local partnerPosition = world.entityPosition(stateData.partnerId)
  if partnerPosition == nil then return true end

  local toPartner = world.distance(partnerPosition, entity.position())
  local direction = util.toDirection(toPartner[1])

  local distance = world.magnitude(toPartner)
  local distanceRange = entity.configParameter("chat.distanceRange")
  if distance < distanceRange[1] then
    move({ -direction, 0 }, dt)
  elseif distance > distanceRange[2] then
    move( { direction, 0 }, dt)
  else
    setFacingDirection(direction)

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