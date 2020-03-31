-- VLC-Roosterteeth video stream plugin
-- Author: ZacJW

function probe()
	if vlc.access ~= "https" then
		return false
	end
	if string.match( vlc.path, "^roosterteeth%.com/watch") then
		return true
	else
		return false
	end
end

function parse_json(url)
	local json = require("dkjson")
	local stream = vlc.stream(url)
	local string = ""
	local line = ""
	
	if not stream then return nil end
	while true do
		line = stream:readline()
		
		if not line then break end
		string = string .. line
	end
	
	return json.decode(string)
end

function parse()
	vlc.msg.info("Using roosterteeth plugin")
	item = {}
	
	while true do
		line = vlc.readline()
		if not line then break end
		if string.match( line, "^<title>") then
			s,subStart = string.find(line, "^<title>")
			subStart = 7
			subEnd, e = string.find(line, "</title>")
			item.title = string.sub(line, subStart + 1, subEnd - 1)
			break
		end
	end
	
	s, e = string.find(vlc.path, "/watch/", 0, true)
	if vlc.path[-1] == "/" then
		videos = "videos"
	else
		videos = "/videos"
	end
	json, pos, err = parse_json("https://svod-be.roosterteeth.com/api/v1/watch/" .. string.sub(vlc.path, e + 1) .. videos)
	
	if err then return nil, "JSON Error" end
	
	url = json.data[1].links.download
	
	item.path = url
	
	return { item }
end
