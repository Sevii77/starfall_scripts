--@include ./enum/stencil.lua

local STENCIL = require("./enum/stencil.lua")

local stencil = {}

----------------------------------------

function stencil.pushMask(mask, invert)
	render.setStencilReferenceValue(0)
	render.setStencilPassOperation(STENCIL.KEEP)
	render.setStencilZFailOperation(STENCIL.KEEP)
	render.clearStencil()
	
	render.setStencilEnable(true)
	render.setStencilCompareFunction(STENCIL.NEVER)
	render.setStencilFailOperation(STENCIL.REPLACE)
	
	render.setStencilReferenceValue(0x1C)
	render.setStencilWriteMask(0x55)
	
	mask()
	
	render.setStencilTestMask(0xF3)
	render.setStencilReferenceValue(0x10)
	render.setStencilCompareFunction(invert and STENCIL.EQUAL or STENCIL.NOTEQUAL)
end

function stencil.popMask()
	render.setStencilEnable(false)
end

----------------------------------------

return stencil