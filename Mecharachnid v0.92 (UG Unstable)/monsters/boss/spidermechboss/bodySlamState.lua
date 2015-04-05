bodySlamState = {}

function bodySlamState.enter()
	if stateInTesting and stateInTesting ~= "bodySlam" then return nil end
	if not hasTarget() or self.sector == "spawnBox" then return nil end
	local dist = world.distance(world.entityPosition(self.targetId), mcontroller.position())
	if string.sub(self.sector, 1, 3) == string.sub(self.targetSector, 1, 3) and -9 <= dist[1] and dist[1] <= 9 and dist[2] < 0 then
		local wiggle = -6
		if math.random() <= 0.5 then wiggle = 6 end
		return {["dropTimer"] = 1.3, ["dropped"] = false, ["wiggle"] = wiggle}
	else
		return nil
	end
end

function bodySlamState.enterWith(args)
	if stateInTesting and stateInTesting ~= "bodySlam" then return nil end
	if not hasTarget() or self.sector == "spawnBox" then return nil end
	if not args.legAttack then return nil end
	local dist = world.distance(world.entityPosition(self.targetId), mcontroller.position())
	if string.sub(self.sector, 1, 3) == string.sub(self.targetSector, 1, 3) and -9 <= dist[1] and dist[1] <= 9 and dist[2] < 0 then
		return {["dropTimer"] = 1.2, ["dropped"] = false, ["smashed"] = false}
	else
		return nil
	end
end

function bodySlamState.enteringState(stateData)
	spoofInput.moves.down = false
	spoofInput.moves.up = true
end

function bodySlamState.update(dt, stateData)
	if stateData.dropTimer < 0 then
		return true
	elseif stateData.dropTimer < 0.4 and not stateData.dropped then
		spoofInput.moves.up = false
		if string.sub(self.sector,1,3) == "low" then
			spoofInput.moves.down = true
		end
		mcontroller.setYVelocity(-80)
		stateData.dropped = true
		world.spawnProjectile("spidermechBodySlam", mcontroller.position(), entity.id(), {0,0}, true, {timeToLive = 0.3, power = attackStats.bodySlam.power, level = attackStats.bodySlam.level})
	end
	if stateData.dropped and not stateData.smashed and math.abs(mcontroller.velocity()[2]) < 0.6 then
		entity.playSound("smashInto")
		world.spawnProjectile("spidermechBodySlamWave", vec2.add(mcontroller.position(), {-7,0}), entity.id(), {-5, 0}, false, {timeToLive = 0.3, power = attackStats.bodySlam.power, level = attackStats.bodySlam.level})
		world.spawnProjectile("spidermechBodySlamWave", vec2.add(mcontroller.position(), {7,0}), entity.id(), {5, 0}, false,  {timeToLive = 0.3, power = attackStats.bodySlam.power, level = attackStats.bodySlam.level})
		stateData.smashed = true
	end
	stateData.dropTimer = stateData.dropTimer - dt
end

function bodySlamState.leavingState(stateData)
	self.state.shuffleStates()
	spoofInput.moves.up = false
	self.bossHorizForce = 0
	if string.sub(self.sector,1,3) == "low" then
		spoofInput.moves.down = true
	else
		spoofInput.moves.down = false
	end
end