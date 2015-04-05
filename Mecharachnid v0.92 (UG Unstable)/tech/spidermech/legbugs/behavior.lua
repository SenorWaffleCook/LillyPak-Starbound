spiderMechActiveStats = {
{stat = "biomeheatImmunity", amount = 1}, 
{stat = "breathProtection", amount = 1},
{stat = "biomecoldImmunity", amount = 1}, 
{stat = "biomeradiationImmunity", amount = 1}, 
{stat = "poisonImmunity", amount = 1}, 
{stat = "fireImmunity", amount = 1}, 
{stat = "lavaImmunity", amount = 1}, 
{stat = "biomeheatImmunity", amount = 1}, 
}

function init(args)
	self.dead = false
	entity.setDamageOnTouch(false)
    entity.setAggressive(false)
	self.visible = false
	silenceTime = 0
	status.addPersistentEffects("spiderMechActive", spiderMechActiveStats)
end

function update(args)
	if silenceTime > 10 then
		kill()
	elseif silenceTime > 2 then
		if self.visible then 
			entity.setAnimationState("body", "off") 
			self.visible = false
		end
		silenceTime = silenceTime + 1
	else
		silenceTime = silenceTime + 1
	end
end

function takeItems(min, max, playerID)
	--world.logInfo("--Bug is taking")
	local itemList = {}
	local foundItemDrops = world.entityQuery(min, max)
	for _,item in ipairs(foundItemDrops) do
		local data = world.takeItemDrop(item, playerID)
		if data and itemList[item] == nil then
			local cd = vec2.mag(world.distance(world.entityPosition(item), world.entityPosition(playerID)))/35
			itemList[item] = {["data"] = data, ["cd"] = cd}
		end
	end
	--world.logInfo("--%s", itemList)
	world.setProperty("spiderMechItemDropList", itemList)
	--world.logInfo("--Bug has Taken")
end

function moveLeg(footPos, jointPos, rootPos, newVelocity, chassisMotion)
	--world.logInfo("Yes Hello this is bug, %s", jointPos)
	mcontroller.controlFace(1)
	mcontroller.setPosition(vec2.add(jointPos, entity.anchorPoint("body")))
	mcontroller.setVelocity(newVelocity)
	local legLine = world.distance(footPos, jointPos)
	local legAngle = vec2.pureAngle(legLine)
	entity.rotateGroup("lowerLegGroup", legAngle, true)

	if not self.visible then 
		entity.setAnimationState("body", "idle")
		self.visible = true
	end
	silenceTime = 0
	
	if rootPos ~= nil then
		legLine = world.distance(rootPos, jointPos)
		legAngle = vec2.pureAngle(legLine)
		entity.rotateGroup("upperLegGroup", legAngle, true)
	end
end

function kill()
	entity.setAnimationState("body", "off")
	--world.logInfo("Killspawn: %s", world.spawnMonster("moontant", mcontroller.position()))
	self.dead = true
end

function shouldDie()
  return self.dead
end

function damage(args)

end

function vec2.pureAngle(vector)
	local angle = math.atan2(vector[2], vector[1])
	if angle < 0 then angle = angle + 2 * math.pi end
	return angle
end