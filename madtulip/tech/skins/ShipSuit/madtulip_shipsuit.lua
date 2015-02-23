function init()
	----- Suit -----
	status.setPersistentEffects("madtulip_shipsuit", {{stat = "madtulip_shipsuit", amount = 1}})
	
	-- Here we remove the invulnerability of the player on the Shipworld when he first equipps a suit
	world.setProperty("invinciblePlayers",false)
  
	No_Gravity_In_Space_init();
end

function uninit()
	status.clearPersistentEffects("madtulip_shipsuit")
end

function input(args)
	No_Gravity_In_Space_input(args);
end

function update(args)
	No_Gravity_In_Space_update(args);
end