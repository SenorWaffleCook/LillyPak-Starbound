function init(args)
	entity.setDeathParticleBurst("deathPoof")
	--entity.setAnimationState("movement", "idle")
	self.health = 100 -- entity.health()
end

function shouldDie()
	--if entity.health() <= 0 then return true end
	if self.health <= 0 then return true end

	return false
end

function damage(args)
	-- this is a workaround as i couldnt figure out how to damage only this monster by the fire extinguisher weapon
	if (args.sourceKind == "fire_extinguisher") then
		self.health = self.health - args.damage
	end
end


function update(dt)
--[[
  local masterId, minionIndex, minionTimer = findMaster()
  if masterId ~= 0 then
    self.hadMaster = true

    local angle = ((minionIndex - 1) * math.pi / 2.0) + minionTimer
    local target = vec2.add(world.entityPosition(masterId), {
      20.0 * math.cos(angle),
      8.0 * math.sin(angle)
    })

    entity.flyTo(target, true)
  else
    self.hadMaster = false

    entity.fly({0,0}, true)
  end

  util.trackTarget(30.0, 10.0)

  if self.targetPosition ~= nil then
    entity.setFireDirection({0,0}, world.distance(self.targetPosition, entity.position()))
    entity.startFiring("plasmabullet")
  else
    entity.stopFiring()
  end
  --]]
end