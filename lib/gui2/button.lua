return {
	inherit = "label",
	constructor = function(self)
		
	end,
	
	----------------------------------------
	
	data = {
		_click = false,
		_click_right = false,
		_last_click = 0,
		_hover = false,
		
		------------------------------
		
		_changed = function(self)
			
		end,
		
		_tick = function(self)
			
		end,
		
		_hover = function(self)
			
		end,
		
		------------------------------
		
		onClick = function(self) end,
		onRightClick = function(self) end,
		onDoubleClick = function(self) end,
		onHold = function(self) end,
		onRightHold = function(self) end,
		onRelease = function(self) end,
		onRightRelease = function(self) end,
		onHoverBegin = function(self) end,
		onHoverEnd = function(self) end,
		onHover = function(self) end,
	},
	
	----------------------------------------
	
	properties = {
		
	}
	
}