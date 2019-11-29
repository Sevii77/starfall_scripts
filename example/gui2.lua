--@client
--@include lib/gui2.lua

GUI = require("lib/gui2.lua")
local gui = GUI()
--gui.theme = "light"

local container = gui:create("container")
container.pos = Vector(100, 100)
container.size = Vector(100, 60)

local label = gui:create("label", container)
label.pos = Vector(20, 20)
label.size = Vector(50, 30)
label.text = "Label"

hook.add("render", "", function()
	gui:render()
end)
