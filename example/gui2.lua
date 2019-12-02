--@name GUI2 Example
--@include ../lib/gui2.lua
--@client

GUI = require("../lib/gui2.lua")
local gui = GUI()
-- gui.theme = "light"

local text_block = "Satisfied conveying an dependent contented he gentleman agreeable do be. Warrant private blushes removed an in equally totally if. Delivered dejection necessary objection do mr prevailed. Mr feeling do chiefly cordial in do. Water timed folly right aware if oh truth. Imprudence attachment him his for sympathize. Large above be to means. Dashwood do provided stronger is. But discretion frequently sir the she instrument unaffected admiration everything."

-- Default themes
local lighttheme = gui:create("button")
lighttheme.pos = Vector(50, 50)
lighttheme.size = Vector(100, 50)
lighttheme.text = "Light Theme"
lighttheme.onClick = function(self)
	gui.theme = "light"
end

local darktheme = gui:create("button")
darktheme.pos = Vector(150, 50)
darktheme.size = Vector(100, 50)
darktheme.text = "Dark Theme"
darktheme.onClick = function(self)
	gui.theme = "dark"
end

local customtheme = gui:create("button")
customtheme.pos = Vector(250, 50)
customtheme.size = Vector(100, 50)
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

-- Button with double click callback
local button = gui:create("button")
button.pos = Vector(50, 150)
button.size = Vector(200, 50)
button.text = "Double click on me"
button.onDoubleClick = function(self)
	self.text = "Good Job :D"
	
	timer.simple(1, function()
		self.text = "Double click on me"
	end)
end

-- Button that is toggable
local button = gui:create("button")
button.pos = Vector(300, 150)
button.size = Vector(150, 50)
button.text = "Toggle"
button.toggle = true


-- Container
local container = gui:create("container")
container.pos = Vector(50, 250)
container.size = Vector(400, 250)

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

-- Rendering of gui
hook.add("render", "", function()
	gui:think()
	gui:render()
	
	if checkbox.state then
		gui:renderDebug()
	end
	
	render.setRGBA(255, 255, 255, 255)
	render.drawSimpleText(0, 0, tostring(math.round(quotaAverage() * 1000000)))
end)
