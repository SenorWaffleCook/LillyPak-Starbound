-- Sample SMM script

function samplescript(panel)
  local h = panel.height
  local pad = 5

  local buttonH = 12
  local button = TextButton(pad, h - pad - buttonH, 100, buttonH, "Spawn Item")
  button.onClick = function()
    world.spawnItem("torch", world.entityPosition(smm.sourceId()))
  end

  local sliderH = 8
  local slider = Slider(pad, button.y - pad - sliderH, 100, sliderH, 0, 100, 1)
  local label = Label(slider.x + slider.width + pad, slider.y, "", sliderH)
  label:bind("text", Binding.concat(
               "Sample Slider: ", Binding(slider, "value")))
  
  panel:add(button)
  panel:add(slider)
  panel:add(label)
  return "Sample Mod", {"Tags"}
end

smm(samplescript)
