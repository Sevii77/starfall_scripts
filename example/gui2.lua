--@name GUI2 Example
--@include ../lib/gui2.lua
--@client

GUI = require("../lib/gui2.lua")
local gui = GUI()

local text_block = "Satisfied conveying an dependent contented he gentleman agreeable do be. Warrant private blushes removed an in equally totally if. Delivered dejection necessary objection do mr prevailed. Mr feeling do chiefly cordial in do. Water timed folly right aware if oh truth. Imprudence attachment him his for sympathize. Large above be to means. Dashwood do provided stronger is. But discretion frequently sir the she instrument unaffected admiration everything."
local debug_rendering = false

do
	-- Default themes
	local lighttheme = gui:create("button")
	lighttheme.pos = Vector(6, 26)
	lighttheme.size = Vector(100, 40)
	lighttheme.text = "Light Theme"
	lighttheme.onClick = function(self)
		gui.theme = "light"
	end
	
	local darktheme = gui:create("button")
	darktheme.pos = Vector(106, 26)
	darktheme.size = Vector(100, 40)
	darktheme.text = "Dark Theme"
	darktheme.onClick = function(self)
		gui.theme = "dark"
	end
	
	-- Random theme
	local customtheme = gui:create("button")
	customtheme.pos = Vector(206, 26)
	customtheme.size = Vector(100, 40)
	customtheme.text = "Art Theme"
	customtheme.onClick = function(self)
		local function randclr()
			return Color(math.random(0, 256), math.random(0, 256), math.random(0, 256))
		end
		
		-- We only set the theme to a table of colors, since it will keep old values if new ones are not supplied
		gui.theme = {
			mainColor = randclr(),
			secondaryColor = randclr(),
			accentColor = randclr(),
			activeColor = randclr(),
			hoverColor = randclr(),
			activeHoverColor = randclr(),
			textColor = randclr()
		}
	end
	
	-- FPS slider
	local fps_limit = gui:create("slider")
	fps_limit.pos = Vector(306, 26)
	fps_limit.size = Vector(100, 20)
	fps_limit:setRange(10, 300)
	fps_limit.round = -1
	fps_limit.value = gui.fpsLimit
	fps_limit.style = 2
	fps_limit.onChange = function(self, value)
		gui.fpsLimit = value
	end
	
	local label = gui:create("label")
	label.pos = Vector(306, 46)
	label.size = Vector(100, 20)
	label.text = "FPS Limiter"
end

do
	-- Button with double click callback
	local button = gui:create("button")
	button.pos = Vector(6, 100)
	button.size = Vector(150, 50)
	button.text = "Double click on me"
	button.onDoubleClick = function(self)
		self.text = "Good Job :D"
		
		timer.simple(1, function()
			self.text = "Double click on me"
		end)
	end
	
	-- Button that is toggable
	local button = gui:create("button")
	button.pos = Vector(6, 150)
	button.size = Vector(150, 50)
	button.text = "Toggle"
	button.toggle = true
end

do
	-- Frame
	local frame = gui:create("frame")
	frame.pos = Vector(206, 100)
	frame.size = Vector(200, 100)
	frame.title = "frame"
	
	local frame = gui:create("frame", frame.inner)
	frame.pos = Vector(0, 0)
	frame.size = Vector(160, 100)
	frame.title = "Cool frame"
	
	--[[local button = gui:create("button", frame.inner)
	button.text = "button in\na frame"
	button.dock = 1
	button.dockMargin = {l = 5, t = 5, r = 5, b = 5}]]
	
	local holder = gui:create("container", frame.inner)
	holder.dock = GUI.DOCK.FILL
	holder:setDockMargin(5, 5, 5, 5)
	
	local left = gui:create("button", holder)
	left.w = 30
	left.text = "left"
	left.dock = GUI.DOCK.LEFT
	
	local right = gui:create("button", holder)
	right.w = 30
	right.text = "right"
	right.dock = GUI.DOCK.RIGHT
	
	local top = gui:create("button", holder)
	top.h = 20
	top.text = "top"
	top.dock = GUI.DOCK.TOP
	
	local bottom = gui:create("button", holder)
	bottom.h = 20
	bottom.text = "bottom"
	bottom.dock = GUI.DOCK.BOTTOM
	
	local fill = gui:create("button", holder)
	fill.text = "fill"
	fill.dock = GUI.DOCK.FILL
	fill.onClick = function(self)
		holder.enabled = false
		
		timer.simple(1, function()
			holder.enabled = true
		end)
	end
end

do
	-- Container
	local container = gui:create("container")
	container.pos = Vector(6, 240)
	container.size = Vector(400, 266)
	
	-- Label with text wrapping
	local label = gui:create("label", container)
	label.pos = Vector(25, 10)
	label.size = Vector(350, 60)
	label.text = text_block
	label.textAlignmentX = 0
	label.textAlignmentY = 4
	label.textWrapping = true
	
	-- Slider
	local slider = gui:create("slider", container)
	slider.pos = Vector(25, 80)
	slider.size = Vector(150, 20)
	slider.min = 0
	slider.max = 360
	slider.round = 0
	slider.onChange = function(self, value)
		local clr = Color(value, 0.5, 1):hsvToRGB()
		
		gui.theme.accentColor = clr
		gui.theme.activeColor = clr
		gui.theme.activeHoverColor = clr * 0.8
	end
	
	local slider_style = gui:create("button", container)
	slider_style.pos = Vector(225, 80)
	slider_style.size = Vector(150, 20)
	slider_style.text = "Change slider style"
	slider_style.onClick = function()
		slider.style = slider.style == 1 and 2 or 1
	end
	
	-- Checkbox
	local checkbox = gui:create("checkbox", container)
	checkbox.pos = Vector(25, 120)
	checkbox.size = Vector(150, 20)
	checkbox.text = "Debug Rendering"
	checkbox.onChange = function(self, state)
		debug_rendering = state
	end
	
	for i = 1, 3 do
		local checkbox_style = gui:create("button", container)
		checkbox_style.pos = Vector(175 + i * 50, 120)
		checkbox_style.size = Vector(50, 20)
		checkbox_style.text = "Style " .. i
		checkbox_style.onClick = function()
			checkbox.style = i
		end
	end
	
	local checkbox_fb = gui:create("button", container)
	checkbox_fb.pos = Vector(225, 140)
	checkbox_fb.size = Vector(150, 20)
	checkbox_fb.text = "Full Borders"
	checkbox_fb.toggle = true
	checkbox_fb.onClick = function(self)
		checkbox.fullBorders = self.state
	end
	
	-- Text
	local s = ""
	for k, v in pairs(string.split(text_block, " ")) do
		s = s .. v .. (k % 10 == 0 and "\n" or " ")
	end
	
	local text = gui:create("text", container)
	text.pos = Vector(200, 170)
	text.text = s
	text.textAlignmentY = 3
end

do -- Custom element with custom masks example
	GUI.registerElement("rounded_button", {
		inherit = "button",
		constructor = function(self)
		
		end,
		
		data = {
			_corner_size = 10,
			_mask_poly = {},
			
			--
			
			_calculateMaskPoly = function(self)
				local cs = self._corner_size
				local w, h = self._w, self._h
				local poly = {}
				
				-- Top Left
				for i = 0, 9 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = cs - math.cos(rad) * cs, y = cs - math.sin(rad) * cs})
				end
				
				-- Top Right
				for i = 9, 18 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = w - cs - math.cos(rad) * cs, y = cs - math.sin(rad) * cs})
				end
				
				-- Bottom Right
				for i = 18, 27 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = w - cs - math.cos(rad) * cs, y = h - cs - math.sin(rad) * cs})
				end
				
				-- Bottom Left
				for i = 27, 36 do
					local rad = i / 18 * math.pi
					table.insert(poly, {x = cs - math.cos(rad) * cs, y = h - cs - math.sin(rad) * cs})
				end
				
				self._mask_poly = poly
			end,
			
			_sizeChanged = function(self)
				self:_calculateMaskPoly()
			end,
			
			--
			
			_invert_render_mask = false,
			
			_custonRenderMask = function(self, w, h)
				-- We use a poly here instead of roundedBox because masks dont support texture filtering
				render.drawPoly(self._mask_poly)
			end,
			
			_custonInputMask = function(self, cx, cy)
				-- We also wanna have a input mask so if we hover over the rounded corners it doesnt activate
				local cs = self._corner_size
				local w, h = self._w, self._h
				
				local function out(x, y)
					-- https://i.imgur.com/uvhJnv9.png
					local x, y = math.abs(x / cs), math.abs(y / cs)
					
					if x > 1 or y > 1 then return false end
					
					local x, y = x - 1, y - 1
					if math.sqrt(x * x + y * y) < 1 then return false end
					
					return true
				end
				
				if out(cx, cy) then return false end
				if out(cx - w, cy) then return false end
				if out(cx - w, cy - h) then return false end
				if out(cx, cy - h) then return false end
				
				return true
			end
		},
		
		properties = {
			cornerSize = {
				set = function(self, value)
					self._corner_size = value
					self:_calculateMaskPoly()
				end,
				
				get = function(self)
					return self._corner_size
				end
			}
		}
	})
	
	local rounded = gui:create("rounded_button")
	rounded.pos = Vector(416, 240)
	rounded.size = Vector(90, 266)
	rounded.cornerSize = 30
	rounded.text = "a\nfancy\nrounded\nbutton\n:)"
end

-- Rendering of gui
hook.add("render", "", function()
	gui:think()
	gui:render()
	gui:renderCursor()
	
	if debug_rendering then
		gui:renderDebug()
	end
	
	render.setRGBA(255, 255, 255, 255)
	render.drawSimpleText(0, 0, tostring(math.round(quotaAverage() * 1000000)))
end)
