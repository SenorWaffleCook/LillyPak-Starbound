materialHueShift = {}


function materialHueShift.round(n)
  local roundTable = {
    [315] = 317.647064208984375,
    [294] = 296.4705810546875,
    [270] = 272.4705810546875,
    [225] = 227.29412841796875,
    [180] = 179.29412841796875,
    [135] = 134.117645263671875,
    [90]  = 88.9411773681640625,
    [45]  = 43.764705657958984375
  }

  return roundTable[n] or (math.floor(n / (360/255)) * (360/255))
end


function dyeEngine.materialHueShift(itemName, color, itemConfig)
  if color.hue == nil then return {} end

  local recipe = dyeEngine.genericRecipe(itemName, color, itemConfig)

  if color.hue == "default" then return {recipe} end

  local hueShift = materialHueShift.round((color.hue + itemConfig.hue) % 360)
  recipe.output.parameters = { materialHueShift = hueShift }

  return {recipe}
end
