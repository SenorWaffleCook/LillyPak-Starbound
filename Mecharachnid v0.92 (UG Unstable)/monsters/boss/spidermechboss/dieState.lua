dieState = {}

function dieState.enterWith(args)
  if not args.die then return nil end
  return {
    timer = 3.0,
	dropTimer = 0.3
  }
end

function dieState.enteringState(stateData)
  debugPane = {["position"] = mcontroller.position()[1]}
  spoofInput = {
		["aimPosition"] = vec2.add(mcontroller.position(), {0,-5}), 
		["moves"] = {
			["special"] = 0, 
			["jump"] = false, 
			["up"] = false, 
			["down"] = false, 
			["left"] = false,
			["right"] = false,
			["primaryFire"] = false,
			["altFire"] = false
		}
	}
	entity.setAnimationState("frenzy", "frenzying")
	entity.setParticleEmitterActive("frenzying", true)
	entity.setParticleEmitterEmissionRate("frenzying", 50)
end

function dieState.update(dt, stateData)
  --world.logInfo("dying")
	--entity.burstParticleEmitter("frenzying")
  if stateData.dropTimer <= 0.0 then
	local dropPoint = vec2.add(mcontroller.position(), {math.random()*16-8, math.random()*6-3})
	world.spawnProjectile("zbomb", dropPoint, entity.id(), {0,0}, false, {timeToLive = 0.01, power = 0})
	for n=1,3 do
		local wreckVec = vec2.rotate({5,0}, math.random()*2*math.pi)
		world.spawnProjectile("mecharachnidwreckage", dropPoint, entity.id(), wreckVec)
	end
	--world.spawnItem("mecharachnidwreckage", dropPoint, 1)
	stateData.dropTimer = 0.3
  end
  if stateData.timer <= 0.0 then
    self.dead = true
	entity.setAnimationState("body", "bodyOnly")
	entity.setAnimationState("frenzy", "idle")
	deactivate()
	world.callScriptedEntity(self.doorSwitch, "output", true)
  end
  mcontroller.controlForce(vec2.rotate({300,0}, math.random()*2*math.pi))
  stateData.timer = stateData.timer - dt
  stateData.dropTimer = stateData.dropTimer - dt
  return false
end

function dieState.leavingState(stateData)
	
end