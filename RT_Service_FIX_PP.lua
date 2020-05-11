-- VLC-Roosterteeth video stream plugin
-- Author: ZacJW

function probe()
	if vlc.access ~= "https" then
		return false
	end
	return string.match( vlc.path, "^svod%-be%.roosterteeth%.com/api/v1/") and string.match(vlc.path, "/master%.m3u8$")
end


function parse()
	vlc.msg.info("Using roosterteeth FIX plugin")
	items = {}
	
    while true do
        item = {}
		line = vlc.readline()
		if not line then break end
        if string.match( line, "^#EXT%-X%-STREAM%-INF") and string.match(line, "RESOLUTION=") then
            
            s,subStart = string.find(line, "RESOLUTION=")
            
            subEnd, e = string.find(line, ",CODECS")
            res = string.sub(line, subStart + 1, subEnd - 1)
            res = string.sub(res, string.find(res, "x") + 1) .. "p"
            item.title = res
            item.path = "https://svod-be.roosterteeth.com" .. vlc.readline()
            table.insert(items, item)
		end
	end
	
	return items
end
