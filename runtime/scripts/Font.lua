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

Font = Class()

local CFG_SECTION = "fonts"
local DEF_FONT_NAME = gbl.cfg:get_string(CFG_SECTION.."/.default/name")
local DEF_FONT_SIZE = gbl.cfg:get_int(CFG_SECTION.."/.default/size", 10)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Font.load(name)
    local section = CFG_SECTION.."/"..name.."/"
    local name = gbl.cfg:get_string(section.."name", DEF_FONT_NAME)
    local size = gbl.cfg:get_int(section.."size", DEF_FONT_SIZE)
    local font = of.TrueTypeFont()
    font:load(name, size)
    return font
end

return Font
