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
	button.text = "Good Job :D"
	
	timer.simple(1, function()
		button.text = "Double click on me"
	end)
end


local container = gui:create("container")
container.pos = Vector(50, 250)
container.size = Vector(400, 250)

local label = gui:create("label", container)
label.pos = Vector(120, 10)
label.size = Vector(400, 30)
label.text = "Label"

-- Slider
local slider = gui:create("slider", container)
slider.pos = Vector(25, 50)
slider.size = Vector(150, 20)

local slider_style = gui:create("button", container)
slider_style.pos = Vector(200, 50)
slider_style.size = Vector(150, 20)
slider_style.text = "Change slider style"
slider_style.onClick = function()
	slider.style = slider.style == 1 and 2 or 1
end

hook.add("render", "", function()
	gui:think()
	gui:render()
	
	render.setRGBA(255, 255, 255, 255)
	render.drawSimpleText(0, 0, tostring(math.round(quotaAverage() * 1000000)))
end)
