--@name GUI2 Example
--@include ../lib/gui2.lua
--@client

GUI = require("../lib/gui2.lua")
local gui = GUI()
-- gui.theme = "light"

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

local button = gui:create("button")
button.pos = Vector(300, 150)
button.size = Vector(150, 50)
button.text = "Toggle"
button.toggle = true


local container = gui:create("container")
container.pos = Vector(50, 250)
container.size = Vector(400, 250)

local label = gui:create("label", container)
label.pos = Vector(120, 10)
label.size = Vector(400, 30)
label.text = "Label"
label.textAlignmentX = 0
label.textAlignmentY = 3

-- Slider
local slider = gui:create("slider", container)
slider.pos = Vector(25, 50)
slider.size = Vector(150, 20)
slider.max = 360
slider.round = 0
slider.onChange = function(self, value)
	gui.theme.accent = Color(value, 0.5, 1):hsvToRGB()
end

local slider_style = gui:create("button", container)
slider_style.pos = Vector(200, 50)
slider_style.size = Vector(150, 20)
slider_style.text = "Change slider style"
slider_style.onClick = function()
	slider.style = slider.style == 1 and 2 or 1
end

-- Checkbox
local checkbox = gui:create("checkbox", container)
checkbox.pos = Vector(25, 100)
checkbox.size = Vector(150, 20)
checkbox.text = "Debug Rendering"

for i = 1, 3 do
	local checkbox_style = gui:create("button", container)
	checkbox_style.pos = Vector(150 + i * 50, 100)
	checkbox_style.size = Vector(50, 20)
	checkbox_style.text = "Style " .. i
	checkbox_style.onClick = function()
		checkbox.style = i
	end
end

hook.add("render", "", function()
	gui:think()
	gui:render()
	
	if checkbox.state then
		gui:renderDebug()
	end
	
	render.setRGBA(255, 255, 255, 255)
	render.drawSimpleText(0, 0, tostring(math.round(quotaAverage() * 1000000)))
end)
