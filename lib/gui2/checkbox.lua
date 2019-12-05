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
		
		render.setMaterial()
		
		-- Full borders
		if self._full_border then
			local h2 = h / 2
			if self.borderAccentCorner then
				render.setColor(self.accentColor)
				render.drawRect(h2, 0, w - h2, h)
				
				render.setColor(self.secondaryColor)
				render.drawRect(h2 + b, b, w - b - h2, h - b)
			else
				render.setColor(self.secondaryColor)
				render.drawRect(h2, 0, w - h2, h)
				
				render.setColor(self.accentColor)
				render.drawRect(h2, 0, w - b - h2, h - b)
			end
			
			render.setColor(self.mainColor)
			render.drawRect(h2, b, w - b - h2, h - b2)
		end
		
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
		
		local hp = self._hoverprogress
		local hp1 = 1 - self._hoverprogress
		if self._stateprogress > 0 then
			m:setScale(Vector(h - b2, h - b2))
			render.pushMatrix(m, true)
			render.setColor(self.activeColor * hp1 + self.activeHoverColor * hp)
			render.drawPoly(circle)
			render.popMatrix()
		end
		
		if self._stateprogress < 1 then
			m:setScale(Vector(h - b2, h - b2) * (1 - self._stateprogress))
			render.pushMatrix(m, true)
			render.setColor(self.mainColor * hp1 + self.hoverColor * hp)
			render.drawPoly(circle)
			render.popMatrix()
		end
		
		-- Text
		render.setFont(self.font)
		render.setColor(self.textColor)
		render.drawSimpleText(h * 2 + (h - self._text_height) / 2, h / 2, self.text, 0, 1)
	end,
	
	
	function(self, w, h)
		local b = self.borderSize
		local b2 = b * 2
		
		render.setMaterial()
		
		-- Full borders
		if self._full_border then
			local h2 = h / 2
			if self.borderAccentCorner then
				render.setColor(self.accentColor)
				render.drawRect(h2, 0, w - h2, h)
				
				render.setColor(self.secondaryColor)
				render.drawRect(h2 + b, b, w - b - h2, h - b)
			else
				render.setColor(self.secondaryColor)
				render.drawRect(h2, 0, w - h2, h)
				
				render.setColor(self.accentColor)
				render.drawRect(h2, 0, w - b - h2, h - b)
			end
			
			render.setColor(self.mainColor)
			render.drawRect(h2, b, w - b - h2, h - b2)
		end
		
		-- Check circle
		local m = Matrix()
		m:setTranslation(Vector(h / 2))
		
		m:setScale(Vector(h))
		render.pushMatrix(m, true)
		render.setColor(self.accentColor)
		render.drawPoly(circle)
		render.popMatrix()
		
		local hp = self._hoverprogress
		local hp1 = 1 - self._hoverprogress
		if self._stateprogress > 0 then
			m:setScale(Vector(h - b2, h - b2))
			render.pushMatrix(m, true)
			render.setColor(self.activeColor * hp1 + self.activeHoverColor * hp)
			render.drawPoly(circle)
			render.popMatrix()
		end
		
		if self._stateprogress < 1 then
			m:setScale(Vector(h - b2, h - b2) * (1 - self._stateprogress))
			render.pushMatrix(m, true)
			render.setColor(self.mainColor * hp1 + self.hoverColor * hp)
			render.drawPoly(circle)
			render.popMatrix()
		end
		
		render.setFont(self.font)
		render.setColor(self.textColor)
		render.drawSimpleText(h + (h - self._text_height) / 2, h / 2, self.text, 0, 1)
	end,
	
	
	function(self, w, h)
		local b = self.borderSize
		local b2 = b * 2
		
		-- Full borders
		if self._full_border then
			local h2 = h / 2
			if self.borderAccentCorner then
				render.setColor(self.accentColor)
				render.drawRect(h2, 0, w - h2, h)
				
				render.setColor(self.secondaryColor)
				render.drawRect(h2 + b, b, w - b - h2, h - b)
			else
				render.setColor(self.secondaryColor)
				render.drawRect(h2, 0, w - h2, h)
				
				render.setColor(self.accentColor)
				render.drawRect(h2, 0, w - b - h2, h - b)
			end
			
			render.setColor(self.mainColor)
			render.drawRect(h2, b, w - b - h2, h - b2)
		end
		
		-- Checkbox
		if b > 0 then
			if self.borderAccentCorner then
				render.setColor(self.accentColor)
				render.drawRect(0, 0, h, h)
				
				render.setColor(self.secondaryColor)
				render.drawRect(b, b, h - b, h - b)
			else
				render.setColor(self.secondaryColor)
				render.drawRect(0, 0, h, h)
				
				render.setColor(self.accentColor)
				render.drawRect(0, 0, h - b, h - b)
			end
		end
		
		local hp = self._hoverprogress
		local hp1 = 1 - self._hoverprogress
		
		if self._stateprogress < 1 then
			render.setColor(self.mainColor * hp1 + self.hoverColor * hp)
			render.drawRect(b, b, h - b2, h - b2)
		end
		if self._stateprogress > 0 then
			local s = (h - b2) * self._stateprogress
			local o = ((h - b2) - s) / 2
			
			render.setColor(self.activeColor * hp1 + self.activeHoverColor * hp)
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
		_animation_speed = false,
		_full_border = false,
		_active_color = false,
		_hover_color = false,
		_active_hover_color = false,
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
		
		_think = function(self, dt, cx, cy)
			local anim_speed = self.animationSpeed
			
			if self._hovering then
				if self._hoverprogress < 1 then
					self._hoverprogress = math.min(1, self._hoverprogress + dt * anim_speed)
					self:_changed(true)
				end
			elseif self._hoverprogress > 0 then
				self._hoverprogress = math.max(0, self._hoverprogress - dt * anim_speed)
				self:_changed(true)
			end
			
			if self._state then
				if self._stateprogress < 1 then
					self._stateprogress = math.min(1, self._stateprogress + dt * anim_speed)
					self:_changed(true)
				end
			elseif self._stateprogress > 0 then
				self._stateprogress = math.max(0, self._stateprogress - dt * anim_speed)
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
			
			self:_cursorMode(GUI.CURSORMODE.CLICKABLE, GUI.CURSORMODE.NORMAL)
			self._hovering = true
		end,
		
		_hoverEnd = function(self)
			self:onHoverEnd()
			
			self:_cursorMode(GUI.CURSORMODE.NORMAL, GUI.CURSORMODE.CLICKABLE)
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
		
		animationSpeed = {
			set = function(self, value)
				self._animation_speed = value
			end,
			
			get = function(self)
				return self._animation_speed or self._theme.animationSpeed
			end
		},
		
		fullBorders = {
			set = function(self, state)
				self._full_border = state
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._full_border
			end
		},
		
		activeColor = {
			set = function(self, color)
				self._active_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._active_color or self._theme.activeColor
			end
		},
		
		hoverColor = {
			set = function(self, color)
				self._hover_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._hover_color or self._theme.hoverColor
			end
		},
		
		activeHoverColor = {
			set = function(self, color)
				self._active_hover_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._active_hover_color or self._theme.activeHoverColor
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