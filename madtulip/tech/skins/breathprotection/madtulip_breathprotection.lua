function init()
	----- Suit -----
	status.setPersistentEffects("breathprotectionTech", {{stat = "breathProtection", amount = 1}})
	
	-- Here we remove the invulnerability of the player on the Shipworld when he first equipps a suit
	world.setProperty("invinciblePlayers",false)
	
	-- checks if player should be floating and receive damage in space
	No_Gravity_In_Space_init();
	
	-- checks if player should suffocate or if a life support system is in his room
	Init_Suit_Life_Support();
end

function uninit()
	status.clearPersistentEffects("breathprotectionTech")
end

function input(args)
	No_Gravity_In_Space_input(args);
end

function update(dt)
	No_Gravity_In_Space_update(dt);

	Update_Suit_Life_Support(dt);
end