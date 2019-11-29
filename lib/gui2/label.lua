return {
	inherit = "container",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_text = "",
		_font = false,
		_text_color = false,
		_text_alignment_x = 1,
		_text_alignment_y = 1,
		
		_text_height = 0,
		
		------------------------------
		
		onDraw = function(self, w, h)
			self.base()
			
			local ax, ay = self._text_alignment_x, self._text_alignment_y
			local d = self.borderSize
			
			render.setFont(self.font)
			render.setColor(self.textColor)
			render.drawSimpleText(ax == 0 and d or (ax == 1 and w / 2 or w - d), ay == 3 and d or (ay == 1 and h / 2 or h - d), self.text, ax, ay)
		end
	},
	
	----------------------------------------
	
	properties = {
		text = {
			set = function(self, text)
				self._text = text
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._text
			end
		},
		
		font = {
			set = function(self, font)
				self._font = font
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._font or self._theme.font
			end
		},
		
		textColor = {
			set = function(self, color)
				self._text_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._text_color or self._theme.text
			end
		},
		
		textAlignmentX = {
			set = function(self, x)
				self._text_alignment_x = x
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._text_alignment_x
			end
		},
		
		textAlignmentY = {
			set = function(self, y)
				self._text_alignment_y = y
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._text_alignment_y
			end
		},
		
		textAlignment = {
			set = function(self, x, y)
				self._text_alignment_x = x
				self._text_alignment_y = y
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._text_alignment_x, self._text_alignment_y
			end
		}
	}
	
}