legAttackState = {}

--The basic melee attack
--Stops and ams for a second to let the player try and dodge

function legAttackState.enterWith(args)
	if not args.legAttack or not hasTarget() then return nil end
	local targetPos = world.entityPosition(self.targetId)

	--Since the leg attack sweep adjusts its arc a fair amount - arcing down, mostly, to look better and prevent bas cases of invalid ened points -  the boss needs to correct for that.
	--As a tech, that's up to the player to do, but need hard numerics here!
	local swipeAdjust = {0,0}
	if world.distance(targetPos, mcontroller.position())[1] < 0 then
		swipeAdjust[1] = -1
	elseif	world.distance(targetPos, mcontroller.position())[1] >= 0 then
		swipeAdjust[1] = 1
	end
	if world.distance(targetPos, mcontroller.position())[2] < -8 then
		swipeAdjust[2] = 1
	elseif  world.distance(targetPos, mcontroller.position())[2] < -2 then
		swipeAdjust[2] = 2
	elseif  world.distance(targetPos, mcontroller.position())[2] > 3 then
		swipeAdjust[1] = -swipeAdjust[1]
		swipeAdjust[2] = 2
	else
		swipeAdjust[1] = -swipeAdjust[1]
		swipeAdjust[2] = 2
	end
	targetPos = vec2.add(targetPos, swipeAdjust)
	
	local aimPos = world.distance(targetPos, mcontroller.position())
	local distance = vec2.mag(aimPos)
	
	world.debugLine(vec2.add(mcontroller.position(), vec2.mul(vec2.norm(aimPos), 1.5*params.legOverreach)), vec2.add(mcontroller.position(),
    	vec2.mul(vec2.norm(aimPos), 1.1*(params.lowerLegLength+params.upperLegLength))), "green")
	
	if distance < 1.1*(params.lowerLegLength+params.upperLegLength) and
	  distance > 1.6*params.legOverreach and
	  aimPos[1] < 0.7*(params.lowerLegLength+params.upperLegLength) 
	  then
		return {["targetPos"] = targetPos, ["phase"] = currentBossPhase or 4}
	else
		return nil
	end
end

function legAttackState.autoPickState()
	return true
end	

function legAttackState.enteringState(stateData)
	local attackVector = world.distance(stateData.targetPos, mcontroller.position())
	debugPane = {
		["targetPos"] = {["text"] = tostring(stateData.targetPos[1])..","..tostring(stateData.targetPos[2]), ["X"] = 1, ["Y"] = 1},
		["attackVector"] = {["text"] = tostring(attackVector[1])..","..tostring(attackVector[2]), ["X"] = 1, ["Y"] = 2},
		["phaseTimer"] = {["text"] = tostring(stateData.phase).." ,"..tostring(bossPhases[stateData.phase].legAimTime), ["X"] = 1, ["Y"] = 3},
		["position"] = mcontroller.position()[1]
		}
	legAttackState.timer = 0
	legAttackState.isWindup = true
	spoofInput.moves.altFire = true
	spoofInput.moves.left = false
	spoofInput.moves.right = false
	spoofInput.aimPosition = stateData.targetPos
end

function legAttackState.update(dt, stateData)
	world.debugLine(mcontroller.position(), stateData.targetPos, "green")
	spoofInput.aimPosition = stateData.targetPos
	if legAttackState.timer < bossPhases[stateData.phase].legAimTime then
	elseif legAttackState.isWindup then
		spoofInput.moves.altFire = false
		legAttackState.isWindup = false
	elseif legAttackState.timer > bossPhases[stateData.phase].legAimTime + 0.5 then 
		return true
	end	
	legAttackState.timer = legAttackState.timer + dt
end

function legAttackState.leavingState(stateData)
	self.state.shuffleStates()
	spoofInput.moves.altFire = false
end