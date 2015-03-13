-- MadTulip:
function Init_Crew_Data()
	if storage.Occupation == nil then storage.Occupation = "Deckhand" end
	if storage.colorIndex == nil then storage.colorIndex = 1 end
	if storage.Command_Texts == nil then
		storage.Command_Texts = {}
		storage.Command_Perform = {}
		storage.Command_Task_Name = {}
		storage.Command_Texts[1] = "Not available."
		storage.Command_Perform[1] = false
		storage.Command_Task_Name[1] = ""
	end
	
	Set_Occupation_Cloth()
end

update = function (dt)
	noticePlayers()

	-- NPC checks his surrounding for tasks (like someone bleeding or a fire)
	madtulip_TS.update_Task_Scheduler(dt)

	self.state.update(dt)
	self.timers.tick(dt)
end

init = function ()
  -- madtulip:
  Init_Crew_Data()

  -- vanilla:
  self.timers = createTimers()

  local states = stateMachine.scanScripts(entity.configParameter("scripts"), "(%a+State)%.lua")
  self.state = stateMachine.create(states)

  self.state.enteringState = function(stateName)
--    debugLog("entering %s", stateName)
  end

  self.state.leavingState = function(stateName)
    self.state.moveStateToEnd(stateName)
    self.stateTargetId = nil
  end

  entity.setInteractive(true)

  self.scriptDelta = entity.configParameter("initialScriptDelta") or 5
  script.setUpdateDelta(self.scriptDelta)

  local offeredQuests = entity.configParameter("offeredQuests")
  if type(offeredQuests) == "table" and #offeredQuests > 0 then
    entity.setOfferedQuests(offeredQuests)
  end

  local turnInQuests = entity.configParameter("turnInQuests")
  if type(turnInQuests) == "table" and #turnInQuests > 0 then
    entity.setTurnInQuests(turnInQuests)
  end

  self.pathing = {}

  self.noticePlayersRadius = entity.configParameter("noticePlayersRadius", -1)
  self.forgetPlayerTime = entity.configParameter("forgetPlayerTime", 3)

  local primaryItemType = itemType("primary"), false
  self.hasMeleeWeapon = primaryItemType == "sword"
  self.hasRangedWeapon = primaryItemType == "gun"

  local sheathedPrimaryItemType = itemType("sheathedprimary")
  self.hasSheathedMeleeWeapon = sheathedPrimaryItemType == "sword"
  self.hasSheathedRangedWeapon = sheathedPrimaryItemType == "gun"

  self.hasShield = itemType("alt") == "shield"
  self.hasSheathedShield = itemType("sheathedalt") == "shield"

  self.movementParameters = mcontroller.baseParameters()
  self.jumpHoldTime = self.movementParameters.airJumpProfile.jumpHoldTime
  self.jumpSpeed = self.movementParameters.airJumpProfile.jumpSpeed
  self.walkSpeed = self.movementParameters.walkSpeed

  if storage.attackOnSightIds == nil then
    storage.attackOnSightIds = {}
  end

  if storage.spawnPosition == nil then
    local position = mcontroller.position()

    -- NPCs aren't always placed right on the ground. They may need to be
    -- moved up or down a few blocks so their spawn position is actually on the
    -- ground
    local supportRegion = {
      math.floor(position[1] + 0.5) - 1, math.floor(position[2] + 0.5) - 3,
      math.floor(position[1] + 0.5) + 1, math.floor(position[2] + 0.5) - 2,
    }

    for i = 0, 3, 1 do
      if world.rectCollision(supportRegion, true) then
        supportRegion[2] = supportRegion[2] + 1
        supportRegion[4] = supportRegion[4] + 1
      else
        break
      end
    end

    for i = 0, 3, 1 do
      supportRegion[2] = supportRegion[2] - 1
      supportRegion[4] = supportRegion[4] - 1
      if world.rectCollision(supportRegion, false) then
        break
      end
    end

    storage.spawnPosition = { position[1], supportRegion[2] + 3.5 }
  end

  self.debug = false
end