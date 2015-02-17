gui = {mouseState = {}, context = {scale = 12, hot = 0, active = 0, focus = 0}}

function init()
	self.code = ""
	self.display = "****"
	self.validCode = console.configParameter("currentPasscode")
	
	if not self.validCode then
		self.blinking = true
		self.blinkTimer = 1
	end
end


function update(dt)
	gui.start()
		console.canvasDrawRect({0,100,75,125}, {125,125,125}) -- Draw our stuff
		if not (self.blinking and self.blinkTimer >= 0.5) then
			for l = 1, 4 do
				gui.label({5 + (l-1)*17,123},string.sub(self.display,l,l),24, {255,255,255}, nil)
			end
		end
		
		if self.blinking then
			self.blinkTimer = self.blinkTimer - dt*4
			if self.blinkTimer <= 0 then
				self.blinkTimer = 1
			end
		end
		
		for i = 1, 9 do
			if gui.button(i, {((i-1)%3)*25, 100 - math.floor((i-1) / 3)*25}, 25,25, tostring(i), {75,175,90}, {255,255,255}) then
				addNumber(i)
			end				
		end
		if gui.button("0", {25, 25}, 25,25, "0", {75,175,90}, {255,255,255}) then
			addNumber(0)
		end
		if gui.button("C", {50,25}, 25,25, "C", {75,175,90}, {255,255,255}) then
			self.code = ""
			self.display = "****"
		end	
		if gui.button("*", {0,25}, 25,25, "*", {75,175,90}, {255,255,255}) then
			console.dismiss()
		end				
	gui.finish()
end

function addNumber(num)
	self.code = self.code .. tostring(num)
	local length = string.len(self.code)
	if length >= 4 then
		if not self.validCode then
			world.callScriptedEntity(console.sourceEntity(), "setCode", self.code)
			self.validCode = self.code
			self.blinking = false
		elseif self.code == self.validCode then
			world.callScriptedEntity(console.sourceEntity(), "toggleOutput")
		end
		self.code = ""
		length = 0
	end
	
	self.display = self.code
	for i = 1, 4-length do
		self.display = self.display .. "*"
	end
end

function canvasClickEvent(position, button, isPressed)
	gui.updateMouse(button, isPressed)
end



function gui.button(id,pos,width,height,text,color,sColor)
	local x1,y1,x2,y2 = pos[1], pos[2], pos[1] + width, pos[2] - height
	local offset = 0
	color = color or {125,125,125,255}
	sColor = sColor or {255,255,255,255}
	
	if gui.isInRect(x1,y1,x2,y2) then
		gui.setHot(id) -- We are now Hot
		color, sColor = sColor, color -- We are hovering over the button, so swap colors
		
		if gui.isMouseDown(1) then
			offset = 2
			if not gui.isActive(id) then
				gui.setActive(id) -- Set us to active
				gui.setFocus(id)
			end
		end
	end
	
	console.canvasDrawRect({x1+offset,y1-offset,x2+offset,y2-offset}, color) -- Draw our stuff
	if text then
		local tWidth = gui.getStringWidth(text, gui.context.scale)
		-- TODO: Fix the damned text scaling and positioning.
		console.canvasDrawText(text, {position={pos[1] + (width/2) - (tWidth/2) +offset, pos[2]-offset - (gui.context.scale / 2)}}, gui.context.scale, sColor)
	end
	return gui.isActive(id)
end


function gui.label(pos,text,fSize,color, background)
	if background then
		console.canvasDrawRect({x1,y1,x2+ gui.getStringWidth(text, fSize),y2-fSize}, background)
	end
	console.canvasDrawText(text, {position=pos}, fSize, color)
end

-- Draw the text string, offsetting the string to account for leading whitespace.
--
-- All parameters are identical to those of console.canvasDrawText
function gui.drawText(text, options, fontSize, color)
  if text:byte() == 32 then -- If it starts with a space, offset the string
    fontSize = fontSize or 16
    local xOffset = gui.getStringWidth(" ", fontSize)
    local oldX = options.position[1]
    options.position[1] = oldX + xOffset
    console.canvasDrawText(text, options, fontSize, color)
    options.position[1] = oldX
  else
    console.canvasDrawText(text, options, fontSize, color)
  end
end

function gui.isMouseDown(button)
	return gui.mouseState[button] or false
end

function gui.isInRect(x1,y1,x2,y2)
	local pos = console.canvasMousePosition()
	
	if pos[1] >= x1 and pos[1] <= x2 and pos[2] <= y1 and pos[2] >= y2 then
		return true
	end
	return false
end

function gui.isHot(id)
	return gui.context.hot == id
end

function gui.isActive(id)
	return gui.context.active == id
end

function gui.setHot(id)
	gui.context.hot = id
end

function gui.setActive(id)
	gui.context.active = id
end

function gui.setFocus(id)
	gui.context.focus = id
end

function gui.getFocus()
	return gui.context.focus
end

function gui.updateMouse(mouse, isDown)
	gui.mouseState[mouse] = isDown or false
end

function gui.start()	
	
	if not gui.mouseState[1] then -- Reset our Active/Hot if our mouse is not down.
		gui.setActive(0)
		gui.setHot(0)
	end
end

function gui.finish()
	gui.mouseState[1] = false
end


-- Pixel widths of the first 255 characters. This was generated in Java.
gui.charWidths = {8, 8, 8, 8, 8, 8, 8, 8, 0, 0, 8, 8, 0, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 12, 10, 12, 12, 4, 6, 6, 8, 8, 6, 8, 4, 12, 10, 6, 10, 10, 10, 10, 10, 10, 10, 10, 4, 4, 8, 8, 8, 10, 12, 10, 10, 8, 10, 8, 8, 10, 10, 8, 10, 10, 8, 12, 10, 10, 10, 10, 10, 10, 8, 10, 10, 12, 10, 10, 8, 6, 12, 6, 8, 10, 6, 10, 10, 8, 10, 10, 8, 10, 10, 4, 6, 10, 4, 12, 10, 10, 10, 10, 8, 10, 8, 10, 10, 12, 8, 10, 10, 8, 4, 8, 10, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8}




function gui.getStringWidth(text, fontSize)
  local widths = gui.charWidths
  local scale = gui.getFontScale(fontSize)
  local out = 0
  for i=1,#text,1 do
    out = out + widths[string.byte(text, i)]
  end
  return out * scale
end

-- Gets the scale of the specified font size.
--
-- @param size The font size to get the scale for
function gui.getFontScale(size)
  return (size - 16) * 0.0625 + 1
end


function canvasClickEvent(position, button, isPressed)
	gui.updateMouse(button, isPressed)
end




