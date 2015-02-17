-- Randomized weapon script

function randomweapons(panel)
  self.weaponRarity = "common"
  self.weaponLevel = 1
  self.weaponClass = "assaultrifle"
  self.guntext = ""
  self.slider = Slider(75, 50, 120, 8, 1, 10, 1)
  
  local h = panel.height
  local pad = 5
  local pad2 = 14
  local padtop = 170
  local buttonH = 12
  local buttonW = 85
  local buttonPad1 = 35
  local buttonPad2 = 150
  self.label = Label(pad, pad, "", 8)
  local labelHead1 = Label(58, 185, "Gun Types", 8, "orange")
  local labelHead2 = Label(170, 185, "Gun Rarity", 8, "orange")
  self.labelHead3 = Label(112, 60, self.guntext, 8, "orange")

  -- Buttons for weapon classes. 
	-- Button 1
  local classButton1 = TextButton(buttonPad1, padtop, buttonW, buttonH, "Assault Rifle")
    classButton1.onClick = function()
    self.weaponClass = "assaultrifle"
  end
	-- Button 2
  local classButton2 = TextButton(buttonPad1, padtop - pad2, buttonW, buttonH, "Grenade Launcher")
    classButton2.onClick = function()
    self.weaponClass = "grenadelauncher"
  end
	-- Button 3
  local classButton3 = TextButton(buttonPad1, padtop - pad2 * 2, buttonW, buttonH, "Machine Pistol")
    classButton3.onClick = function()
    self.weaponClass = "machinepistol"
  end
	-- Button 4
  local classButton4 = TextButton(buttonPad1, padtop - pad2 * 3, buttonW, buttonH, "Pistol")
    classButton4.onClick = function()
    self.weaponClass = "pistol"
  end
	-- Button 5
  local classButton5 = TextButton(buttonPad1, padtop - pad2 * 4, buttonW, buttonH, "Rocket Launcher")
    classButton5.onClick = function()
    self.weaponClass = "rocketlauncher"
  end
	-- Button 6
  local classButton6 = TextButton(buttonPad1, padtop - pad2 * 5, buttonW, buttonH, "Shotgun")
    classButton6.onClick = function()
    self.weaponClass = "shotgun"
  end
	-- Button 7
  local classButton7 = TextButton(buttonPad1, padtop - pad2 * 6, buttonW, buttonH, "Sniper Rifle")
    classButton7.onClick = function()
    self.weaponClass = "sniperrifle"
  end
  
  -- Buttons for rarity levels
	-- Button 1
  local rarityButton1 = TextButton(buttonPad2, padtop, buttonW, buttonH, "Common")
    rarityButton1.onClick = function()
    self.weaponRarity = "common"
  end
	-- Button 2
  local rarityButton2 = TextButton(buttonPad2, padtop - pad2, buttonW, buttonH, "Uncommon")
    rarityButton2.onClick = function()
    self.weaponRarity = "uncommon"
  end
	-- Button 3
  local rarityButton3 = TextButton(buttonPad2, padtop - pad2 * 2, buttonW, buttonH, "Rare")
    rarityButton3.onClick = function()
    self.weaponRarity = "rare"
  end
	-- Button 4
  local rarityButton4 = TextButton(buttonPad2, padtop - pad2 * 3, buttonW, buttonH, "Legendary")
    rarityButton4.onClick = function()
    self.weaponRarity = "legendary"
  end
  
  -- Button for spawning the weapon
  local spawnButton = TextButton(180, pad, buttonW, buttonH, "Spawn weapon", "orange")
    spawnButton.onClick = function()
    self.weaponItem = self.weaponRarity .. self.weaponClass
    world.spawnItem("generatedgun", world.entityPosition(smm.sourceId()), 1, {level = self.weaponLevel, definition = self.weaponItem})
  end

  -- Spawn all the UI elements
  panel:add(classButton1)
  panel:add(classButton2)
  panel:add(classButton3)
  panel:add(classButton4)
  panel:add(classButton5)
  panel:add(classButton6)
  panel:add(classButton7)
  panel:add(rarityButton1)
  panel:add(rarityButton2)
  panel:add(rarityButton3)
  panel:add(rarityButton4)
  panel:add(self.slider)
  panel:add(spawnButton)
  panel:add(self.label)
  panel:add(labelHead1)
  panel:add(labelHead2)
  panel:add(self.labelHead3)
  return "Guns", {"Tags"}
end

function randomweaponsupdate()
    self.weaponLevel = self.slider.value
	self.labelText = "Gun type: " .. self.weaponClass .. "\nGun rarity: " .. self.weaponRarity .. "\nGun level: " .. self.weaponLevel
	self.label.text = self.labelText
	self.gunText = "Gun level (" .. self.weaponLevel .. ")"
	self.labelHead3.text = self.gunText
end

smm(randomweapons, randomweaponsupdate)
