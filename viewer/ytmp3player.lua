--@name YT MP3 Player
--@author Sevii

local server = "https://sevii.dev/api/ytmp3/%s"
local audio_count = 1
local volume = 1
local mindist = 1000
local maxdist = 1200

if SERVER then
	
	local video_id
	
	hook.add("playerSay", "", function(ply, text)
		local cmds = string.split(text, " ")
		
		if string.sub(text, 1, 4) ~= ".yt " then return end
		
		video_id = nil
		local id = string.match(cmds[2], "[%w_-]+$")
		
		net.start("download")
		net.writeString(id)
		net.send(owner())
		
		net.start("loading")
		net.writeString(id)
		net.send()
	end)
	
	net.receive("request", function(_, ply)
		if video_id then
			net.start("id")
			net.writeString(video_id)
			net.send(ply)
		end
	end)
	
	net.receive("download", function(_, ply)
		if ply ~= owner() then return end
		
		video_id = net.readString()
		
		net.start("id")
		net.writeString(video_id)
		net.send()
	end)
	
else
	
	local curaudios = {}
	local status, video_id
	
	local function play(id)
		for _, audio in pairs(curaudios) do
			audio:stop()
			if isValid(audio) then
				audio:destroy()
			end
		end
		
		status = "Playing"
		video_id = id
		
		for i2 = 1, audio_count do
			local i = i2
			
			bass.loadURL(string.format(server, video_id), "3d noblock noplay", function(snd, a, b)
				if not snd then
					video_id = tostring(a) .. " " .. tostring(b)
					
					return
				end
				
				curaudios[i] = snd
				curaudios[i]:setLooping(true)
				
				if i == audio_count then
					for _, audio in pairs(curaudios) do
						audio:play()
					end
				end
			end)
		end
	end
	
	local function dothink()
		local pos = player():getPos()
		local dist = (pos - chip():getPos()):getLength()
		local volume = math.max(0, 1 - math.max(0, dist - mindist) / (maxdist - mindist)) * volume
		
		for _, audio in pairs(curaudios) do
			if not audio or not isValid(audio) then continue end
			
			audio:setPos(pos)
			audio:setVolume(volume)
		end
	end
	
	local function dorender()
		render.drawSimpleText(256, 256, tostring(status) .. " " ..tostring(video_id), 1, 1)
		
		local curaudio = curaudios[1]
		if not curaudio or not isValid(curaudio) then return end
		
		local fft = curaudio:getFFT(5.2)
		if #fft < 64 then return end
		
		for i = 0, 63 do
			local height = fft[i + 1] * 400
			render.drawRect(i * 8, 512 - height, 8, height)
		end
	end
	
	local function load()
		net.start("request")
		net.send()
		
		net.receive("loading", function()
			video_id = net.readString()
			status = "Loading"
		end)
		
		net.receive("id", function()
			play(net.readString())
		end)
		
		hook.add("think", "", dothink)
		hook.add("render", "", dorender)
	end
	
	----------------------------------------
	
	if player() == owner() then
		net.receive("download", function()
			local video_id = net.readString()
			
			http.get(string.format(server, video_id), function()
				cururl = new
				
				net.start("download")
				net.writeString(video_id)
				net.send()
			end, print)
		end)
	end
	
	----------------------------------------
	
	local perms = {
		"render.screen",
		"bass.loadURL",
		"sound.create",
		"sound.modify"
	}
	
	local has = true
	for _, perm in pairs(perms) do
		if not hasPermission(perm) then
			has = false
			
			break
		end
	end
	
	if has then
		load()
	else
		setupPermissionRequest(perms, "do it pussboi", true)
		
		if hasPermission("render.screen") then
			hook.add("render", "perms", function()
				render.drawSimpleText(256, 256, "Press e to listen to epic songs", 1, 1)
			end)
		end
		
		hook.add("permissionrequest", "perms", function()
			if permissionRequestSatisfied() then
				hook.remove("permissionrequest", "perms")
				hook.remove("render", "perms")
				
				load()
			end
		end)
	end
	
end