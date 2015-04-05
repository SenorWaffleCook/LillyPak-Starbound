repositionState ={}

--The general movement state
--This takes a start and a random/provided end sector, then determiens which way to circle build a path there
--It caan be set as "hostile" to look for targets on route, in which case it will interrput movement and try a melee attack
--Or it can be set "veryHostile", in which case it just rhows random punches

function repositionState.enter()
	--If not being called specifically, le'ts just go somewhere random
	if stateInTesting and stateInTesting ~= "reposition" then return nil end
	if self.sector == "spawnBox" then return nil end
	if self.sector == nil then updatePosition() end
	local goal = self.sector
	--random that isn't here of course
	while goal == self.sector or goal == self.targetSector do
		if math.random() <= 0.5 then
			goal = "upper"
		else
			goal = "lower"
		end
		goal = goal..tostring(math.random(5))
	end
	local hostile = false
	--and maybe we'll stop to punch people, maybe not
	if math.random() < 0.3 then hostile = true end
	local stateData = {["start"] = self.sector, ["goal"] = goal, ["target"] = self.targetSector, ["hostile"] = hostile} 
	return stateData
end

function repositionState.enterWith(args)
	if not args.reposition or self.sector == "spawnBox" then return nil end
	if self.sector == args.destination then return nil end
	return {["start"] = self.sector, ["goal"] = args.destination, ["target"] = self.targetSector, ["hostile"] = args.hostile, ["nextStateArgs"] = args.stack, ["veryHostile"] = args.veryHostile}
end

function repositionState.enteringState(stateData)	
	--world.logInfo("Reposition start: %s", stateData)
	local subSector = stateData.start
	local goal = stateData.goal
	local sectorPath1 = {}
	local sectorPath2 = {}
	--Finding a proper path, choose clockwise or counterclockwise whatever's shortest
	if self.sector == "upper1" then table.insert(sectorPath1, "upper1") end
	while subSector ~= goal do
		subSector = sectorClockwise[subSector]
		table.insert(sectorPath1, subSector)
	end
	if self.sector == "lower5" then table.insert(sectorPath2, "lower5") end
	
	subSector = stateData.start
	while subSector ~= goal do 
		subSector = sectorCounterClockwise[subSector]
		table.insert(sectorPath2, subSector)
	end

	if #sectorPath2 < #sectorPath1 then
		repositionState.currentPath = sectorPath2
	else
		repositionState.currentPath = sectorPath1	
	end
	
	if stateData.veryHostile then
		--entity.setParticleEmitterActive("frenzying", true)
	end
	
	repositionState.driveBySwipe = nil
	debugPane = {
		["start"] = {["text"] = stateData.start, ["X"] = 1, ["Y"] = 1},
		["goal"] = {["text"] = stateData.goal, ["X"] = 1, ["Y"] = 2},
		["hostile"] = {["text"] = tostring(stateData.hostile or "false"), ["X"] = 1, ["Y"] = 3},
		["veryHostile"] = {["text"] = tostring(stateData.veryHostile or "false"), ["X"] = 1, ["Y"] = 4},
		["hasStack"] = {["text"] = tostring(not not stateData.stack), ["X"] = 1, ["Y"] = 5},
		["position"] = mcontroller.position()[1]
		}
end

function repositionState.update(dt, stateData)
	--Basically, moving region to region
	if withinBounds(mcontroller.position(), sectorCenters[repositionState.currentPath[1]]) then
		table.remove(repositionState.currentPath, 1)
	end
	
	if #repositionState.currentPath > 0 then
		local goal = repositionState.currentPath[1]
		
		world.debugLine({sectorCenters[goal][1], sectorCenters[goal][2]}, {sectorCenters[goal][3],  sectorCenters[goal][4]}, {200,250,200,255})
		world.debugLine({sectorCenters[goal][1], sectorCenters[goal][4]}, {sectorCenters[goal][3],  sectorCenters[goal][2]}, {200,250,200,255})
		
		local pos = mcontroller.position()
		if pos[1] > sectorCenters[goal][3] then
			spoofInput.moves.left = true
			spoofInput.moves.right = false
		elseif pos[1] < sectorCenters[goal][1] then
			spoofInput.moves.left = false
			spoofInput.moves.right = true
		else
			spoofInput.moves.left = false
			spoofInput.moves.right = false
		end
		
		if pos[2] < sectorCenters[goal][2] then
			spoofInput.moves.jump = true
		else
			spoofInput.moves.jump = false
		end
		
		--Crouching on the bottom layer so the legs don't grab onto the top
		if string.sub(goal, 1, 3) == "low" then
			spoofInput.moves.down = true
		else
			spoofInput.moves.down = false
		end
	else
		spoofInput.moves.jump = false
		if string.sub(self.sector, 1, 3) == "low" then
			spoofInput.moves.down = true
		else
			spoofInput.moves.down = false
		end
		spoofInput.moves.left = false
		spoofInput.moves.right = false
		
		--If we have something to do next, do it
		if stateData.nextStateArgs ~= nil then			
			self.state.pickState(stateData.nextStateArgs) 
		end
		
		return true
	end
	
	--This is the "throw random punches" state
	if stateData.veryHostile then	
		if repositionState.driveBySwipe == nil then
			if spoofInput.moves.left then
				if string.sub(self.sector,1,3) == "low" then
					repositionState.driveBySwipe = {["target"] = vec2.rotate({-10,0}, math.pi/16 - math.random()*(math.pi/8)), ["timer"] = 1.0}
				else
					repositionState.driveBySwipe = {["target"] = vec2.rotate({-10,0}, math.pi/8 - math.random()*(math.pi/4)), ["timer"] = 1.0}
				end
			else
				if string.sub(self.sector,1,3) == "low" then
					repositionState.driveBySwipe = {["target"] = vec2.rotate({10,0}, math.pi/16 - math.random()*(math.pi/8)), ["timer"] = 1.0}
				else
					repositionState.driveBySwipe = {["target"] = vec2.rotate({10,0}, math.pi/8 - math.random()*(math.pi/4)), ["timer"] = 1.0}
				end
			end
			spoofInput.aimPosition = vec2.add(mcontroller.position(), repositionState.driveBySwipe.target)
			spoofInput.moves.altFire = true
		else
			spoofInput.aimPosition = vec2.add(mcontroller.position(), repositionState.driveBySwipe.target)
			if repositionState.driveBySwipe.timer < 0.5 then
				spoofInput.moves.altFire = false
			end
			if repositionState.driveBySwipe.timer < 0 then
				repositionState.driveBySwipe = nil
			else
				repositionState.driveBySwipe.timer = repositionState.driveBySwipe.timer  - dt
			end
		end
	end
	
	if stateData.hostile then
		self.state.pickState({legAttack = true})
	end
	
	return false
end

function repositionState.leavingState(stateData)
	self.state.shuffleStates()
	spoofInput.moves.jump = false
	if string.sub(self.sector, 1, 3) == "low" then
		spoofInput.moves.down = true
	else
		spoofInput.moves.down = false
	end
	spoofInput.moves.left = false
	spoofInput.moves.right = false
	if stateData.veryHostile then
		spoofInput.moves.altFire = false
	end
	repositionState.driveBySwipe = nil
end