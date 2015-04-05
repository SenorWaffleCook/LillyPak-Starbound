function overrideParams()
	sectorList = {
	["upper1"] = { 668, 830, 696, 852},
	["upper2"] = { 696, 830, 732, 852},
	["upper3"] = { 732, 830, 768, 852},
	["upper4"] = { 768, 830, 804, 852},
	["upper5"] = { 804, 830, 832, 852},
	["lower1"] = { 668, 812, 696, 830},
	["lower2"] = { 696, 812, 732, 830},
	["lower3"] = { 732, 812, 768, 830},
	["lower4"] = { 768, 812, 804, 830},
	["lower5"] = { 804, 812, 832, 830},
	["spawnBox"] = { 668, 852, 832, 912}
	}

	arenaBox = {668, 813, 832, 852}
	
	sectorCenters = {
	["upper1"] = { 668+0, 830+5, 696-7, 852-5},
	["upper2"] = { 696+9, 830+5, 732-9, 852-5},
	["upper3"] = { 732+9, 830+5, 768-9, 852-5},
	["upper4"] = { 768+9, 830+5, 804-9, 852-5},
	["upper5"] = { 804+9, 830+5, 832-0, 852-5},
	["lower1"] = { 668+0, 812+5, 696-9, 830-5},
	["lower2"] = { 696+9, 812+5, 732-9, 830-5},
	["lower3"] = { 732+9, 812+5, 768-9, 830-5},
	["lower4"] = { 768+9, 812+5, 804-9, 830-5},
	["lower5"] = { 804+7, 812+5, 832-0, 830-5},
	["spawnBox"] = { 714+12, 852+6, 750-12, 912-6}
	}

	sectorClockwise = {
	["upper1"] = "upper2",
	["upper2"] = "upper3",
	["upper3"] = "upper4",
	["upper4"] = "upper5",
	["upper5"] = "lower5",
	["lower1"] = "upper1",
	["lower2"] = "lower1",
	["lower3"] = "lower2",
	["lower4"] = "lower3",
	["lower5"] = "lower4",
	["spawnBox"] = "upper2"
	}

	sectorCounterClockwise = {
	["upper1"] = "lower1",
	["upper2"] = "upper1",
	["upper3"] = "upper2",
	["upper4"] = "upper3",
	["upper5"] = "upper4",
	["lower1"] = "lower2",
	["lower2"] = "lower3",
	["lower3"] = "lower4",
	["lower4"] = "lower5",
	["lower5"] = "upper5",
	["spawnBox"] = "upper3"
	}	
	gunBeamRange = 200
	
	attackStats = {
	["beam"] = {["time"] = 0, ["endProjectile"] = "spiderlaserterminus1", ["midProjectile"] = "spiderlaserBOSS1", ["light"] = {140,0,0}, ["power"] = 0},
	["beamHigh"] = {["time"] = 0.3, ["endProjectile"] = "spiderlaserterminus2", ["midProjectile"] = "spiderlaserBOSS2", ["light"] = {200,0,0}, ["power"] = 0}, 
	["beamMax"] = {["time"] = 2.3, ["endProjectile"] = "spiderlaserterminus3", ["midProjectile"] = "spiderlaserBOSS3", ["light"] = {250,0,0}, ["power"] = 0},
	["normalStomp"] = "/projectiles/explosions/spiderstomp/spiderstompnormal.config",
	["frenziedStomp"] = "/projectiles/explosions/spiderstomp/spiderstompfrenziedNOBG.config",
	["legSwipe"] = {["power"] = 60, ["level"] = 6},
	["bodySlam"] = {["power"] = 60, ["level"] = 6}
	}
	frenzyForceMults = {0,0}
	
	currentBossPhase = 4
	bossPhases = {
	{["health"]=0.25, ["name"] = "phase4", ["legAimTime"] = 0.8, ["sparkRate"] = 16},
	{["health"]=0.5, ["name"] = "phase3", ["legAimTime"] = 0.9, ["sparkRate"] = 8},
	{["health"]=0.75, ["name"] = "phase2", ["legAimTime"] = 1.0, ["sparkRate"] = 2},
	{["health"]=1.01, ["name"] = "phase1", ["legAimTime"] = 1.1, ["sparkRate"] = 0}
	}
	stateInTesting = nil
end
function init(args)
	world.logInfo("I am spider boss!")
	---From tech:
	initialParams()
	overrideParams()
	
	self = {}
	self.active = false	
	self.movesLast = {["up"] = false, ["down"] = false, ["left"] = false, ["right"] = false, ["jump"] = false, ["special"] = 0}
	self.movementBlocked = {}
	self.poweringDown = false
	self.isBoosting = false
	self.legAttacking = false
	self.movementDirection = "none"
	self.manualVertForce = 0
	self.fireBeam = {false, 0}
	self.collisionPoly = mcontroller.baseParameters().standingPoly
	self.chassisMotion = {0,0}
	self.laserBlacklist = {}
	self.storedPointsForLegShockwave = {}
	self.laserProjectileCooldown = 0.4
	self.pickupTimer = 0
	self.legAttackTimer = 0
	self.deactivateTimer = 0
	customMovementParameters = tech.parameter("spiderMovementParameters")
	self.takenItems = {}
	customMovementParameters.jumpingSuppressed = true
	customMovementParameters.glideModifier = 0
	customMovementParameters.liquidMovementModifier = 0
	customMovementParameters.groundMovementModifier = 0
	self.debug = false
	tech.setParticleEmitterOffsetRegion("frenzying", customMovementParameters.bBox)
	tech.setParticleEmitterActive("frenzying", false)
	tech.setVisible(false)
	makeCheckPolys()
	--End from tech

	entity.setAnimationState("pilot", "corpse")
	self.tookDamage = false
	self.dead = false
	debugPane = {}
	self.spawnPosition = mcontroller.position()

	self.trackTargetDistance = entity.configParameter("trackTargetDistance")
	self.switchTargetDistance = entity.configParameter("switchTargetDistance")
	self.keepTargetInSight = entity.configParameter("keepTargetInSight", true)

	self.targets = {}
	--Non-combat states
	local states = stateMachine.scanScripts(entity.configParameter("scripts"), "(%a+State)%.lua")
	self.state = stateMachine.create(states)

	self.state.leavingState = function(stateName)
		self.state.moveStateToEnd(stateName)
	end
	self.skillParameters = {}
	for _, skillName in pairs(entity.configParameter("skills")) do
		self.skillParameters[skillName] = entity.configParameter(skillName)
	end
	
	updatePosition()
	entity.setDeathParticleBurst("deathPoof")
	entity.setDeathSound("deathPuff")
end

function update(dt)
	--world.logInfo("boss update")
	self.tookDamage = false
	if not self.active then 
		activate() 
	end
	
	updateTargets(dt)
	updatePosition()

	for skillName, params in pairs(self.skillParameters) do
		if type(_ENV[skillName].onUpdate) == "function" then
			_ENV[skillName].onUpdate(dt)
		end
	end

	if hasTarget() and entity.health() > 0 then
		script.setUpdateDelta(1)
		self.hadTarget = true
	end
	
	if not hasTarget() and entity.health() > 0 and self.hadTarget then
		--status.setResource("health", status.stat("maxHealth"))
		self.hadTarget = false
	end

	local healthFraction = status.resourcePercentage("health")
	for phase,_ in ipairs(bossPhases) do
		if healthFraction <= bossPhases[phase].health then
			if currentBossPhase ~= phase then
				entity.setParticleEmitterActive("frenzying", true)
				entity.setParticleEmitterEmissionRate("frenzying", bossPhases[phase].sparkRate)
				currentBossPhase = phase
			end
			break
		end
	end
	
	if entity.health() > 0 then 
		script.setUpdateDelta(1) 
	end

	if not self.state.update(dt) or self.state.stateDesc() == "" then
		self.state.pickState()
	end
	
	local args = spoofInput
	args.dt = dt
	
	if args.moves.down then
		mcontroller.controlDown()
	end
	
	showDebugPane()
	
	--From tech
	input(spoofInput)
	decrementTimers(args.dt)

	if self.active and not self.poweringDown then
		updateAnchors()
		updateMotion(args)
		renderLegs()
	elseif self.active and self.poweringDown then
		mcontroller.controlModifiers({movementSuppressed = true})
		mcontroller.controlParameters(customMovementParameters)
		mcontroller.setVelocity({0,-6})
		--handle shutting down
		if self.poweringDown then
			if checkPoly(customMovementParameters.standingPoly, vec2.add(mcontroller.position(), {0,-0.25})) or 
			  world.liquidAt(vec2.add(mcontroller.position(), {0, collisionBottom(customMovementParameters.standingPoly)})) then
				deactivate()
				return false
			else
				return false
			end
		end
	end
	--From tech end
	status.clearEphemeralEffects()
	mcontroller.controlFace(1)
end

function updatePosition()
	local position = mcontroller.position()
	for sector,bounds in pairs(sectorList) do
		if withinBounds(position, bounds) then
			self.sector = sector
			break
		end
	end
	if self.targetId ~= nil and world.entityExists(self.targetId) then
		local targetPosition = world.entityPosition(self.targetId)
		spoofInput.aimPosition = targetPosition
		for sector,bounds in pairs(sectorList) do
			if withinBounds(targetPosition, bounds) then
				self.targetSector = sector
				break
			end
		end
	else
		self.targetSector = nil
		spoofInput.aimPosition = vec2.add(mcontroller.position(), {0,-5})
	end
end

function showDebugPane()
	local paneAnchor = {(debugPane.position or mcontroller.position()[1]), 810}
	local paneX = 1
	local paneY = -2
	world.debugText(self.state.stateDesc(), vec2.add(paneAnchor, {0, -paneY}), "red")
	world.debugText(string.format("%." .. (2) .. "f", status.resource("health")).." / "..string.format("%." .. (2) .. "f", status.resourceMax("health")).." : ("..status.resourcePercentage("health")..")", vec2.add(paneAnchor, {0, -paneY-1}), "green")
	if debugPane ~= {} then
		for name,data in pairs(debugPane) do
			if name ~= "position" then
				world.debugText(name, vec2.add(paneAnchor, {(data.X-1)*paneX, data.Y*paneY+1}), (data.colorName or "white"))
				world.debugText(data.text, vec2.add(paneAnchor, {data.X*paneX, data.Y*paneY}), (data.colorData or "green"))
			end
		end
	end
end

function damage(args)
  self.tookDamage = true
  if entity.health() <= 0 then
    local inState = self.state.stateDesc()
    if inState ~= "dieState" and not self.state.pickState({ die = true }) then
      self.state.endState()
      self.dead = true
    end
  end

  if args.sourceId and args.sourceId ~= 0 and not inTargets(args.sourceId) then
    table.insert(self.targets, args.sourceId)
  end
end

function shouldDie()
  return self.dead
end


function hasTarget()
  if self.targetId and self.targetId ~= 0 and world.entityExists(self.targetId) then
    return self.targetId
  end
  return false
end

function updateTargets(dt)
	if self.targetId == nil or not world.entityExists(self.targetId) then
		self.targetId = nil
		if #self.targets == 0 then
			self.targets = world.entityQuery({arenaBox[1], arenaBox[2]}, {arenaBox[3], arenaBox[4]}, {includedTypes = {"player"}})
		end
		for i,targetId in ipairs(self.targets) do
			if world.entityExists(targetId) and withinBounds(world.entityPosition(targetId), arenaBox) then
				self.targetId = targetId
				--world.logInfo("Switching target to %s from %s", targetId, self.targets)
			else
				table.remove(self.targets, i)
			end
		end
	else
		if self.healDebuffTimer == nil or self.healDebuffTimer < 0 then
			world.spawnProjectile("spiderlaserbeam", world.entityPosition(self.targetId), entity.id(), {0,0}, false, {statusEffects = {"healingimpaired"}})
			self.healDebufTimer = 5
		else
			self.healDebuffTimer = self.healDebuffTimer - dt
		end
		
		if not withinBounds(world.entityPosition(self.targetId), arenaBox) then
			self.targetId = nil
			updateTargets(dt)
		end
	end
	if self.doorSwitch == nil then
		self.doorSwitch = world.objectQuery({732,808}, 2)[1]
	end
end

function withinBounds(pos, box)
	if pos[1] >= box[1] and pos[2] >= box[2] and pos[1] < box[3] and pos[2] < box[4] then
		return true
	else
		return false
	end
end

function inTargets(entityId)
  for i,targetId in ipairs(self.targets) do
    if targetId == entityId then
      return true
    end
  end
  return false
end


function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end