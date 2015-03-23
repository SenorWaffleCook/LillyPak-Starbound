function Init_Suit_Life_Support ()

	-- Init for life support functions
	LS_init();
	madtulip.scan_intervall_time = 1;
	
	-- spawn a new main calculation thread
	co = coroutine.create(function ()
		-- Automatic Hull Breach Scans for all Vents in the Area
		main_threaded();
	 end)

end

function Update_Suit_Life_Support(dt)
	--main_threaded();
	if (coroutine.status(co) == "suspended") then
		-- start thread
		coroutine.resume(co);
	elseif (coroutine.status(co) == "dead") then
		-- spawn a new main calculation thread
		co = coroutine.create(function ()
			-- Automatic Hull Breach Scans for all Vents in the Area
			main_threaded();
		 end)
	elseif (coroutine.status(co) == "running") then
		-- nothing
	end
end

function main_threaded()
	-- only works on ship, not on planet
	if not is_shipworld() then return false end
	
	-- check scan results
	if (madtulip.Flood_Data_Matrix.Scan_Executed_Once) then
		if (madtulip.Flood_Data_Matrix ~= nil) then
			if (madtulip.Flood_Data_Matrix.Room_is_not_enclosed == 1) then
				-- in breached area
				status.addEphemeralEffect("madtulip_no_life_support");
			else
				-- none breached area
				if not madtulip.Flood_Data_Matrix.Vent_Found_In_Scanned_Area then
					-- but theres also no ventilation here
					status.addEphemeralEffect("madtulip_no_life_support");
				end
			end
		end
	end
	
	-- area scan
	if(os.time() >= madtulip.scan_time_last_executiong + madtulip.scan_intervall_time) then
		LS_Start_New_Room_Breach_Scan_preallocated_memory(mcontroller.position());
		madtulip.scan_time_last_executiong = os.time()
	end
end
