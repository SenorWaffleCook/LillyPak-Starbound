function colorOption(fromPalette, toPalette)
  local colorOption = {}

  for i, fromColor in ipairs(fromPalette) do
    toIndex = i % #toPalette
    if toIndex == 0 then toIndex = #toPalette end
    toColor = toPalette[toIndex]

    colorOption[fromColor] = toColor
  end

  if next(colorOption) ~= nil then
    return colorOption
  end
end


function dyeEngine.colorOption(itemName, color, itemConfig)
  if color.palette == nil then return end

  local recipe = dyeEngine.genericRecipe(itemName, color, itemConfig)

  if color.palette == "default" then return {recipe} end

  local colorOption = colorOption(itemConfig.palette[1], color.palette)
  recipe.output.parameters = { colorOptions = {colorOption} }

  return {recipe}
end
