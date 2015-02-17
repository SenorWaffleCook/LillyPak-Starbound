function init(args)
  entity.setInteractive(true)
end

function onInteraction(args)
    local heldItem = world.entityHandItem(args.sourceId, "primary")
    world.spawnItem(heldItem, entity.toAbsolutePosition({ 0.0, 5.0 }), 1)
end