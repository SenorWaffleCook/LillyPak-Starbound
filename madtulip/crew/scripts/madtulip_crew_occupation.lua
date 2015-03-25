function Set_Occupation(Occupation)
	if Occupation == nil then return nil end
	
	if     Occupation == "Engineer" then
		-- Engineer
		storage.Occupation = "Engineer";
		entity.say("Yes SIR! Working as " .. Occupation .."!")
		Set_Occupation_Cloth()
		Set_Commands_based_on_occupation()
		return true
	elseif Occupation == "Medic" then
		-- Medic
		storage.Occupation = "Medic";
		entity.say("Yes SIR! Working as " .. Occupation .. "!")
		Set_Occupation_Cloth()
		Set_Commands_based_on_occupation()
		return true
	elseif Occupation == "Scientist" then
		-- Scientist
		storage.Occupation = "Scientist";
		entity.say("Yes SIR! Working as " .. Occupation .. "!")
		Set_Occupation_Cloth()
		Set_Commands_based_on_occupation()
		return true
	elseif Occupation == "Marine" then
		-- Marine
		storage.Occupation = "Marine";
		entity.say("Yes SIR! Working as " .. Occupation .. "!")
		Set_Occupation_Cloth()
		Set_Commands_based_on_occupation()
		return true
	elseif Occupation == "Deckhand" then
		-- None
		storage.Occupation = "Deckhand";
		entity.say("Working as a simple Deckhand, SIR!")
		Set_Occupation_Cloth()
		Set_Commands_based_on_occupation()
		return true
	else
		entity.say("What kind of job is that!?, SIR!")
		return nil
	end
	
	return nil
end

function Set_Occupation_Cloth()
	if storage.Occupation == nil then return nil end
	if     storage.Occupation == "Engineer" then
		-- Engineer
		--entity.setItemSlot("primary", nil)
		--entity.setItemSlot("alt", nil)
		entity.setItemSlot("chest", {name = "madtulip_" .. entity.species() .. "_engineer_chest", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("legs" , {name = "madtulip_" .. entity.species() .. "_engineer_pants", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("back" , {name = "madtulip_spacesuit_back", data ={ colorIndex = storage.colorIndex }})
		return true
	elseif storage.Occupation == "Medic" then
		-- Medic
		--entity.setItemSlot("primary", nil)
		--entity.setItemSlot("alt", nil)
		entity.setItemSlot("chest", {name = "madtulip_" .. entity.species() .. "_medical_chest", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("legs" , {name = "madtulip_" .. entity.species() .. "_medical_pants", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("back" , {name = "madtulip_spacesuit_back", data ={ colorIndex = storage.colorIndex }})
		return true
	elseif storage.Occupation == "Scientist" then
		-- Scientist
		--entity.setItemSlot("primary", nil)
		--entity.setItemSlot("alt", nil)
		entity.setItemSlot("chest", {name = "madtulip_" .. entity.species() .. "_science_chest", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("legs" , {name = "madtulip_" .. entity.species() .. "_science_pants", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("back" , {name = "madtulip_spacesuit_back", data ={ colorIndex = storage.colorIndex }})
		return true
	elseif storage.Occupation == "Marine" then
		-- Marine
		--entity.setItemSlot("primary", nil)
		--entity.setItemSlot("alt", nil)
		entity.setItemSlot("chest", {name = "madtulip_" .. entity.species() .. "_marine_chest", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("legs" , {name = "madtulip_" .. entity.species() .. "_marine_pants", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("back" , {name = "madtulip_spacesuit_back", data ={ colorIndex = storage.colorIndex }})
		return true
	elseif storage.Occupation == "Deckhand" then
		-- None
		--entity.setItemSlot("primary", nil)
		--entity.setItemSlot("alt", nil)
		entity.setItemSlot("chest", {name = "madtulip_" .. entity.species() .. "_deckhand_chest", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("legs" , {name = "madtulip_" .. entity.species() .. "_deckhand_pants", data ={ colorIndex = storage.colorIndex }})
		entity.setItemSlot("back" , {name = "madtulip_spacesuit_back", data ={ colorIndex = storage.colorIndex }})
		return true
	else
		entity.say("What kind of job is that!?, SIR!")
		return nil
	end
	
	return nil
end

function Set_Commands_based_on_occupation()
	if storage.Occupation == nil then return nil end
	if     storage.Occupation == "Engineer" then
		-- Engineer
		storage.Command_Texts = {}
		storage.Command_Perform = {}
		storage.Command_Task_Name = {}
		storage.Command_Texts[1] = "Fixing hull breaches, SIR!"
		storage.Command_Perform[1] = true
		storage.Command_Task_Name[1] = "Fix_Hull_Breach"
		return true
	elseif storage.Occupation == "Medic" then
		-- Medic
		storage.Command_Texts = {}
		storage.Command_Perform = {}
		storage.Command_Task_Name = {}
		storage.Command_Texts[1] = "Healing the crew, SIR!"
		storage.Command_Perform[1] = true
		storage.Command_Task_Name[1] = "Heal_Player" -- both player and NPC have the same Task name atm
		return true
	elseif storage.Occupation == "Scientist" then
		-- Scientist
		storage.Command_Texts = {}
		storage.Command_Perform = {}
		storage.Command_Task_Name = {}
		storage.Command_Texts[1] = "Not available."
		storage.Command_Perform[1] = false
		storage.Command_Task_Name[1] = ""
		return true
	elseif storage.Occupation == "Marine" then
		-- Marine
		storage.Command_Texts = {}
		storage.Command_Perform = {}
		storage.Command_Task_Name = {}
		storage.Command_Texts[1] = "Not available."
		storage.Command_Perform[1] = false
		storage.Command_Task_Name[1] = ""
		return true
	elseif storage.Occupation == "Deckhand" then
		-- None
		storage.Command_Texts = {}
		storage.Command_Perform = {}
		storage.Command_Task_Name = {}
		storage.Command_Texts[1] = "Not available."
		storage.Command_Perform[1] = false
		storage.Command_Task_Name[1] = ""
		return true
	else
		entity.say("What kind of job is that!?, SIR!")
		return nil
	end
	
	return nil
end

function Toggle_Commands_based_on_occupation(command_nr)
	if storage.Occupation == nil then return nil end
	if     storage.Occupation == "Engineer" then
		-- Engineer
		if (command_nr == 1) then
			if (storage.Command_Perform[command_nr] == true) then
				storage.Command_Perform[command_nr] = false
				storage.Command_Texts[command_nr] = "NOT fixing hull breaches, SIR!"
				entity.say(storage.Command_Texts[command_nr])
				return true
			else
				storage.Command_Perform[command_nr] = true
				storage.Command_Texts[command_nr] = "Fixing hull breaches, SIR!"				
				entity.say(storage.Command_Texts[command_nr])
				return true
			end
		-- elseif here for other commands
		end
		return false
	elseif storage.Occupation == "Medic" then
		-- Medic
		if (command_nr == 1) then
			if (storage.Command_Perform[command_nr] == true) then
				storage.Command_Perform[command_nr] = false
				storage.Command_Texts[command_nr] = "NOT healing the crew, SIR!"
				entity.say(storage.Command_Texts[command_nr])
				return true
			else
				storage.Command_Perform[command_nr] = true
				storage.Command_Texts[command_nr] = "Healing the crew, SIR!"
				entity.say(storage.Command_Texts[command_nr])
				return true
			end
		-- elseif here for other commands
		end
		return false
	elseif storage.Occupation == "Scientist" then
		-- Scientist
		return false
	elseif storage.Occupation == "Marine" then
		-- Marine
		return false
	elseif storage.Occupation == "Deckhand" then
		-- None
		return false
	else
		return false
	end
	
	return false
end