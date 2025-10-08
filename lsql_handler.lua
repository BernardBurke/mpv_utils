-- mpv_history_handler.lua

-- Define the module table
local M = {}

-- Standard dependencies
local sqlite3 = require('lsqlite3')
local msg = require('mp.msg')
local os = os
local string = string
local tonumber = tonumber
local mp = mp

-- --- Configuration: Environment Variables for Database Paths ---
-- Use environment variables (MPV_HISTORY_DB and MPV_LIBRARY_DB)
-- If variables are not set, fall back to default path (history.db in config dir)

local ENV_HISTORY_DB = os.getenv("MPV_HISTORY_DB")
local ENV_LIBRARY_DB = os.getenv("MPV_LIBRARY_DB")

local default_db_path = (function()
    local cfg = mp.find_config_file('.')
    return cfg:sub(1, #cfg - 1)
end)()

-- DB Connections Table: We'll store all connections here.
-- Key is a descriptive name, value is the db handle.
local DB_CONNECTIONS = {}

-- --- Logging Function ---
function M.log(level, ...)
    local message = table.concat({...}, ' ')
    if level == "error" then
        msg.error("[HISTORY] " .. message)
    else
        msg.info("[HISTORY] " .. message)
    end
end

-- --- Database Path Initialization ---
-- This runs once when the script loads
local HISTORY_DB_PATH = ENV_HISTORY_DB or (default_db_path .. 'history.db')
M.log("info", "History DB Path:", HISTORY_DB_PATH)

local LIBRARY_DB_PATH = ENV_LIBRARY_DB or (default_db_path .. 'library.db')
M.log("info", "Library DB Path:", LIBRARY_DB_PATH)

-- --- Internal Utility: Opens and returns a DB handle ---
local function open_db(db_path, db_name)
    local db_handle, errcode, errmsg = sqlite3.open(db_path)
    if not db_handle then
        M.log("error", db_name, "Failed to open:", errmsg)
        error(string.format("%s DB failed to open: %s", db_name, errmsg))
    end
    DB_CONNECTIONS[db_name] = db_handle
    M.log("info", db_name, "opened successfully.")
    return db_handle
end

-- --- Function 1: Check and Create Table ---
function M.start_file()
    M.log("info", "Attempting to acquire database connection for this MPV instance.")
    
    -- Connect to history DB
    local db = open_db(HISTORY_DB_PATH, "history")
    
    -- Check if table exists
    local check_table = "SELECT name FROM sqlite_master WHERE type='table' AND name='history_item';"
    local cursor = db:exec(check_table)
    
    local table_exists = false
    if cursor then
        table_exists = cursor:fetch() ~= nil
        cursor:close()
    end

    if not table_exists then
        M.log("info", "history_item table not found. Creating it...")
        local create_tables = [[
            CREATE TABLE history_item(
                id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                path        TEXT    NOT NULL,
                filename    TEXT    NOT NULL,
                title       TEXT    NOT NULL,
                time_pos    INTEGER,
                date        DATE    NOT NULL
            );
        ]]
        
        local res = db:exec(create_tables)
        if res ~= sqlite3.OK then M.log("error", db:errmsg()); error(db:errmsg()) end
        M.log("info", "history_item table created successfully.")
    end

    -- You can also connect to the secondary library DB here if needed:
    -- open_db(LIBRARY_DB_PATH, "library")
end

-- --- Function 2: Insert New File on Load ---
function M.file_loaded()
    local db = DB_CONNECTIONS.history -- Get the connection for this instance
    if not db then return M.log("error", "History DB not connected in file_loaded.") end

    local path = mp.get_property("path") or "N/A"
    local filename = mp.get_property("filename") or "N/A"
    local title = mp.get_property("media-title") or "N/A"
    local date_str = os.date("%Y-%m-%d %H:%M")

    -- Sanitize inputs to prevent SQL injection issues from property values
    local safe_path = string.gsub(path, "'", "''")
    local safe_filename = string.gsub(filename, "'", "''")
    local safe_title = string.gsub(title, "'", "''")

    local video_query = string.format([[
        INSERT INTO history_item (path, filename, title, date)
        VALUES(
            '%s',
            '%s',
            '%s',
            '%s'
        );
        SELECT LAST_INSERT_ROWID();
    ]], safe_path, safe_filename, safe_title, date_str)

    -- Use a dedicated MPV property to store the current file's ID for this instance
    local last_id = nil
    local res = db:exec(video_query, function(udata, cols, values, names)
        last_id = tonumber(values[1])
        return 0
    end, nil)
    
    if res == sqlite3.OK and last_id then
        mp.set_property_number("script-opts/history-id", last_id) -- PER-INSTANCE STORAGE
        M.log("info", "New history ID recorded in MPV property:", last_id)
    else
        M.log("error", "Failed to insert history item:", db:errmsg())
    end
end

-- --- Function 3: Update Time on Unload ---
function M.on_unload()
    local db = DB_CONNECTIONS.history
    if not db then return M.log("error", "History DB not connected in on_unload.") end

    local time_pos = tonumber(mp.get_property("percent-pos")) -- Use percent-pos for robust saving
    local current_id = tonumber(mp.get_property("script-opts/history-id"))

    if not current_id then
        return M.log("info", "No history ID found for current file. Skipping update.")
    end
    if not time_pos then
        return M.log("info", "No time position found. Skipping update.")
    end

    local query = string.format([[
        UPDATE history_item
        SET time_pos = %d
        WHERE id = %d;
    ]], time_pos, current_id)

    local res = db:exec(query)
    if res ~= sqlite3.OK then
        M.log("error", "Failed to update time position:", db:errmsg())
    else
        M.log("info", "Time position updated for ID:", current_id)
    end
end

-- --- Function 4: Close DB on Shutdown ---
function M.shutdown()
    for name, db_handle in pairs(DB_CONNECTIONS) do
        if db_handle then
            M.log("info", "Closing", name, "database.")
            db_handle:close()
        end
    end
end

-- Register hooks to the module's functions
mp.register_event("start-file", M.start_file)
mp.register_event("file-loaded", M.file_loaded)
mp.add_hook("on_unload", 50, M.on_unload) -- Use the internal function name from the module table
mp.register_event("shutdown", M.shutdown)

-- Return the module table
return M
