local GUI = GUI

local default_layout = {
	_DEFAULT_MENU = "MENU_MAIN",
	
	MENU_MAIN = {
		icon = function(self, x, y, w, h)
			render.drawSimpleText(x + w / 2, y + h / 2, "ABC", 1, 1)
		end,
		
		{{"q", "1"}, {"w", "2"}, {"e", "3"}, {"r", "4"}, {"t", "5"}, {"y", "6"}, {"u", "7"}, {"i", "8"}, {"o", "9"}, {"p", "0"}, "BACKSPACE"},
		{"a", "s", "d", "f", "g", "h", "j", "k", "l", "CONFIRM"},
		{"SHIFT", "z", "x", "c", "v", "b", "n", "m", "!", "?", "SHIFT"},
		{"MENU_CHARS", ",", "SPACE", ".", "MENU_CHARS"}
	},
	
	MENU_CHARS = {
		icon = function(self, x, y, w, h)
			render.drawSimpleText(x + w / 2, y + h / 2, "?123", 1, 1)
		end,
		
		{{"1", "¹"}, {"2", "²"}, {"3", "³"}, "4", "5", "6", "7", "8", "9", "0", "BACKSPACE"},
		{"@", "#", "$", "_", "&", "-", "+", "(", ")", "/", "CONFIRM"},
		{"MENU_SPECIAL", "\\", "%", "*", "\"", "'", ":", ";", "!", "?", "MENU_SPECIAL"},
		{"MENU_MAIN", ",", "SPACE", ".", "MENU_MAIN"}
	},
	
	MENU_SPECIAL = {
		icon = function(self, x, y, w, h)
			render.drawSimpleText(x + w / 2, y + h / 2, "=\\<", 1, 1)
		end,
		
		{"~", "`", "|", " ", " ", " ", " ", "×", "¶", " ", "BACKSPACE"},
		{" ", " ", "€", "¥", "^", " ", "=", "{", "}", " ", "CONFIRM"},
		{"MENU_CHARS", " ", " ", " ", "©", "®", " ", "[", "]", " ", "MENU_CHARS"},
		{"MENU_MAIN", "<", "SPACE", ">", "MENU_MAIN"}
	}
}

local icons = {
	SHIFT = {
		{x = 0.5, y = 0.1},
		{x = 1,   y = 0.6},
		{x = 0.7, y = 0.6},
		{x = 0.7, y = 0.8},
		{x = 0.3, y = 0.8},
		{x = 0.3, y = 0.6},
		{x = 0,   y = 0.6}
	}
}

local utf8sub = string.sub

return {
	inherit = "container",
	constructor = function(self)
		self:setLayout()
	end,
	
	----------------------------------------
	
	data = {
		_text_color = false,
		
		_font = false,
		_newline_on_confirm = false,
		_target_element = false,
		_target_element_key = "text",
		_layout = {},
		
		_current_menu = false,
		_shift_mode = 0,
		_click_pos = false,
		_cursor = 0,
		
		_specials = {
			BACKSPACE = {
				render = function(self, x, y, w, h)
					render.drawSimpleText(x + w / 2, y + h / 2, "<<]", 1, 1)
				end,
				
				click = function(self)
					if not self._target_element then return end
					
					self._cursor = math.max(self._cursor - 1, 0)
					
					local entry = self:getEntry()
					self:modifyEntry(utf8sub(entry, 1, self._cursor) .. utf8sub(entry, self._cursor + 2))
				end
			},
			
			SHIFT = {
				render = function(self, x, y, w, h)
					local w2, h2 = w / 3, h / 3
					local xo, yo = w / 3, h / 3
					
					if self._shift_mode == 1 then
						local m = Matrix()
						m:setTranslation(Vector(x + xo, y + yo))
						m:setScale(Vector(w2, h2))
						
						render.pushMatrix(m)
						render.drawPoly(icons.SHIFT)
						render.popMatrix()
					elseif self._shift_mode == 2 then
						local m = Matrix()
						m:setTranslation(Vector(x + xo, y + yo))
						m:setScale(Vector(xo, yo))
						
						render.pushMatrix(m)
						render.drawPoly(icons.SHIFT)
						render.drawRect(0.3, 0.9, 0.4, 0.1)
						render.popMatrix()
					else
						local last = icons.SHIFT[#icons.SHIFT]
						for _, cur in ipairs(icons.SHIFT) do
							render.drawLine(x + last.x * w2 + xo, y + last.y * h2 + yo, x + cur.x * w2 + xo, y + cur.y * h2 + yo)
							
							last = cur
						end
					end
				end,
				
				click = function(self)
					self._shift_mode = (self._shift_mode + 1) % 3
					self:_changed()
				end
			},
			
			CONFIRM = {
				max = true,
				
				render = function(self, x, y, w, h)
					render.drawSimpleText(x + w / 2, y + h / 2, "<_/", 1, 1)
				end,
				
				click = function(self)
					if self._newline_on_confirm then
						self:typeString("\n")
					else
						self:onConfirm()
					end
				end
			},
			
			SPACE = {
				fill = true,
				
				render = function(self, x, y, w, h)
					render.drawRect(x + h / 4, y + h / 4, w - h / 2, h / 2)
				end,
				
				click = function(self)
					self:typeString(" ")
				end
			}
		},
		
		------------------------------
		
		getEntry = function(self)
			if not self._target_element then return "" end
			
			return self._target_element[self._target_element_key]
		end,
		
		modifyEntry = function(self, str)
			if not self._target_element then return end
			
			self._target_element[self._target_element_key] = str
		end,
		
		typeString = function(self, str)
			if not self._target_element then return end
			
			local entry = self:getEntry()
			self:modifyEntry(utf8sub(entry, 1, self._cursor) .. str .. utf8sub(entry, self._cursor + 1))
			
			self._cursor = self._cursor + 1 --string.utf8len(str)
		end,
		
		switchMenu = function(self, menu)
			if not self._layout[menu] then return end
			
			self._current_menu = self._layout[menu]
			self:_changed()
		end,
		
		------------------------------
		
		_press = function(self)
			local menu = self._current_menu
			local x, y = self._gui:getCursorPos(self)
			x = x / self._w
			y = math.floor(y / self._h * #menu) + 1
			
			for colum, key in ipairs(menu[y]) do
				if x > key.x and x < key.x + key.w then
					self._click_pos = Vector(colum, y)
					
					return
				end
			end
		end,
		
		_release = function(self)
			if self._click_pos then
				local key = self._current_menu[self._click_pos.y][self._click_pos.x].key[1]
				if self._specials[key] then
					self._specials[key].click(self)
				elseif string.sub(key, 1, 4) == "MENU" then
					self:switchMenu(key)
				else
					self:typeString(self._shift_mode ~= 0 and string.upper(key) or key)
					
					if self._shift_mode == 1 then
						self._shift_mode = 0
						self:_changed()
					end
				end
				
				self._click_pos = false
			end
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			base()
			
			render.setFont(self.font)
			
			local menu = self._current_menu
			for row, keys in ipairs(menu) do
				for colum, key in ipairs(keys) do
					local icon = key.key[1]
					
					render.setRGBA(255, 0, 255, 255)
					render.drawRect(key.x * w + 1, key.y * h + 1, key.w * w - 2, key.h * h - 2)
					
					render.setColor(self.textColor)
					if self._specials[icon] then
						self._specials[icon].render(self, key.x * w, key.y * h, key.w * w, key.h * h)
					elseif string.sub(icon, 1, 4) == "MENU" and self._layout[icon].icon then
						self._layout[icon].icon(self, key.x * w, key.y * h, key.w * w, key.h * h)
					else
						render.drawSimpleText((key.x + key.w / 2) * w, (key.y + key.h / 2) * h, self._shift_mode ~= 0 and string.upper(icon) or icon, 1, 1)
					end
				end
			end
		end,
		
		onConfirm = function(self) end
	},
	
	----------------------------------------
	
	properties = {
		mainColor = {
			set = function(self, color)
				self._main_color = color
				
				self:_changed()
			end,
			
			get = function(self)
				local clr = self._main_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.primaryColorDark
			end
		},
		
		textColor = {
			set = function(self, color)
				self._text_color = color
				
				self:_changed()
			end,
			
			get = function(self)
				local clr = self._text_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.primaryTextColor
			end
		},
		
		------------------------------
		
		font = {
			set = function(self, font)
				self._font = font
				
				self:_changed(true)
				
				if self._text_wrap then
					self._text, self._text_height = self:_wrapText(self._text_raw)
				else
					self:_setTextHeight()
				end
			end,
			
			get = function(self)
				return self._font or self._theme.font
			end
		},
		
		newlineOnConfirm = {
			set = function(self, state)
				self._newline_on_confirm = state
			end,
			
			get = function(self)
				return self._newline_on_confirm
			end
		},
		
		targetElement = {
			set = function(self, state)
				self._target_element = state
			end,
			
			get = function(self)
				return self._target_element
			end
		},
		
		targetElementKey = {
			set = function(self, key)
				self._target_element_key = ket
			end,
			
			get = function(self)
				return self._target_element_key
			end
		},
		
		layout = {
			set = function(self, layout)
				if not layout then
					layout = default_layout
				end
				
				self._layout = {}
				for k, menu in pairs(layout) do
					if string.sub(k, 1, 4) == "MENU" then
						local max_count = 0
						for _, row in ipairs(menu) do
							max_count = math.max(max_count, #row)
						end
						
						local key_w = 1 / max_count
						local key_h = 1 / #menu
						
						self._layout[k] = {icon = menu.icon}
						for row, keys in ipairs(menu) do
							self._layout[k][row] = {}
							
							local x = (max_count - #keys) / 2 / max_count
							for colum, key in ipairs(keys) do
								if type(key) ~= "table" then
									key = {key}
								end
								
								local kx = x
								local kw = key_w
								
								local special = self._specials[key[1]]
								if special then
									if special.max then
										if colum == 1 then
											kx = 0
											kw = (x + key_w)
										end if colum == #keys then
											kw = 1 - x
										end
									elseif special.fill then
										for i = 1, colum - 1 do
											self._layout[k][row][i].x = key_w * (i - 1)
											self._layout[k][row][i].w = key_w
										end
										
										kx = key_w * (colum - 1)
										kw = 1 - (#keys - 1) * key_w
										x = (colum - 2) * key_w + kw
									end
								end
								
								self._layout[k][row][colum] = {
									key = key,
									x = kx, --(colum - 1) / max_count + (max_count - #keys) / 2 / max_count,
									y = (row - 1) / #menu,
									w = kw,
									h = key_h
								}
								
								x = x + key_w
							end
						end
					end
				end
				
				self._current_menu = self._layout[layout._DEFAULT_MENU]
			end
		},
		
		------------------------------
		
		cursorPos = {
			set = function(self, pos)
				self._cursor_pos = math.clamp(pos, 0, #self:getEntry())
			end,
			
			get = function(self)
				return self._cursor_pos
			end
		}
	}
	
}