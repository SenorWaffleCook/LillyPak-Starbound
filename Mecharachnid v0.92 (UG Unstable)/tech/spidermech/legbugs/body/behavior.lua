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
	justSpawned = 30
	status.addPersistentEffects("spiderMechActive", spiderMechActiveStats)
end

function update(args)
	if justSpawned > 0 then
		justSpawned = justSpawned - 1
	elseif justSpawned  == 0 then
		kill()
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

function moveBody(position, newVelocity, chassisMotion)
	justSpawned = -1
	mcontroller.setPosition(position)
	mcontroller.setVelocity(newVelocity)tateGroup("upperLegGroup", legAngle, true)
end

function kill()
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