function init(virtual)
  if virtual then return end
  entity.setInteractive(true)
  storage.config = entity.configParameter("dyeEngine")
end


function onInteraction(args)
  local itemName = world.entityHandItem(args.sourceId, "primary")
  if not itemName then
    return { "ShowPopup", { message = "I should hold the item that I want to dye." } }
  end

  local interactionConfig = dyeEngine.all(storage.config, itemName)
  interactionConfig.recipes = reverse(interactionConfig.recipes or {})

  if isEmpty(interactionConfig.recipes) then
    return { "ShowPopup", { message = "I can not dye that item." } }
  end

  return {"OpenCraftingInterface", interactionConfig}
end
