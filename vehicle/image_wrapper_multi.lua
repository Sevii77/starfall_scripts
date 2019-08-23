--@name Image Wrapper
--@author Sevii (https://steamcommunity.com/id/dadamrival/)
--@include ../lib/mesh.lua
--@include ../lib/polyclip.lua

--[[
	Does the same as the non multi version but allows for multiple images per chip and can save
	
	Red sphere is the sphere where props will be checked to see if they should be wrapped, having as little props in it as possible is a good idea
	
	decals, table containing all decals
		size = Vector(x, y)
		image = url to image (best to use whitelisted url)
	
	min_face_ang = what the normal.z should be larger than (0 - 1), altho -1 also would work it would put the faces inside the prop
	class_whitelist = all classes that will be attempted to wrapped
	model_filter = only attempts to wrap props of which their models match any of the filters
	
	to wrap the image type '.do' in chat while looking at the projection prop
	to save the positions of the decal projectors type '.save' in chat while looking at the chip
		when the chip is reloaded or dupe finished it will load the decals
]]

local decals = {
	{
		size = Vector(318, 143) / 143 * 30,
		image = "https://i.imgur.com/f5FIyJM.jpg"
	},
	
	{
		size = Vector(40, 40),
		image = "https://i.imgur.com/uY7bH0m.png"
	}
}

local min_face_ang = 0.3
local class_whitelist = {
	["prop_physics"] = true
}
local model_filter = {
	["models/sprops/rectangles(.+)"] = true,
	["models/sprops/cuboids/(.+)"] = true,
	["models/sprops/geometry/(.+)"] = true,
	["models/sprops/misc/(.+)"] = true,
	["models/sprops/cylinders/(.+)"] = true
}

----------------------------------------

if SERVER then
	
	local saved_pos = getUserdata()
	if #saved_pos > 0 then
		saved_pos = json.decode(saved_pos)
	else
		saved_pos = {}
	end
	
	
	local project_request_buffer = {}
	local projectors = {}
	local projectors_ents = {}
	
	----------------------------------------
	
	local function writeEntities(projector_ent)
		local decals_data = decals[projectors_ents[projector_ent]]
		local ents = find.inSphere(projector_ent:getPos(), math.max(decals_data.size.x, decals_data.size.y), function(ent)
			if projectors_ents[ent] then return false end
			if not class_whitelist[ent:getClass()] then return false end
			
			local model = ent:getModel()
			for filter, _ in pairs(model_filter) do
				if string.match(model, filter) then
					return true
				end
			end
			
			return false
		end)
		
		local ents_sorted = {}
		for _, ent in pairs(ents) do
			local parent = ent:getParent()
			local id = parent:isValid() and parent or ent
			ents_sorted[id] = ents_sorted[id] or {}
			
			table.insert(ents_sorted[id], ent)
		end
		
		print(#ents .. " Entities")
		
		net.writeUInt(projectors_ents[projector_ent], 8)
		net.writeUInt(projector_ent:entIndex(), 13)
		net.writeUInt(table.count(ents_sorted), 8)
		for parent, ents in pairs(ents_sorted) do
			net.writeUInt(parent:entIndex(), 13)
			net.writeUInt(#ents, 8)
			
			for _, ent in pairs(ents) do
				net.writeUInt(ent:entIndex(), 13)
			end
		end
	end
	
	----------------------------------------
	
	hook.add("think", "projection_prop_spawner", function()
		while prop.canSpawn() and #projectors < #decals do
			local index = #projectors + 1
			local decal = decals[index]
			
			local pos, ang
			if saved_pos[index] then
				pos = chip():localToWorld(saved_pos[index].pos)
				ang = chip():localToWorldAngles(saved_pos[index].ang)
			else
				pos = chip():getPos() + Vector(0, 0, 18 * index)
				ang = Angle()
			end
			
			local ent = prop.create(pos, ang, "models/sprops/misc/cones/size_0/cone_6x12.mdl", true)
			
			local holo_radius = holograms.create(ent:getPos(), ent:getAngles(), "models/sprops/geometry/sphere_144.mdl", Vector(math.max(decal.size.x, decal.size.y) / 72))
			holo_radius:setColor(Color(255, 0, 0, 50))
			holo_radius:setParent(ent)
			
			local holo_img = holograms.create(ent:getPos(), ent:getAngles(), "models/sprops/cuboids/height06/size_1/cube_6x6x6.mdl", Vector(decal.size.x / 6, decal.size.y / 6, 0.1))
			holo_img:setParent(ent)
			
			projectors_ents[ent] = index
			projectors[index] = {
				ent = ent,
				holo_radius = holo_radius,
				holo_img = holo_img
			}
			
			if index == #decals then
				hook.remove("think", "projection_prop_spawner")
				
				-- Load saved data and send to owner for building
				if #saved_pos > 0 then
					-- Put a 2 second delay on it to be save
					timer.simple(2, function()
						local count = 0
						for i = 1, #saved_pos do
							if i > #decals then break end
							
							count = count + 1
						end
						
						if count > 0 then
							net.start("map")
							net.writeUInt(count, 8)
							for i = 1, count do
								writeEntities(projectors[i].ent)
							end
							net.send(owner())
						end
					end)
				end
				
				-- Send build request to owner for all saved projectors
				if #project_request_buffer > 0 then
					-- Send projectors to clients to make preview
					net.start("pholo")
					for i, v in pairs(projectors) do
						net.writeUInt(v.holo_img:entIndex(), 13)
					end
					net.send(project_request_buffer)
				end
			end
		end
	end)
	
	----------------------------------------
	
	hook.add("playerSay", "", function(ply, text)
		if ply ~= owner() then return end
		
		if text == ".save" then
			if ply:getEyeTrace().Entity ~= chip() then return end
			
			local save = {}
			for i, data in pairs(projectors) do
				save[i] = {
					pos = chip():worldToLocal(data.ent:getPos()),
					ang = chip():worldToLocalAngles(data.ent:getAngles())
				}
			end
			
			setUserdata(json.encode(save))
			
			return ""
		elseif text == ".do" then
			local projector_ent = ply:getEyeTrace().Entity
			if not projectors_ents[projector_ent] then return end
			
			net.start("map")
			net.writeUInt(1, 8) -- Amount of projectors it wants to do
			writeEntities(projector_ent)
			net.send(owner())
			
			return ""
		end
	end)
	
	----------------------------------------
	
	local vertices_sorted = {}
	local holos = {}
	
	function sendVertices(plys, vertices)
		net.start("data")
		net.writeStream(fastlz.compress(json.encode(vertices)))
		net.send(plys)
	end
	
	----------------------------------------
	
	net.receive("data", function(_, ply)
		if ply ~= owner() then return end
		
		--[[local projector_id = net.readUInt(8)
		vertices_sorted[projector_id] = {
			ent = projectors[projector_id].ent:entIndex(),
			data = {}
		}]]
		
		net.readStream(function(data)
			local data = json.decode(fastlz.decompress(data))
			
			local send = {}
			for projector_id, data in pairs(data) do
				vertices_sorted[projector_id] = {
					ent = projectors[projector_id].ent:entIndex(),
					data = {}
				}
				
				holos[projector_id] = holos[projector_id] or {}
				
				local valid_holos = {}
				for _, holo in pairs(holos[projector_id]) do
					if holo:isValid() then
						table.insert(valid_holos, holo)
					end
				end
				holos[projector_id] = valid_holos
				
				local i = 1
				for parent, vertices in pairs(data) do
					local p = entity(parent)
					
					local holo = holos[projector_id][i] or holograms.create(p:getPos(), p:getAngles(), "models/sprops/cuboids/height06/size_1/cube_6x6x6.mdl", Vector(1))
					holo:setParent(p)
					
					local holo_index = holo:entIndex()
					
					holos[projector_id][i] = holo
					vertices_sorted[projector_id].data[holo_index] = vertices
					
					i = i + 1
				end
				
				local count = table.count(data)
				if count < #holos[projector_id] then
					for i = count + 1, #holos[projector_id] do
						holos[projector_id][i]:remove()
						table.remove(holos[projector_id], count + 1)
					end
				end
				
				send[projector_id] = vertices_sorted[projector_id]
			end
			
			-- Just send the new stuff
			sendVertices(nil, send)
			--sendVertices(nil, {[projector_id] = vertices_sorted[projector_id]})
		end)
	end)
	
	----------------------------------------
	
	net.receive("rpholo", function(_, ply)
		if #projectors < #decals then
			project_request_buffer[ply] = ply
			
			return
		end
		
		net.start("pholo")
		for i, v in pairs(projectors) do
			net.writeUInt(v.holo_img:entIndex(), 13)
		end
		net.send(ply)
	end)
	
	net.receive("request", function(_, ply)
		if table.count(vertices_sorted) == 0 then return end
		
		-- Send everything
		sendVertices(ply, vertices_sorted)
	end)
	
else
	
	-- Check if we can create the mesh, if not dont run the rest of the code
	if not hasPermission("mesh") then return end
	
	-- Check if we got permissions to create a material, if not skip it
	local create_mat = true
	local mats = {}
	
	for _, perm in pairs({
		"material.create",
		"material.urlcreate"
	}) do
		if not hasPermission(perm) then
			create_mat = false
			
			break
		end
	end
	
	if create_mat then
		for i, data in pairs(decals) do
			mats[i] = material.create("VertexLitGeneric")
			mats[i]:setInt("$flags", 0x0100 + 0x2000)
			mats[i]:setFloat("$alphatestreference", 0.1)
			mats[i]:setTextureURL("$basetexture", data.image, function(_, _, w, h, layout)
				layout(0, 0, 1024, 1024)
			end)
		end
	end
	
	----------------------------------------
	-- Projection holo
	
	net.start("rpholo")
	net.send()
	
	net.receive("pholo", function()
		for i = 1, #decals do
			local p = entity(net.readUInt(13)):toHologram()
			
			local p1 = {pos = Vector(-3, -3, 0), normal = Vector(0, 0, 1), u = 0, v = 0}
			local p2 = {pos = Vector( 3, -3, 0), normal = Vector(0, 0, 1), u = 1, v = 0}
			local p3 = {pos = Vector( 3,  3, 0), normal = Vector(0, 0, 1), u = 1, v = 1}
			local p4 = {pos = Vector(-3,  3, 0), normal = Vector(0, 0, 1), u = 0, v = 1}
			
			local mesh = mesh.createFromTable({p2, p1, p4, p3, p2, p4})
			p:setMesh(mesh)
			p:setMeshMaterial(mats[i])
		end
	end)
	
	----------------------------------------
	
	function doVerticies(data, projector_id, projector_ent)
		local vertices = {}
		local p = data.parent
		
		local ang_chip = projector_ent:getAngles()
		local ang_parent = p:getAngles()
		for i, vertex in pairs(data.vertices) do
			local uv = vertex.pos / decals[projector_id].size + Vector(0.5, 0.5)
			
			table.insert(vertices, {
				pos = p:worldToLocal(projector_ent:localToWorld(vertex.pos - Vector(0, 0, 0.5))), -- + vertex.normal)
				normal = vertex.normal,
				u = uv.x,
				v = uv.y
			})
		end
		
		local mesh = mesh.createFromTable(vertices)
		p:setMesh(mesh)
		p:setMeshMaterial(mats[projector_id])
		
		return mesh
	end
	
	----------------------------------------
	
	net.start("request")
	net.send()
	
	local vertices_sorted = {}
	
	net.receive("data", function()
		net.readStream(function(data)
			local tbl = json.decode(fastlz.decompress(data))
			
			for projector_id, d in pairs(tbl) do
				if vertices_sorted[projector_id] then
					for _, data in pairs(vertices_sorted[projector_id].segments) do
						if data.mesh then
							data.mesh:destroy()
						end
					end
				end
				
				vertices_sorted[projector_id] = {
					projector_ent_id = d.ent,
					segments = {}
				}
				
				for parent, vertices in pairs(d.data) do
					vertices_sorted[projector_id].segments[parent] = {
						loaded = false,
						vertices = {}
					}
					
					for i, vertex in pairs(vertices) do
						vertices_sorted[projector_id].segments[parent].vertices[i] = {
							pos = vertex.pos,
							normal = vertex.normal
						}
					end
				end
			end
		end)
	end)
	
	hook.add("think", "", function()
		for projector_id, main_data in pairs(vertices_sorted) do
			local p = entity(main_data.projector_ent_id)
			
			if p:isValid() then
				main_data.projector_ent = p
			end
			
			if main_data.projector_ent then
				for parent, data in pairs(main_data.segments) do
					if not data.loaded then
						local p = entity(parent)
						
						if p:isValid() then
							data.parent = p:toHologram()
							data.loaded = true
							data.mesh = doVerticies(data, projector_id, main_data.projector_ent)
						end
					end
				end
			end
		end
	end)
	
	----------------------------------------
	
	if player() == owner() then
		local mesh = require("../lib/mesh.lua")
		local polyclip = require("../lib/polyclip.lua")
		
		local function linePlane(pos, plane_pos, plane_normal)
			local x = plane_normal:dot(plane_pos - pos) / plane_normal:dot(Vector(0, 0, 9999))
			return pos + Vector(0, 0, x * 9999)
		end
		
		net.receive("map", function()
			local vertices_sorted = {}
			
			for _ = 1, net.readUInt(8) do
				local projector_id = net.readUInt(8)
				local projector_ent = entity(net.readUInt(13))
				
				local ents_sorted = {}
				for i = 1, net.readUInt(8) do
					local tbl = {}
					local parent = net.readUInt(13)
					
					for i2 = 1, net.readUInt(8) do
						tbl[i2] = entity(net.readUInt(13))
					end
					
					ents_sorted[parent] = tbl
				end
				
				vertices_sorted[projector_id] = {}
				local ang = projector_ent:getAngles()
				for parent, ents in pairs(ents_sorted) do
					local vertices = {}
					
					for _, vertex in pairs(mesh.getEntityVertices(ents, Vector())) do
						table.insert(vertices, projector_ent:worldToLocal(vertex.pos))
					end
					
					local new = {}
					for i = 1, #vertices, 3 do
						local a = vertices[i]
						local b = vertices[i + 1]
						local c = vertices[i + 2]
						
						if a.z < 0 then continue end
						if b.z < 0 then continue end
						if c.z < 0 then continue end
						
						local normal = (b - a):cross(c - a):getNormalized()
						
						-- Check normal
						if normal.z < min_face_ang then continue end
						
						-- Clip poly
						local pos_a = Vector(a.x, a.y)
						local pos_b = Vector(b.x, b.y)
						local pos_c = Vector(c.x, c.y)
						
						local s = decals[projector_id].size / 2
						local poly = polyclip.clip({pos_a, pos_b, pos_c}, {Vector(-s.x, -s.y), Vector(s.x, -s.y), Vector(s.x, s.y), Vector(-s.x, s.y)})
						
						if #poly > 0 then
							local start = poly[1]
							for i = 3, #poly do
								table.insert(new, {
									pos = linePlane(start, a, normal),
									normal = normal
								})
								
								table.insert(new, {
									pos = linePlane(poly[i - 1], a, normal),
									normal = normal
								})
								
								table.insert(new, {
									pos = linePlane(poly[i], a, normal),
									normal = normal
								})
							end
						end
					end
					
					if #new > 0 then
						vertices_sorted[projector_id][parent] = new
					end
				end
			end
			
			net.start("data")
			--net.writeUInt(projector_id, 8)
			net.writeStream(fastlz.compress(json.encode(vertices_sorted)))
			net.send()
		end)
	end
	
end