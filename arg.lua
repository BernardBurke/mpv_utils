local utils = require("mp.utils")
function new_file(name,value)
    if value == nil then
        mp.osd_message("File has ended")
    else
        mp.osd_message("File has changed to: " .. value)
        filename = mp.get_property("path")
        print(filename)
    end
end

mp.observe_property("filename","string",new_file)


