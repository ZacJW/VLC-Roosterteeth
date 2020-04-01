function descriptor()
	return { title = "RoosterTeeth Video Discovery", capabilities={} }
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

function main()
	channels = {}
	for x = 1, 10, 1 do

		json, pos, err = parse_json("https://svod-be.roosterteeth.com/api/v1/episodes?per_page=12&order=desc&page=" .. tostring(x))
		if json == nil then
			vlc.msg.info(err)
		end
		for i = 1, 12, 1 do
			if not json.data[i].attributes.is_sponsors_only then
				video_json = parse_json("https://svod-be.roosterteeth.com" .. json.data[i].links.self .. "/videos")
				if video_json ~= nil then
					if video_json.data ~= nil then
						new_path = video_json.data[1].links.download
						new_name = json.data[i].attributes.display_title .. " - " .. json.data[i].attributes.show_title
						new_art = json.data[i].included.images[1].attributes.thumb
						channel = json.data[i].attributes.channel_slug
						if channels[channel] == nil then
							channels[channel] = vlc.sd.add_node({title=channel})
						end
						channels[channel]:add_subitem({title = new_name, path = new_path, arturl = new_art})
					end
				end
			end
		end
	end
end