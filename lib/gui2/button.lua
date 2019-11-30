return {
	inherit = "label",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_toggle = false,
		
		_hovering = false,
		_click = false,
		_click_right = false,
		_clickprogress = 0,
		_hoverprogress = 0,
		
		------------------------------
		
		_think = function(self)
			if self._hovering then
				if self._hoverprogress < 1 then
					self._hoverprogress = math.min(1, self._hoverprogress + timer.frametime() * 20)
					self:_changed(true)
				end
			elseif self._hoverprogress > 0 then
				self._hoverprogress = math.max(0, self._hoverprogress - timer.frametime() * 20)
				self:_changed(true)
			end
			
			if self._click or self._click_right then
				if self._clickprogress < 1 then
					self._clickprogress = math.min(1, self._clickprogress + timer.frametime() * 20)
					self:_changed(true)
				end
				
				if self._click then
					self:onHold()
				end
				if self.click_right then
					self:onRightHold()
				end
			elseif self._clickprogress > 0 then
				self._clickprogress = math.max(0, self._clickprogress - timer.frametime() * 20)
				self:_changed(true)
			end
		end,
		
		_press = function(self)
			self:onClick()
			
			self._click = not self._toggle and true or not self._click
		end,
		
		_pressRight = function(self)
			self:onRightClick()
			
			self._click_right = not self._toggle and true or not self._click_right
		end,
		
		_pressDouble = function(self)
			self:onDoubleClick()
		end,
		
		_release = function(self)
			self:onRelease()
			
			if not self._toggle then
				self._click = false
			end
		end,
		
		_releaseRight = function(self)
			self:onRightRelease()
			
			if not self._toggle then
				self._click_right = false
			end
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
			local b = self.borderSize
			local b2 = b * 2
			
			if b > 0 then
				render.setColor(self.secondaryColor)
				render.drawRect(0, 0, w, h)
				
				render.setColor(self.accentColor)
				render.drawRect(0, 0, w - b, h - b)
			end
			
			render.setColor((self.mainColor * (1 - self._hoverprogress) + self.secondaryColor * self._hoverprogress) * (1 - self._clickprogress) + self.accentColor * self._clickprogress)
			render.drawRect(b, b, w - b2, h - b2)
			
			render.setFont(self.font)
			render.setColor(self.textColor)
			render.drawSimpleText(w / 2, h / 2, self.text, 1, 1)
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
		}
	}
	
}