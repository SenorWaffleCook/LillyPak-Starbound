smm = {
  mods = {},
  updateFunctions = {}
}

setmetatable(
  smm,
  {
    __call = function(t, ...)
      local args = table.pack(...)
      assert(type(args[1]) == "function",
             "The first argument must be your panel init function")
      table.insert(t.mods, args[1])
      if args[2] then
        table.insert(t.updateFunctions, args[2])
      end
    end
  }
)

function init()
  storage = console.configParameter("scriptStorage")
  local source = console.configParameter("interactSource")
  local sourceId = console.configParameter("interactSourceId")
  smm.source = function()
    return {source[1], source[2]}
  end
  smm.sourceId = function()
    return sourceId
  end
  
  local guiConfig = console.configParameter("gui")
  local canvasRect = guiConfig.scriptCanvas.rect
  
  local width = canvasRect[3] - canvasRect[1]
  local height = canvasRect[4] - canvasRect[2]
  local padding = 5
  local fontSize = 14
  local modList = List(padding, padding, 100, height - 8, fontSize)
  modList.backgroundColor = "#635d32"
  modList.borderColor = "black"
  
  local modPanelX = modList.x + modList.width + padding
  local modPanelY = modList.y
  local modPanelWidth = width - modPanelX - padding
  local modPanelHeight = height - modPanelY - padding

  local modPanelRectSize = 2
  local modPanelRect = Rectangle(modPanelX - modPanelRectSize,
                                 modPanelY - modPanelRectSize,
                                 modPanelWidth + modPanelRectSize * 2,
                                 modPanelHeight + modPanelRectSize * 2,
                                 "black", modPanelRectSize)
  for k,v in ipairs(smm.mods) do
    local modPanel = Panel(modPanelX, modPanelY)
    modPanel.width = modPanelWidth
    modPanel.height = modPanelHeight
    local modName, modTags = v(modPanel)
    assert(type(modName) == "string",
           "Your init function must return your mod name.")
    local modButton = modList:emplaceItem(modName)
    modButton.modTags = modTags
	modButton.borderColor = "black"
	modButton.bordercolor = "gray"
	modButton.backgroundColor = "#1f1f1f"
    modPanel:bind("visible", Binding(modButton, "selected"))
    GUI.add(modPanel)
  end

  GUI.add(modList)
  GUI.add(modPanelRect)

  table.sort(
    modList.items,
    function(a, b)
      return a.text < b.text
    end
  )
end


function syncStorage()
  world.callScriptedEntity(console.sourceEntity(), "onConsoleStorageRecieve", storage)
end

function update(dt)
  GUI.step(dt)
  for _,updateFunction in ipairs(smm.updateFunctions) do
	updateFunction(dt)
  end
end

function canvasClickEvent(position, button, pressed)
  GUI.clickEvent(position, button, pressed)
end

function canvasKeyEvent(key, isKeyDown)
  GUI.keyEvent(key, isKeyDown)
end
