function initialParams()
	params = {}
	params.upperLegLength = 10
	params.lowerLegLength = 14
	params.legOverreach = math.abs(params.upperLegLength - params.lowerLegLength)+1
	params.maxExtension = 0.9*(params.lowerLegLength+params.upperLegLength)
	params.vertEquilibrium = 12
	spiderMechActiveStats = {
	{stat = "biomeheatImmunity", amount = 1}, 
	{stat = "breathProtection", amount = 1},
	{stat = "biomecoldImmunity", amount = 1}, 
	{stat = "biomeradiationImmunity", amount = 1}, 
	{stat = "poisonImmunity", amount = 1}, 
	{stat = "fireImmunity", amount = 1}, 
	{stat = "lavaImmunity", amount = 1}, 
	{stat = "biomeheatImmunity", amount = 1}, 
	{stat = "waterImmunity", amount = 1},
	{stat = "fallDamageMultiplier", basePercentage = -1}
	}
	legBaseJoints = {
	["lB"] = {-2, 0},
	["lF"] = {-4, 0},
	["rB"] = {2,0},
	["rF"] = {4,0}
	}
	legBugs = {
	}
	legFromGroundJoints = {
	["lB"] = {-2, params.vertEquilibrium},
	["lF"] = {-4, params.vertEquilibrium},
	["rB"] = {2, params.vertEquilibrium},
	["rF"] = {4, params.vertEquilibrium}
	}
	legFallPositions = {
	["lB"] = {-5,-0.8*params.maxExtension},
	["lF"] = {-15,-0.8*params.maxExtension},
	["rB"] = {5,-0.8*params.maxExtension},
	["rF"] = {15,-0.8*params.maxExtension}
	}
	legStepZones = {
	["lB"] = {-22,0},
	["lF"] = {-22,0},
	["rB"] = {0,22},
	["rF"] = {0,22}
	}
	legSeeds = {
	["lB"] = -5,
	["lF"] = -15,
	["rB"] = 5,
	["rF"] = 15
	}
	legColors = {
	["lB"] = {160,0,0,255},
	["lF"] = {255,0,0,255},
	["rB"] = {0,0,160,255},
	["rF"] = {0,0,255,255}
	}
	legs = {"lB", "rB", "lF", "rF"}
	legPairs = {
	["lB"] = "lF",
	["lF"] = "lB",
	["rB"] = "rF",
	["rF"] = "rB"
	}
	--status: anchor, leg state(falling, stable, moving, searching, attackReady, attacking), current stack, search cooldown
	legStatus = {
	["lB"] = {["anchor"] = "none", ["state"] = "falling", ["stack"] = {}, ["cd"] = 0},
	["lF"] = {["anchor"] = "none", ["state"] = "falling", ["stack"] = {}, ["cd"] = 0},
	["rB"] = {["anchor"] = "none", ["state"] = "falling", ["stack"] = {}, ["cd"] = 0},
	["rF"] = {["anchor"] = "none", ["state"] = "falling", ["stack"] = {}, ["cd"] = 0},
	}
	
	gunBeamRange = 75
	--Polys for streamlining anchor point searching (check poly, if hit, do manual sweep)
	--Poly Params: #lines, #steps in lines, radius infall per line, vertical check step, angle divisor
	checkPolyParam = {}
	checkPolyParam[1] = 13 
	checkPolyParam[2] = 16
	checkPolyParam[3] = 1.0
	checkPolyParam[4] = 1.2
	checkPolyParam[5] = 21
	landingPoly = {{-0.75, -18}, {0.75, -18}, {0.75, 0}, {-0.75, 0}}
	checkPolySweepL ={}
	checkPolySweepR ={}
	checkPolyRec = {}
	checkPolyFrenzy = {}
	checkPolyAnchor = {{0,0.25},{-0.25,0},{0,-0.5},{0.25,0}}

	attackStats = {
	["beam"] = {["time"] = 0, ["endProjectile"] = "spiderlaserterminus1", ["midProjectile"] = "spiderlaser1", ["light"] = {140,0,0}, ["power"] = 5},
	["beamHigh"] = {["time"] = 2, ["endProjectile"] = "spiderlaserterminus2", ["midProjectile"] = "spiderlaser2", ["light"] = {200,0,0}, ["power"] = 5}, 
	["beamMax"] = {["time"] = 4, ["endProjectile"] = "spiderlaserterminus3", ["midProjectile"] = "spiderlaser3", ["light"] = {250,0,0}, ["power"] = 5},
	["normalStomp"] = "/projectiles/explosions/spiderstomp/spiderstompnormal.config",
	["frenziedStomp"] = "/projectiles/explosions/spiderstomp/spiderstompfrenzied.config",
	["legSwipe"] = {["power"] = 600, ["level"] = 6}
	}
	energyCosts = {
	["boost"] = 40,
	["beam"] = 25,
	["beamHigh"] = 50,
	["beamMax"] = 75,
	["legAttack"] = 110,
	["frenzy"] = 60
	}
	frenzyForceMults = {300,200}
end

function init(args)
	initialParams()
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
	
	if world.entityType(entity.id()) == "player" then
		local maxEnergy = status.resourceMax("energy")
		for move,cost in pairs(energyCosts) do
			energyCosts[move] = cost*math.min(math.max((400+maxEnergy)/1200, 0.5), 1)
		end
	end
end

function makeCheckPolys()
	--Left/Right Sweep Poly
	--Outer edge
	local checkRadius = params.maxExtension - checkPolyParam[3]
	local checkAngle = math.pi/6 + 1*(math.pi/checkPolyParam[5])
	local checkNode1 = vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle)
	local checkNode2 = {0,0}
	table.insert(checkPolySweepL, checkNode1)
	for i = 1, checkPolyParam[2] do
		checkAngle = math.pi/6 + i*(math.pi/checkPolyParam[5])
		checkNode1 = vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle)
		checkAngle = math.pi/6 + (i+1)*(math.pi/checkPolyParam[5])
		checkNode2 = vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle)
		table.insert(checkPolySweepL, checkNode2)
	end
	--Inner edge
	checkRadius = params.maxExtension - checkPolyParam[3] * checkPolyParam[1]
	checkAngle = math.pi/6 + (checkPolyParam[2]+1)*(math.pi/checkPolyParam[5])
	checkNode1 = {0,0}
	checkNode2 = vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle)
	table.insert(checkPolySweepL, checkNode2)
	for i = checkPolyParam[2], 1, -1 do
		checkAngle = math.pi/6 + i*(math.pi/checkPolyParam[5])
		checkNode1 = vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle)
		checkAngle = math.pi/6 + (i+1)*(math.pi/checkPolyParam[5])
		checkNode2 = vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle)
		table.insert(checkPolySweepL, checkNode1)
	end
	--Right poly is reflection of left
	for _,node in ipairs(checkPolySweepL) do
		table.insert(checkPolySweepR, {-node[1], node[2]})
	end
	
	--Rectangular Poly
	table.insert(checkPolyRec, {-(checkPolyParam[1]-1)/2, 1-checkPolyParam[4]})
	table.insert(checkPolyRec, {(checkPolyParam[1]-1)/2, 1-checkPolyParam[4]})
	table.insert(checkPolyRec, {(checkPolyParam[1]-1)/2, 1-checkPolyParam[4]*checkPolyParam[2]})
	table.insert(checkPolyRec, {-(checkPolyParam[1]-1)/2, 1-checkPolyParam[4]*checkPolyParam[2]})
	
	--Frenzy poly
	table.insert(checkPolyFrenzy, {-5, 4})
	table.insert(checkPolyFrenzy, {5, 4})
	table.insert(checkPolyFrenzy, {5, legFallPositions[legs[1]][2]})
	table.insert(checkPolyFrenzy, {-5, legFallPositions[legs[1]][2]})

end

function input(args)
	if self.poweringDown then return "none" end
	--Basic activation mechanism
	if args.moves["special"] == 1 and self.movesLast["special"] ~= 1 then
		if self.active and (not self.isFalling or mcontroller.liquidMovement()) and not self.isBoosting and not self.legAttacking and vec2.mag(mcontroller.velocity()) < 10 and self.deactivateTimer <= 0 and (findLandingZone() or mcontroller.liquidMovement()) then
			self.poweringDown = true
			for _,leg in ipairs(legs) do
				world.callScriptedEntity(legBugs[leg] or 0, "kill")
			end
			mcontroller.setVelocity({0, -6})
			tech.setAnimationState("gun", "idle")
			tech.rotateGroup("leftBooster", 3*math.pi/2-0.2, true)
			tech.rotateGroup("rightBooster", 3*math.pi/2+0.2, true)
			tech.setAnimationState("boosters", "boosting")
			tech.setAnimationState("body", "bodyOnly")
			self.toPowerDown = false
			tech.playSound("beginDescent")
			return "none"
		elseif not self.active and world.resolvePolyCollision(customMovementParameters.standingPoly, mcontroller.position(), 2, "Any") then
			self.deactivateTimer = 2.0
			activate()
		elseif self.deactivateTimer <= 0 then
			self.deactivateTimer = 1.0
			if self.active then
				tech.playSound("failAction")
			end
		end
	elseif args.moves["special"] == 1 then
		if self.forceEjectTimer > 2 then 
			self.poweringDown = true
			for _,leg in ipairs(legs) do
				world.callScriptedEntity(legBugs[leg] or 0, "kill")
			end
			mcontroller.setVelocity({0, -6})
			tech.setAnimationState("gun", "idle")
			tech.rotateGroup("leftBooster", 3*math.pi/2-0.2, true)
			tech.rotateGroup("rightBooster", 3*math.pi/2+0.2, true)
			tech.setAnimationState("boosters", "boosting")
			tech.setAnimationState("body", "bodyOnly")
			self.toPowerDown = false
			tech.playSound("beginDescent")
			return "none"
		end
		self.forceEjectTimer = self.forceEjectTimer + args.dt
	else
		self.forceEjectTimer = 0
	end

	if args.moves["special"] == 2 then
		pickupNearbyItems()
	end
	
	if args.moves["special"] == 3 and self.movesLast["special"] ~= 3 and self.active then
		if self.spotLightOn then
			tech.setLightActive("spotLight", false)
			tech.setLightActive("diffuseLight", false)
			self.spotLightOn = false
		else
			tech.setLightActive("spotLight", true)
			tech.setLightActive("diffuseLight", true)
			self.spotLightOn = true
		end
	end
	
	--left and right together makes the emch "frenzy"
	if args.moves["left"] and not args.moves["right"] then
		self.movementDirection = "left"
		self.frenzyTimer = 0
	elseif args.moves["right"] and not args.moves["left"] then
		self.movementDirection = "right"
		self.frenzyTimer = 0
	elseif args.moves["right"] and args.moves["left"] and not args.moves["jump"] and not args.moves["altFire"] then
		self.movementDirection = "frenzy"
		self.manualVertForce = -20
		self.frenzyTimer = self.frenzyTimer + args.dt
	else
		self.movementDirection = "none"
		self.frenzyTimer = 0
	end
	
	self.isCrouching = false
	--up or down or confused
	if args.moves["up"] and not args.moves["down"] then
		self.manualVertForce = 16
	elseif args.moves["down"] and not args.moves["up"] then
		self.manualVertForce = -20
		self.isCrouching = true
		if not self.movesLast["down"] then
			self.pickupTimer = 1
		end	
	elseif not args.moves["up"] and not args.moves["down"] then
		self.manualVertForce = 0
	else
		self.manualVertForce = 0
	end
	
	--weapons systems
	--laser ramps up with time
	if args.moves["primaryFire"] and tech.consumeTechEnergy(args.dt * energyCosts[(self.fireBeam[1] or "beam")]) then
		if self.fireBeam[2] + args.dt >= attackStats["beamMax"].time then
			self.fireBeam = {"beamMax", self.fireBeam[2] + args.dt}
		elseif self.fireBeam[2] + args.dt >= attackStats["beamHigh"].time then
			self.fireBeam = {"beamHigh", self.fireBeam[2] + args.dt}
		else
			self.fireBeam = {"beam", self.fireBeam[2] + args.dt}
		end
	else
		self.fireBeam = {false, 0}
	end
	
	--leg attack:
	--if attack button down AND canLegAttack (no attack in progress, valid target area, attck off cooldown)
	if args.moves["altFire"] and canLegAttack() then
		self.attackLeg = canLegAttack()
		legAttack("Update")
	--attack button down AND attack in progress
	elseif args.moves["altFire"] and self.legAttacking then
		legAttack("Update")
	--attack button released AND attack in progress
	elseif not args.moves["altFire"] and self.legAttacking then
		legAttack("Execute")
		self.legAttackTimer = 1.0
	--attack button AND no attack in progress AND leg attak off cooldown AND invalid target area
	elseif args.moves["altFire"] and self.legAttackTimer < 0 and not canLegAttack() then
		self.legAttackTimer = 1.0
		tech.playSound("failAction")
	end
	
	--jumpjets
	if args.moves["jump"] and (mcontroller.liquidMovement() or tech.consumeTechEnergy(args.dt * energyCosts["boost"])) then
		self.frenzyTimer = 0
		self.isBoosting = true
	else
		self.isBoosting = false
	end
	
	self.movesLast = args.moves
end

function activate()
	self.active = true
	--mirror some init() to reset stuff
	self.poweringDown = false
	self.isBoosting = false
	self.spotLightOn = false
	self.movementDirection = "none"
	self.recoilForce = {0,0}
	self.manualVertForce = 0
	self.fireBeam = {false, 0}
	self.laserBlacklist = {}
	self.legAttackBlacklist = {}
	self.storedPointsForLegShockwave = nil
	self.laserProjectileCooldown = 0.25
	self.blockedMovement = {["left"] = false, ["right"] = false, ["up"] = false, ["down"] = false}
	self.pickupTimer = 0
	self.forceEjectTimer = 0
	self.frenzyTimer = 0
	self.legAttackTimer = 0
	tech.setParentState("sit")
	tech.setVisible(true)
	--I can't make the player turn around, so hiding them
	--tech.setParentDirectives("?multiply=00d4d4ff")
	tech.setAnimationState("boosters", "idle")
	tech.setToolUsageSuppressed(true)
	self.chassisMotion = {0,0}
	self.chassisForce = {30,100}
	status.addPersistentEffects("spiderMechActive", spiderMechActiveStats)
	status.setStatusProperty("mouthPosition", {0, 3})
	status.setStatusProperty("targetMaterialKind", "robotic")
	updateAnchors(true)
	tech.playSound("activate")
	self.isFalling = false
	--world.logInfo("Activating Spidermech")
end

function deactivate()
	self.active = false
	self.poweringDown = false
	tech.setVisible(false)
	tech.setParentOffset({0,0})
	tech.setParentDirectives()
	status.setStatusProperty("mouthPosition", {0, 0.75})
	status.setStatusProperty("targetMaterialKind", "organic")
	mcontroller.setPosition(transformPoly(mcontroller.baseParameters().standingPoly) or mcontroller.position())
	tech.setParentState()
	tech.setToolUsageSuppressed(false)
	for _,leg in ipairs(legs) do
		legStatus[leg].anchor = {0,0}
		legStatus[leg].state = "falling"
		legStatus[leg].stack = {legFallPositions[leg]}
		if legBugs[leg] ~= nil and world.entityExists(legBugs[leg]) then
			world.callScriptedEntity(legBugs[leg], "kill")
		end
	end
	status.clearPersistentEffects("spiderMechActive")
end

function updateMotion(args)
	--world.logInfo("updateMotion() begin")
	if self.poweringDown then return nil end
	--No player movment
	--mcontroller.controlModifiers({movementSuppressed = true})
	

	--Weapons
	--interpert iaming position: aniamte gun, set pilot facing
	local gunPos = vec2.add(mcontroller.position(), tech.anchorPoint("gunCenter"))
	local gunAim = world.distance(tech.aimPosition(), gunPos)
	local laserLine = {0,0}
	local gunAngle = math.max(math.min(vec2.pureAngle(vec2.rotate(gunAim, -math.pi/2)), 3*math.pi/2+0.2), math.pi/2-0.2) + math.pi/2
	
    local nudge = tech.appliedOffset()
	local parentOffset = {0,2.25}
    tech.setParentOffset({parentOffset[1] + nudge[1], parentOffset[2] + nudge[2]})
	if gunAim[1] < 0 then mcontroller.controlFace(-1) else mcontroller.controlFace(1) end
	
	mcontroller.controlModifiers({jumpingSuppressed = true, glideModifier = 0, groundMovementModifier = 0, liquidMovementModifier = 0, runningSuppressed = true})
	mcontroller.controlParameters(customMovementParameters)
	
	
	
	tech.rotateGroup("mechGun",gunAngle, true)
	tech.setLightPointAngle("spotLight", (360*gunAngle)/(2*math.pi))
	
	
	--the laser turret
	if self.fireBeam[1] then
		if tech.animationState("gun") ~= self.fireBeam[1] then
			tech.setAnimationState("gun", self.fireBeam[1])
			tech.setLightActive("laserLight", true)
		end
		gunAngle = tech.currentRotationAngle("mechGun") or 3*math.pi/2
		tech.setLightPointAngle("laserLight", (360*gunAngle)/(2*math.pi))
		gunAim = vec2.add(gunPos, vec2.rotate({gunBeamRange,0}, gunAngle))
		local gunCheck = {gunAim[1], gunAim[2]}
		world.debugLine(gunPos, gunAim, {255,255,255,255})
		
		--where is the beam being blocked
		local blockCheck = world.collisionBlocksAlongLine(gunPos, gunAim, "Dynamic", 3)
		for i=1, 3 do
			if blockCheck[i] ~= nil then
				local blockSide = 0
				if world.distance(gunPos, blockCheck[i])[1] < 0 then
						blockSide = -0.2
				else
						blockSide = 1.2
				end
				local tempWallX = {vec2.add(blockCheck[i], {blockSide, -0.7}), vec2.add(blockCheck[i], {blockSide, 1.2})}
				if world.distance(gunPos, blockCheck[i])[2] < 0 then
						blockSide = -0.2
				else
						blockSide = 1.2
				end
				local tempWallY = {vec2.add(blockCheck[i], {-0.7, blockSide}), vec2.add(blockCheck[i], {1.2, blockSide})}
				world.debugLine(tempWallX[1], tempWallX[2], "green")
				world.debugLine(tempWallY[1], tempWallY[2], "green")
				gunAim = vec2.intersect(gunPos, gunAim, tempWallX[1], tempWallX[2]) or gunAim
				gunAim = vec2.intersect(gunPos, gunAim, tempWallY[1], tempWallY[2]) or gunAim
				if not vec2.eq(gunAim, gunCheck) then break end
			end
        end
		laserLine = world.distance(gunAim, gunPos)
		tech.scaleGroup("mechBeam", {(vec2.mag(laserLine)+0.1)/20, 1})
		
		if self.laserBlacklist["terminus"] == nil then
			world.spawnProjectile("spiderlaserterminus", gunAim, entity.id(), {0,0}, false, {lightColor = attackStats[self.fireBeam[1]].light, actionOnReap = {{action = "config", file = "/projectiles/explosions/spiderlaserterminus/"..attackStats[self.fireBeam[1]].endProjectile..".config"}}, power = attackStats[self.fireBeam[1]].power})
			self.laserBlacklist["terminus"] = 0.12
		end
		--do the damage
		local laserEntities = world.entityLineQuery(gunPos, gunAim, {notAnObject = true})
		for _,target in ipairs(laserEntities) do
			--I always get funky results from using the entityQuery options, so I prefer doing mys own screening
			if self.laserBlacklist[target] == nil and world.entityType(target) == "player" or world.entityType(target) == "monster" or world.entityType(target) == "npc" then
				world.spawnProjectile("spiderlaserbeam", world.entityPosition(target), entity.id(), {0,0}, false, {statusEffects = {attackStats[self.fireBeam[1]].midProjectile}})
				self.laserBlacklist[target] = self.laserProjectileCooldown
			end
		end
	elseif tech.animationState("gun") ~= "idle" then
		tech.setLightActive("laserLight", false)
		tech.setAnimationState("gun", "idle")
	end
	
	--Horizontal movement base
	if self.movementDirection == "left" then
		self.manualHorizForce = -25
	elseif self.movementDirection == "right" then
		self.manualHorizForce = 25
	else
		self.manualHorizForce = 0
	end

	--Calculate the summed suspension force for legs with anchors
	local suspensionForce = {0,0}
	local gravityAdjust = math.min(math.max((world.gravity(mcontroller.position())-80)/10, 0), 4)
	local vertWeights = {}
	local horizWeights = {}
	for _,leg in ipairs(legs) do
		local basePos = vec2.add(mcontroller.position(), legBaseJoints[leg])
		local currentAnchor = legStatus[leg].anchor
		if legStatus[leg].state == "stable" or legStatus[leg].state == "moving" then 
			vertWeights[leg] = params.vertEquilibrium - gravityAdjust - world.distance(basePos, currentAnchor)[2]
			horizWeights[leg] = -world.distance(basePos, currentAnchor)[1]
		else
			vertWeights[leg] = nil
			horizWeights[leg] = nil
		end
	end
	
	--if one end is unsupported, we are 'falling'
	self.isFalling = false
	for _,leg in pairs(legs) do
		if vertWeights[leg] == nil and vertWeights[legPairs[leg]] == nil then
			self.isFalling = true 
			break
		end
		suspensionForce[2] = suspensionForce[2] + (vertWeights[leg] or 0)
	end			
	for _,leg in pairs(legs) do
		local soloAdjust = 0.2
		if horizWeights[leg] == nil and horizWeights[legPairs[leg]] == nil then
			suspensionForce[1] = 0
			break
		elseif horizWeights[leg] ~= nil and horizWeights[legPairs[leg]] == nil then
			soloAdjust = 2*soloAdjust
		end
		suspensionForce[1] = suspensionForce[1] + (horizWeights[leg] or 0) * soloAdjust
	end
	if self.isFalling then
		customMovementParameters.gravityEnabled = true
	else
		customMovementParameters.gravityEnabled = false
	end
	
	self.chassisMotion[1] = suspensionForce[1] + self.manualHorizForce + (self.bossHorizForce or 0)
	self.chassisMotion[2] = suspensionForce[2] + self.manualVertForce + (self.bossVertForce or 0)
	
	--frenzying is its own state
	local frenzyForce = {0,0}
	if self.frenzyTimer > 0 then
		frenzyForce = vec2.rotate({1,0}, math.random()*2*math.pi)
		frenzyForce = {frenzyForce[1]*frenzyForceMults[1], frenzyForce[2]*frenzyForceMults[2]}
		--world.logInfo("FF: %s", frenzyForce[1])
		mcontroller.controlForce(vec2.add(self.chassisMotion, frenzyForce))
		if self.frenzyTimer >= 1 then
			if tech.consumeTechEnergy(energyCosts["frenzy"]*args.dt) then
				tech.setParticleEmitterActive("frenzying", true)
				tech.setParticleEmitterEmissionRate("frenzying", math.min(self.frenzyTimer*4, 40))
				if tech.animationState("frenzy") == "idle" then tech.setAnimationState("frenzy", "frenzying") end
				self.isFrenzying = true
			elseif self.isFrenzying then
				tech.setParticleEmitterActive("frenzying", false)
				if tech.animationState("frenzy") == "frenzying" then tech.setAnimationState("frenzy", "idle") end
				self.isFrenzying = false
			end
		else
			-- tech.setParticleEmitterActive("frenzying", false)
			-- if tech.animationState("frenzy") == "frenzying" then tech.setAnimationState("frenzy", "idle") end
			-- self.isFrenzying = false
		end
	elseif self.isFrenzying then
		tech.setParticleEmitterActive("frenzying", false)
		if tech.animationState("frenzy") == "frenzying" then tech.setAnimationState("frenzy", "idle") end
		self.isFrenzying = false
	end
	
	world.debugLine(mcontroller.position(), vec2.add(mcontroller.position(), suspensionForce), {255,255,255,255})
		
	self.chassisMotion = vec2.add(self.chassisMotion, self.recoilForce)
	self.recoilForce = {0,0}
	
	if math.abs(self.chassisMotion[1]) < 2 then self.chassisMotion[1] = 0 end
	if self.movementBlocked["left"] then
		self.movementBlocked["left"] = false
		mcontroller.controlForce({400,0})
		--self.chassisMotion[1] = math.min(self.chassisMotion[1], 5)
	end
	if self.movementBlocked["right"] then
		--self.chassisMotion[1] = math.max(self.chassisMotion[1], -5)
		mcontroller.controlForce({-400,0})
		self.movementBlocked["right"] = false
	end
	mcontroller.controlApproachXVelocity(self.chassisMotion[1],self.chassisForce[1])
	
	--boosting and falling override the suspension force
	if self.poweringDown then
		mcontroller.controlApproachYVelocity(-8 ,self.chassisForce[2])
	elseif self.isBoosting then
		self.chassisMotion[2] = 30
		mcontroller.controlApproachYVelocity(self.chassisMotion[2],self.chassisForce[2])
	elseif not self.isFalling then
		if math.abs(self.chassisMotion[2]) < 0.5 then self.chassisMotion[2] = 0 end
		mcontroller.controlApproachYVelocity(self.chassisMotion[2], self.chassisForce[2])
	end
	
	--Animate the boosters
	if self.isBoosting and tech.animationState("boosters") == "idle" then
		local boostAngle = vec2.pureAngle(vec2.mul(self.chassisMotion,-1))
		tech.rotateGroup("leftBooster", math.max(math.min(boostAngle, 7*math.pi/4), 5*math.pi/4), true)		
		tech.rotateGroup("rightBooster", math.max(math.min(boostAngle, 7*math.pi/4), 5*math.pi/4), true)
		tech.setLightActive("leftBoosterLight", true)
		tech.setLightActive("rightBoosterLight", true)
		tech.setAnimationState("boosters", "boosting")
	elseif not self.isBoosting and tech.animationState("boosters") == "boosting" then
		tech.setAnimationState("boosters", "idle")
		tech.setLightActive("leftBoosterLight", false)
		tech.setLightActive("rightBoosterLight", false)
	elseif self.isBoosting then
		local boostAngle = vec2.pureAngle(vec2.mul(self.chassisMotion,-1))
		tech.rotateGroup("leftBooster", math.max(math.min(boostAngle, 7*math.pi/4), 5*math.pi/4), false)
		tech.rotateGroup("rightBooster", math.max(math.min(boostAngle, 7*math.pi/4), 5*math.pi/4), false)
	end
	--world.logInfo("updateMotion() end")
end

function checkPoly(poly, center, solidOnly)
	for i=2,#poly do
		world.debugLine(vec2.add(poly[i], center), vec2.add(poly[i-1], center), {200,200,250,240})
	end
	world.debugLine(vec2.add(poly[1], center), vec2.add(poly[#poly], center), {200,200,250,240})
	if not solidOnly then
		return world.polyCollision(poly, center, "Any")
	else
		return world.polyCollision(poly, center, "Dynamic")
	end
end

function pickupNearbyItems()
	if self.pickupTimer > 0 then return false end
	local callBug = nil
	for leg,bug in pairs(legBugs) do
		callBug = bug
	end
	if callBug == nil then world.logInfo("No bug!") return false end
	tech.playSound("tractorBeam")
	self.pickupTimer = 1
	world.callScriptedEntity(callBug, "takeItems", vec2.add(mcontroller.position(), {-8,-30}), vec2.add(mcontroller.position(), {8, -4}), entity.id())
	world.debugLine(vec2.add(mcontroller.position(), {-8,-4}), vec2.add(mcontroller.position(), {8,-4}), {100,100,220,255})
	world.debugLine(vec2.add(mcontroller.position(), {8,-4}), vec2.add(mcontroller.position(), {8, -30}), {100,100,220,255})
	world.debugLine(vec2.add(mcontroller.position(), {8,-30}), vec2.add(mcontroller.position(), {-8, -30}), {100,100,220,255})
	world.debugLine(vec2.add(mcontroller.position(), {-8,-30}), vec2.add(mcontroller.position(), {-8, -4}), {100,100,220,255})
end

function updateAnchors(onGround)
	--world.logInfo("updateAnchors() begin")
	if self.poweringDown then return nil end
	for _,leg in ipairs(legs) do
		local currentAnchor = legStatus[leg].anchor
		local basePos = vec2.add(mcontroller.position(), legBaseJoints[leg])
		--just a quick adjustment for when firing up
		if onGround then
			basePos = vec2.add(mcontroller.position(), legFromGroundJoints[leg])
		end
		local checkParameters = checkPolyParam
		local newAnchor = nil
		local checkDirection = self.movementDirection
		local legDirection = "none"
		if string.sub(leg, 1, 1) == "l" then legDirection = "left" 
		elseif string.sub(leg, 1, 1) == "r" then legDirection = "right" end
		--many possible conditions to force an anchor change! 
		if isLegReadyToSearch(leg) then
			if legStatus[leg].state == "searching" or
			 legStatus[leg].state == "falling" or 
			 legStatus[leg].state == "attacking" or
			 type(legStatus[leg].anchor) ~= "table" or
			 vec2.mag(world.distance(basePos, currentAnchor)) > params.maxExtension or
			 not checkPoly(checkPolyAnchor, currentAnchor, self.isCrouching) or
			 (not self.isFrenzying and legStepZones[leg][1] > world.distance(currentAnchor, basePos)[1]) or
			 (not self.isFrenzying and legStepZones[leg][2] < world.distance(currentAnchor, basePos)[1]) or
			 vec2.mag(vec2.sub(currentAnchor, basePos)) <= params.legOverreach or
			 (self.isFrenzying and legStatus[leg].state == "stable") or
			 not renderLeg(leg, currentAnchor, false, true) then
				--first make sure there is something in the region
				if (legDirection == "left" and checkDirection == "left" and checkPoly(checkPolySweepL, basePos, false)) or
				 (legDirection == "right" and checkDirection == "right" and checkPoly(checkPolySweepR, basePos, false)) or
				 (legDirection == "left" and checkDirection == "right" and checkPoly(checkPolyRec, vec2.add(basePos, {-math.ceil(checkParameters[1]/2), 0}), false)) or
				 (legDirection == "right" and checkDirection == "left" and checkPoly(checkPolyRec, vec2.add(basePos, {math.ceil(checkParameters[1]/2), 0}), false)) or 
				 (checkDirection == "none" and checkPoly(checkPolyRec, vec2.add(mcontroller.position(), {legSeeds[leg],legBaseJoints[leg][2]}), false)) or
				 (checkDirection == "frenzy" and checkPoly(checkPolyFrenzy, vec2.add(mcontroller.position(), {legSeeds[leg], legBaseJoints[leg][2]}), false)) then
					local checkAngle = 0
					local checkRadius = params.maxExtension
					local checkNode1 = {0,0}
					local checkNode2 = {0,0}			
					----world.logInfo("%s", legDirection)
					--various geometries
					if checkDirection == "left" or checkDirection == "right" then
						for n = 1, checkParameters[1] do
							checkRadius = checkRadius - checkParameters[3]
							for i = 1, checkParameters[2] do
								if checkDirection == legDirection then
									local angleBase = math.pi/6
									local angleIncrement = math.pi/checkParameters[5]
									if self.isCrouching then
										angleBase = math.pi/3
										angleIncrement = (angleIncrement*checkParameters[1] - 1/6)/(angleIncrement*checkParameters[1])*angleIncrement
									end
									if checkDirection == "left" then
										checkAngle = angleBase + i*angleIncrement
									elseif checkDirection == "right" then
										checkAngle = -angleBase - i*angleIncrement
									end
									checkNode1 = vec2.add(basePos, vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle))
									if checkDirection == "left" then
										checkAngle = angleBase + (i+1)*angleIncrement
									elseif checkDirection == "right" then
										checkAngle = -angleBase - (i+1)*angleIncrement
									end
									checkNode2 = vec2.add(basePos, vec2.rotate( vec2.mul( {0,1} , checkRadius) , checkAngle))
								elseif checkDirection == "none" then
									checkNode1 = vec2.add(mcontroller.position(), {legSeeds[leg]+math.floor(n/2)*((-1)^(n)), 1 - checkParameters[4]*i})
									checkNode2 = vec2.add(checkNode1, {0, -checkParameters[4]})
								elseif checkDirection == "right" and legDirection == "left" then
									checkNode1 = vec2.add(basePos, {-n, 1 -checkParameters[4]*i})
									checkNode2 = vec2.add(basePos, {-n, 1 -checkParameters[4]*(i+1)})
								elseif checkDirection == "left" and legDirection == "right" then
									checkNode1 = vec2.add(basePos, {n, 1 -checkParameters[4]*i})
									checkNode2 = vec2.add(basePos, {n, 1 -checkParameters[4]*(i+1)})
								elseif checkDirection == "frenzy" and legDirection == "left" then
									checkNode1 = vec2.add(mcontroller.position(), {legSeeds[leg]-5+i*(12/checkParameters[2]),5-n})
									checkNode2 = vec2.add(checkNode1, {12/checkParameters[2],0})
								elseif checkDirection == "frenzy" and legDirection == "right" then
									checkNode1 = vec2.add(mcontroller.position(), {legSeeds[leg]+5-i*(12/checkParameters[2]),5-n})
									checkNode2 = vec2.add(checkNode1, {-12/checkParameters[2],0})
								end
								world.debugLine(checkNode1, checkNode2, {0,200,0,180})
								local checkCollisions = {}
								if self.isCrouching then
									checkCollisions = world.collisionBlocksAlongLine(checkNode1, checkNode2, "Dynamic", 1)
								else
									checkCollisions = world.collisionBlocksAlongLine(checkNode1, checkNode2, "Any", 1)
								end
								if #checkCollisions > 0 and vec2.mag(vec2.sub(vec2.add(checkCollisions[1], {0.5,1}), basePos)) > params.legOverreach then
									local checkCollisions2 = world.collisionBlocksAlongLine(vec2.add(checkCollisions[1],{0.5,1.5}), vec2.add(checkCollisions[1], {0.5, 3.5}), "Dynamic", 1)
									if #checkCollisions2 == 0 and 
									  renderLeg(leg, vec2.add(checkCollisions[1], {0.5,1}), false, true) and
									  (type(legStatus[legPairs[leg]].anchor) ~= "table" or self.isFrenzying or vec2.mag(world.distance(vec2.add(checkCollisions[1], {0.5,1}), legStatus[legPairs[leg]].anchor)) >= 5) and
									  checkCollisions[1][2] - mcontroller.position()[2] <= 10 then
										newAnchor = vec2.add(checkCollisions[1], {0.5,1})
									end
								end
								if newAnchor ~= nil then break end
							end
							if newAnchor ~= nil then break end
						end
					elseif checkDirection == "frenzy" then
						for n = 1, math.floor(5-legFallPositions[leg][2]) do	
							if legDirection == "left" then
								checkNode1 = vec2.add(mcontroller.position(), {legSeeds[leg]-6,5-n})
								checkNode2 = vec2.add(checkNode1, {12,0})
							elseif legDirection == "right" then
								checkNode1 = vec2.add(mcontroller.position(), {legSeeds[leg]+6,5-n})
								checkNode2 = vec2.add(checkNode1, {-12,0})
							end
							world.debugLine(checkNode1, checkNode2, {0,200,0,180})
							local checkCollisions = world.collisionBlocksAlongLine(checkNode1, checkNode2, "Any", 1)
							
							local sideCheck = 1
							if legDirection == "right" then sideCheck = -1 end
							for _,block in ipairs(checkCollisions) do
								if vec2.mag(vec2.sub(vec2.add(block, {0.5,1}), basePos)) > params.legOverreach and 
								  vec2.mag(world.distance(vec2.add(block, {0.5,1}), currentAnchor)) >= 1.7 and
								  #world.collisionBlocksAlongLine(vec2.add(block,{0.5,1.5}), vec2.add(block, {0.5, 3.5}), "Dynamic", 1) == 0 and
								  renderLeg(leg, vec2.add(block, {0.5,1}), false, true) then
									newAnchor = vec2.add(block, {0.5,1})
								elseif vec2.mag(vec2.sub(vec2.add(block, {sideCheck,0.5}), basePos)) > params.legOverreach and 
								  vec2.mag(world.distance(vec2.add(block, {sideCheck,0.5}), currentAnchor)) >= 1.7 and
								  #world.collisionBlocksAlongLine(vec2.add(block,{1.5*sideCheck,0.5}), vec2.add(block, {3.5*sideCheck, 0.5}), "Dynamic", 1) == 0 and
								  renderLeg(leg, vec2.add(block, {sideCheck,0.5}), false, true) then
									newAnchor = vec2.add(block, {sideCheck,0.5})
								end
								if newAnchor ~= nil then break end
							end
							if newAnchor ~= nil then 
								if vec2.eq(newAnchor,currentAnchor) then smackImpactPoint(newAnchor) end
								break 
							end
						end
					else
						for n = 1, checkParameters[1] do
							checkNode1 = vec2.add(mcontroller.position(), {legSeeds[leg]+math.floor(n/2)*((-1)^(n)), 1})
							checkNode2 = vec2.add(checkNode1, {0, -checkParameters[4]*checkParameters[2]})
							local checkCollisions = {}
							if self.isCrouching then
								checkCollisions = world.collisionBlocksAlongLine(checkNode1, checkNode2, "Dynamic", 1)
							else
								checkCollisions = world.collisionBlocksAlongLine(checkNode1, checkNode2, "Any", 1)
							end
							for _,block in ipairs(checkCollisions) do
								if vec2.mag(vec2.sub(vec2.add(block, {0.5,1}), basePos)) > params.legOverreach and 
								  #world.collisionBlocksAlongLine(vec2.add(block,{0.5,1.5}), vec2.add(block, {0.5, 3.5}), "Dynamic", 1) == 0 and
								  renderLeg(leg, vec2.add(block, {0.5,1}), false, true) and
								  (type(legStatus[legPairs[leg]].anchor) ~= "table" or vec2.mag(world.distance(vec2.add(checkCollisions[1], {0.5,1}), legStatus[legPairs[leg]].anchor)) >= 5) then
									newAnchor = vec2.add(block, {0.5,1})
								end
								if newAnchor ~= nil then break end
							end
							if newAnchor ~= nil then break end
						end
					end
					if newAnchor ~= nil then
						assignNewAnchor(leg, newAnchor, onGround)
					else
						assignNewAnchor(leg, "none", onGround)
					end
				else
					assignNewAnchor(leg, "none", onGround)
				end
			end
		end
	end
	--world.logInfo("updateAnchors() end")
end

function isLegReadyToSearch(leg)
	if legStatus[leg].state == "attackReady" then return false end
	if legStatus[leg].state == "attacking" and #legStatus[leg].stack > 1 then return false end
	if legStatus[leg].cd > 0 then
		legStatus[leg].cd = legStatus[leg].cd - 1
		return false
	elseif legStatus[leg].state == "stable" or legStatus[leg].state == "moving" then
		return true
	elseif legStatus[leg].state == "falling" then
		legStatus[leg].cd = 5
		return true
	elseif legStatus[leg].state == "searching" then
		legStatus[leg].cd = 3
		return true
	else 
		return true
	end
end

function assignNewAnchor(leg, anchor, baseInstant)
	local instant = baseInstant
	local oldPos = legStatus[leg].anchor
	if type(oldPos) ~= "table" then
		instant = true
	end
	local fallingPos = vec2.add(vec2.add(mcontroller.position(), legBaseJoints[leg]), {legSeeds[leg],-params.vertEquilibrium})
	if type(anchor) == "table" then 
		legStatus[leg].cd = 0
		if instant then
			legStatus[leg].anchor = anchor
			legStatus[leg].state = "stable"
			legStatus[leg].stack = {}
		else
			legStatus[leg].anchor = anchor
			local arc = 0
			local frameFactor = 27 - vec2.mag(mcontroller.velocity())
			if legStatus[leg].state == "stable" then
				arc = 4
				frameFactor = math.ceil(1*frameFactor)
			else
				arc = 1
				frameFactor = math.ceil(0.4*frameFactor)
			end
			frameFactor = math.min(math.max(frameFactor, 4), 25)
			makeLegStack(leg, oldPos, anchor, frameFactor, 0, {0, arc}, false)
			legStatus[leg].state = "moving"
		end
	else
		if self.isFalling and legStatus[leg].state ~= "falling" then
			legStatus[leg].state = "falling"
			legStatus[leg].cd = math.random(5)
			if instant then
				legStatus[leg].anchor = vec2.add(mcontroller.position(), legFallPositions[leg])	
				legStatus[leg].stack = {legFallPositions[leg]}
			else
				makeLegStack(leg, legStatus[leg].anchor, legFallPositions[leg], 5, 0, {0,0}, true)
			end
		elseif not self.isFalling and legStatus[leg].state ~= "searching" then 
			legStatus[leg].state = "searching"
			legStatus[leg].cd = math.random(3)
			if instant then
				legStatus[leg].anchor = vec2.add(vec2.add(mcontroller.position(), legBaseJoints[leg]), {legSeeds[leg], -params.vertEquilibrium})
				legStatus[leg].stack = {}
			else
				legStatus[leg].stack = {}
			end
		end
	end
end

function makeLegStack(leg, rawOldPos, rawNewPos, frames, lingerFrames, rawArc, relative)
	--to get from A to B with style
	local newPos = rawNewPos
	local oldPos = rawOldPos
	if relative then
		oldPos = world.distance(rawOldPos, mcontroller.position())
		newPos = rawNewPos
	end
	local newStack = {}
	local newLine = world.distance(newPos, oldPos)
	local arc = {0,0}
	if vec2.mag(rawArc) > 0.4 then
		arc = vec2.mul(rawArc, math.min(vec2.mag(rawArc), vec2.mag(newLine)/2)/vec2.mag(rawArc))
	end
	for i=1,frames do
		local disp = vec2.mul(arc, (1-(1-2*i/frames)^2))
		table.insert(newStack, 1, vec2.add(vec2.add(oldPos ,vec2.mul(newLine , i/frames)), disp))
	end
	if lingerFrames > 0 then
		for i=1,lingerFrames do
			table.insert(newStack, 1, newPos)
		end
	end
	legStatus[leg].stack = newStack
end

function renderLegs()
	--world.logInfo("renderLegs() begin")
	if self.poweringDown then return nil end
	--different legs doing different things
	--world.logInfo("States: %s, %s, %s, %s", legStatus[legs[1]].state,legStatus[legs[2]].state,legStatus[legs[3]].state,legStatus[legs[4]].state)
	for _,leg in ipairs(legs) do
		if legStatus[leg].state == "stable" then 
			--"stable" legs are stable
			renderLeg(leg, legStatus[leg].anchor)
		elseif legStatus[leg].state == "falling" or legStatus[leg].state == "attackReady" then
			--"falling" legs should head to their base root points and wait there
			if #legStatus[leg].stack > 1 then
				legStatus[leg].anchor = vec2.add(table.remove(legStatus[leg].stack), mcontroller.position())
			else
				legStatus[leg].anchor = vec2.add(mcontroller.position(), legStatus[leg].stack[1] or legFallPositions[leg])
			end
			local drag = mcontroller.velocity()
			if vec2.mag(drag) > 1 then 
				drag = vec2.mul(vec2.norm(drag), -math.log(vec2.mag(drag)/10 + 1))
			else
				drag = {0,0}
			end
			--if leg == "lF" then world.logInfo("Drag on %s: %s", leg, drag) end
			--world.debugLine(vec2.add(mcontroller.position(), legStatus[leg].anchor), vec2.add(mcontroller.position(), vec2.add(legStatus[leg].anchor, drag)), {0,200, 100, 255})
			renderLeg(leg, vec2.add(legStatus[leg].anchor, drag))
			if legStatus[leg].state == "attackReady" then
				self.recoilForce = {legStatus[leg].stack[1][1]*(-0.3), legStatus[leg].stack[1][2]*(-1.0)}
			end
		elseif legStatus[leg].state == "attacking" then
			if #legStatus[leg].stack == 0 then 
				renderLeg(leg, legStatus[leg].anchor, false, false, true)
				self.legAttackBlacklist = {}
				self.storedPointsForLegShockwave = nil
			elseif self.attackLegShockwavePending and vec2.eq(legStatus[leg].anchor, legStatus[leg].stack[#legStatus[leg].stack]) then
				legStatus[leg].anchor = vec2.add(table.remove(legStatus[leg].stack), mcontroller.position())
				renderLeg(leg, legStatus[leg].anchor, true, false, false)
				self.legAttackBlacklist = {}
				self.storedPointsForLegShockwave = nil
			else
				self.recoilForce = {0, legStatus[leg].stack[1][2]*0.7}
				mcontroller.controlForce({legStatus[leg].stack[1][1]*6, 0})
				legStatus[leg].anchor = vec2.add(table.remove(legStatus[leg].stack), mcontroller.position())
				renderLeg(leg, legStatus[leg].anchor, true, false, true)
			end
		elseif legStatus[leg].state == "moving" then
			--"moving" legs transition through their arcs
			if #legStatus[leg].stack > 0 then 
				renderLeg(leg, table.remove(legStatus[leg].stack), false, false, true)
			else
				smackImpactPoint(legStatus[leg].anchor)
				legStatus[leg].state = "stable"
				renderLeg(leg, legStatus[leg].anchor, false, false, true)
			end
		elseif legStatus[leg].state == "searching" then
			--"searching" legs play a little twitchy game
			if #legStatus[leg].stack == 0 then 
				local newToPoint = {legSeeds[leg]+legBaseJoints[leg][1],legBaseJoints[leg][2] - params.vertEquilibrium + 2}
				newToPoint = vec2.add(newToPoint, vec2.rotate({4*math.random(),0}, math.random()*2*math.pi))
				makeLegStack(leg, legStatus[leg].anchor, newToPoint, 20, 40, {2*math.random(), 2*math.random()}, true)
				legStatus[leg].anchor = vec2.add(table.remove(legStatus[leg].stack), mcontroller.position())
				renderLeg(leg, legStatus[leg].anchor)
			else
				legStatus[leg].anchor = vec2.add(table.remove(legStatus[leg].stack), mcontroller.position())
				renderLeg(leg, legStatus[leg].anchor)
			end
		end
	end
	--world.logInfo("renderLegs() end")
end

function renderLeg(leg, footPos, destructive, justChecking, noBounce)
	--world.logInfo("renderLeg(%s) begin", leg)
	if self.poweringDown then return nil end
	--there's only one way to fit bridge two points with a leg. find it first
	local rootPos = vec2.add(mcontroller.position(), legBaseJoints[leg])
	local jointPos = {0,0}
	local baseLine = world.distance(footPos, rootPos)
	local squeezeFactor = 1
	local rotateAngle = 0
	--if leg == "lF" then world.logInfo("Rendering: %s, %s, %s", rootPos, footPos, baseLine) end
	if vec2.mag(baseLine) < params.upperLegLength + params.lowerLegLength then
		rotateAngle = math.acos((params.upperLegLength^2 + vec2.mag(baseLine)^2 - params.lowerLegLength^2)/(2 * params.upperLegLength * vec2.mag(baseLine)))
		if string.sub(leg, 1, 1) == "l" then rotateAngle = -rotateAngle end
		jointPos = vec2.add(mcontroller.position(), legBaseJoints[leg])
		jointPos = vec2.add(jointPos, vec2.rotate( vec2.mul( vec2.norm(baseLine) , params.upperLegLength), rotateAngle))
	else 
		return false
	end
	local lowerLeg = world.distance(footPos, jointPos)
	local upperLeg = world.distance(jointPos, rootPos)
	
	local blockingBlocks1 = world.collisionBlocksAlongLine(rootPos, jointPos)
	local blockingBlocks2 = world.collisionBlocksAlongLine(jointPos, footPos)
	if #blockingBlocks1 > 1 or #blockingBlocks2 > 1 then
		if justChecking then
			return false
		end
	else
		if justChecking then
			return true
		end
		table.insert(blockingBlocks1, blockingBlocks2[1])
		for _,block in ipairs(blockingBlocks1) do
			local adjusts = {{0,1},{1,0},{-1,0},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}}
			local sideBlocks = {}
			for i,j in ipairs(adjusts) do
				local tile = vec2.add(block, j)
				if world.tileIsOccupied(tile, true) then
					table.insert(sideBlocks, j)
				end
			end
			if #sideBlocks == 1 or (#sideBlocks == 2 and vec2.mag(vec2.add(sideBlocks[1], sideBlocks[2])) <= 1) then 
				world.damageTiles({block}, "foreground", mcontroller.position(), "explosive", 1000, 99)
			end
		end
		-- if #blockingBlocks1 > 0 then
			-- world.damageTiles(blockingBlocks1, "foreground", mcontroller.position(), "explosive", 1000, 99)
		-- end
		-- if #blockingBlocks2 > 0 then
			-- world.damageTiles(blockingBlocks2, "foreground", mcontroller.position(), "explosive", 1000, 99)
		-- end
	end
	
	local myBug = legBugs[leg]
	if leg == "rF" then
		rotateAngle = vec2.pureAngle(upperLeg)
		tech.rotateGroup("upperRightLeg", rotateAngle, true)	
		if myBug == nil or not world.entityExists(myBug) then
			legBugs[leg] = world.spawnMonster("scriptbugspidermechrightfrontleg", jointPos)
			local buglist = world.monsterQuery(jointPos, 10+vec2.mag(mcontroller.velocity()))
			for i,j in ipairs(buglist) do
				if world.monsterType(j) == "scriptbugspidermechrightfrontleg" then
					legBugs[leg] = j					
					tech.setAnimationState("body", "idle")
					break
				end
			end
			myBug = legBugs[leg]
		end
		world.callScriptedEntity(myBug, "moveLeg", footPos, jointPos, nil, mcontroller.velocity(), self.chassisMotion)
		if not noBounce and world.pointTileCollision(jointPos) and mcontroller.xVelocity() > 0 then 
			mcontroller.setXVelocity(0) 
			self.movementBlocked["right"] = true
		end
	elseif leg == "lF" then
		rotateAngle = vec2.pureAngle(upperLeg)
		tech.rotateGroup("upperLeftLeg", rotateAngle, true)
		if myBug == nil or not world.entityExists(myBug) then
			legBugs[leg] = world.spawnMonster("scriptbugspidermechleftfrontleg", jointPos)
			local buglist = world.monsterQuery(jointPos, 10+vec2.mag(mcontroller.velocity()))
			for i,j in ipairs(buglist) do
				if world.monsterType(j) == "scriptbugspidermechleftfrontleg" then
					legBugs[leg] = j
					tech.setAnimationState("body", "idle")
					break
				end
			end
			myBug = legBugs[leg]
		end
		world.callScriptedEntity(myBug, "moveLeg", footPos, jointPos, nil, mcontroller.velocity(), self.chassisMotion)
		if not noBounce and world.pointTileCollision(jointPos) and mcontroller.xVelocity() < 0 then 
			mcontroller.setXVelocity(0) 
			self.movementBlocked["left"] = true
		end
	elseif leg == "rB" then
		if myBug == nil or not world.entityExists(myBug) then
			legBugs[leg] = world.spawnMonster("scriptbugspidermechrightbackleg", jointPos)
			local buglist = world.monsterQuery(jointPos, 10+vec2.mag(mcontroller.velocity()))
			for i,j in ipairs(buglist) do
				if world.monsterType(j) == "scriptbugspidermechrightbackleg" then
					legBugs[leg] = j
					tech.setAnimationState("body", "idle")
					break
				end
			end
			myBug = legBugs[leg]
		end
		world.callScriptedEntity(myBug, "moveLeg", footPos, jointPos, rootPos, mcontroller.velocity(), self.chassisMotion)
		if not noBounce and world.pointTileCollision(jointPos) and mcontroller.xVelocity() > 0 then 
			mcontroller.setXVelocity(0)
			self.movementBlocked["right"] = true
		end
	elseif leg == "lB" then
		--world.logInfo("Render: %s, %s", leg, footPos)
		--world.logInfo("Bug = %s", myBug)
		if myBug == nil or not world.entityExists(myBug) then
			legBugs[leg] = world.spawnMonster("scriptbugspidermechleftbackleg", jointPos)
			local buglist = world.monsterQuery(jointPos, 10+vec2.mag(mcontroller.velocity()))
			for i,j in ipairs(buglist) do
				if world.monsterType(j) == "scriptbugspidermechleftbackleg" then
					legBugs[leg] = j
					tech.setAnimationState("body", "idle")
					break
				end
			end
			myBug = legBugs[leg]
		end
		--world.logInfo("Bug Call: %s, %s, %s, %s, %s, %s, %s", myBug, "moveLeg", footPos, jointPos, rootPos, mcontroller.velocity(), self.chassisMotion)
		world.callScriptedEntity(myBug, "moveLeg", footPos, jointPos, rootPos, mcontroller.velocity(), self.chassisMotion)
		if not noBounce and world.pointTileCollision(jointPos) and mcontroller.xVelocity() < 0 then 
			mcontroller.setXVelocity(0)
			self.movementBlocked["left"] = true
		end
	end

	if destructive then
		legAttackShockwave(leg, jointPos, footPos, false)
	end
	world.debugLine(rootPos, jointPos, legColors[leg])
	world.debugLine(jointPos, footPos, legColors[leg])
	--world.logInfo("renderLeg(%s) end", leg)
end

function canLegAttack()
	--world.logInfo("canLegAttack()")
	if self.legAttacking then return false end
	if self.legAttackTimer > 0 then return false end
	if vec2.mag(world.distance(tech.aimPosition(), mcontroller.position())) < 8 then return false end
	local aimPos = world.distance(tech.aimPosition(), mcontroller.position())
	local bestLeg = nil
	for _,leg in ipairs(legs) do
		local adjPos = vec2.sub(aimPos, legBaseJoints[leg])
		world.debugLine(vec2.add(mcontroller.position(), legBaseJoints[leg]), tech.aimPosition(), {0,50,200,255})
		if math.abs(aimPos[1] - legSeeds[leg]) <= math.abs(aimPos[1] - legSeeds[bestLeg or leg]) and 
		  (legStatus[legPairs[leg]].state == "stable" or legStatus[legPairs[leg]].state == "falling") and
		  vec2.mag(adjPos) > 3 then--and math.abs(vec2.angle(adjPos) - math.pi/2) > math.pi/6 then
		    world.debugLine(vec2.add(mcontroller.position(), legBaseJoints[leg]), tech.aimPosition(), {200,50,200,255})
			bestLeg = leg
		end
	end
	--world.logInfo("bestLeg: %s", bestLeg)
	self.attackLeg = bestLeg
	return bestLeg
end

function legAttack(action)
	--world.logInfo("lAttack")
	leg = self.attackLeg
	if leg == nil then return false end
	local aimPos = world.distance(tech.aimPosition(), vec2.add(legBaseJoints[leg], mcontroller.position()))
	local aimLength = vec2.mag(aimPos)
	local aimAngle = vec2.pureAngle(aimPos)
	local angleAdjust = 0.2
	if action == "Execute" then
		tech.consumeTechEnergy(energyCosts["legAttack"])
		tech.playSound("legAttack")
		self.legAttackBlacklist = {}
		self.storedPointsForLegShockwave = nil
		--world.logInfo("execute")
		local maxRange = 0.99*(params.lowerLegLength+params.upperLegLength)
		if vec2.mag(aimPos) ~= maxRange then
			aimPos = vec2.mul(vec2.norm(aimPos), maxRange)
		end
		local arc = {0,0}
		if string.sub(leg,1,1) == "l" then
			aimAngle = math.max(math.min(aimAngle, 10*math.pi/6), 2*math.pi/6)
			arc = vec2.mul(vec2.rotate({1,0}, aimAngle + math.pi/2),5)
		else
			if aimAngle <= 4*math.pi/6 then
			elseif aimAngle >= 8*math.pi/6 then
			elseif aimAngle <= math.pi then
				aimAngle = 4*math.pi/6
			else
				aimAngle = 8*math.pi/6
			end
			arc = vec2.mul(vec2.rotate({1,0}, aimAngle - math.pi/2),5)
		end
		legStatus[leg].state = "attacking"
		self.attackLegShockwavePending = true
		self.legAttacking = false
		makeLegStack(leg, legStatus[leg].anchor, vec2.add(legBaseJoints[leg], vec2.rotate({maxRange, 0}, aimAngle)), 10, 10, arc, true)
	elseif action == "Update" then
		--world.logInfo("U: %s, %s, %s", aimPos, aimLength, aimAngle)
		self.legAttacking = true
		aimLength = math.max(math.min(aimLength/3, 1.6*params.legOverreach), 1.1*params.legOverreach)
		if string.sub(leg,1,1) == "l" then
			aimAngle = math.max(math.min(aimAngle, 10*math.pi/6), 5.5*math.pi/6) + angleAdjust
		else
			if aimAngle <= 0.5*math.pi/6 then
				aimAngle = aimAngle - angleAdjust
			elseif aimAngle >= 8*math.pi/6 then
				aimAngle = aimAngle - angleAdjust
			elseif aimAngle <= math.pi then
				aimAngle = 0.5*math.pi/6 - angleAdjust
			else
				aimAngle = 8*math.pi/6 - angleAdjust
			end
		end
		--world.logInfo("%s, %s -> %s", aimLength, aimAngle ,vec2.add(legBaseJoints[leg], vec2.rotate({aimLength, 0}, aimAngle)))
		world.debugLine(vec2.add(mcontroller.position(), legBaseJoints[leg]),vec2.add(mcontroller.position(), vec2.add(legBaseJoints[leg], vec2.rotate({aimLength, 0}, aimAngle))) , {0,200,0,255})
		if legStatus[leg].state ~= "attackReady" then 
			legStatus[leg].state = "attackReady" 
			makeLegStack(leg, legStatus[leg].anchor, vec2.add(legBaseJoints[leg], vec2.rotate({aimLength, 0}, aimAngle)), 30, 0, {0,0}, true)
		elseif #legStatus[leg].stack <= 1 then
			--world.logInfo("adjust")
			legStatus[leg].stack[1] = vec2.add(legBaseJoints[leg], vec2.rotate({aimLength, 0}, aimAngle))
		end
	end
end

function update(args)
	--world.logInfo("tech update")
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
end

function decrementTimers(dt)
	if self.deactivateTimer > 0 then self.deactivateTimer = self.deactivateTimer - dt end
	if self.pickupTimer > 0 then self.pickupTimer = self.pickupTimer - dt end
	if self.legAttackTimer > 0 then self.legAttackTimer = self.legAttackTimer - dt end
	for target,cd in pairs(self.laserBlacklist) do
		if cd - dt <= 0 then self.laserBlacklist[target] = nil else self.laserBlacklist[target] = cd - dt end
	end
	--world.logInfo("---Tick")
	--world.logInfo("-%s", self.takenItems)
	local newItems = world.getProperty("spiderMechItemDropList") or {}
	--world.logInfo("-%s", newItems)
	for id,item in pairs(newItems) do
		if self.takenItems[id] == nil then
			self.takenItems[id] = {["data"] = item.data, ["cd"] = item.cd}
		end
	end
	--world.logInfo("-%s", self.takenItems)
	for id,item in pairs(self.takenItems) do
		if item.cd <= 0 then 
			--world.logInfo("-Spawn: %s", item)
			world.spawnItem(item.data.name, mcontroller.position(), item.data.count, item.data.parameters)
			self.takenItems[id] = nil
		else
			self.takenItems[id] = {["data"] = item.data, ["cd"] = item.cd - dt}
		end
	end
	--world.logInfo("-%s", self.takenItems)
	world.setProperty("spiderMechItemDropList", {})	
	--world.logInfo("---Tock")
end

function findLandingZone()
	if not checkPoly(landingPoly, mcontroller.position()) and not world.liquidAt(vec2.add(mcontroller.position(), {0, -15.5})) then return false end
	for i=0,15 do
		local pos1 = checkPoly(customMovementParameters.standingPoly, vec2.add(mcontroller.position(), {0,-i}))
		local pos2 = world.liquidAt(vec2.add(mcontroller.position(), {0, -4-i+0.125*collisionBottom(customMovementParameters.standingPoly)}))
			world.debugLine(vec2.add(mcontroller.position(), {-1, -4-i+0.125*collisionBottom(customMovementParameters.standingPoly)}),vec2.add(mcontroller.position(), {1, -4-i+0.125*collisionBottom(customMovementParameters.standingPoly)}),{0,200,0,255})
		local pos3 = checkPoly(customMovementParameters.standingPoly, vec2.add(mcontroller.position(), {0,-i-1}))
		if not pos1 and (pos2 or pos3) then
			--world.logInfo(":: %s, %s, %s", pos1, pos2, pos3)
			if type(pos2) == "table" or checkPoly({{-0.75, -8}, {0.75,-8}, {0.75, 0}, {-0.75, 0}},  vec2.add(mcontroller.position(), {0,-i})) then
				return true
			else
				return false
			end
		end
	end
end

function smackImpactPoint(point)
	if self.isFrenzying then 
		world.spawnProjectile("spidermechstep", vec2.add(point, {0, -0.5}), entity.id(), {0,0}, false, {actionOnReap = {{action = "config", file = attackStats["frenziedStomp"]}}, power = 100})
	else
		world.spawnProjectile("spidermechstep", vec2.add(point, {0, -0.5}), entity.id(), {0,0}, false, {actionOnReap = {{action = "config", file = attackStats["normalStomp"]}}, power = 0})
	end
end

function legAttackShockwave(leg, rootPos, footPos, terminate)
	local tilesToDamage = {}
	local baseLine = world.distance(footPos, rootPos)
	local newPoints = {}
	for i = 0, params.lowerLegLength + 6 do
		local point = vec2.add(vec2.mul(baseLine, i/params.lowerLegLength), rootPos)
		table.insert(newPoints, point)
	end
	if type(self.storedPointsForLegShockwave) == "table" then
		for i, point1 in ipairs(self.storedPointsForLegShockwave) do
			local point2 = newPoints[i]
			local newLine = world.distance(point2, point1)
			
			local tempList = world.entityLineQuery(point1, point2, {notAnObject = true, withoutEntityId = entity.id()})
			for _,target in ipairs(tempList) do
				if self.legAttackBlacklist[target] == nil and 
				  (world.entityType(target) == "monster" or entity.isValidTarget(target)) then
					self.legAttackBlacklist[target] = true
					world.callScriptedEntity(target, "mcontroller.setVelocity", vec2.mul(newLine, 30))
					world.spawnProjectile("spiderlegswoosh", world.entityPosition(target), entity.id(), {0,0}, false, attackStats["legSwipe"])
				end
			end
			--world.logInfo("000 %s", newLine)
			local newLength = vec2.mag(newLine)
			--world.logInfo("111")
			if newLength > 0.5 then 
				local newNorm = vec2.norm(newLine)
				--world.logInfo("222")
				for n = 0, math.floor(newLength) do
					local damagePoint = vec2.add(point1, vec2.mul(newNorm, n))
					damagePoint = {math.floor(damagePoint[1]), math.floor(damagePoint[2])}
					table.insert(tilesToDamage, damagePoint)
				end
			end
		end
	end
	self.storedPointsForLegShockwave = newPoints
	if world.damageTiles(tilesToDamage, "foreground", mcontroller.position(), "beamish", 1000, 99) then
		world.spawnProjectile("spiderlegsound", footPos, entity.id(), {0,0}, false)
	end
	world.damageTiles(tilesToDamage, "background", mcontroller.position(), "plantish", 1, 99)
end

function transformPoly(toPoly)
  local position = mcontroller.position()
  local yAdjust = collisionBottom(mcontroller.collisionPoly()) - collisionBottom(toPoly)
  return world.resolvePolyCollision(toPoly, {position[1], position[2] + yAdjust}, 1)
end

function collisionBottom(collisionPoly)
  local lowest = 0
  for _,point in pairs(collisionPoly) do
    if point[2] < lowest then
      lowest = point[2]
    end
  end
  return lowest
end

function vec2.pureAngle(vector)
	local angle = math.atan2(vector[2], vector[1])
	if angle < 0 then angle = angle + 2 * math.pi end
	return angle
end

function uninit()
   deactivate()
end
