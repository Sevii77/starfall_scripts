--@includedir ./gui2
--@include ./class.lua
--@client

local class, checktype = unpack(require("./class.lua"))

-- local gui = {
-- 	themes = {
-- 		light = {
			
-- 		},
		
-- 		dark = {
			
-- 		}
-- 	},
	
-- 	elements = {}
-- }

----------------------------------------

local GUI
GUI = class {
	type = "gui",
	
	constructor = function(self, w, h)
		self._w = w or 512
		self._h = h or (w or 512)
		
		self.theme = "dark"
	end,
	
	----------------------------------------
	
	data = {
		_theme = false,
		_w = 0,
		_h = 0,
		_objects = {},
		
		------------------------------
		
		create = function(self, name, parent)
			local element = GUI.elements[name]
			
			if not element then
				error(name .. " is not a valid element", 2)
			end
			
			--
			
			local object = {
				parent = parent,
				children = {}
			}
			
			local obj = element.class()
			obj.parent = parent
			obj.base = element.base
			obj.remove = function(o)
				for child, child_object in pairs(o.children) do
					b:remove()
				end
				
				self._objects[object] = nil
			end
			
			object.object = obj
			
			if parent then
				self._objects[parent].children[obj] = object
			else
				self._objects[obj] = object
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
			local function draw(objects)
				for obj, data in pairs(objects) do
					local m = Matrix()
					m:setTranslation(obj.pos)
					
					render.pushMatrix(m)
						obj:_draw(self._theme)
						draw(data.children)
					render.popMatrix()
				end
			end
			
			draw(self._objects)
		end,
		
		------------------------------
		
		setTheme = function(self, theme)
			self.theme = theme
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
			end,
			
			get = function(self)
				return self._theme
			end
		}
	},
	
	----------------------------------------
	
	static_data = {
		themes = {
			light = {
				main = Color(220, 220, 220),
				secondary = Color(180, 180, 180),
				accent = Color(50, 255, 180),
				text = Color(30, 30, 30),
				
				borderSize = 1,
				
				font = render.createFont("Roboto", 18, 600)
			},
			
			dark = {
				main = Color(50, 50, 50),
				secondary = Color(90, 90, 90),
				accent = Color(50, 255, 180),
				text = Color(255, 255, 255),
				
				borderSize = 1,
				
				font = render.createFont("Roboto", 18, 600)
			}
		},
		
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
			-- if inherit then
			-- 	local i = GUI.elements[inherit].raw
				
			-- 	-- Main inherit stuff
			-- 	for k, v in pairs(i.data) do
			-- 		local t = type(v) == "table"
			-- 		if not data.data[k] then
			-- 			data.data[k] = t and table.copy(v) or v
			-- 		end
			-- 	end
				
			-- 	for k, v in pairs(i.properties) do
			-- 		if not data.properties[k] then
			-- 		local t = type(v) == "table"
			-- 			data.properties[k] = t and table.copy(v) or v
			-- 		end
					
			-- 		if t and v.set then
			-- 			base["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
			-- 		end
					
			-- 		if t and v.get then
			-- 			base["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
			-- 		end
			-- 	end
				
			-- 	-- Add base to data functions
			-- 	for k, v in pairs(data.data) do
			-- 		if i.data[k] and type(v) == "function" then
			-- 			local func = v
			-- 			local func_i = i.data[k]
						
			-- 			data.data[k] = function(self, ...)
			-- 				local vals = {...}
							
			-- 				self.base = function()
			-- 					func_i(self, unpack(vals))
			-- 				end
							
			-- 				func(self, ...)
							
			-- 				self.base = nil
			-- 			end
			-- 		end
			-- 	end
			-- end
			
			local base = {
				__newindex = function()
					error("base is readonly", 2)
				end
			}
			
			if inherit then
				local d = GUI.elements[inherit].raw
				
				for k, v in pairs(d.data) do
					local t = type(v) == "table"
					if not data.data[k] then
						data.data[k] = t and table.copy(v) or v
					end
					
					base[k] = t and table.copy(v) or v
				end
				
				for k, v in pairs(d.properties) do
					if not data.properties[k] then
					local t = type(v) == "table"
						data.properties[k] = t and table.copy(v) or v
					end
					
					base[k] = t and table.copy(v) or v
					
					if t and v.set then
						base["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
					end
					
					if t and v.get then
						base["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
					end
				end
			end
			
			base.__index = base
			
			-- Store element
			GUI.elements[name] = {
				raw = data,
				class = class(data),
				base = setmetatable({}, base),
				constructor = constructor,
				inherit = GUI.elements[inherit]
			}
		end
	},
	
	----------------------------------------
	
	static_properties = {
		
	}
	
}

-- function gui.registerElement(name, inherit, data)
-- 	if not data then
-- 		data = inherit
-- 		inherit = nil
-- 	end
	
-- 	-- Generate methods
-- 	for k, v in pairs(data.properties) do
-- 		if type(v) == "table" and v.set then
-- 			data.data["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
-- 		end
		
-- 		if type(v) == "table" and v.get then
-- 			data.data["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
-- 		end
-- 	end
-- end

-- function gui.create(name, parent)
	
-- end

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
