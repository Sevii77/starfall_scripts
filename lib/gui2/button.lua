return {
	inherit = "label",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_click = false,
		_click_right = false,
		_clickprogress = 0,
		_hoverprogress = 0,
		
		------------------------------
		
		_changed = function(self)
			
		end,
		
		_tick = function(self)
			self._hoverprogress = math.max(0, self._hoverprogress - timer.frametime() * 20)
			
			if self._click or self._click_right then
				self._clickprogress = math.min(1, self._clickprogress + timer.frametime() * 20)
				
				if self._click then
					self:onHold()
				end
				if self.click_right then
					self:onRightHold()
				end
			else
				self._clickprogress = math.max(0, self._clickprogress - timer.frametime() * 20)
			end
		end,
		
		_press = function(self)
			self:onClick()
			
			self._click = true
		end,
		
		_pressRight = function(self)
			self:onRightClick()
			
			self._click_right = true
		end,
		
		_pressDouble = function(self)
			self:onDoubleClick()
		end,
		
		_release = function(self)
			self:onRelease()
			
			self._click = false
		end,
		
		_releaseRight = function(self)
			self:onRightRelease()
			
			self._click_right = false
		end,
		
		_hover = function(self)
			self:onHover()
			
			self._hoverprogress = math.min(1, self._hoverprogress + timer.frametime() * 40) -- 40 instead of 20 to combat _tick
		end,
		
		_hoverStart = function(self)
			self:onHoverBegin()
		end,
		
		_hoverEnd = function(self)
			self:onHoverEnd()
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
		
	}
	
}