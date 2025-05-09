local utils = require("mp.utils")

local EDL_FILE = "/tmp/current_clip_edl.edl" -- Temporary EDL for current session
local OUTPUT_DIR = "/tmp/clipped_media" -- Output directory for clips

local cut_start_time = nil

local function file_exists(filepath)
    local f = io.open(filepath, "rb")
    if f then f:close() return true else return false end
end

local function create_edl_if_not_exists(filepath)
    if not file_exists(filepath) then
        local file = io.open(filepath, "wb")
        file:write("# mpv EDL v0\n")
        file:close()
        print("Created: " .. filepath)
    end
end

local function write_edl_record(filepath, record)
    create_edl_if_not_exists(filepath)
    local file = io.open(filepath, "a")
    file:write(record .. "\n")
    file:close()
end

local function read_edl_records(edl_file)
    if not file_exists(edl_file) then
        mp.osd_message("EDL file not found: " .. edl_file, 5)
        return nil
    end

    local records = {}
    for line in io.lines(edl_file) do
        if line:sub(1, 1) ~= "#" and line:match(",") then
            local parts = {}
            for part in line:gmatch("[^,]+") do
                table.insert(parts, part)
            end
            if #parts == 3 then
                records[#records + 1] = {
                    filepath = parts[1],
                    start_time = parts[2],
                    duration = parts[3]
                }
            end
        end
    end
    return records
end

local function clip_media(record)
    local input_file = record.filepath
    local start_time = record.start_time
    local duration = record.duration
    local output_file = OUTPUT_DIR .. "/" .. utils.strftime("%Y%m%d_%H%M%S") .. "_" .. utils.split_path(input_file).filename .. ".mp4"

    local ffmpeg_cmd = {
        "ffmpeg",
        "-i", input_file,
        "-ss", start_time,
        "-t", duration,
        "-c", "copy",
        output_file
    }

    local result = utils.subprocess(ffmpeg_cmd)

    if result.status == 0 then
        mp.osd_message("Clip created: " .. output_file, 5)
    else
        mp.osd_message("FFmpeg error: " .. (result.stderr or "Unknown error"), 5)
    end
end

local function process_edl()
    local records = read_edl_records(EDL_FILE)
    if records then
        for _, record in ipairs(records) do
            clip_media(record)
        end
    end
end

local function start_cut()
    cut_start_time = mp.get_property_number("time-pos")
    mp.osd_message("Cut start: " .. cut_start_time, 2)
end

local function end_cut()
    if cut_start_time then
        local cut_end_time = mp.get_property_number("time-pos")
        local duration = cut_end_time - cut_start_time
        local current_file = mp.get_property("path")
        local record = current_file .. "," .. cut_start_time .. "," .. duration
        write_edl_record(EDL_FILE, record)
        mp.osd_message("Cut end: " .. cut_end_time .. ", Duration: " .. duration, 2)
        cut_start_time = nil -- Reset cut start
    else
        mp.osd_message("No cut start time recorded.", 2)
    end
end

-- Key bindings
mp.add_key_binding("KP1", "start_cut", start_cut, { repeatable = false })
mp.add_key_binding("KP2", "end_cut", end_cut, { repeatable = false })
mp.add_key_binding("c", "process_edl", process_edl, { repeatable = false })

print("EDL cutter loaded. Use KP1/KP2 to mark cuts, 'c' to process.")