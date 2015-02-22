function init()
	----- Suit -----
	status.setPersistentEffects("heatprotectionTech", {{stat = "biomeheatImmunity", amount = 1}, {stat = "breathProtection", amount = 1}})
	
	-- Here we remove the invulnerability of the player on the Shipworld when he first equipps a suit
	world.setProperty("invinciblePlayers",false)
  
	No_Gravity_In_Space_init();
end

function uninit()
	status.clearPersistentEffects("heatprotectionTech")
end

function input(args)
	No_Gravity_In_Space_input(args);
end

function update(args)
	No_Gravity_In_Space_update(args);
end