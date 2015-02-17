function init(args)
  self.weaponType = "generatedgun"
  self.weaponLevel = 10
  self.weaponRarity = "common"
  self.weaponClass = "assaultrifle"
  entity.setInteractive(true)
end

function onInteraction(args)
    local weaponItem = self.weaponRarity .. self.weaponClass
    world.spawnItem(self.weaponType, entity.toAbsolutePosition({ 0.0, 5.0 }), 1, {level = self.weaponLevel, definition = weaponItem})
end