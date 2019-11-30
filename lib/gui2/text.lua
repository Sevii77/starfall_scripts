return {
	inherit = "base",
	constructor = function(self)
		self._true_pos = self.pos
	end,
	
	----------------------------------------
	
	data = {
		_text = "",
		_font = false,
		_text_color = false,
		_text_alignment_x = 1,
		_text_alignment_y = 1,
		
		--_text_size = {w = 0, h = 0},
		
		------------------------------
		
		_textChanged = function(self)
			render.setFont(self.font)
			local w, h = render.getTextSize(self._text)
			local ax, ay = self._text_alignment_x, self._text_alignment_y
			
			self._true_pos = self._pos
			
			self._pos = Vector(self._x - (ax == 0 and 0 or (ax == 1 and w / 2 or w)), self._y - (ay == 3 and 0 or (ay == 1 and h / 2 or h)))
			self._size = Vector(w, h)
			self._w, self._h = w, h
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			render.drawText(0, 0, self.text)
		end
	},
	
	----------------------------------------
	
	properties = {
		pos = {
			set = function(self, pos)
				self._x = pos.x
				self._y = pos.y
				
				self:_changed()
				self:_textChanged()
			end,
			
			get = function(self)
				return Vector(self._x, self._y)
			end
		},
		
		x = {
			set = function(self, x)
				self._pos.x = x
				self._x = x
				
				self:_changed()
				self:_textChanged()
			end,
			
			get = function(self)
				return self._x
			end
		},
		
		y = {
			set = function(self, y)
				self._pos.y = y
				self._y = y
				
				self:_changed()
				self:_textChanged()
			end,
			
			get = function(self)
				return self._y
			end
		},
		
		------------------------------
		
		size = {
			get = function(self)
				return self._size
			end
		},
		
		w = {
			get = function(self)
				return self._w
			end
		},
		
		h = {
			get = function(self)
				return self._h
			end
		},
		
		------------------------------
		
		text = {
			set = function(self, text)
				self._text = text
				
				self:_changed(true)
				self:_textChanged()
			end,
			
			get = function(self)
				return self._text
			end
		},
		
		font = {
			set = function(self, font)
				self._font = font
				
				self:_changed(true)
				self:_textChanged()
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
				self:_textChanged()
			end,
			
			get = function(self)
				return self._text_alignment_x
			end
		},
		
		textAlignmentY = {
			set = function(self, y)
				self._text_alignment_y = y
				
				self:_changed(true)
				self:_textChanged()
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
				self:_textChanged()
			end,
			
			get = function(self)
				return self._text_alignment_x, self._text_alignment_y
			end
		}
	}
	
}