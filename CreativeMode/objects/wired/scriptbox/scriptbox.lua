function init(virtual)
  if not virtual then
    storage.consoleStorage = storage.consoleStorage or {}
    entity.setInteractive(true)
  end
end

function onConsoleStorageRecieve(consoleStorage)
  storage.consoleStorage = consoleStorage
end

function onInteraction(args)
  local interactionConfig = entity.configParameter("interactionConfig")
  local mods = entity.configParameter("mods")

  interactionConfig.scriptStorage = storage.consoleStorage
  for _,modScript in ipairs(mods) do
    table.insert(interactionConfig.scripts, modScript)
  end
  interactionConfig.interactSource = args.source
  interactionConfig.interactSourceId = args.sourceId
  
  return {"ScriptConsole", interactionConfig}
end
                                 
