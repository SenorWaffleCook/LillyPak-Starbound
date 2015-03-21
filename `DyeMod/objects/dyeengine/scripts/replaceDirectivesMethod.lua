function replaceDirectives(fromPalette, toPalette)
  replacements = ""

  for i,fromColor in ipairs(fromPalette) do
    toIndex = i % #toPalette
    if toIndex == 0 then toIndex = #toPalette end
    toColor = toPalette[toIndex]

    if fromColor and toColor and fromColor ~= toColor then
      replacements = replacements .. ";" .. fromColor .. "=" .. toColor
    end
  end

  if replacements ~= "" then
    return "?replace" .. replacements
  end
end

function dyeEngine.replaceDirectives(itemName, color, itemConfig)
  if color.palette == nil then return end

  local recipe = dyeEngine.genericRecipe(itemName, color, itemConfig)

  if color.palette == "default" then return {recipe} end

  local directives = replaceDirectives(itemConfig.palette[1], color.palette)
  recipe.output.parameters = { directives = directives }

  return {recipe}
end
