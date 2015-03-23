itemConfig = {}


function itemConfig.allowed(itemName, itemTypeConfig)
  local whitelist = itemTypeConfig.whitelist or {}
  local blacklist = itemTypeConfig.blacklist or {}

  if (isEmpty(whitelist)
      or inTable(whitelist, itemName))
      and not inTable(blacklist, itemName)
  then
    return true
  end
end


function itemConfig.get(config, itemName)
  local itemType = world.itemType(itemName)

  local globalDefault = config.default or {}

  local itemTypeConfig = config[itemType] or {}
  if type(itemTypeConfig) == "string" then
    itemTypeConfig = config[itemTypeConfig]
  end

  if not itemConfig.allowed(itemName, itemTypeConfig) then
    return {}
  end

  local itemDefault = itemTypeConfig.default or {}

  local itemSpecial = (itemTypeConfig.special or {})[itemName] or {}
  if type(itemSpecial) == "string" then
    itemSpecial = (itemTypeConfig.specialSets or {})[itemSpecial] or {}
  end

  local itemConfig = {}

  for k,v in pairs(globalDefault) do
    itemConfig[k] = v
  end
  for k,v in pairs(itemDefault) do
    itemConfig[k] = v
  end
  for k,v in pairs(itemSpecial) do
    itemConfig[k] = v
  end

  return itemConfig
end
