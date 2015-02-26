function init()
  script.setUpdateDelta(5)

  self.tickTimer = 1
  self.degen = 0.05

  self.pulseTimer = 0
  self.halfPi = math.pi / 2
end

function update(dt)
  status.modifyResourcePercentage("energy", -self.degen * dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
	self.tickTimer = 1
	self.degen = self.degen + 0.01
	status.applySelfDamageRequest({
		damageType = "IgnoresDef",
		damage = self.degen * status.resourceMax("health"),
		sourceEntityId = entity.id()
	  })
  end
  
  self.pulseTimer = self.pulseTimer + dt * 5
  if self.pulseTimer >= math.pi then
	self.pulseTimer = self.pulseTimer - math.pi
  end
  local pulseMagnitude = math.floor(math.cos(self.pulseTimer - self.halfPi) * 16) / 16
  effect.setParentDirectives("fade=AA00AA="..pulseMagnitude * 0.4 + 0.2)
end

function uninit()

end