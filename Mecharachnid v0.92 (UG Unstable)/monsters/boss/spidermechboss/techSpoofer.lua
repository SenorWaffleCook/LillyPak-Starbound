tech = {}
spoofInput = {
	["aimPosition"] = {0,0}, 
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
function tech.parameter(parameter)
	return entity.configParameter(parameter)
end
function tech.animationState(stateName)
	return entity.animationState(stateName)
end
function tech.setAnimationState(stateName, stateType)
	return entity.setAnimationState(stateName, stateType)
end
function tech.currentRotationAngle(group)
	return entity.currentRotationAngle(group)
end
function tech.rotateGroup(name, angle, instant)
	return entity.rotateGroup(name, angle, instant)
end
function tech.scaleGroup(group, scale)
	return entity.scaleGroup(group, scale)
end
function tech.anchorPoint(anchor)
	return entity.anchorPoint(anchor)
end
function tech.appliedOffset()
	return entity.appliedOffset()
end
function tech.setLightActive(light, active)
	return entity.setLightActive(light, active)
end
function tech.setLightPointAngle(light, angle)
	return entity.setLightPointAngle(light, angle)
end
function tech.playSound(sound)
	return entity.playSound(sound)
end
function tech.consumeTechEnergy(energy)
	return true
end
function tech.setParticleEmitterActive(emitter, active)
	return entity.setParticleEmitterActive(emitter, active)
end
function tech.setParticleEmitterOffsetRegion(emitter, bounds)
	return entity.setParticleEmitterOffsetRegion(emitter, bounds)
end
function tech.setParticleEmitterEmissionRate(emitter, rate)
	return entity.setParticleEmitterEmissionRate(emitter, rate)
end
function tech.setVisible()
	return true
end
function tech.setParentState()
	return true
end
function tech.setToolUsageSuppressed()
	return true
end
function tech.setParentOffset()
	return true
end
function tech.setParentDirectives()
	return true
end
function tech.aimPosition()
	return spoofInput.aimPosition or mcontroller.position()
end


