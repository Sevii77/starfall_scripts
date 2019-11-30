local circle = {}
for i = 1, 32 do
	local rad = i / 16 * math.pi
	circle[i] = {x = -math.sin(rad) / 2, y = math.cos(rad) / 2}
end

local circle_half = {}
for i = 0, 16 do
	local rad = i / 16 * math.pi
	circle_half[i + 1] = {x = -math.sin(rad) / 2, y = math.cos(rad) / 2}
end

local pill = {}
for i = 0, 16 do
	local rad = i / 16 * math.pi
	pill[i + 1] = {x = -math.sin(rad) / 2 + 0.5, y = math.cos(rad) / 2 + 0.5}
end
for i = 17, 32 do
	local rad = i / 16 * math.pi
	pill[i] = {x = -math.sin(rad) / 2 + 1.5, y = math.cos(rad) / 2 + 0.5}
end

local pill_half = {}
for i = 4, 16 do
	local rad = i / 16 * math.pi
	table.insert(pill_half, {x = -math.sin(rad) / 2 + 0.5, y = math.cos(rad) / 2 + 0.5})
end
for i = 17, 20 do
	local rad = i / 16 * math.pi
	table.insert(pill_half, {x = -math.sin(rad) / 2 + 1.5, y = math.cos(rad) / 2 + 0.5})
end


local styles = {
	function(self, w, h)
		local b = self.borderSize
		local b2 = b * 2
		
		-- Pill
		local m = Matrix()
		
		m:setScale(Vector(h))
		render.pushMatrix(m, true)
		render.setColor(self.accentColor)
		render.drawPoly(pill_half)
		render.popMatrix()
		
		m:translate(Vector(2, 1))
		m:rotate(Angle(0, 180, 0))
		render.pushMatrix(m, true)
		render.setColor(self.secondaryColor)
		render.drawPoly(pill_half)
		render.popMatrix()
		
		m:setTranslation(Vector(b))
		m:setScale(Vector(h - b, h - b2))
		m:setAngles(Angle())
		render.pushMatrix(m, true)
		render.setColor(self.mainColor)
		render.drawPoly(pill)
		render.popMatrix()
		
		-- Knob
		m:setTranslation(Vector(h * self._stateprogress + h / 2, h / 2))
		m:setScale(Vector(h))
		render.pushMatrix(m, true)
		render.setColor(self.accentColor)
		render.drawPoly(circle)
		render.popMatrix()
		
		m:setScale(Vector(h - b2, h - b2) * (1 - self._stateprogress))
		render.pushMatrix(m, true)
		render.setColor(self.mainColor * (1 - self._hoverprogress) + self.secondaryColor * self._hoverprogress)
		render.drawPoly(circle)
		render.popMatrix()
		
		-- Text
		render.setFont(self.font)
		render.setColor(self.textColor)
		render.drawSimpleText(h * 2 + (h - self._text_height) / 2, h / 2, self.text, 0, 1)
	end,
	
	
	function(self, w, h)
		local b = self.borderSize
		local b2 = b * 2
		
		local m = Matrix()
		m:setTranslation(Vector(h / 2))
		
		-- m:setScale(Vector(h))
		-- m:setAngles(Angle(0, 45, 0))
		-- render.pushMatrix(m, true)
		-- render.setColor(self.accentColor)
		-- render.drawPoly(circle_half)
		-- render.popMatrix()
		
		-- m:rotate(Angle(0, 180, 0))
		-- render.pushMatrix(m, true)
		-- render.setColor(self.secondaryColor)
		-- render.drawPoly(circle_half)
		-- render.popMatrix()
		
		-- m:setScale(Vector(h - self.borderSize * 2))
		-- render.pushMatrix(m, true)
		-- render.setColor((self.mainColor * (1 - self._hoverprogress) + self.secondaryColor * self._hoverprogress) * (1 - self._stateprogress) + self.accentColor * self._stateprogress)
		-- render.drawPoly(circle)
		-- render.popMatrix()
		
		m:setScale(Vector(h))
		render.pushMatrix(m, true)
		render.setColor(self.accentColor)
		render.drawPoly(circle)
		render.popMatrix()
		
		m:setScale(Vector(h - b2, h - b2) * (1 - self._stateprogress))
		render.pushMatrix(m, true)
		render.setColor(self.mainColor * (1 - self._hoverprogress) + self.secondaryColor * self._hoverprogress)
		render.drawPoly(circle)
		render.popMatrix()
		
		render.setFont(self.font)
		render.setColor(self.textColor)
		render.drawSimpleText(h + (h - self._text_height) / 2, h / 2, self.text, 0, 1)
	end,
	
	
	function(self, w, h)
		local b = self.borderSize
		local b2 = b * 2
		
		if b > 0 then
			render.setColor(self.secondaryColor)
			render.drawRect(0, 0, h, h)
			
			render.setColor(self.accentColor)
			render.drawRect(0, 0, h - b, h - b)
		end
		
		if self._stateprogress < 1 then
			render.setColor(self.mainColor * (1 - self._hoverprogress) + self.secondaryColor * self._hoverprogress)
			render.drawRect(b, b, h - b2, h - b2)
		end
		if self._stateprogress > 0 then
			local s = (h - b2) * self._stateprogress
			local o = ((h - b2) - s) / 2
			
			render.setColor(self.accentColor)
			render.drawRect(b + o, b + o, s, s)
		end
		
		render.setFont(self.font)
		render.setColor(self.textColor)
		render.drawSimpleText(h + (h - self._text_height) / 2, h / 2, self.text, 0, 1)
	end
}

return {
	inherit = "label",
	constructor = function(self)
		self.style = 1
		
		self:_calculateTextHeight()
	end,
	
	----------------------------------------
	
	data = {
		_state = false,
		_style_index = 0,
		
		_text_height = 0,
		_hoverprogress = 0,
		_stateprogress = 0,
		
		------------------------------
		
		_calculateTextHeight = function(self)
			render.setFont(self.font)
			local _, h = render.getTextSize("%")
			
			self._text_height = h
		end,
		
		------------------------------
		
		_think = function(self, cx, cy)
			if self._hovering then
				if self._hoverprogress < 1 then
					self._hoverprogress = math.min(1, self._hoverprogress + timer.frametime() * 20)
					self:_changed(true)
				end
			elseif self._hoverprogress > 0 then
				self._hoverprogress = math.max(0, self._hoverprogress - timer.frametime() * 20)
				self:_changed(true)
			end
			
			if self._state then
				if self._stateprogress < 1 then
					self._stateprogress = math.min(1, self._stateprogress + timer.frametime() * 20)
					self:_changed(true)
				end
			elseif self._stateprogress > 0 then
				self._stateprogress = math.max(0, self._stateprogress - timer.frametime() * 20)
				self:_changed(true)
			end
		end,
		
		_press = function(self)
			self._state = not self._state
			
			self:onClick()
			self:onChange(self._state)
		end,
		
		_hover = function(self)
			self:onHover()
		end,
		
		_hoverStart = function(self)
			self:onHoverBegin()
			
			self._hovering = true
		end,
		
		_hoverEnd = function(self)
			self:onHoverEnd()
			
			self._hovering = false
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			
		end,
		
		onClick = function(self) end,
		onHoverBegin = function(self) end,
		onHoverEnd = function(self) end,
		onHover = function(self) end,
		onChange = function(self, state) end
	},
	
	----------------------------------------
	
	properties = {
		font = {
			set = function(self, font)
				self._font = font
				
				self:_changed(true)
				self:_calculateTextHeight()
			end,
			
			get = function(self)
				return self._font or self._theme.font
			end
		},
		
		------------------------------
		
		style = {
			set = function(self, index)
				if not styles[index] then
					error(index .. " is out of range of valid styles", 3)
				end
				
				self._style_index = index
				self.onDraw = styles[index]
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._style_index
			end
		},
		
		------------------------------
		
		state = {
			set = function(self, state)
				self._state = state
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._state
			end
		}
	}
	
}