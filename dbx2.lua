local utils = require("mp.utils")

-- Environment variables
local SNITCH_DIR = os.getenv("BCHU")
local USCR = os.getenv("USCR")
local HI = os.getenv("HI")
local subtitles_file = os.getenv("IMGSUBTITLES")

-- Constants
local SNITCH_SEGMENT_LENGTH = 30
local MESSAGE_DISPLAY_TIME_DEFAULT = 15
local SUBTITLES_ENABLED = false

-- Mode settings
local DITCH_MODE = os.getenv("DITCH_MODE") and "DITCH" or "SNITCH"
local message_display_time = tonumber(os.getenv("MESSAGE_DISPLAY_TIME")) or MESSAGE_DISPLAY_TIME_DEFAULT

-- File paths
local EDL_SNITCH_JOURNAL = SNITCH_DIR.."/edl_journal.edl"
local NON_EDL_JOURNAL = SNITCH_DIR.."/m3u_journal.m3u"
local USCR_CMD = USCR.."\\snapped.sh"
local LOG_FILE = "/tmp/dbx2_logger.log"

-- Subtitles
local lines = {}
local step_count = 1
local line_count = 0

-- Chapter timing
local previous_chapter_time = 0

-- Cut timing
local g_start_second = 0

-- Logger function
local function logger(message)
    local log_message = os.date("%Y-%m-%d %H:%M:%S") .. " - " .. message
    print(log_message)
    local log_handle = io.open(LOG_FILE, "a")
    log_handle:write(log_message .. "\n")
    log_handle:close()
end

-- Utility functions
local function isempty(s)
    logger("isempty called")
    return s == nil or s == ''
end

local function all_trim(s)
    logger("all_trim called")
    return s:match("^%s*(.-)%s*$")
end

local function send_OSD(message_string, seconds)
    logger("send_OSD called with message: " .. message_string)
    local message_str = mp.get_property("osd-ass-cc/0")..message_string..mp.get_property("osd-ass-cc/1")
    mp.osd_message(message_str, seconds)
end

local function file_exists(file)
    logger("file_exists called with file: " .. file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

local function create_edl_if_missing(bfile)
    logger("create_edl_if_missing called with file: " .. bfile)
    if not file_exists(bfile) then
        local hndl = io.open(bfile, "wb")
        hndl:write("# mpv EDL v0\n")
        hndl:close()
    end
end

local function get_file_class(filename)
    logger("get_file_class called with filename: " .. filename)
    local ext = filename:match("[^.]+$")
    if ext == "edl" then return "edl" end
    if ext == "mkv" or ext == "mp4" or ext == "avi" or ext == "webm" or ext == "wmv" then return "video" end
    if ext == "jpg" or ext == "png" or ext == "gif" then return "image" end
    if ext == "mp3" or ext == "m4a" then return "audio" end
    return "unrecognised"
end

local function toggle_SNITCH()
    logger("toggle_SNITCH called")
    DITCH_MODE = (DITCH_MODE == "SNITCH") and "DITCH" or "SNITCH"
    send_OSD("DITCH_MODE = "..DITCH_MODE, 1)
end

local function write_that_SNITCH(SNITCHfilename, record, journal_type, path)
    logger("write_that_SNITCH called with SNITCHfilename: " .. SNITCHfilename)
    local SNITCH_handle = io.open(SNITCHfilename, "a")
    SNITCH_handle:write(record)
    SNITCH_handle:close()

    if journal_type == "edl" then
        create_edl_if_missing(EDL_SNITCH_JOURNAL)
        local journal_handle = io.open(EDL_SNITCH_JOURNAL, "a")
        journal_handle:write(record)
        journal_handle:close()
    else
        local journal_handle = io.open(NON_EDL_JOURNAL, "a")
        journal_handle:write(record)
        journal_handle:close()
    end

    send_OSD("SNITCHED: "..path:gsub("\\", "/"), 3)
end

local function SNITCH_file()
    logger("SNITCH_file called")
    local filename = mp.get_property("filename")
    local path = mp.get_property("path")
    local fileclass = get_file_class(filename)
    local record = nil
    local journal_type = "edl"

    if fileclass == "unrecognised" then
        send_OSD("unrecognised file type: "..path:gsub("\\", "/"), 2)
        return
    end

    local SNITCHfilename = SNITCH_DIR.."/edl_SNITCH"..os.date('%d_%m_%y_%H')..".edl"
    if fileclass == "video" then
        create_edl_if_missing(SNITCHfilename)
        local time_pos = mp.get_property_number("time-pos")
        local start_second = math.floor(time_pos)
        record = path..","..start_second..","..SNITCH_SEGMENT_LENGTH.."\n"
        mp.command("seek "..SNITCH_SEGMENT_LENGTH)
    elseif fileclass == "image" then
        SNITCHfilename = SNITCH_DIR.."/image_SNITCH"..os.date('%d_%m_%y_%H')..".m3u"
        if not file_exists(SNITCHfilename) then
            local tmphandle = io.open(SNITCHfilename, "wb")
            tmphandle:close()
        end
        record = path.."\n"
        journal_type = "non_edl"
        mp.command("playlist-next")
    end

    write_that_SNITCH(SNITCHfilename, record, journal_type, path)
end

local function ditch_file()
    logger("ditch_file called")
    local path = mp.get_property("path")
    local strPath = "rm -v "..'"'..path..'"'.."\n"
    local ditch_file = os.getenv("EDLSRC").."/ditched.txt"
    local ditch_handle = io.open(ditch_file, "a")
    ditch_handle:write(strPath)
    send_OSD("ditched : "..strPath, 1)
    mp.command("playlist-next")
    ditch_handle:close()
end

local function ditch_or_SNITCH()
    logger("ditch_or_SNITCH called")
    if DITCH_MODE == "SNITCH" then
        SNITCH_file()
    else
        ditch_file()
    end
end

local function write_subtitles(chaptime_length)
    logger("write_subtitles called")
    if SUBTITLES_ENABLED then
        local msg = tostring(lines[step_count]):gsub("\r", "")
        mp.osd_message(msg, chaptime_length)
        step_count = (step_count % line_count) + 1
    end
end

local function new_chapter()
    logger("new_chapter called")
    local chapterlist = mp.get_property_native("chapter-list")
    local chapter = mp.get_property_native("chapter")

    if chapter then
        local chaptime_time = chapterlist[chapter + 1].time
        chaptime_time = chaptime_time == 0 and 30 or chaptime_time
        local chaptime_length = chaptime_time - previous_chapter_time
        previous_chapter_time = chaptime_time
        write_subtitles(chaptime_length)
    end
end

local function new_file(filename)
    logger("new_file called with filename: " .. filename)
    previous_chapter_time = 0
end

local function valid_for_cutting()
    logger("valid_for_cutting called")
    local fileclass = get_file_class(mp.get_property("filename"))
    if fileclass == "video" or fileclass == "audio" then
        return true
    else
        send_OSD("Wrong file type for cutting "..fileclass, 2)
        return false
    end
end

local function start_cut()
    logger("start_cut called")
    if not valid_for_cutting() then return end
    local time_pos = mp.get_property_number("time-pos")
    g_start_second = math.floor(time_pos)
    send_OSD("Start cut "..g_start_second, 1)
end

local function end_cut()
    logger("end_cut called")
    if not valid_for_cutting() then return end
    local time_pos = mp.get_property_number("time-pos")
    local stop_second = math.floor(time_pos) - g_start_second
    local path = mp.get_property("path")
    local str_record = path..","..g_start_second..","..stop_second.."\n"
    local SNITCHfilename = "video_SNITCH_"..os.date('%d_%m_%y_%H')..".edl"
    local SNITCH_file = SNITCH_DIR.."/"..SNITCHfilename
    create_edl_if_missing(SNITCH_file)
    write_that_SNITCH(SNITCH_file, str_record, "edl", path)
    send_OSD("ready for next Cut", 2)
end

local function deleteMe()
    logger("deleteMe called")
    local filename = mp.get_property_native("path")
    local delete_handle = io.open('/tmp/deleteMe.sh', "a")
    local wrtString = "rm -v '"..filename.."'\n"
    delete_handle:write(wrtString)
    delete_handle:close()
    mp.command("playlist-next")
end

-- Load subtitles if available
if subtitles_file then
    subtitles_file = subtitles_file:gsub("\\", "/")
    if file_exists(subtitles_file) then
        for line in io.lines(subtitles_file) do
            if string.len(all_trim(line)) >= 1 then
                lines[#lines + 1] = line
                line_count = line_count + 1
            end
        end
        SUBTITLES_ENABLED = true
    end
end

-- Set OSD properties
mp.set_property("osd-align-y", "bottom")
mp.set_property("osd-align-x", "center")
mp.set_property("image-display-duration", message_display_time)

-- Observe properties
mp.observe_property("filename", "string", new_file)
mp.observe_property("chapter", "number", new_chapter)

-- Key bindings
mp.add_key_binding("D", "toggle_SNITCH", toggle_SNITCH, {repeatable=true})
mp.add_key_binding("MBTN_Right", "ditch_or_SNITCH", ditch_or_SNITCH, {repeatable=true})
mp.add_key_binding("KP1", "start_cut", start_cut, {repeatable=true})
mp.add_key_binding("KP2", "end_cut", end_cut, {repeatable=true})
mp.add_key_binding("Ctrl+DEL", "deleteMe", deleteMe, {repeatable=true})

print("dbx.lua loaded - waiting for new file or chapter")
