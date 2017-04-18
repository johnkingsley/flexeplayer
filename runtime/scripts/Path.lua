--
-- Flex.E.Player: Video kiosk for the Raspberry Pi
-- Copyright (C) 2017 John Kingsley
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

local Class = require("Class")

local Path = Class()

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Path.filename(path)
    local filename = path:gsub("^.*/([^/]*)$", "%1")
    return filename
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Path.basename(path)
    local filename = Path.filename(path)
    local basename = filename:gsub("^(.*)%.[^.]*$", "%1")
    return basename
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Path.dirname(path)
    local dirname = path:gsub("^(.*/)[^/]*$", "%1")
    return dirname
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Path.slurp(path, chomp)
    local f = io.open(path, "rb")
    if f == nil then
        return nil
    else
        local content = f:read("*all")
        f:close()

        if chomp then
            content = content:gsub("[\n\r]$", "")
        end

        return content
    end
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Path.file_exists(path)
    local f = io.open(path,"r")
    if f == nil then
        return false
    else
        io.close(f)
        return true
    end
end

return Path
