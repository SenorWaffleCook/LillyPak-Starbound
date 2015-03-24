function dyeEngine.simpleColor(itemName, color, itemConfig)
  if not inTable(itemConfig.simpleColors, color.name) then return {} end

  local recipe = dyeEngine.genericRecipe(itemName, color, itemConfig)
  recipe.output.parameters = { color = color.name }

  return {recipe}
end
