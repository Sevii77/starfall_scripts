return {
	constructor = function(self)
		self._pos = Vector()
		self._size = Vector(30, 30)
	end,
	
	----------------------------------------
	
	data = {
		_gui = true, -- Set in the core when created
		_theme = true, -- Set in the core when created
		
		_enabled = true,
		_translucent = false, -- Allow mouse rays to pass through
		
		_pos = true,
		_x = 0,
		_y = 0,
		
		_size = true,
		_w = 0,
		_h = 0,
		
		------------------------------
		
		remove = function(self)
			local gui = self._gui
			
			for child, child_object in pairs(gui._object_refs[self].children) do
				child:remove()
			end
			
			gui._remove_queue[self] = true
		end,
		
		focus = function(self)
			self._gui:focus(self)
		end,
		
		------------------------------
		-- Docking
		-- enum list available through GUI.DOCK
		
		_dock = {
			type = 0,
			margin = {l = 0, t = 0, r = 0, b = 0},
			padding = {l = 0, t = 0, r = 0, b = 0}
		},
		
		_updateDockingParent = function(self)
			local parent = self.parent
			if parent then
				parent:_updateDocking()
			else
				self:_updateDocking()
			end
		end,
		
		_updateDocking = function(self)
			-- Children resize and stuff
			local dock = self._dock
			local sx, sy, sw, sh = dock.padding.l, dock.padding.t, self._w - dock.padding.l - dock.padding.r, self._h - dock.padding.t - dock.padding.b
			
			local children = self.children
			for i = #children, 1, -1 do
				local child = children[i]
				local dock = child._dock
				
				local dt = dock.type
				if dt ~= 0 then
					local ox, oy, ow, oh = child._x, child._y, child._w, child._h
					local l, t, r, b = dock.margin.l, dock.margin.t, dock.margin.r, dock.margin.b
					local x, y, w, h
					
					-- Dock stuff
					if dt == 1 then
						-- FILL
						x, y, w, h = sx + l, sy + t, sw - l - r, sh - t - b
						sw, sy = 0, 0
					elseif dt == 2 then
						-- LEFT
						x, y, w, h = sx + l, sy + t, math.min(sw - l - r, ow), sh - t - b
						sx, sw = sx + w, sw - w
					elseif dt == 3 then
						-- RIGHT
						y, w, h = sy + t, math.min(sw - l - r, ow), sh - t - b
						x = sx + sw - w
						sw = sw - w
					elseif dt == 4 then
						-- TOP
						x, y, w, h = sx + l, sy + t, sw - l - r, math.min(sh - t - b, oh)
						sy, sh = sy + h, sh - h
					elseif dt == 5 then
						-- BOTTOM
						x, w, h = sx + l, sw - l - r, math.min(sh - t - b, oh)
						y = sy + sh - h
						sh = sh - h
					end
					
					-- Margin
					-- x = x + l
					-- y = y + t
					-- w = w - l - r
					-- h = h - t - b
					
					-- Apply
					if x ~= ox or y ~= oy then
						child._pos.x = x
						child._pos.y = y
						child._x = x
						child._y = y
					end
					
					-- For some reason w and ow are always the same? i dont understand
					--if w ~= ow or h ~= oh then
						child._size.x = w
						child._size.y = h
						child._w = w
						child._h = h
						
						child:_updateDocking()
						child:_changed()
					--end
					
					if sw == 0 or sh == 0 then
						break
					end
				end
			end
		end,
		
		------------------------------
		
		_changed = function(self, simple)
			self._gui:_changed(self, simple)
			
			--[[
				called whenever it needs to be redrawn
				
				simple: is true if only the current element needs to be redrawn
			]]
		end,
		
		_cursorMode = function(self, mode, from)
			local gui = self._gui
			if gui._cursor_mode == from or from == nil then
				gui._cursor_mode = mode
			end
			
			--[[
				Call this to set the new mode of the cursor
				from: the mode the cursor must be in in order to be allowed to change, nil for any
				
				enum list available through GUI.CURSORMODE
			]]
		end,
		
		_draw = function(self, dt)
			self:onDraw(self._w, self._h)
			self:onDrawOver(self._w, self._h)
		end,
		
		_think = function(self, dt, cx, cy)
			
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
		
		onDraw = function(self, w, h) end,
		onDrawOver = function(self, size) end,
	},
	
	----------------------------------------
	
	-- No need to have stuff like :setPos in data, since those will be auto generated from properties
	properties = {
		enabled = {
			set = function(self, state)
				self._enabled = state
			end,
			
			get = function(self)
				return self._enabled
			end
		},
		
		translucent = {
			set = function(self, state)
				self._translucent = state
			end,
			
			get = function(self)
				return self._translucent
			end
		},
		
		parent = {
			set = function(self, parent)
				self._gui._parent_queue[self] = true
			end,
			
			get = function(self)
				return self._gui._object_refs[self].parent
			end
		},
		
		children = {
			get = function(self)
				local tbl = {}
				for _, obj in pairs(self._gui._object_refs[self].order) do
					table.insert(tbl, obj)
				end
				
				return tbl
			end
		},
		
		------------------------------
		
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
				
				self:_updateDockingParent()
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
				
				self:_updateDockingParent()
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
				
				self:_updateDockingParent()
				self:_changed()
			end,
			
			get = function(self)
				return self._h
			end
		},
		
		------------------------------
		
		dock = {
			set = function(self, dock_type)
				self._dock.type = dock_type
				
				self:_updateDockingParent()
			end,
			
			get = function(self)
				return self._dock.type
			end
		},
		
		dockMargin = {
			set = function(self, l, t, r, b)
				if type(l) == "table" then
					self._dock.margin = {l = l.l, t = l.t, r = l.r, b = l.b}
				else
					self._dock.margin = {l = l, t = t, r = r, b = b}
				end
				
				self:_updateDockingParent()
			end,
			
			get = function(self)
				local t = self._dock.margin
				
				return t.l, t.t, t.r, t.b
			end
		},
		
		dockPadding = {
			set = function(self, l, t, r, b)
				if type(l) == "table" then
					self._dock.padding = {l = l.l, t = l.t, r = l.r, b = l.b}
				else
					self._dock.padding = {l = l, t = t, r = r, b = b}
				end
				
				self:_updateDocking()
			end,
			
			get = function(self)
				local t = self._dock.padding
				
				return t.l, t.t, t.r, t.b
			end
		}
	}
	
}