return {
	inherit = "label",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_toggle = false,
		_animation_speed = false,
		_active_color = false,
		_hover_color = false,
		_active_hover_color = false,
		
		_hovering = false,
		_click = false,
		_click_right = false,
		_clickprogress = 0,
		_hoverprogress = 0,
		
		------------------------------
		
		_think = function(self)
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
			
			if self._click or (not self._toggle and self._click_right) then
				if self._clickprogress < 1 then
					self._clickprogress = math.min(1, self._clickprogress + timer.frametime() * anim_speed)
					self:_changed(true)
				end
				
				if self._click then
					self:onHold()
				end
				if self.click_right then
					self:onRightHold()
				end
			elseif self._clickprogress > 0 then
				self._clickprogress = math.max(0, self._clickprogress - timer.frametime() * anim_speed)
				self:_changed(true)
			end
		end,
		
		_press = function(self)
			self._click = not self._toggle and true or not self._click
			
			self:onClick()
		end,
		
		_pressRight = function(self)
			self._click_right = true
			
			self:onRightClick()
		end,
		
		_pressDouble = function(self)
			self:onDoubleClick()
		end,
		
		_release = function(self)
			if not self._toggle then
				self._click = false
			end
			
			self:onRelease()
		end,
		
		_releaseRight = function(self)
			self._click_right = false
			
			self:onRightRelease()
		end,
		
		_hover = function(self)
			self:onHover()
		end,
		
		_hoverStart = function(self)
			self._hovering = true
			
			self:_cursorMode(GUI.CURSORMODE.CLICKABLE, GUI.CURSORMODE.NORMAL)
			self:onHoverBegin()
		end,
		
		_hoverEnd = function(self)
			self._hovering = false
			
			self:_cursorMode(GUI.CURSORMODE.NORMAL, GUI.CURSORMODE.CLICKABLE)
			self:onHoverEnd()
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
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
			
			-- render.setColor((self.mainColor * (1 - self._hoverprogress) + self.hoverColor * self._hoverprogress) * (1 - self._clickprogress) + self.activeColor * self._clickprogress)
			local hp = self._hoverprogress
			local hp1 = 1 - self._hoverprogress
			render.setColor((self.mainColor * hp1 + self.hoverColor * hp) * (1 - self._clickprogress) + (self.activeColor * hp1 + self.activeHoverColor * hp) * self._clickprogress)
			render.drawRect(b, b, w - b2, h - b2)
			
			local ax, ay = self._text_alignment_x, self._text_alignment_y
			render.setFont(self.font)
			render.setColor(self.textColor)
			render.drawText(ax == 0 and b or (ax == 1 and w / 2 or w - b), ay == 3 and b or (ay == 1 and (h - self._text_height) / 2 or h - self._text_height - b), self.text, ax)
		end,
		
		onClick = function(self) end,
		onRightClick = function(self) end,
		onDoubleClick = function(self) end,
		onHold = function(self) end,
		onRightHold = function(self) end,
		onRelease = function(self) end,
		onRightRelease = function(self) end,
		onHoverBegin = function(self) end,
		onHoverEnd = function(self) end,
		onHover = function(self) end,
	},
	
	----------------------------------------
	
	properties = {
		toggle = {
			set = function(self, state)
				self._toggle = state
			end,
			
			get = function(self)
				return self._toggle
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
		
		------------------------------
		
		state = {
			get = function(self)
				return self._click
			end
		}
	}
	
}