-- Randomized weapon script

function miscweapons(panel)
  self.miscLevel = 1
  self.miscClass = "avianblaster"
  self.miscText = ""
  self.miscSlider = Slider(75, 50, 120, 8, 1, 10, 1)
  
  local h = panel.height
  local pad = 5
  local pad2 = 14
  local padtop = 170
  local buttonH = 12
  local buttonW = 85
  local buttonPad1 = 5
  local buttonPad2 = 95
  local buttonPad3 = 185
  self.miscLabel = Label(pad, pad, "", 8)
  local misclabelHead2 = Label(120, 185, "Gun Type", 8, "orange")
  self.misclabelHead3 = Label(112, 60, self.miscText, 8, "orange")

  -- Buttons for weapon classes (row 1). 
	-- Button 1
  local classButtonM1 = TextButton(buttonPad1, padtop, buttonW, buttonH, "Avian Blaster")
    classButtonM1.onClick = function()
    self.miscClass = "avianblaster"
  end
	-- Button 2
  local classButtonM2 = TextButton(buttonPad1, padtop - pad2, buttonW, buttonH, "Avian Heavy Blaster")
    classButtonM2.onClick = function()
    self.miscClass = "avianheavyblaster"
  end
	-- Button 3
  local classButtonM3 = TextButton(buttonPad1, padtop - pad2 * 2, buttonW, buttonH, "Bone Rifle")
    classButtonM3.onClick = function()
    self.miscClass = "boneassault"
  end
	-- Button 4
  local classButtonM4 = TextButton(buttonPad1, padtop - pad2 * 3, buttonW, buttonH, "Bone Pistol")
    classButtonM4.onClick = function()
    self.miscClass = "bonepistol"
  end
	-- Button 5
  local classButtonM5 = TextButton(buttonPad1, padtop - pad2 * 4, buttonW, buttonH, "Bone Shotgun")
    classButtonM5.onClick = function()
    self.miscClass = "boneshotgun"
  end
	-- Button 6
  local classButtonM6 = TextButton(buttonPad1, padtop - pad2 * 5, buttonW, buttonH, "Cell Zapper")
    classButtonM6.onClick = function()
    self.miscClass = "cellzapper"
  end
	-- Button 7
  local classButtonM7 = TextButton(buttonPad1, padtop - pad2 * 6, buttonW, buttonH, "Crossbow")
    classButtonM7.onClick = function()
    self.miscClass = "crossbow"
  end
  
  -- Buttons for weapon classes (row 2).
	-- Button 1
  local classButtonM8 = TextButton(buttonPad2, padtop, buttonW, buttonH, "Crossbow - Special")
    classButtonM8.onClick = function()
    self.miscClass = "crossbowspecial"
  end
	-- Button 2
  local classButtonM9 = TextButton(buttonPad2, padtop - pad2, buttonW, buttonH, "Crossbow - Wood")
    classButtonM9.onClick = function()
    self.miscClass = "crossbowwood"
  end
	-- Button 3
  local classButtonM10 = TextButton(buttonPad2, padtop - pad2 * 2, buttonW, buttonH, "Flamethrower")
    classButtonM10.onClick = function()
    self.miscClass = "flamethrower"
  end
	-- Button 4
  local classButtonM11 = TextButton(buttonPad2, padtop - pad2 * 3, buttonW, buttonH, "Floran Gren. Launcher")
    classButtonM11.onClick = function()
    self.miscClass = "florangrenadelauncher"
  end
	-- Button 5
  local classButtonM12 = TextButton(buttonPad2, padtop - pad2 * 4, buttonW, buttonH, "Floran Needler")
    classButtonM12.onClick = function()
    self.miscClass = "floranneedler"
  end
	-- Button 6
  local classButtonM13 = TextButton(buttonPad2, padtop - pad2 * 5, buttonW, buttonH, "Globe Launcher")
    classButtonM13.onClick = function()
    self.miscClass = "globelauncher"
  end
	-- Button 7
  local classButtonM14 = TextButton(buttonPad2, padtop - pad2 * 6, buttonW, buttonH, "Lightning Coil")
    classButtonM14.onClick = function()
    self.miscClass = "lightningcoil"
  end
  
  -- Buttons for weapon classes (row 3)
	-- Button 1
  local classButtonM15 = TextButton(buttonPad3, padtop, buttonW, buttonH, "Pulse Rifle")
    classButtonM15.onClick = function()
    self.miscClass = "pulserifle"
  end
	-- Button 2
  local classButtonM16 = TextButton(buttonPad3, padtop - pad2, buttonW, buttonH, "Revolver")
    classButtonM16.onClick = function()
    self.miscClass = "revolver"
  end
  	-- Button 3
  local classButtonM17 = TextButton(buttonPad3, padtop - pad2 * 2, buttonW, buttonH, "Shatter Gun")
    classButtonM17.onClick = function()
    self.miscClass = "shattergun"
  end
	-- Button 4
  local classButtonM18 = TextButton(buttonPad3, padtop - pad2 * 3, buttonW, buttonH, "Stinger Gun")
    classButtonM18.onClick = function()
    self.miscClass = "stingergun"
  end
	-- Button 5
  local classButtonM19 = TextButton(buttonPad3, padtop - pad2 * 4, buttonW, buttonH, "Uzi")
    classButtonM19.onClick = function()
    self.miscClass = "uzi"
  end
  
  
  -- Button for spawning the weapon
  local spawnButton3 = TextButton(180, pad, buttonW, buttonH, "Spawn weapon", "orange")
    spawnButton3.onClick = function()
    world.spawnItem("generatedgun", world.entityPosition(smm.sourceId()), 1, {level = self.miscLevel, definition = self.miscClass})
  end

  -- Spawn all the UI elements
  panel:add(classButtonM1)
  panel:add(classButtonM2)
  panel:add(classButtonM3)
  panel:add(classButtonM4)
  panel:add(classButtonM5)
  panel:add(classButtonM6)
  panel:add(classButtonM7)
  panel:add(classButtonM8)
  panel:add(classButtonM9)
  panel:add(classButtonM10)
  panel:add(classButtonM11)
  panel:add(classButtonM12)
  panel:add(classButtonM13)
  panel:add(classButtonM14)
  panel:add(classButtonM15)
  panel:add(classButtonM16)
  panel:add(classButtonM17)
  panel:add(classButtonM18)
  panel:add(classButtonM19)
  panel:add(self.miscSlider)
  panel:add(spawnButton3)
  panel:add(self.miscLabel)
  panel:add(misclabelHead2)
  panel:add(self.misclabelHead3)
  return "Misc. Guns", {"Tags"}
end

function miscweaponsupdate()
    self.miscLevel = self.miscSlider.value
	self.misclabelText = "Gun type: " .. self.miscClass .. "\nGun level: " .. self.miscLevel
	self.miscLabel.text = self.misclabelText
	self.miscText = "Gun level (" .. self.miscLevel .. ")"
	self.misclabelHead3.text = self.miscText
end

smm(miscweapons, miscweaponsupdate)
