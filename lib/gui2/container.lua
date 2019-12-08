return {
	inherit = "base",
	constructor = function(self)
		self:_createShapePoly()
	end,
	
	----------------------------------------
	
	data = {
		_corner_style = {},
		_corner_size = {},
		_border_size = false,
		
		_main_color = false,
		
		_main_matrix = nil,
		_mask_poly = nil,
		
		------------------------------
		
		_postCreateShapePoly = function(self)
			-- Used by elements that inherit and want to adjust things after the shape poly has been created
		end,
		
		_createShapePoly = function(self)
			local stl, str, sbr, sbl = self:getCornerStyle()
			local ztl, ztr, zbr, zbl = self:getCornerSize()
			local w, h = self._w, self._h
			local poly = {}
			
			-- Top Left
			if stl == 0 then
				table.insert(poly, {x = 0, y = 0})
			else
				for i = 0, 9, stl == 1 and 1 or 9 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = ztl - math.cos(rad) * ztl, y = ztl - math.sin(rad) * ztl})
				end
			end
			
			-- Top Right
			if str == 0 then
				table.insert(poly, {x = w, y = 0})
			else
				for i = 9, 18, str == 1 and 1 or 9 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = w - ztr - math.cos(rad) * ztr, y = ztr - math.sin(rad) * ztr})
				end
			end
			
			-- Bottom Right
			if sbr == 0 then
				table.insert(poly, {x = w, y = h})
			else
				for i = 18, 27, sbr == 1 and 1 or 9 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = w - zbr - math.cos(rad) * zbr, y = h - zbr - math.sin(rad) * zbr})
				end
			end
			
			-- Bottom Left
			if sbl == 0 then
				table.insert(poly, {x = 0, y = h})
			else
				for i = 27, 36, sbl == 1 and 1 or 9 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = zbl - math.cos(rad) * zbl, y = h - zbl - math.sin(rad) * zbl})
				end
			end
			
			self._mask_poly = poly
			self:_postCreateShapePoly()
		end,
		
		_sizeChanged = function(self)
			self:_createShapePoly()
		end,
		
		------------------------------
		
		_customRenderMask = function(self, w, h)
			render.setRGBA(math.random(100, 256), math.random(100, 256), math.random(100, 256), 100)
			render.drawPoly(self._mask_poly)
		end,
		
		_customInputMask = function(self, cx, cy)
			local stl, str, sbr, sbl = self:getCornerStyle()
			local ztl, ztr, zbr, zbl = self:getCornerSize()
			local w, h = self._w, self._h
			
			local function out(x, y, s, z)
				if s == 0 then
					return false
				elseif s == 1 then
					-- https://i.imgur.com/uvhJnv9.png
					local x, y = math.abs(x / z), math.abs(y / z)
					
					if x > 1 or y > 1 then return false end
					
					local x, y = x - 1, y - 1
					if math.sqrt(x * x + y * y) < 1 then return false end
					
					return true
				else
					return math.abs(x) / z + math.abs(y) / z < 1
				end
			end
			
			if out(cx,     cy,     stl, ztl) then return false end
			if out(cx - w, cy,     str, ztr) then return false end
			if out(cx - w, cy - h, sbr, zbr) then return false end
			if out(cx,     cy - h, sbl, zbl) then return false end
			
			return true
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			render.setColor(self.mainColor)
			render.drawRect(0, 0, w, h)
		end
	},
	
	----------------------------------------
	
	properties = {
		cornerStyle = {
			set = function(self, tl, tr, br, bl)
				if type(l) == "table" then
					self._corner_style = {tl = tl.tl, tr = tl.tr, br = tl.br, bl = tl.bl}
				else
					self._corner_style = {tl = tl, tr = tr or tl, br = br or tl, bl = bl or tl}
				end
				
				self:_createShapePoly()
				self:_changed(true)
			end,
			
			get = function(self)
				local t = self._corner_style
				local d = self._theme.cornerStyle
				
				return t.tl or d, t.tr or d, t.br or d, t.bl or d
			end
		},
		
		cornerSize = {
			set = function(self, tl, tr, br, bl)
				if type(l) == "table" then
					self._corner_size = {tl = tl.tl, tr = tl.tr, br = tl.br, bl = tl.bl}
				else
					self._corner_size = {tl = tl, tr = tr or tl, br = br or tl, bl = bl or tl}
				end
				
				self:_createShapePoly()
				self:_changed(true)
			end,
			
			get = function(self)
				local t = self._corner_size
				local d = self._theme.cornerSize
				
				return t.tl or d, t.tr or d, t.br or d, t.bl or d
			end
		},
		
		------------------------------
		
		mainColor = {
			set = function(self, color)
				self._main_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				local clr = self._main_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.primaryColor
			end
		}
	}
	
}