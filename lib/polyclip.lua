--[[
	Sutherland–Hodgman algorithm
	
	Source:
	https://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping#Lua
]]

----------------------------------------

local function inside(p, cp1, cp2)
	return (cp2.x - cp1.x) * (p.y - cp1.y) > (cp2.y - cp1.y) * (p.x - cp1.x)
end
 
local function intersection(cp1, cp2, s, e)
	local dcx, dcy = cp1.x - cp2.x, cp1.y - cp2.y
	local dpx, dpy = s.x - e.x, s.y - e.y
	local n1 = cp1.x * cp2.y - cp1.y * cp2.x
	local n2 = s.x * e.y - s.y * e.x
	local n3 = 1 / (dcx * dpy - dcy * dpx)
	local x = (n1 * dpx - n2 * dcx) * n3
	local y = (n1 * dpy - n2 * dcy) * n3
	
	return Vector(x, y)
end
 
local function clip(subjectPolygon, clipPolygon)
	local outputList = subjectPolygon
	local cp1 = clipPolygon[#clipPolygon]
	for _, cp2 in ipairs(clipPolygon) do  -- WP clipEdge is cp1,cp2 here
		local inputList = outputList
		local s = inputList[#inputList]
		outputList = {}
		
		for _, e in ipairs(inputList) do
			if inside(e, cp1, cp2) then
				if not inside(s, cp1, cp2) then
					outputList[#outputList+1] = intersection(cp1, cp2, s, e)
				end
				outputList[#outputList+1] = e
			elseif inside(s, cp1, cp2) then
				outputList[#outputList+1] = intersection(cp1, cp2, s, e)
			end
			
			s = e
		end
		
		cp1 = cp2
	end
	
	return outputList
end

----------------------------------------

return {
	inside = inside,
	intersection = intersection,
	clip = clip
}