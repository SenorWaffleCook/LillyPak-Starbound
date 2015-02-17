-- Randomized weapon script

function randomplasma(panel)
  self.plasmaRarity = "common"
  self.plasmaLevel = 1
  self.plasmaClass = "plasmaassaultrifle"
  self.plasmaText = ""
  self.plasmaSlider = Slider(75, 70, 120, 8, 1, 10, 1)
  
  local h = panel.height
  local pad = 5
  local pad2 = 14
  local padtop = 170
  local buttonH = 12
  local buttonW = 100
  local buttonPad1 = 35
  local buttonPad2 = 150
  local buttonLess = 15
  self.plasmaLabel = Label(pad, pad, "", 8)
  local plasmalabelHead1 = Label(65, 185, "Gun Types", 8, "orange")
  local plasmalabelHead2 = Label(170, 185, "Gun Rarity", 8, "orange")
  self.plasmalabelHead3 = Label(112, 80, self.plasmaText, 8, "orange")

  -- Buttons for weapon classes. 
	-- Button 1
  local classButtonP1 = TextButton(buttonPad1, padtop, buttonW, buttonH, "Plasma Assault Rifle")
    classButtonP1.onClick = function()
    self.plasmaClass = "plasmaassaultrifle"
  end
	-- Button 2
  local classButtonP2 = TextButton(buttonPad1, padtop - pad2, buttonW, buttonH, "Plasma Machine Pistol")
    classButtonP2.onClick = function()
    self.plasmaClass = "plasmamachinepistol"
  end
	-- Button 3
  local classButtonP3 = TextButton(buttonPad1, padtop - pad2 * 2, buttonW, buttonH, "Plasma Pistol")
    classButtonP3.onClick = function()
    self.plasmaClass = "plasmapistol"
  end
	-- Button 4
  local classButtonP4 = TextButton(buttonPad1, padtop - pad2 * 3, buttonW, buttonH, "Plasma Shotgun")
    classButtonP4.onClick = function()
    self.plasmaClass = "plasmashotgun"
  end
	-- Button 5
  local classButtonP5 = TextButton(buttonPad1, padtop - pad2 * 4, buttonW, buttonH, "Plasma Sniper Rifle")
    classButtonP5.onClick = function()
    self.plasmaClass = "plasmasniperrifle"
  end
  
  -- Buttons for rarity levels
	-- Button 1
  local rarityButtonP1 = TextButton(buttonPad2, padtop, buttonW - buttonLess, buttonH, "Common")
    rarityButtonP1.onClick = function()
    self.plasmaRarity = "common"
  end
	-- Button 2
  local rarityButtonP2 = TextButton(buttonPad2, padtop - pad2, buttonW - buttonLess, buttonH, "Rare")
    rarityButtonP2.onClick = function()
    self.plasmaRarity = "rare"
  end
  
  -- Button for spawning the weapon
  local spawnButton2 = TextButton(180, pad, buttonW - buttonLess, buttonH, "Spawn weapon", "orange")
    spawnButton2.onClick = function()
    self.plasmaItem = self.plasmaRarity .. self.plasmaClass
    world.spawnItem("generatedgun", world.entityPosition(smm.sourceId()), 1, {level = self.plasmaLevel, definition = self.plasmaItem})
  end

  -- Spawn all the UI elements
  panel:add(classButtonP1)
  panel:add(classButtonP2)
  panel:add(classButtonP3)
  panel:add(classButtonP4)
  panel:add(classButtonP5)
  panel:add(rarityButtonP1)
  panel:add(rarityButtonP2)
  panel:add(self.plasmaSlider)
  panel:add(spawnButton2)
  panel:add(self.plasmaLabel)
  panel:add(plasmalabelHead1)
  panel:add(plasmalabelHead2)
  panel:add(self.plasmalabelHead3)
  return "Plasma Guns", {"Tags"}
end

function randomplasmaupdate()
    self.plasmaLevel = self.plasmaSlider.value
	self.plasmalabelText = "Gun type: " .. self.plasmaClass .. "\nGun rarity: " .. self.plasmaRarity .. "\nGun level: " .. self.plasmaLevel
	self.plasmaLabel.text = self.plasmalabelText
	self.plasmaText = "Gun level (" .. self.plasmaLevel .. ")"
	self.plasmalabelHead3.text = self.plasmaText
end

smm(randomplasma, randomplasmaupdate)
