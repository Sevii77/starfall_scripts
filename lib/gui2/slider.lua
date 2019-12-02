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

local styles = {
	{
		think = function(self, cx, cy)
			local anim_speed = self.animationSpeed
			
			if self._hovering then
				if self._hoverprogress < 1 then
					self._hoverprogress = math.min(1, self._hoverprogress + timer.frametime() * anim_speed)
					self:_changed(true)
				end
			elseif self._hoverprogress > 0 then
				self._hoverprogress = math.max(0, self._hoverprogress - timer.frametime() * anim_speed)
				self:_changed(true)
			end
			
			if self._holding then
				if self._holdprogress < 1 then
					self._holdprogress = math.min(1, self._holdprogress + timer.frametime() * anim_speed)
					self:_changed(true)
				end
				
				if cx then
					local last = self._progress
					local progress = math.clamp((cx - self._h / 2) / (self._w - self._h), 0, 1)
					self._value = math.round(progress * (self._max - self._min) + self._min, self._round)
					self._progress = (self._value - self._min) / (self._max - self._min)
					
					if self._progress ~= last then
						self:onChange(self._value)
						self:_changed(true)
					end
				end
				
				self:onHold()
			elseif self._holdprogress > 0 then
				self._holdprogress = math.max(0, self._holdprogress - timer.frametime() * anim_speed)
				self:_changed(true)
			end
		end,
		draw = function(self, w, h)
			local bh = self.barSize
			local x = h / 2 - bh / 2
			local y = x
			local bw = w - x * 2
			local b = self.borderSize
			local b2 = b * 2
			local bb = self.barBorderSize
			local bb2 = bb * 2
			
			render.setMaterial()
			
			if b > 0 then
				if self.borderAccentCorner then
					render.setColor(self.accentColor)
					render.drawRect(x, y, bw, bh)
					
					render.setColor(self.secondaryColor)
					render.drawRect(x + bb, y + bb, bw - bb, bh - bb)
				else
					render.setColor(self.secondaryColor)
					render.drawRect(x, y, bw, bh)
					
					render.setColor(self.accentColor)
					render.drawRect(x, y, bw - bb, bh - bb)
				end
			end
			
			-- Bar
			render.setColor(self.activeColor)
			render.drawRect(x + bb, y + bb, bw - bb2, bh - bb2)
			
			render.setColor(self.mainColor)
			render.drawRect(x + bb + (bw - bb2) * self._progress, y + bb, (bw - bb2) * (1 - self._progress), bh - bb2)
			
			-- Knob
			local m = Matrix()
			m:setTranslation(Vector((w - h) * self._progress + h / 2, h / 2))
			m:setScale(Vector(h, h))
			
			render.pushMatrix(m, true)
			render.setColor(self.accentColor)
			render.drawPoly(circle)
			render.popMatrix()
			
			-- m:setTranslation(Vector((w - h) * self._progress + h / 2, h / 2))
			-- m:setScale(Vector(h - b2, h - b2) * (1 - self._holdprogress))
			-- render.pushMatrix(m, true)
			-- render.setColor(self.mainColor * (1 - self._hoverprogress) + self.secondaryColor * self._hoverprogress)
			-- render.drawPoly(circle)
			-- render.popMatrix()
			
			m:setTranslation(Vector((w - h) * self._progress + h / 2, h / 2))
			
			local hp = self._hoverprogress
			local hp1 = 1 - self._hoverprogress
			if self._holdprogress > 0 then
				m:setScale(Vector(h - b2, h - b2))
				render.pushMatrix(m, true)
				render.setColor(self.activeColor * hp1 + self.activeHoverColor * hp)
				render.drawPoly(circle)
				render.popMatrix()
			end
			
			if self._holdprogress < 1 then
				m:setScale(Vector(h - b2, h - b2) * (1 - self._holdprogress))
				render.pushMatrix(m, true)
				render.setColor(self.mainColor * hp1 + self.hoverColor * hp)
				render.drawPoly(circle)
				render.popMatrix()
			end
		end,
	},
	
	
	{
		think = function(self, cx, cy)
			local anim_speed = self.animationSpeed
			
			if self._hovering then
				if self._hoverprogress < 1 then
					self._hoverprogress = math.min(1, self._hoverprogress + timer.frametime() * anim_speed)
					self:_changed(true)
				end
			elseif self._hoverprogress > 0 then
				self._hoverprogress = math.max(0, self._hoverprogress - timer.frametime() * anim_speed)
				self:_changed(true)
			end
			
			if self._holding then
				if self._holdprogress < 1 then
					self._holdprogress = math.min(1, self._holdprogress + timer.frametime() * anim_speed)
					self:_changed(true)
				end
				
				if cx then
					local last = self._progress
					local progress = math.clamp(cx / self._w, 0, 1)
					self._value = math.round(progress * (self._max - self._min) + self._min, self._round)
					self._progress = (self._value - self._min) / (self._max - self._min)
					
					if self._progress ~= last then
						self:onChange(self._value)
						self:_changed(true)
					end
				end
				
				self:onHold()
			elseif self._holdprogress > 0 then
				self._holdprogress = math.max(0, self._holdprogress - timer.frametime() * anim_speed)
				self:_changed(true)
			end
		end,
		draw = function(self, w, h)
			local b = self.borderSize
			local b2 = b * 2
			
			if b > 0 then
				if self.borderAccentCorner then
					render.setColor(self.accentColor)
					render.drawRect(0, 0, w, h)
					
					render.setColor(self.secondaryColor)
					render.drawRect(b, b, w - b, h - b)
				else
					render.setColor(self.secondaryColor)
					render.drawRect(0, 0, w, h)
					
					render.setColor(self.accentColor)
					render.drawRect(0, 0, w - b, h - b)
				end
			end
			
			local hp = self._hoverprogress
			local hp1 = 1 - self._hoverprogress
			
			render.setColor(self.activeColor * hp1 + self.activeHoverColor * hp)
			render.drawRect(b, b, w - b2, h - b2)
			
			render.setColor(self.mainColor * hp1 + self.hoverColor * hp)
			render.drawRect(b + (w - b2) * self._progress, b, (w - b2) * (1 - self._progress), h - b2)
			
			render.setFont(self.font)
			render.setColor(self.textColor)
			render.drawSimpleText(w / 2, h / 2, tostring(self._value), 1, 1)
		end
	}
}

return {
	inherit = "label",
	constructor = function(self)
		self.style = 1
	end,
	
	----------------------------------------
	
	data = {
		_value = 0,
		_bar_size = false,
		_bar_border_size = false,
		_animation_speed = false,
		_active_color = false,
		_hover_color = false,
		_active_hover_color = false,
		_min = 0,
		_max = 1,
		_round = 2,
		_style_index = 0,
		
		_holding = false,
		_progress = 0,
		_hoverprogress = 0,
		_holdprogress = 0,
		
		------------------------------
		
		_think = function(self, cx, cy)
			
		end,
		
		_press = function(self)
			self:onClick()
			
			self._holding = true
		end,
		
		_release = function(self)
			self:onRelease()
			
			self._holding = false
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
		onHold = function(self) end,
		onRelease = function(self) end,
		onHoverBegin = function(self) end,
		onHoverEnd = function(self) end,
		onHover = function(self) end,
		onChange = function(self, value) end
	},
	
	----------------------------------------
	
	properties = {
		barSize = {
			set = function(self, value)
				self._bar_size = value
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._bar_size or self._theme.barSize
			end
		},
		
		barBorderSize = {
			set = function(self, value)
				self._bar_border_size = value
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._bar_border_size or self._theme.barBorderSize
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
		
		min = {
			set = function(self, min)
				self._min = min or 0
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._min
			end
		},
		
		max = {
			set = function(self, max)
				self._max = max or 1
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._max
			end
		},
		
		range = {
			set = function(self, min, max)
				self._min = min or 0
				self._max = max or 1
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._min, self._max
			end
		},
		
		round = {
			set = function(self, round)
				self._round = round
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._round
			end
		},
		
		------------------------------
		
		style = {
			set = function(self, index)
				if not styles[index] then
					error(index .. " is out of range of valid styles", 3)
				end
				
				self._style_index = index
				self.onDraw = styles[index].draw
				self._think = styles[index].think
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._style_index
			end
		},
		
		------------------------------
		
		value = {
			set = function(self, value)
				self._value = value
				self._progress = (self._value - self._min) / (self._max - self._min)
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._value
			end
		}
	}
	
}