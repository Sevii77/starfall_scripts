local pi = math.pi

local sbm = {
	loader = {}
}

--[[
	TODO:
	
	v0:
		binary material loading
	
	v1:
		bones
]]

------------------------------

--[[
SBM Simple Binary Model (v0)

All floats are single-precision 32 bit
All strings are null terminated
Rotations in radians
An object segment is a collection of vertices with a different material
Material index being 0 means it has no material


material flags:
	0x01 = material contains transparency
	0x02 = material shader is unlit, can be overwritten in the loader
	
	0x04 = material contains an albedo map
	0x08 = albedo is binary data, else local path
	
	0x10 = material contains an normal map
	0x20 = normal is binary data, else local path

object flags:
	0x01 = vertices contains normals
	0x02 = vertices contains uv's


byte	- SBM version
byte	- material count
per material:
	short	- material flags
	string 	- name
	uint32	- size of albedo (if 0x04 and not 0x08)
	string	- path or data for albedo map (if 0x04 set)
	uint32	- size of normal (if 0x10 and not 0x20)
	string	- path or data for normal map (if 0x10 set)
byte	- object count
per object:
	byte	- object flags
	string	- name
	float	- position x
	float	- position y
	float	- position z
	float	- rotation x
	float	- rotation y
	float	- rotation z
	float	- scale x
	float	- scale y
	float	- scale z
	short	- vertex count
	per vertex:
		float	- position z
		float	- position y
		float	- position z
		float	- normal z (if 0x01 set)
		float	- normal y (if 0x01 set)
		float	- normal z (if 0x01 set)
		float	- u (if 0x02 set)
		float	- v (if 0x02 set)
	byte	- segment count
	per segment:
		byte	- material index
		short	- triangle count
		per triangle:
			short	- vertex index
			short	- vertex index
			short	- vertex index
]]
sbm.loader[0] = function(ss, shader_overwrite)
	local materials = {}
	local material_count = ss:readUInt8()
	for i = 1, material_count do
		local flags = ss:readUInt16()
		local name = ss:readString()
		
		local mat = material.create(shader_overwrite ~= nil and (shader_overwrite and "UnlitGeneric" or "VertexLitGeneric") or (bit.band(flags, 0x02) ~= 0 and "UnlitGeneric" or "VertexLitGeneric"))
		mat:setInt("$treeSway", 0)
		
		if bit.band(flags, 0x01) ~= 0 then
			mat:setInt("$flags", 0x0100 + 0x0010)
		else
			mat:setInt("$flags", 0)
		end
		if bit.band(flags, 0x04) ~= 0 then
			local texture
			if bit.band(flags, 0x08) ~= 0 then
				texture = "data:image/png;base64," .. string.replace(http.base64Encode(ss:read(ss:readUInt32())), "\n", "")
			else
				texture = ss:readString()
			end
			print(texture)
			mat:setTextureURL("$basetexture", texture, function(_, _, _, _, l) l(0, 0, 1024, 1024) end)
		end
		if bit.band(flags, 0x10) ~= 0 then
			local texture
			if bit.band(flags, 0x08) ~= 0 then
				texture = "data:image/png;base64," .. string.replace(http.base64Encode(ss:read(ss:readUInt32())), "\n", "")
			else
				texture = ss:readString()
			end
			
			mat:setTextureURL("$bumpmap", texture, function(_, _, _, _, l) l(0, 0, 1024, 1024) end)
		end
		
		materials[i] = mat
	end
	
	local objects = {}
	local object_count = ss:readUInt8()
	for i = 1, object_count do
		local flags = ss:readUInt8()
		local name = ss:readString()
		local pos = Vector(ss:readFloat(), ss:readFloat(), ss:readFloat())
		local ang = Angle(ss:readFloat() / pi * 180, ss:readFloat() / pi * 180, ss:readFloat() / pi * 180)
		local scale = Vector(ss:readFloat(), ss:readFloat(), ss:readFloat())
		
		local vertices = {}
		local vertex_count = ss:readUInt16()
		for i = 1, vertex_count do
			local uv = bit.band(flags, 0x02) ~= 0
			
			vertices[i] = {
				pos = Vector(ss:readFloat(), ss:readFloat(), ss:readFloat()),
				normal = bit.band(flags, 0x01) ~= 0 and Vector(ss:readFloat(), ss:readFloat(), ss:readFloat()) or nil,
				u = uv and ss:readFloat() or nil,
				v = uv and ss:readFloat() or nil
			}
		end
		
		local segments = {}
		local segment_count = ss:readUInt8()
		for i = 1, segment_count do
			local material = ss:readUInt8()
			
			local triangles = {}
			local triangle_count = ss:readUInt16()
			for i = 1, triangle_count do
				triangles[i * 3 - 2] = vertices[ss:readUInt16() + 1]
				triangles[i * 3 - 1] = vertices[ss:readUInt16() + 1]
				triangles[i * 3    ] = vertices[ss:readUInt16() + 1]
			end
			
			segments[i] = {
				material = materials[material],
				mesh = mesh.createFromTable(triangles)
			}
		end
		
		objects[i] = {
			name = name,
			pos = pos,
			ang = ang,
			scale = scale,
			segments = segments
		}
	end
	
	return objects, materials
end

--[[
SBM Simple Binary Model (v1)

All floats are single-precision 32 bit
All strings are null terminated
Rotations in degrees
An object segment is a collection of vertices with a different material
Material index being 0 means it has no material


material flags:
	0x01 = material contains transparency
	0x02 = material shader is unlit, can be overwritten in the loader
	
	0x04 = material contains an albedo map
	0x08 = albedo is local path to albedo file, else the binary data
	
	0x10 = material contains an normal map
	0x20 = normal is local path to normal file, else the binary data

object flags:
	0x01 = vertices contains normals
	0x02 = vertices contains uv's
	0x04 = model contains bones


byte	- SBM version
byte	- material count
per material:
	byte	- material flags
	string 	- name
	
	string	- path or data for albedo map (if 0x04 set)
	string	- path or data for normal map (if 0x10 set)
byte	- object count
per object:
	byte	- object flags
	string	- name
	float	- position x
	float	- position y
	float	- position z
	float	- rotation x
	float	- rotation y
	float	- rotation z
	float	- scale x
	float	- scale y
	float	- scale z
	short	- bone count (if 0x04 set)
	per bone:
		todo
	short	- vertex count
	per vertex:
		float	- position z
		float	- position y
		float	- position z
		float	- normal z (if 0x01 set)
		float	- normal y (if 0x01 set)
		float	- normal z (if 0x01 set)
		float	- u (if 0x02 set)
		float	- v (if 0x02 set)
		short	- bone id (if 0x04 set)
	byte	- segment count
	per segment:
		byte	- material index
		short	- triangle count
		per triangle:
			short	- vertex index
			short	- vertex index
			short	- vertex index
]]

------------------------------

function sbm.load(sbm_data, shader_overwrite)
	local ss = bit.stringstream(sbm_data)
	local sbm_version = ss:readUInt8()
	
	if not sbm.loader[sbm_version] then
		error("Unsupported SBM version, " .. sbm_version, 2)
	end
	
	local mdl_data, materials = sbm.loader[sbm_version](ss, shader_overwrite)
	
	return mdl_data, materials
end

------------------------------

return sbm