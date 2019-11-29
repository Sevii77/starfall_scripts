--@name GUI2 Example
--@include ../lib/gui2.lua
--@client

GUI = require("../lib/gui2.lua")
local gui = GUI()
-- gui.theme = "light"

local container = gui:create("container")
container.pos = Vector(100, 300)
container.size = Vector(100, 60)

local label = gui:create("label", container)
label.pos = Vector(20, 20)
label.size = Vector(50, 30)
label.text = "Label"

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
button.text = "Double click on me :D"
button.onDoubleClick = function(self)
	button.text = "double click"
	
	timer.simple(1, function()
		button.text = "Button :D"
	end)
end

hook.add("render", "", function()
	gui:think()
	gui:render()
end)
