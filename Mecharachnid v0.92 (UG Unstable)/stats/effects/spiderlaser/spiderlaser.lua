function init()
  if not effect.configParameter("noBurn") then
	  animator.setParticleEmitterOffsetRegion("flames", mcontroller.boundBox())
	  animator.setParticleEmitterActive("flames", true)
  end
  effect.setParentDirectives("fade=FF8800=0.2")
  
  script.setUpdateDelta(5)

  self.tickTime = effect.configParameter("tickTime")
  self.tickTimer = self.tickTime
  self.damage = effect.configParameter("tickDamage")

  status.applySelfDamageRequest({
      damageType = "IgnoresDef",
      damage = self.damage,
      sourceEntityId = entity.id()
    })
end

function update(dt)
  self.tickTimer = self.tickTimer - dt
  if self.tickTimer <= 0 then
    self.tickTimer = self.tickTime
    status.applySelfDamageRequest({
        damageType = "IgnoresDef",
        damage = self.damage,
        sourceEntityId = entity.id()
      })
  end
end

function uninit()
	if not effect.configParameter("noBurn") then
	status.addEphemeralEffect("burning")
	end
end