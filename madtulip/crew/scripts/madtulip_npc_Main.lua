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
	
-- debug out damage team
--local damage_team =  entity.damageTeam()
--world.logInfo("Player Damage Team:" .. damage_team.type .. " " .. damage_team.team)
end

main = function ()
  noticePlayers()
  
  local dt = entity.dt()

  -- NPC checks his surrounding for tasks (like someone bleeding or a fire)
  madtulip_TS.update_Task_Scheduler(dt)
  
  self.state.update(dt)
  self.timers.tick(dt)
end

init = function (args)
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

  if storage.attackOnSightIds == nil then
    storage.attackOnSightIds = {}
  end

  if storage.spawnPosition == nil then
    local position = entity.position()

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
end

function copyTable(source)
	local _copy
	if type(source) == "table" then
		_copy = {}
		for k, v in pairs(source) do
			_copy[copyTable(k)] = copyTable(v)
		end
	else
		_copy = source
	end
	return _copy
end