local circle = {}
for i = 1, 32 do
	local rad = i / 16 * math.pi
	circle[i] = {x = -math.sin(rad) / 2, y = math.cos(rad) / 2}
end


return {
	inherit = "label",
	constructor = function(self)
		self.style = 1
		
		self:_setTextHeight()
	end,
	
	----------------------------------------
	
	data = {
		_background_color = false,
		_active_color = false,
		_hover_color = false,
		
		_draw_background = false,
		_animation_speed = false,
		_min = 0,
		_max = 1,
		_round = 2,
		_bar_size = 4,
		
		_value = 0,
		_progress = 0,
		_holding = false,
		
		------------------------------
		
		_styles = {
			{
				_think = function(self, dt, cx, cy)
					local anim_speed = dt * self.animationSpeed
					
					self:_animationUpdate("hover", self._hovering, anim_speed)
					self:_animationUpdate("hold", self._holding, anim_speed)
					
					if self._holding then
						if cx then
							local last = self._progress
							local progress = math.clamp((cx - self._h / 2) / (self._w - self._h), 0, 1)
							self._value = math.round(progress * (self._max - self._min) + self._min, self._round)
							self._progress = (self._value - self._min) / (self._max - self._min)
							
							if self._progress ~= last then
								self:onChange(self._value)
								self:_changed(true)
							end
						end
						
						self:onHold()
					end
				end,
				
				onDraw = function(self, w, h)
					render.setMaterial()
					
					-- Background
					if self._draw_background then
						render.setColor(self.backgroundColor)
						render.drawRect(0, 0, w, h)
					end
					
					-- Bar
					local p = self._progress
					local bh = self._bar_size
					local bw = w - h + bh
					local bo = (h - bh) / 2
					
					render.setColor(self.activeColor)
					render.drawRect(bo, bo, bw * p, bh)
					
					render.setColor(self.mainColor)
					render.drawRect(bo + bw * p, bo, bw * (1 - p), bh)
					
					-- Knob
					local m = Matrix()
					m:setTranslation(Vector((w - h) * p + h / 2, h / 2))
					m:setScale(Vector(h))
					render.pushMatrix(m)
					render.setColor(GUI.lerpColor(self.activeColor, self.hoverColor, self:getAnimation("hover")))
					render.drawPoly(circle)
					render.popMatrix()
				end,
			},
			
			
			{
				_think = function(self, dt, cx, cy)
					local anim_speed = dt * self.animationSpeed
					
					self:_animationUpdate("hover", self._hovering, anim_speed)
					self:_animationUpdate("hold", self._holding, anim_speed)
					
					if self._holding then
						if cx then
							local last = self._progress
							local progress = math.clamp(cx / self._w, 0, 1)
							self._value = math.round(progress * (self._max - self._min) + self._min, self._round)
							self._progress = (self._value - self._min) / (self._max - self._min)
							
							if self._progress ~= last then
								self:onChange(self._value)
								self:_changed(true)
							end
						end
						
						self:onHold()
					end
				end,
				
				onDraw = function(self, w, h)
					render.setMaterial()
					
					-- Bar
					local p = self._progress
					local hover = self:getAnimation("hover")
					local hcp = math.min(0.1, hover * 0.2)
					local clr = GUI.lerpColor(self.activeColor, self.hoverColor, hover)
					
					if hover > 0 then
						render.setColor(clr)
						render.drawRect(w * p, 0, w * (1 - p), h)
					end
					
					local m = Matrix()
					m:setTranslation(Vector(hcp * 0.5 * h))
					m:setScale(Vector(1 - hcp * (h / w), 1 - hcp))
					render.pushMatrix(m)
					render.setColor(self.mainColor)
					render.drawPoly(self._mask_poly)
					render.popMatrix()
					
					render.setColor(clr)
					render.drawRect(0, 0, w * p, h)
					
					-- Text
					local ax, ay = self._text_alignment_x, self._text_alignment_y
					
					render.setFont(self.font)
					render.setColor(self.textColor)
					render.drawText(ax == 0 and 0 or (ax == 1 and w / 2 or w), ay == 3 and 0 or (ay == 1 and (h - self._text_height) / 2 or h - self._text_height), tostring(self._value), ax)
				end
			}
		},
		
		------------------------------
		
		_think = function(self, dt, cx, cy)
			
		end,
		
		_press = function(self)
			self:onClick()
			
			self._holding = true
		end,
		
		_release = function(self)
			self:onRelease()
			
			self._holding = false
		end,
		
		_hover = function(self)
			self:onHover()
		end,
		
		_hoverStart = function(self)
			self:onHoverBegin()
			
			self:_cursorMode(GUI.CURSORMODE.CLICKABLE, GUI.CURSORMODE.NORMAL)
			self._hovering = true
		end,
		
		_hoverEnd = function(self)
			self:onHoverEnd()
			
			self:_cursorMode(GUI.CURSORMODE.NORMAL, GUI.CURSORMODE.CLICKABLE)
			self._hovering = false
		end,
		
		------------------------------
		
		onDraw = function(self, w, h)
			
		end,
		
		onClick = function(self) end,
		onHold = function(self) end,
		onRelease = function(self) end,
		onHoverBegin = function(self) end,
		onHoverEnd = function(self) end,
		onHover = function(self) end,
		onChange = function(self, value) end
	},
	
	----------------------------------------
	
	properties = {
		mainColor = {
			set = function(self, color)
				self._main_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				local clr = self._main_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.primaryColorLight
			end
		},
		
		backgroundColor = {
			set = function(self, color)
				self._main_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				local clr = self._background_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.primaryColorDark
			end
		},
		
		activeColor = {
			set = function(self, color)
				self._active_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				local clr = self._active_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.secondaryColor
			end
		},
		
		hoverColor = {
			set = function(self, color)
				self._hover_color = color
				
				self:_changed(true)
			end,
			
			get = function(self)
				local clr = self._hover_color
				return clr and (type(clr) == "string" and self._theme[clr] or clr) or self._theme.secondaryColorLight
			end
		},
		
		------------------------------
		
		drawBackground = {
			set = function(self, state)
				self._draw_background = state
			end,
			
			get = function(self)
				return self._draw_background
			end
		},
		
		animationSpeed = {
			set = function(self, value)
				self._animation_speed = value
			end,
			
			get = function(self)
				return self._animation_speed or self._theme.animationSpeed
			end
		},
		
		min = {
			set = function(self, min)
				self._min = min or 0
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._min
			end
		},
		
		max = {
			set = function(self, max)
				self._max = max or 1
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._max
			end
		},
		
		range = {
			set = function(self, min, max)
				self._min = min or 0
				self._max = max or 1
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._min, self._max
			end
		},
		
		round = {
			set = function(self, round)
				self._round = round
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._round
			end
		},
		
		barSize = {
			set = function(self, value)
				self._bar_size = value
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._bar_size
			end
		},
		
		------------------------------
		
		value = {
			set = function(self, value)
				self._value = value
				self._progress = (self._value - self._min) / (self._max - self._min)
				
				self:_changed(true)
			end,
			
			get = function(self)
				return self._value
			end
		}
	}
	
}