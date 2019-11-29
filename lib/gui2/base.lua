return {
	constructor = function(self)
		self._pos = Vector()
		self._size = Vector(30, 30)
	end,
	
	----------------------------------------
	
	data = {
		_theme = true, -- Set in the core when created
		
		_pos = true,
		_x = 0,
		_y = 0,
		
		_size = true,
		_w = 0,
		_h = 0,
		
		------------------------------
		
		_changed = function(self, simple)
			--[[
				Created in core
				
				called whenever it needs to be redrawn
				
				simple: is true if only the current element needs to be redrawn
			]]
		end,
		
		_draw = function(self, theme)
			self._theme = theme
			
			self:onDraw(self._w, self._h)
			self:onDrawOver(self._w, self._h)
		end,
		
		_think = function(self, cx, cy)
			
		end,
		
		_press = function(self)
			
		end,
		
		_pressRight = function(self)
			
		end,
		
		_pressDouble = function(self)
			
		end,
		
		_release = function(self)
			
		end,
		
		_releaseRight = function(self)
			
		end,
		
		_hover = function(self)
			
		end,
		
		_hoverStart = function(self)
			
		end,
		
		_hoverEnd = function(self)
			
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			render.drawRect(w, h)
		end,
		onDrawOver = function(self, size) end,
	},
	
	----------------------------------------
	
	-- No need to have stuff like :setPos in data, since those will be auto generated from properties
	properties = {
		pos = {
			set = function(self, pos)
				self._pos = pos
				self._x = pos.x
				self._y = pos.y
				
				self:_changed()
			end,
			
			get = function(self)
				return self._pos
			end
		},
		
		x = {
			set = function(self, x)
				self._pos.x = x
				self._x = x
				
				self:_changed()
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
			end,
			
			get = function(self)
				return self._y
			end
		},
		
		------------------------------
		
		size = {
			set = function(self, size)
				self._size = size
				self._w = size.x
				self._h = size.y
				
				self:_changed()
			end,
			
			get = function(self)
				return self._size
			end
		},
		
		w = {
			set = function(self, w)
				self._size.x = w
				self._w = w
				
				self:_changed()
			end,
			
			get = function(self)
				return self._w
			end
		},
		
		h = {
			set = function(self, h)
				self._size.y = h
				self._h = h
				
				self:_changed()
			end,
			
			get = function(self)
				return self._h
			end
		}
	}
	
}