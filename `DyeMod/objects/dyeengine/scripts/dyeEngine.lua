dyeEngine = {}

function dyeEngine.all(config, itemName)
  local itemConfig = itemConfig.get(config, itemName)
  if not itemConfig.method then return {} end

  local recipes = {}

  for _,color in ipairs(config.colors) do
    recipes = concatTable(recipes, dyeEngine[itemConfig.method](itemName, color, itemConfig))
  end

  return { recipes = recipes, config = itemConfig.windowConfig }
end


function dyeEngine.genericRecipe(itemName, color, itemConfig)
  local recipe = {
    input = {
      { item = itemName, count = itemConfig.amount }
    },
    output = {
      item = itemName,
      count = itemConfig.amount
    },
    groups = color.groups
  }

  if not itemConfig.free then
    local dyes = color.dyes or { color.name.."dye" }

    for _,dye in ipairs(dyes) do
      table.insert(recipe.input, dye)
    end
  end

  return recipe
end
