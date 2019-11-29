return {
	inherit = "container",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_text = "",
		_font = false,
		_text_color = false,
		
		------------------------------
		
		_changed = function(self)
			
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			self.base.onDraw(self, w, h)
			-- self.base()
			
			render.setFont(self.font)
			render.setColor(self.textColor)
			render.drawSimpleText(w / 2, h / 2, self.text, 1, 1)
		end
	},
	
	----------------------------------------
	
	properties = {
		text = {
			set = function(self, text)
				self._text = text
				
				self:_changed()
			end,
			
			get = function(self)
				return self._text
			end
		},
		
		font = {
			set = function(self, font)
				self._font = font
				
				self:_changed()
			end,
			
			get = function(self)
				return self._font or self._theme.font
			end
		},
		
		textColor = {
			set = function(self, color)
				self._text_color = color
				
				self:_changed()
			end,
			
			get = function(self)
				return self._text_color or self._theme.text
			end
		}
	}
	
}