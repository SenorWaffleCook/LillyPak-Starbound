frenzyFallState = {}

--The grand introduction!
--Turns tile protection off briefly and frenzies down through the ceiling
--Then dances a bit to show off :D

function frenzyFallState.enter()
	if not hasTarget() then return nil end
	if self.sector == "spawnBox" then return true else return nil end
end

function frenzyFallState.enteringState(stateData)
	debugPane = {
		["position"] = mcontroller.position()[1]
		} 
	local dungeon = world.dungeonId(mcontroller.position())
	world.setTileProtection(dungeon, false)
	frenzyFallState.falling = true
	frenzyFallState.timer = nil
	world.callScriptedEntity(self.doorSwitch, "output", false)
end

function frenzyFallState.update(dt, stateData)
	if frenzyFallState.falling and mcontroller.position()[2] < 846 then 
		spoofInput.moves.left = false
		spoofInput.moves.right = false
		local dungeon = world.dungeonId(mcontroller.position())
		world.setTileProtection(dungeon, true)
		frenzyFallState.falling = false
		frenzyFallState.timer = 3
	elseif frenzyFallState.timer ~= nil and frenzyFallState.timer < 0 then
		return true
	else
		if frenzyFallState.timer ~= nil then
			frenzyFallState.timer = frenzyFallState.timer - dt
		end
		spoofInput.moves.left = true
		spoofInput.moves.right = true
	end
	return false
end

function frenzyFallState.leavingState(stateData)
	debugPane = {}
	local dungeon = world.dungeonId(mcontroller.position())
	world.setTileProtection(dungeon, true)
	spoofInput.moves.left = false
	spoofInput.moves.right = false
end