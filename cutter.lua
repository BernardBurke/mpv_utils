local utils = require("mp.utils")
-- This script is used by mpv to cut video files.
-- It uses the KP1 to `start_time` and KP2 to `end` calulate the cut
-- This script get's activated by using mpv to play a video file or audio file
-- Then, the user can press KP1 to save the start_time time. Then, the user can press KP2 to save the end time.
-- The script will then write the cut as an MPV EDL record to the file `cuts.edl` in /tmp
-- The user can then use the `edl` script to play the cut video file.
-- The user can also use the `edl` script to play the cut audio file.

-- This function is used to get the current time of the video file
local function get_time()
    return mp.get_property_number("time-pos")
end

-- This function is used to get the current file path of the video file
local function get_path()
    return mp.get_property("path")
end

-- This function is used to get the current file name of the video file
local function get_filename()
    return mp.get_property("filename")
end

-- This function is used to get the current file extension of the video file
local function get_extension()
    return mp.get_property("file-format")
end

-- This function is used to get the current file name of the video file without the extension
local function get_filename_without_extension()
    return mp.get_property("filename/no-ext")
end

-- This function is a general purpose logger for the script
local function log(message)
    mp.msg.info(message)
end



-- This function is used to write the cut to the file `cuts.edl` in /tmp
function write_cut(start_time, end_time)
    local file = io.open("/tmp/cuts.edl", "a")
    file:write(get_filename_without_extension() .. " " .. start_time .. " " .. end_time .. "\n")
    file:close()
end

-- define the key bindings for the script
mp.add_key_binding("KP1", "start_time", function()
    log("start_time time saved: " .. get_time())
    mp.osd_message("start_time time saved: " .. get_time())
    start_time = get_time()
end)

mp.add_key_binding("KP2", "end_time", function()
    log("End time saved: " .. get_time())
    mp.osd_message("End time saved: " .. get_time())
    end_time = get_time()
    write_cut(start_time, end_time)
end)

-- monitor the property `path` to see if the user has changed the video file or the file has ended
mp.observe_property("path", "string", function(name, value)
    if value == nil then
        log("File has ended")
        mp.osd_message("File has ended")
    else
        log("File has changed to: " .. value)
        mp.osd_message("File has changed to: " .. value)
    end
end)    


-- announce that we are start_timeing and use log to describe the full path of the current playing file
print(mp.get_property("filename"))
log('start_timeing cutter.lua for file: '..get_filename())
--mp.osd_message("start_timeing cutter.lua for file: ".. get_path())