function init(args)
  if not self.initialized and not args then
	  self.initialized = true
	  self.anchor = entity.configParameter("anchors")[1]
  end
  entity.setInteractive(false)
  if storage.state == nil then
    output(false)
  else
    entity.setAllOutboundNodes(storage.state)
    if storage.state then
	  if (self.anchor == "bottom") then
		entity.setAnimationState("DisplayState", "ON_Top_operation")
	  elseif (self.anchor == "top") then
	    entity.setAnimationState("DisplayState", "ON_Bottom_operation")
	  end
    else
	  if (self.anchor == "bottom") then
		entity.setAnimationState("DisplayState", "OFF_Top_operation")
	  elseif (self.anchor == "top") then
	    entity.setAnimationState("DisplayState", "OFF_Bottom_operation")
	  end
    end
  end
  self.gates = entity.configParameter("gates")
  self.truthtable = entity.configParameter("truthtable")
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    entity.setAllOutboundNodes(state)
    if state then
	  if (self.anchor == "bottom") then
		entity.setAnimationState("DisplayState", "ON_Top_operation")
	  elseif (self.anchor == "top") then
	    entity.setAnimationState("DisplayState", "ON_Bottom_operation")
	  end
    else
	  if (self.anchor == "bottom") then
		entity.setAnimationState("DisplayState", "OFF_Top_operation")
	  elseif (self.anchor == "top") then
	    entity.setAnimationState("DisplayState", "OFF_Bottom_operation")
	  end
    end
  end
end

function toIndex(truth)
  if truth then
    return 2
  else
    return 1
  end
end

function update(dt)
  if self.gates == 1 then
    output(self.truthtable[toIndex(entity.getInboundNodeLevel(0))])
  elseif self.gates == 2 then
    output(self.truthtable[toIndex(entity.getInboundNodeLevel(0))][toIndex(entity.getInboundNodeLevel(1))])
  elseif self.gates == 3 then
    output(self.truthtable[toIndex(entity.getInboundNodeLevel(0))][toIndex(entity.getInboundNodeLevel(1))][toIndex(entity.getInboundNodeLevel(2))])
  end
end