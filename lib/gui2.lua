--@includedir ./gui2
--@include ./class.lua
--@client

--[[
	TODO:
	have a more advanced changed system:
		if an element has changed in a minor way (changed something within the same bounds)
		make it only redraw the element itself and not the whole gui
	docking
	more elements
]]

local class, checktype = unpack(require("./class.lua"))

----------------------------------------

local themes = {
	light = {
		main = Color(220, 220, 220),
		secondary = Color(180, 180, 180),
		accent = Color(50, 255, 180),
		text = Color(30, 30, 30),
		
		borderSize = 1,
		barSize = 4,
		
		font = render.createFont("Roboto", 18, 600)
	},
	
	dark = {
		main = Color(50, 50, 50),
		secondary = Color(90, 90, 90),
		accent = Color(50, 255, 180),
		text = Color(255, 255, 255),
		
		borderSize = 1,
		barSize = 4,
		
		font = render.createFont("Roboto", 18, 600)
	}
}

----------------------------------------

local guis = {}
local clearcolor = Color(0, 0, 0, 0)

hook.add("inputPressed", "lib.gui", function(key)
	for gui, _ in pairs(guis) do
		if gui._hover_object then
			for k, _ in pairs(gui._buttons.left) do
				if key == k then
					gui._hover_object.object:_press()
					
					if timer.curtime() - gui._last_click < gui._doubleclick_time then
						gui._hover_object.object:_pressDouble()
					end
					
					gui._last_click = timer.curtime()
					
					table.insert(gui._clicking_objects.left, gui._hover_object)
				end
			end
			
			for k, _ in pairs(gui._buttons.right) do
				if key == k then
					gui._hover_object.object:_pressRight()
					
					table.insert(gui._clicking_objects.right, gui._hover_object)
				end
			end
		end
	end
end)

hook.add("inputReleased", "lib.gui", function(key)
	for gui, _ in pairs(guis) do
		for k, _ in pairs(gui._buttons.left) do
			if key == k then
				for _, obj in pairs(gui._clicking_objects.left) do
					obj.object:_release()
				end
				
				gui._clicking_objects.left = {}
			end
		end
		
		for k, _ in pairs(gui._buttons.right) do
			if key == k then
				for _, obj in pairs(gui._clicking_objects.right) do
					gui._hover_object.object:_releaseRight()
				end
				
				gui._clicking_objects.right = {}
			end
		end
	end
end)

----------------------------------------

local GUI
GUI = class {
	type = "gui",
	
	constructor = function(self, w, h)
		self._id = math.random()
		self._w = w or 512
		self._h = h or (w or 512)
		self.theme = "dark"
		self._rtid = "lib.gui:" .. self._id
		
		render.createRenderTarget(self._rtid)
		
		guis[self] = self
	end,
	
	----------------------------------------
	
	data = {
		_id = 0,
		_buttons = {left = {[107] = true, [15] = true}, right = {[108] = true}},
		_doubleclick_time = 0.25,
		_theme = false,
		_w = 0,
		_h = 0,
		_objects = {},
		_object_refs = {},
		_render_order = {},
		_hover_object = nil,
		_last_click = 0,
		_clicking_objects = {left = {}, right = {}},
		_rtid = "",
		_redraw = {},
		_redraw_all = false,
		
		------------------------------
		
		_changed = function(self, object, simple)
			self._redraw_all = true
		end,
		
		------------------------------
		
		destroy = function(self)
			render.destroyRenderTarget(self._rtid)
			
			guis[self] = nil
		end,
		
		create = function(self, name, parent)
			local element = GUI.elements[name]
			
			if not element then
				error(tostring(name) .. " is not a valid element", 2)
			end
			
			--
			
			local object = {
				parent = parent,
				children = {},
				order = {},
				global_bounding = {x = 0, y = 0, x2 = 0, y2 = 0}
			}
			
			local obj = element.class()
			obj.parent = parent
			obj.remove = function(o)
				for child, child_object in pairs(o.children) do
					b:remove()
				end
				
				self._objects[object] = nil
			end
			obj._theme = self.theme
			obj._changed = function(o, simple)
				self:_changed(o, simple)
			end
			
			object.object = obj
			
			self._object_refs[obj] = object
			
			if parent then
				self._object_refs[parent].children[obj] = object
				table.insert(self._object_refs[parent].order, 1, obj)
			else
				self._objects[obj] = object
				table.insert(self._render_order, 1, obj)
			end
			
			--
			
			local function callConstructor(ele, obj)
				if ele.inherit then
					callConstructor(ele.inherit, obj)
				end
				
				ele.constructor(obj)
			end
			callConstructor(element, obj)
			
			return obj
		end,
		
		render = function(self)
			if self._redraw_all then
				local sx, sy = 1024 / self._w, 1024 / self._h
				
				local function draw(object, px, py, px2, py2)
					local obj = object.object
					local m = Matrix()
					m:setTranslation(obj.pos)
					
					render.pushMatrix(m)
					local x, y = math.max(px, obj.x + px), math.max(py, obj.y + py)
					local x2, y2 = math.min(px2, x + obj.w), math.min(py2, y + obj.h)
					object.global_bounding = {x = x, y = y, x2 = x2, y2 = y2}
					render.enableScissorRect(x * sx, y * sy, x2 * sx, y2 * sy)
					obj:_draw()
					render.disableScissorRect()
					for i = #object.order, 1, -1 do
						draw(object.children[object.order[i]], x, y, x2, y2)
					end
					render.popMatrix()
				end
				
				local m = Matrix()
				m:setScale(Vector(sx, sy))
				
				render.pushMatrix(m, true)
				render.selectRenderTarget(self._rtid)
				render.clear(clearcolor)
				for i = #self._render_order, 1, -1 do
					draw(self._objects[self._render_order[i]], 0, 0, self._w, self._h)
				end
				render.selectRenderTarget()
				render.popMatrix()
				
				self._redraw_all = false
			end
			
			render.setRenderTargetTexture(self._rtid)
			render.setRGBA(255, 255, 255, 255)
			render.drawTexturedRect(0, 0, self._w, self._h)
		end,
		
		renderDirect = function(self)
			local sx, sy = 1024 / self._w, 1024 / self._h
			
			local function draw(object, px, py, px2, py2)
				local obj = object.object
				local m = Matrix()
				m:setTranslation(obj.pos)
				
				render.pushMatrix(m)
				local x, y = math.max(px, obj.x + px), math.max(py, obj.y + py)
				local x2, y2 = math.min(px2, x + obj.w), math.min(py2, y + obj.h)
				object.global_bounding = {x = x, y = y, x2 = x2, y2 = y2}
				obj:_draw()
				for i = #object.order, 1, -1 do
					draw(object.children[object.order[i]], x, y, x2, y2)
				end
				render.popMatrix()
			end
			
			for i = #self._render_order, 1, -1 do
				draw(self._objects[self._render_order[i]], 0, 0, self._w, self._h)
			end
		end,
		
		-- renderDirect = function(self)
		-- 	local function draw(objects)
		-- 		for obj, data in pairs(objects) do
		-- 			local m = Matrix()
		-- 			m:setTranslation(obj.pos)
					
		-- 			render.pushMatrix(m)
		-- 				obj:_draw(self._theme)
		-- 				draw(data.children)
		-- 			render.popMatrix()
		-- 		end
		-- 	end
			
		-- 	draw(self._objects)
		-- end,
		
		think = function(self)
			local _, cx, cy = xpcall(render.cursorPos, input.getCursorPos)
			
			local function think(objects)
				for obj, data in pairs(objects) do
					local b = data.global_bounding
					obj:_think(cx and cx - b.x or nil, cy and cy - b.y or nil)
					think(data.children)
				end
			end
			
			think(self._objects)
			
			-- Mouse stuff
			local last = self._hover_object
			self._hover_object = nil
			
			if cx then
				local function dobj(object)
					local obj = object.object
					local b = object.global_bounding
					if cx > b.x and cy > b.y and cx < b.x2 and cy < b.y2 then
						local hover = object
						
						for i, child in pairs(object.order) do
							local child_object = object.children[child]
							if dobj(child_object) then
								hover = child_object
							end
						end
						
						return hover
					end
				end
				
				for i, obj in pairs(self._render_order) do
					local hover = dobj(self._objects[obj])
					if hover then
						self._hover_object = hover
						
						hover.object:_hover()
						
						break
					end
				end
			end
			
			if self._hover_object ~= last then
				if self._hover_object then
					self._hover_object.object:_hoverStart()
				end
				
				if last then
					last.object:_hoverEnd()
				end
			end
		end,
		
		------------------------------
		
		setTheme = function(self, theme)
			self.theme = theme
		end,
		
		setButtonsLeft = function(self, ...)
			self._buttons.left = {}
			for _, key in pairs({...}) do
				self._buttons.left[key] = true
			end
		end,
		
		setButtonsRight = function(self, ...)
			self._buttons.right = {}
			for _, key in pairs({...}) do
				self._buttons.right[key] = true
			end
		end
	},
	
	----------------------------------------
	
	properties = {
		theme = {
			set = function(self, theme)
				local t = type(theme)
				
				if t == "table" then
					for k, v in pairs(theme) do
						self._theme[k] = v
					end
				elseif t == "string" then
					if not GUI.themes[theme] then
						error(theme .. " is not a valid theme", 2)
					end
					
					self._theme = table.copy(GUI.themes[theme])
				end
				
				self._redraw_all = true
				
				local function dobj(objects)
					for obj, data in pairs(objects) do
						local b = data.global_bounding
						obj._theme = self._theme
						dobj(data.children)
					end
				end
				dobj(self._objects)
			end,
			
			get = function(self)
				return self._theme
			end
		},
		
		buttonsLeft = {
			set = function(self, key)
				self:setButtonsLeft(key)
			end,
			
			get = function(self)
				local buttons = {}
				for key, _ in pairs(self._buttons.left) do
					table.insert(buttons, key)
				end
				
				return buttons
			end
		},
		
		buttonsRight = {
			set = function(self, key)
				self:setButtonsRight(key)
			end,
			
			get = function(self)
				local buttons = {}
				for key, _ in pairs(self._buttons.right) do
					table.insert(buttons, key)
				end
				
				return buttons
			end
		}
	},
	
	----------------------------------------
	
	static_data = {
		themes = themes,
		
		elements = {},
		
		registerElement = function(name, data)
			if GUI.elements[name] then
				error(name .. " is already a registered element", 2)
			end
			
			local inherit = data.inherit
			local constructor = data.constructor
			
			-- General class related stuff
			data.type = "gui." .. name
			data.inherit = nil
			data.constructor = function() end
			
			-- Generate methods
			for k, v in pairs(data.properties) do
				if type(v) == "table" and v.set then
					data.data["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
				end
				
				if type(v) == "table" and v.get then
					data.data["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
				end
			end
			
			-- Apply inherit
			if inherit then
				local i = GUI.elements[inherit].raw
				
				-- Main inherit stuff
				for k, v in pairs(i.data) do
					local t = type(v) == "table"
					if not data.data[k] then
						data.data[k] = t and table.copy(v) or v
					end
				end
				
				for k, v in pairs(i.properties) do
					if not data.properties[k] then
					local t = type(v) == "table"
						data.properties[k] = t and table.copy(v) or v
					end
					
					if t and v.set then
						base["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
					end
					
					if t and v.get then
						base["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
					end
				end
				
				-- Add base to data functions
				for k, v in pairs(data.data) do
					if i.data[k] and type(v) == "function" then
						local func = v
						local func_i = i.data[k]
						
						data.data[k] = function(self, ...)
							local vals = {...}
							
							self.base = function()
								func_i(self, unpack(vals))
							end
							
							func(self, ...)
							
							self.base = nil
						end
					end
				end
			end
			
			-- Store element
			GUI.elements[name] = {
				raw = data,
				class = class(data),
				constructor = constructor,
				inherit = GUI.elements[inherit]
			}
		end
	},
	
	----------------------------------------
	
	static_properties = {
		
	}
	
}

----------------------------------------

-- Register all default elements
local elements_raw = {}
for path, data in pairs(requiredir("./gui2")) do
	elements_raw[string.match(path, "/(%w+).lua$")] = data
end

local function doElement(name)
	local data = elements_raw[name]
	
	if not data.inherit or not elements_raw[data.inherit] then
		GUI.registerElement(name, data)
		
		elements_raw[name] = nil
	else
		doElement(data.inherit)
	end
end

while table.count(elements_raw) > 0 do
	for name, _ in pairs(elements_raw) do
		doElement(name)
		
		break
	end
end

----------------------------------------

return GUI
