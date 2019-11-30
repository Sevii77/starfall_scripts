return {
	inherit = "base",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_border_size = false,
		_main_color = false,
		_secondary_color = false,
		_accent_color = false,
		_border_accent_corner = nil,
		
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
			
			render.setColor(self.mainColor)
			render.drawRect(b, b, w - b2, h - b2)
		end
	},
	
	----------------------------------------
	
	properties = {
		borderSize = {
			set = function(self, borderSize)
				self._border_size = borderSize
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._border_size or self._theme.borderSize
			end
		},
		
		mainColor = {
			set = function(self, color)
				self._main_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._main_color or self._theme.main
			end
		},
		
		secondaryColor = {
			set = function(self, color)
				self._secondary_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._secondary_color or self._theme.secondary
			end
		},
		
		accentColor = {
			set = function(self, color)
				self._accent_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._accent_color or self._theme.accent
			end
		},
		
		borderAccentCorner = {
			set = function(self, state)
				self._border_accent_corner = state
			end,
			
			get = function(self)
				return self._border_accent_corner ~= nil and self._border_accent_corner or self._theme.borderAccentCorner
			end
		}
	}
	
}