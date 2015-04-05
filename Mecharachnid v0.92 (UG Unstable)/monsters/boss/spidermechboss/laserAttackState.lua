laserAttackState = {}

--The mech's ranged attack
--Pokes for two seconds with a damageless targeting laser, then smokes the target down
--Extremely deadly, but gives time to get cover or get out of the firing angle

function laserAttackState.enter()
	if stateInTesting and  stateInTesting ~= "laserAttack" then return nil end
	if not hasTarget() or self.sector == "spawnBox" then return nil end
	
	if vec2.mag(world.distance(world.entityPosition(self.targetId), mcontroller.position())) > 8 and 
	  vec2.mag(world.distance(world.entityPosition(self.targetId), mcontroller.position())) < 85 and 
	  world.entityPosition(self.targetId)[2] - mcontroller.position()[2] < 1 then 
		return {}
	else
		return nil 
	end
end

function laserAttackState.enterWith(args)
	if stateInTesting and  stateInTesting ~= "laserAttack" then return nil end
	if not args.laserAttack then return nil end
	if not hasTarget() or self.sector == "spawnBox" then return nil end
	
	if vec2.mag(world.distance(world.entityPosition(self.targetId), mcontroller.position())) > 8 and 
	  vec2.mag(world.distance(world.entityPosition(self.targetId), mcontroller.position())) < 85 and 
	  world.entityPosition(self.targetId)[2] - mcontroller.position()[2] < 1 then 
		return {}
	else
		return nil 
	end
end

function laserAttackState.enteringState()
	debugPane = {["position"] = mcontroller.position()[1]}
	spoofInput.moves.left = false
	spoofInput.moves.right = false
	laserAttackState.timer = 0
end

function laserAttackState.update(dt, stateData)
	if not hasTarget() then 
		spoofInput.moves.primaryFire = false
		return true
	end
	
	if self.sector == "upper1" then 
		self.state.pickState({reposition = true, destination = "upper2", stack = {laserAttack = true}})
		spoofInput.moves.primaryFire = false
		return true
	elseif self.sector == "upper5" then
		self.state.pickState({reposition = true, destination = "upper4", stack = {laserAttack = true}})
		spoofInput.moves.primaryFire = false
		return true
	end
	
	local timer = laserAttackState.timer
	
	if timer > 6 then
		spoofInput.moves.primaryFire = false
		return true, 2
	elseif timer > 2 then 
		local gunAim = world.distance(world.entityPosition(self.targetId), vec2.add(mcontroller.position(), entity.anchorPoint("gunCenter")))
		--Don't bother continuing if the target is above me
		if vec2.pureAngle(gunAim) > 0.2 and vec2.pureAngle(gunAim) < math.pi-0.2 then 
			spoofInput.moves.primaryFire = false
			return true, 5 
		end
		spoofInput.moves.primaryFire = true
	else
		if math.floor((10*timer))%2 == 1 then
			spoofInput.moves.primaryFire = false
		else
			spoofInput.moves.primaryFire = true
		end
	end
	laserAttackState.timer = timer + dt
	
	return false
end

function laserAttackState.leavingState(stateData)
	self.state.shuffleStates()
	spoofInput.moves.primaryFire = false
end