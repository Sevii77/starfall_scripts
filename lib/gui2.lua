--@includedir ./gui2
--@include ./class.lua
--@include ./stencil.lua

--[[
	TODO:
	have a more advanced changed system:
		if an element has changed in a minor way (changed something within the same bounds)
		make it only redraw the element itself and not the whole gui
	more elements
	mask stacking (perhabs? is expensive)
]]

local class, checktype = unpack(require("./class.lua"))
local stencil = require("./stencil.lua")

----------------------------------------

local cursor_poly_cache = {
	-- DRAGGING
	rect_45_o = {
		{x = -16, y = 0},
		{x = 0, y = -16},
		{x = 16, y = 0},
		{x = 0, y = 16}
	}, rect_45_i = {
		{x = -14, y = 0},
		{x = 0, y = -14},
		{x = 14, y = 0},
		{x = 0, y = 14}
	},
	
	rect_s_o = {
		{x = -8, y = -8},
		{x = 8, y = -8},
		{x = 8, y = 8},
		{x = -8, y = 8}
	}, rect_s_i = {
		{x = -6, y = -6},
		{x = 6, y = -6},
		{x = 6, y = 6},
		{x = -6, y = 6}
	},
	
	-- RESIZE
	arrow_l_o = {
		{x = -16, y = 0},
		{x = -8, y = -8},
		{x = -8, y = 8}
	}, arrow_l_i = {
		{x = -14, y = 0},
		{x = -9.5, y = -4.5},
		{x = -9.5, y = 4.5}
	},
	
	arrow_r_o = {
		{x = 16, y = 0},
		{x = 8, y = 8},
		{x = 8, y = -8}
	}, arrow_r_i = {
		{x = 14, y = 0},
		{x = 9.5, y = 4.5},
		{x = 9.5, y = -4.5}
	},
	
	arrow_u_o = {
		{x = 0, y = -16},
		{x = 8, y = -8},
		{x = -8, y = -8}
	}, arrow_u_i = {
		{x = 0, y = -14},
		{x = 4.5, y = -9.5},
		{x = -4.5, y = -9.5}
	},
	
	arrow_d_o = {
		{x = 0, y = 16},
		{x = -8, y = 8},
		{x = 8, y = 8}
	}, arrow_d_i = {
		{x = 0, y = 14},
		{x = -4.5, y = 9.5},
		{x = 4.5, y = 9.5}
	}
}

local cursor = { --[[32x32]]
	-- NORMAL
	[0] = function(mainColor, outlineColor)
		render.setColor(mainColor)
		render.drawRect(0, 0, 32, 32)
		render.setColor(outlineColor)
		render.drawSimpleText(0, 0, "0")
	end,
	
	-- CLICKABLE
	[1] = function(mainColor, outlineColor)
		render.setColor(mainColor)
		render.drawRect(0, 0, 32, 32)
		render.setColor(outlineColor)
		render.drawSimpleText(0, 0, "1")
	end,
	
	-- LOADING
	[2] = function(mainColor, outlineColor)
		render.setColor(mainColor)
		render.drawRect(0, 0, 32, 32)
		render.setColor(outlineColor)
		render.drawSimpleText(0, 0, "2")
	end,
	
	-- DRAGGING
	[3] = function(mainColor, outlineColor)
		render.setColor(outlineColor)
		render.drawPoly(cursor_poly_cache.rect_45_o)
		
		render.setColor(mainColor)
		render.drawPoly(cursor_poly_cache.rect_45_i)
		
		render.setColor(outlineColor)
		render.drawPoly(cursor_poly_cache.rect_s_o)
		
		render.setColor(mainColor)
		render.drawPoly(cursor_poly_cache.rect_s_i)
	end,
	
	-- RESIZE
	[4] = function(mainColor, outlineColor)
		render.setColor(outlineColor)
		render.drawRect(-8, -2, 16, 4)
		render.drawRect(-2, -8, 4, 16)
		render.drawPoly(cursor_poly_cache.arrow_l_o)
		render.drawPoly(cursor_poly_cache.arrow_r_o)
		render.drawPoly(cursor_poly_cache.arrow_u_o)
		render.drawPoly(cursor_poly_cache.arrow_d_o)
		
		render.setColor(mainColor)
		render.drawRect(-9.5, -1, 19, 2)
		render.drawRect(-1, -9.5, 2, 19)
		render.drawPoly(cursor_poly_cache.arrow_l_i)
		render.drawPoly(cursor_poly_cache.arrow_r_i)
		render.drawPoly(cursor_poly_cache.arrow_u_i)
		render.drawPoly(cursor_poly_cache.arrow_d_i)
	end,
	
	-- RESIZEX
	[5] = function(mainColor, outlineColor)
		render.setColor(outlineColor)
		render.drawRect(-8, -2, 16, 4)
		render.drawPoly(cursor_poly_cache.arrow_l_o)
		render.drawPoly(cursor_poly_cache.arrow_r_o)
		
		render.setColor(mainColor)
		render.drawRect(-9.5, -1, 19, 2)
		render.drawPoly(cursor_poly_cache.arrow_l_i)
		render.drawPoly(cursor_poly_cache.arrow_r_i)
	end,
	
	-- RESIZEY
	[6] = function(mainColor, outlineColor)
		render.setColor(outlineColor)
		render.drawRect(-2, -8, 4, 16)
		render.drawPoly(cursor_poly_cache.arrow_u_o)
		render.drawPoly(cursor_poly_cache.arrow_d_o)
		
		render.setColor(mainColor)
		render.drawRect(-1, -9.5, 2, 19)
		render.drawPoly(cursor_poly_cache.arrow_u_i)
		render.drawPoly(cursor_poly_cache.arrow_d_i)
	end,
	
	-- WRITEABLE
	[7] = function(mainColor, outlineColor)
		render.setColor(mainColor)
		render.drawRect(0, 0, 32, 32)
		render.setColor(outlineColor)
		render.drawSimpleText(0, 0, "7")
	end
}

local themes = {
	light = {
		primaryColor        = Color(190, 190, 190),
		primaryColorLight   = Color(240, 240, 240),
		primaryColorDark    = Color(160, 160, 160),
		primaryTextColor    = Color(15, 15, 15),
		
		secondaryColor      = Color(50, 110, 210),
		secondaryColorLight = Color(80, 140, 255),
		secondaryColorDark  = Color(20, 80, 160),
		secondaryTextColor  = Color(90, 90, 90),
		
		font = render.createFont("Trebuchet", 18, 350, true),
		
		cornerStyle           = 1,
		cornerSize            = 5,
		animationSpeed        = 8,
		
		cursorMainColor       = Color(220, 220, 220),
		cursorOutlineColor    = Color(30, 30, 30),
		cursorSize            = 12,
		cursorRender          = cursor
	},
	
	dark = {
		primaryColor        = Color(40, 40, 40),
		primaryColorLight   = Color(50, 50, 50),
		primaryColorDark    = Color(30, 30, 30),
		primaryTextColor    = Color(255, 255, 255),
		
		secondaryColor      = Color(50, 110, 210),
		secondaryColorLight = Color(80, 140, 255),
		secondaryColorDark  = Color(20, 80, 160),
		secondaryTextColor  = Color(160, 160, 160),
		
		font = render.createFont("Trebuchet", 18, 350, true),
		
		cornerStyle           = 1,
		cornerSize            = 5,
		animationSpeed        = 8,
		
		cursorMainColor       = Color(30, 30, 30),
		cursorOutlineColor    = Color(220, 220, 220),
		cursorSize            = 12,
		cursorRender          = cursor
	}
}

----------------------------------------

local guis = {}
local clearcolor = Color(0, 0, 0, 0)

hook.add("inputPressed", "lib.gui", function(key)
	for gui, _ in pairs(guis) do
		if gui._focus_object then
			for k, _ in pairs(gui._buttons.left) do
				if key == k then
					gui._focus_object.object:_press()
					
					if timer.curtime() - gui._last_click < gui._doubleclick_time then
						gui._focus_object.object:_pressDouble()
					end
					
					gui._last_click = timer.curtime()
					
					table.insert(gui._clicking_objects.left, gui._focus_object)
				end
			end
			
			for k, _ in pairs(gui._buttons.right) do
				if key == k then
					gui._focus_object.object:_pressRight()
					
					table.insert(gui._clicking_objects.right, gui._focus_object)
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
					obj.object:_releaseRight()
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
		_remove_queue = {},
		_parent_queue = {},
		_focus_object = nil,
		_last_click = 0,
		_clicking_objects = {left = {}, right = {}},
		_cursor_mode = 0,
		_rtid = "",
		_redraw = {},
		_redraw_all = false,
		
		_max_fps = 60,
		_last_update = 0,
		_deltatime = 0,
		
		------------------------------
		
		_changed = function(self, object, simple)
			-- self._redraw[object] = simple and true or false
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
				global_bounding = {x = 0, y = 0, x2 = 0, y2 = 0},
				cursor = {x = 0, y = 0}
			}
			
			local obj = element.class()
			obj._gui = self
			obj._theme = self.theme
			
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
				local deltatime = self._deltatime
				local sx, sy = 1024 / self._w, 1024 / self._h
				local s = Vector(sx, sy)
				
				local function draw(object, masks)
					local obj = object.object
					if not obj._enabled or not obj._visible then return end
					
					local b = object.global_bounding
					-- local masks = table.copy(masks)
					-- local crm = obj._customRenderMask
					-- if crm then
					-- 	table.insert(masks, function()
					-- 		local m = Matrix()
					-- 		m:setTranslation(Vector(b.x, b.y))
							
					-- 		render.pushMatrix(m, true)
					-- 		crm(obj, obj._w, obj._h)
					-- 		render.popMatrix()
					-- 	end)
					-- end
					
					-- if #masks > 0 then
					-- 	stencil.pushMask(function()
					-- 		for i, mask in pairs(masks) do
					-- 			mask()
					-- 		end
					-- 	end, not obj._invert_render_mask)
					-- end
					
					local m = Matrix()
					m:setTranslation(obj._pos)
					render.pushMatrix(m)
					
					local crm = obj._customRenderMask
					if crm then
						stencil.pushMask(function()
							crm(obj, obj._w, obj._h)
						end, obj._invert_render_mask)
					end
					
					render.enableScissorRect(b.x * sx, b.y * sy, b.x2 * sx, b.y2 * sy)
					obj:_draw(deltatime)
					render.disableScissorRect()
					
					if crm then
						stencil.popMask()
					end
					
					for i = #object.order, 1, -1 do
						draw(object.children[object.order[i]], masks)
					end
					
					render.popMatrix()
				end
				
				local m = Matrix()
				m:setScale(s)
				render.pushMatrix(m, true)
				render.selectRenderTarget(self._rtid)
				render.clear(clearcolor)
				for i = #self._render_order, 1, -1 do
					draw(self._objects[self._render_order[i]], {})
				end
				render.selectRenderTarget()
				render.popMatrix()
				
				self._redraw = {}
				self._redraw_all = false
			elseif table.count(self._redraw) > 0 then
				-- TODO :D
				
				self._redraw = {}
			end
			
			render.setRenderTargetTexture(self._rtid)
			render.setRGBA(255, 255, 255, 255)
			render.drawTexturedRect(0, 0, self._w, self._h)
		end,
		
		renderHUD = function(self)
			local deltatime = self._deltatime
			local w, h = render.getResolution()
			local sx, sy = w / self._w, h / self._h
			local s = Vector(sx, sy)
			
			local function draw(object, masks)
				local obj = object.object
				if not obj._enabled or not obj._visible then return end
				
				local m = Matrix()
				m:setTranslation(obj._pos)
				render.pushMatrix(m)
				
				local crm = obj._customRenderMask
				if crm then
					stencil.pushMask(function()
						crm(obj, obj._w, obj._h)
					end, obj._invert_render_mask)
				end
				
				local b = object.global_bounding
				render.enableScissorRect(b.x * sx, b.y * sy, b.x2 * sx, b.y2 * sy)
				obj:_draw(deltatime)
				render.disableScissorRect()
				
				if crm then
					stencil.popMask()
				end
				
				for i = #object.order, 1, -1 do
					draw(object.children[object.order[i]], masks)
				end
				
				render.popMatrix()
			end
			
			local m = Matrix()
			m:setScale(s)
			render.pushMatrix(m, true)
			for i = #self._render_order, 1, -1 do
				draw(self._objects[self._render_order[i]], {})
			end
			render.popMatrix()
		end,
		
		renderDirect = function(self)
			local sx, sy = 1024 / self._w, 1024 / self._h
			
			local function draw(object)
				local obj = object.object
				if not obj._enabled or not obj._visible then return end
				
				local m = Matrix()
				m:setTranslation(obj._pos)
				render.pushMatrix(m)
				
				obj:_draw()
				for i = #object.order, 1, -1 do
					draw(object.children[object.order[i]])
				end
				
				render.popMatrix()
			end
			
			for i = #self._render_order, 1, -1 do
				draw(self._objects[self._render_order[i]])
			end
		end,
		
		renderDebug = function(self)
			render.setRGBA(255, 0, 255, 50)
			for obj, object in pairs(self._object_refs) do
				if obj._enabled and obj._visible then
					local b = object.global_bounding
					render.drawLine(b.x, b.y, b.x2, b.y)
					render.drawLine(b.x, b.y, b.x, b.y2)
					render.drawLine(b.x, b.y2, b.x2, b.y2)
					render.drawLine(b.x2, b.y, b.x2, b.y2)
					render.drawLine(b.x, b.y, b.x2, b.y2)
				end
			end
		end,
		
		renderMasks = function(self)
			render.setRGBA(255, 0, 255, 50)
			render.setMaterial()
			
			for obj, object in pairs(self._object_refs) do
				if obj._enabled and obj._visible then
					local crm = obj._customRenderMask
					if crm then
						local b = object.global_bounding
						local m = Matrix()
						m:setTranslation(Vector(b.gx, b.gy))
						render.pushMatrix(m)
						crm(obj, obj._w, obj._h)
						render.popMatrix()
					end
				end
			end
		end,
		
		renderCursor = function(self, s)
			local cx, cy = self:getCursorPos()
			
			if cx then
				local theme = self._theme
				local w, h = render.getResolution()
				local sx, sy = w / self._w, h / self._h
				
				local m = Matrix()
				m:setTranslation(Vector(cx * sx, cy * sy))
				m:setScale(Vector(sx, sy) * self._theme.cursorSize / 32 * (s or 1))
				render.pushMatrix(m)
				render.setMaterial()
				theme.cursorRender[self._cursor_mode](theme.cursorMainColor, theme.cursorOutlineColor)
				render.popMatrix()
			end
		end,
		
		think = function(self, cx, cy)
			local t = timer.curtime()
			
			if self._last_update > t - 1 / self._max_fps then return end
			local deltatime = t - self._last_update
			self._last_update = t
			self._deltatime = deltatime
			
			-- Remove objects
			if table.count(self._remove_queue) > 0 then
				for obj, _ in pairs(self._remove_queue) do
					if self._objects[obj] then
						for i, o in pairs(self._render_order) do
							if o == obj then
								table.remove(self._render_order, i)
							end
						end
						
						self._objects[obj] = nil
					else
						local parent = self._object_refs[self._object_refs[obj].parent]
						
						if parent then
							for i, o in pairs(parent.order) do
								if o == obj then
									table.remove(parent.order, i)
								end
							end
							
							parent.children[obj] = nil
						end
					end
					
					self._object_refs[obj] = nil
				end
				self._remove_queue = {}
				
				self._redraw_all = true
			end
			
			-- Change parents
			if table.count(self._parent_queue) > 0 then
				for obj, parent in pairs(self._parent_queue) do
					local object = self._object_refs[obj]
					if object.parent then
						local parent_object = self._object_refs[object.parent]
						parent_object.children[obj] = nil
						
						for i, o in pairs(parent_object.order) do
							if o == obj then
								table.remove(parent_object.order, i)
								
								break
							end
						end
					else
						self._objects[obj] = nil
						
						for i, o in pairs(self._render_order) do
							if o == obj then
								table.remove(self._render_order, i)
								
								break
							end
						end
					end
					
					if parent then
						self._object_refs[parent].children[obj] = object
						table.insert(self._object_refs[parent].order, 1, obj)
					else
						self._objects[obj] = object
						table.insert(self._render_order, 1, obj)
					end
					
					object.parent = parent
				end
				
				self._parent_queue = {}
				
				self._redraw_all = true
			end
			
			-- Think
			if not cx then
				local _, x, y = xpcall(render.cursorPos, input.getCursorPos)
				cx, cy = x, y
			end
			
			if cx then
				local w, h = render.getResolution()
				cx, cy = self._w / w * cx, self._h / h * cy
			end
			
			local function think(objects, px, py, px2, py2, px3, py3)
				for obj, data in pairs(objects) do
					if obj._enabled and obj._visible then
						local b = data.global_bounding
						local lx, ly = cx and cx - (b.gx or 0) or nil, cy and cy - (b.gy or 0) or nil
						obj:_think(deltatime, lx, ly)
						data.cursor = {x = lx, y = ly}
						
						local x3, y3 = obj._pos.x + px3, obj._pos.y + py3
						local x, y = math.clamp(px, x3, px2), math.clamp(py, y3, py2)
						local x2, y2 = math.clamp(x3 + obj._w, x, px2), math.clamp(y3 + obj._h, y, py2)
						data.global_bounding = {x = x, y = y, x2 = x2, y2 = y2, gx = x3, gy = y3}
						
						think(data.children, x, y, x2, y2, x3, y3)
					end
				end
			end
			
			think(self._objects, 0, 0, self._w, self._h, 0, 0)
			
			-- Mouse stuff
			local last = self._focus_object
			self._focus_object = nil
			
			if cx then
				local function dobj(object)
					local obj = object.object
					if not obj._enabled or not obj._visible then return end
					
					local b = object.global_bounding
					if cx > b.x and cy > b.y and cx < b.x2 and cy < b.y2 then
						local cim = obj._customInputMask
						if cim and not cim(obj, object.cursor.x, object.cursor.y) then return end
						
						local hover
						if not obj._translucent then
							hover = object
						end
						
						for i, child in pairs(object.order) do
							local h = dobj(object.children[child])
							if h then
								hover = h
								
								break
							end
						end
						
						return hover
					end
				end
				
				for i, obj in pairs(self._render_order) do
					local hover = dobj(self._objects[obj])
					if hover then
						self._focus_object = hover
						
						hover.object:_hover()
						
						break
					end
				end
			end
			
			if self._focus_object ~= last then
				if last then
					last.object:_hoverEnd()
				end
				
				if self._focus_object then
					self._focus_object.object:_hoverStart()
				end
			end
		end,
		
		------------------------------
		
		getCursorPos = function(self, obj)
			if obj then
				local p = self._object_refs[obj].cursor
				
				return p.x, p.y
			else
				local _, x, y = xpcall(render.cursorPos, input.getCursorPos)
				
				if x then
					local w, h = render.getResolution()
					x, y = self._w / w * x, self._h / h * y
				end
				
				return x, y
			end
		end,
		
		focus = function(self, obj)
			local object = self._object_refs[obj]
			local parent = self._object_refs[obj.parent]
			
			if parent then
				for i, o in pairs(parent.order) do
					if o == obj then
						table.remove(parent.order, i)
					end
				end
				
				table.insert(parent.order, 1, obj)
			else
				for i, o in pairs(self._render_order) do
					if o == obj then
						table.remove(self._render_order, i)
					end
				end
				
				table.insert(self._render_order, 1, obj)
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
		end,
		
		getButtonsLeft = function(self)
			return self.buttonsLeft
		end,
		
		getButtonsRight = function(self)
			return self.buttonsRight
		end,
		
		setDoubleclickTime = function(self, value)
			self._doubleclick_time = value
		end,
		
		getDoubleclickTime = function(self)
			return self._doubleclick_time
		end,
		
		setFpsLimit = function(self, value)
			self.max_fps = value
		end,
		
		getFpsLimit = function(self)
			return self.max_fps
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
		},
		
		doubleclickTime = {
			set = function(self, value)
				self._doubleclick_time = value
			end,
			
			get = function(self)
				return self.self._doubleclick_time
			end
		},
		
		fpsLimit = {
			set = function(self, value)
				self._max_fps = value
			end,
			
			get = function(self)
				return self._max_fps
			end
		}
	},
	
	----------------------------------------
	
	static_data = {
		themes = themes,
		
		elements = {},
		
		------------------------------
		
		CURSORMODE = {
			NORMAL = 0,
			CLICKABLE = 1,
			LOADING = 2,
			DRAGGING = 3,
			RESIZE = 4,
			RESIZEX = 5,
			RESIZEY = 6,
			WRITEABLE = 7
		},
		
		DOCK = {
			NODOCK = 0,
			FILL = 1,
			LEFT = 2,
			RIGHT = 3,
			TOP = 4,
			BOTTOM = 5
		},
		
		------------------------------
		-- Simple functions
		lerpColor = function(clr1, clr2, progress)
			return clr1 * (1 - progress) + clr2 * progress
		end,
		
		------------------------------
		
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
			
			-- Apply inherit
			if inherit then
				local i = GUI.elements[inherit].raw
				
				-- Main inherit stuff
				for k, v in pairs(i.data) do
					if not data.data[k] then
						data.data[k] = type(v) == "table" and table.copy(v) or v
					end
				end
				
				for k, v in pairs(i.properties) do
					if not data.properties[k] then
						data.properties[k] = type(v) == "table" and table.copy(v) or v
					end
					
					-- if t and v.set then
					-- 	base["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
					-- end
					
					-- if t and v.get then
					-- 	base["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
					-- end
				end
				
				-- Add base to data functions
				for k, v in pairs(data.data) do
					if i.data[k] and type(v) == "function" then
						local func = v
						local func_i = i.data[k]
						
						data.data[k] = function(self, ...)
							local vals = {...}
							
							local old_base = _G.base
							_G.base = function()
								return func_i(self, unpack(vals))
							end
							
							local a, b, c, d, e, f, g, h = func(self, ...)
							
							_G.base = old_base
							
							return a, b, c, d, e, f, g, h
						end
					end
				end
			end
			
			-- Generate methods
			for k, v in pairs(data.properties) do
				if type(v) == "table" and v.set then
					data.data["set" .. string.upper(k[1]) .. string.sub(k, 2)] = v.set
				end
				
				if type(v) == "table" and v.get then
					data.data["get" .. string.upper(k[1]) .. string.sub(k, 2)] = v.get
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

local old_GUI = _G.GUI
_G.GUI = GUI
while table.count(elements_raw) > 0 do
	for name, _ in pairs(elements_raw) do
		doElement(name)
		
		break
	end
end
_G.GUI = old_GUI

----------------------------------------

return GUI
