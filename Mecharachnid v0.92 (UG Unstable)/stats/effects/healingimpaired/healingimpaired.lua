function init()
  animator.setParticleEmitterOffsetRegion("unhealing", mcontroller.boundBox())
  animator.setParticleEmitterEmissionRate("unhealing", effect.configParameter("emissionRate", 3))
  animator.setParticleEmitterActive("unhealing", false)

  script.setUpdateDelta(2)
  healingCap = effect.configParameter("healCap")
  storedHealth = status.resource("health")
end

function update(dt)
  local newHealth = status.resource("health")
  local maxDelta = healingCap * dt
  local hDelta = newHealth - storedHealth
  --world.logInfo("Heal impair: %s, %s, %s, %s", storedHealth, newHealth, maxDelta, hDelta)
  if hDelta > maxDelta then
	animator.burstParticleEmitter("unhealing")
	status.modifyResource("health", storedHealth + maxDelta - newHealth)
  end
  storedHealth = status.resource("health")
end

function uninit()
  
end