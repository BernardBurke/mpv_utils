local utils = require("mp.utils")

mp.set_property("osd-align-y","bottom")
mp.set_property("osd-align-x","center")
mp.set_property("sub-visibility","no")

lines = {}
line_count = 0
latch = "clear"

image_file = os.getenv("IMAGE_M3U")

if image_file == nil then
	print "IMAGE_M3U not set"
	mp.command("quit")
end	

function all_trim(s)
    return s:match( "^%s*(.-)%s*$" )
end


function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function send_OSD(message_string, seconds)

    local message_str = mp.get_property("osd-ass-cc/0")..message_string..mp.get_property("osd-ass-cc/1")

    print("osd message ".. message_str)

    mp.osd_message(message_str, seconds)

end


if file_exists(image_file) then
        print("loading "..image_file)
        for line in io.lines(image_file) do
            print("reading "..line)
            if (string.len(all_trim(line)) >= 1) then
                lines[#lines + 1] = line
                line_count = line_count + 1
            end
        end

        SUBTITLES_LOADED = true
	print("Images loaded : "..line_count)
	line_counter = line_count
else
	print("IMAGE_M3U not set or does not exist "..image_file)
	mp.command("quit")
end

local function new_title()
    local title = mp.get_property_native("sub-text")
    if title ~= nil then
    	print("switching to --> "..title)
 	line_counter = line_counter - 1	
	current_image = lines[line_counter]
	mp.commandv("video-add", current_image,"select")
	send_OSD(title, 30)
	if line_counter == 1 then
		line_counter = line_count
	end
	--imp.osd_message(title)
	--mp.command("playlist-next")
    end
    
    if latch == "clear" then
	latch = "set"
    else
	--mp.commandv("video-remove", 1)
    end

end

mp.observe_property("sub-text","string",new_title)
