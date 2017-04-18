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
local Path = require("Path")
local json = require("dkjson")
local Log = require("Log")

Config = Class()

local BOOL = {
    ["f"]     = false,
    ["false"] = false,
    ["t"]     = true,
    ["true"]  = true,
    ["0"]     = false,
    ["1"]     = true,
}

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config._init(self, cfg_file)
    self.cfg = {}
    self.cfg_file = cfg_file

    print("Loading config file '"..cfg_file.."'")
    local cfg_contents = Path.slurp(cfg_file)
    if cfg_contents == nil then
        print("Config file '"..cfg_file.."' not found.")
        return
    end
    local json_obj, json_pos, json_err = json.decode(cfg_contents)
    if json_err then
        print("Error loading config file: ", json_err)
        return
    end
--    Log.dbg_print_r(json_obj, "    ")

    self.cfg = json_obj
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get_float(self, name, default)
    local val = self:get_string(name, nil)
    if val == nil then
        val = default
    else
        val = tonumber(val)
    end
    return val
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get_int(self, name, default)
    return self:get_float(name, default)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get(self, name, default)
    --print("name = '"..name.."'")

    local val
    local table = self.cfg
    while true do
        local name1, name_rest = string.match(name, "^(.-)/(.*)$")
        if name1 == nil then
            val = table[name]
            break
        else
            table = table[name1]
            if table == nil then
                break
            end
            name = name_rest
        end
    end

    --print("val = '"..tostring(val).."'")
    if val == nil then
        val = default
    end

    return val
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get_string(self, name, default)
    --print("name = '"..name.."'")

    local val = self:get(name, nil)

    --print("val = '"..tostring(val).."'")
    if val == nil then
        val = default
    else
        val = tostring(val)
    end

    return val
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get_bool(self, name, default)
    local val = self:get_string(name, nil)
    if val == nil then
        val = default
    else
        val = BOOL[val:lower()]
        if val == nil then
            print("config "..name.." has bad boolean: '"..val.."'")
            val = false
        end
    end
    return val
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get_width(self, name, default)
    local val = self:get_string(name, nil)
    if val == nil then
        val = Win.getWidth(default)
    else
        val = Win.getWidth(val)
    end
    return val
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Config.get_height(self, name, default)
    local val = self:get_string(name, nil)
    if val == nil then
        val = Win.getHeight(default)
    else
        val = Win.getHeight(val)
    end
    return val
end

return Config
