local tri = {
	{x = 0, y = 0},
	{x = -1, y = 0},
	{x = 0, y = -1}
}
local rect = {
	{x =  0.5, y =  0.5},
	{x = -0.5, y =  0.5},
	{x = -0.5, y = -0.5},
	{x =  0.5, y = -0.5}
}

return {
	inherit = "container",
	constructor = function(self)
		self._inner = self._gui:create("base", self)
		self._inner.translucent = true
		self._inner.dock = 1
		
		self:_calculateInner()
	end,
	
	----------------------------------------
	
	data = {
		_title = "",
		_title_font = false,
		_title_color = false,
		_title_alignment_x = 1,
		_title_alignment_y = 1,
		_title_height = 20,
		
		_min_x = 50,
		_min_y = 50,
		_dragcorner_size = 10,
		_animation_speed = false,
		
		_dragable = true,
		_closeable = true,
		_resizeable = true,
		
		_inner = false,
		_grab = false,
		_close_hovering = false,
		_close_hoverprogress = 0,
		
		------------------------------
		
		_calculateInner = function(self)
			local b = self.borderSize
			local th = self._title_height
			
			self._inner:setDockMargin(b, th, b, b)
		end,
		
		_sizeChanged = function(self)
			self:_calculateInner()
		end,
		
		------------------------------
		
		_think = function(self, dt)
			local x, y = self._gui:getCursorPos(self.parent)
			local g = self._grab
			
			if x and g then
				if g.move then
					local nx = x - g.x
					local ny = y - g.y
					
					if nx ~= self._x or ny ~= self._y then
						self.x = nx
						self.y = ny
					end
				else
					local nw = math.max(self._min_x, math.floor(x - self._x + g.x))
					local nh = math.max(self._min_y, math.floor(y - self._y + g.y))
					
					if nw ~= self._w or nh ~= self._h then
						if g.size then
							self.w = nw
							self.h = nh
						elseif g.sizex then
							self.w = nw
						elseif g.sizey then
							self.h = nh
						end
					end
				end
			end
			
			if self._closeable then
				if self._close_hovering then
					if self._close_hoverprogress < 1 then
						self._close_hoverprogress = math.min(1, self._close_hoverprogress + dt * self.animationSpeed)
						self:_changed(true)
					end
				elseif self._close_hoverprogress > 0 then
					self._close_hoverprogress = math.max(0, self._close_hoverprogress - dt * self.animationSpeed)
					self:_changed(true)
				end
			end
		end,
		
		_press = function(self)
			local x, y = self._gui:getCursorPos(self)
			local b = self.borderSize
			
			if y < self._title_height then
				if x > self._w - self._title_height and self._closeable then
					if not self:onClose() then
						self:remove()
					end
				elseif self._dragable then
					self._grab = {move = true, x = x, y = y}
					self:_cursorMode(GUI.CURSORMODE.DRAGGING)
				end
			elseif self._resizeable then
				local ox, oy = self._w - x, self._h - y
				
				if self._w - x + self._h - y <= self._dragcorner_size then
					self._grab = {size = true, x = ox, y = oy}
					self:_cursorMode(GUI.CURSORMODE.RESIZE)
				elseif y > self._h - b then
					self._grab = {sizey = true, x = ox, y = oy}
					self:_cursorMode(GUI.CURSORMODE.RESIZEY)
				elseif x > self._w - b then
					self._grab = {sizex = true, x = ox, y = oy}
					self:_cursorMode(GUI.CURSORMODE.RESIZEX)
				end
			end
			
			self:focus()
		end,
		
		_release = function(self)
			if self._grab then
				self._grab = false
				self:_cursorMode(GUI.CURSORMODE.NORMAL)
			end
		end,
		
		_hover = function(self)
			local x, y = self._gui:getCursorPos(self)
			
			if x > self._w - self._title_height and y < self._title_height then
				self._close_hovering = true
				self:_cursorMode(GUI.CURSORMODE.CLICKABLE)
			elseif self._close_hovering then
				self._close_hovering = false
				self:_cursorMode(GUI.CURSORMODE.NORMAL)
			end
		end,
		
		_hoverEnd = function(self)
			if self._close_hovering then
				self._close_hovering = false
				self:_cursorMode(GUI.CURSORMODE.NORMAL)
			end
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			self.base()
			
			local b = self.borderSize
			local b2 = b * 2
			local th = self._title_height
			local th2 = th / 2
			local tw = self._closeable and w - th or w
			
			render.setMaterial()
			
			render.setColor(self.secondaryColor)
			render.drawRect(b, th - b, w - b2, b)
			
			-- Drag corner
			if self._dragable then
				local m = Matrix()
				m:setTranslation(Vector(w, h))
				m:setScale(Vector(self._dragcorner_size))
				render.pushMatrix(m)
				render.setColor(self.secondaryColor)
				render.drawPoly(tri)
				render.popMatrix()
			end
			
			local ax, ay = self._title_alignment_x, self._title_alignment_y
			render.setFont(self.titleFont)
			render.setColor(self.titleColor)
			render.drawSimpleText(ax == 0 and b or (ax == 1 and tw / 2 or tw - b), ay == 3 and b or (ay == 1 and th2 or th), self._title, ax, ay)
			
			if self._closeable then
				render.setColor(self.secondaryColor)
				render.drawRect(w - th, b, b, th - b2)
				
				render.setColor(self.secondaryColor * (1 - self._close_hoverprogress) + self.titleColor * self._close_hoverprogress)
				local m = Matrix()
				m:setTranslation(Vector(w - th2, th2))
				m:setAngles(Angle(0, 45, 0))
				m:setScale(Vector(b, th - b2))
				render.pushMatrix(m)
				render.drawPoly(rect)
				render.popMatrix()
				
				m:setScale(Vector(1, 1))
				m:setAngles(Angle(0, 135, 0))
				m:setScale(Vector(b, th - b2))
				render.pushMatrix(m)
				render.drawPoly(rect)
				render.popMatrix()
			end
		end,
		
		onDrag = function(self) end,
		onClose = function(self) --[[retrun true to supress the default removal of the element]] end,
		onResize = function(self) end
		
	},
	
	----------------------------------------
	
	properties = {
		title = {
			set = function(self, text)
				self._title = text
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._title
			end
		},
		
		titleFont = {
			set = function(self, font)
				self._title_font = font
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._title_font or self._theme.font
			end
		},
		
		titleColor = {
			set = function(self, color)
				self._title_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._title_color or self._theme.textColor
			end
		},
		
		titleAlignmentX = {
			set = function(self, x)
				self._title_alignment_x = x
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._title_alignment_x
			end
		},
		
		titleAlignmentY = {
			set = function(self, y)
				self._title_alignment_y = y
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._title_alignment_y
			end
		},
		
		titleAlignment = {
			set = function(self, x, y)
				self._title_alignment_x = x
				self._title_alignment_y = y
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._title_alignment_x, self._title_alignment_y
			end
		},
		
		titleHeight = {
			set = function(self, value)
				self._title_height = value
				
				self:_changed(true)
				self:_calculateInner()
			end,
			
			get = function(self)
				return self._title_height
			end
		},
		
		------------------------------
		
		animationSpeed = {
			set = function(self, value)
				self._animation_speed = value
			end,
			
			get = function(self)
				return self._animation_speed or self._theme.animationSpeed
			end
		},
		
		dragcornerSize = {
			set = function(self, value)
				self._dragcorner_size = value
			end,
			
			get = function(self)
				return self._dragcorner_size
			end
		},
		
		minSizeX = {
			set = function(self, x)
				self._min_x = x
			end,
			
			get = function(self)
				return self._min_x
			end
		},
		
		minSizeY = {
			set = function(self, y)
				self._min_y = y
			end,
			
			get = function(self)
				return self._min_y
			end
		},
		
		minSize = {
			set = function(self, x, y)
				self._min_x = x
				self._min_y = y
			end,
			
			get = function(self)
				return self._min_x, self._min_y
			end
		},
		
		------------------------------
		
		dragable = {
			set = function(self, state)
				self._dragable = state
			end,
			
			get = function(self)
				return self._dragable
			end
		},
		
		closeable = {
			set = function(self, state)
				self._closeable = state
			end,
			
			get = function(self)
				return self._closeable
			end
		},
		
		resizeable = {
			set = function(self, state)
				self._resizeable = state
			end,
			
			get = function(self)
				return self._resizeable
			end
		},
		
		------------------------------
		
		inner = {
			get = function(self)
				return self._inner
			end
		}
	}
	
}