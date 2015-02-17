function init(virtual)
  if virtual then return end
  
  entity.setInteractive(true)
  storage.code = storage.code or entity.configParameter("currentPasscode", "")
  if storage.state == nil then
    output(entity.configParameter("defaultSwitchState", false))
  else
    output(storage.state)
  end
end

function output(state)
  storage.state = state
  if state then
    entity.setAnimationState("switchState", "on")
    if not (entity.configParameter("alwaysLit")) then entity.setLightColor(entity.configParameter("lightColor", {0, 0, 0, 0})) end
    entity.setSoundEffectEnabled(true)
    entity.playSound("on");
    entity.setAllOutboundNodes(true)
  else
    entity.setAnimationState("switchState", "off")
    if not (entity.configParameter("alwaysLit")) then entity.setLightColor({0, 0, 0, 0}) end
    entity.setSoundEffectEnabled(false)
    entity.playSound("off");
    entity.setAllOutboundNodes(false)
  end
end

function toggleOutput()
  storage.state = not storage.state
  output(storage.state)
end

function setCode(code)
	storage.currentPasscode = code
end

function onInteraction(args)
  local interactionConfig = {
    gui = {
      background = {
        zlevel = 0,
        type = "background",
        fileHeader = "/objects/wiredPadlock/consoleheader.png",
        fileBody = "/objects/wiredPadlock/consolebody.png"
      },
      scriptCanvas = {
        zlevel = 1,
        type = "canvas",
        rect = {0, 0, 75, 125},
        captureMouseEvents = true,
        captureKeyboardEvents = true
      }
    },
 
    scripts = {"/objects/wiredPadlock/passcodegui.lua"},
    scriptDelta = 1,
    scriptCanvas = "scriptCanvas"
  }
 
  interactionConfig.currentPasscode = storage.currentPasscode
 
  return {"ScriptConsole", interactionConfig}
end