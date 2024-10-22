local mp = require 'mp'
local utils = require 'mp.utils'

local start_time = nil
local edl_file = "/tmp/mpv_edl.txt"

function format_time(seconds)
    return string.format("%.3f", seconds)
end

function mark_start()
    start_time = mp.get_property_number("time-pos")
    mp.osd_message("EDL start marked", 1)
end

function write_edl()
    if start_time == nil then
        mp.osd_message("Start time not set. Press KP1 first.", 2)
        return
    end

    local end_time = mp.get_property_number("time-pos")
    local duration = end_time - start_time
    local input_file = mp.get_property("path")

    local edl_entry = string.format("%s,%s,%s\n", 
        input_file,
        format_time(start_time),
        format_time(duration))

    local file = io.open(edl_file, "a")
    if file then
        if file:seek("end") == 0 then
            file:write("# mpv EDL v0\n")
        end
        file:write(edl_entry)
        file:close()
        mp.osd_message("EDL entry added", 1)
    else
        mp.osd_message("Failed to write EDL entry", 2)
    end

    start_time = nil
end

mp.add_key_binding("KP1", "mark_edl_start", mark_start)
mp.add_key_binding("KP2", "write_edl_entry", write_edl)

mp.osd_message("EDL script loaded. Use KP1 to mark start, KP2 to write entry.", 4)