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

Widget = Class()

--                   _______ Y axis (0=min, 1=avg, 2=max)
--                   |______ X axis (0=min, 1=avg, 2=max)
--                   ||
--                   vv
Widget.ORIGIN_C  = 0x11
Widget.ORIGIN_N  = 0x01
Widget.ORIGIN_S  = 0x21
Widget.ORIGIN_W  = 0x10
Widget.ORIGIN_E  = 0x12
Widget.ORIGIN_NW = 0x00
Widget.ORIGIN_NE = 0x02
Widget.ORIGIN_SW = 0x20
Widget.ORIGIN_SE = 0x22

local _MIN = 0
local _AVG = 1
local _MAX = 2

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget._init(self, type_name, outline, click_fnc)
    self.type_name = type_name
    self.name = nil
    self.outline = outline
    self.click_fnc = click_fnc
    self.is_visible = true
    self.always_visible = false
    self.x = 0
    self.y = 0
    self.z = nil
    if outline ~= nil then
        local bb = outline:getBoundingBox()
        self.width = bb:getWidth()
        self.height = bb:getHeight()
    else
        self.width = 1
        self.height = 1
    end
    self.origin = Widget.ORIGIN_C
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.load_cfg(self, name)
    self.name = name

    local default_section = "widgets/"..self.type_name.."/"
    local default_x = gbl.cfg:get_width(default_section.."x")
    local default_y = gbl.cfg:get_height(default_section.."y")
    local default_z = gbl.cfg:get_height(default_section.."z")
    local default_width = gbl.cfg:get_width(default_section.."width")
    local default_height = gbl.cfg:get_height(default_section.."height")
    local default_origin = gbl.cfg:get_string(default_section.."origin")

    local this_section = "widgets/"..self.name.."/"
    local this_x = gbl.cfg:get_width(this_section.."x", default_x)
    local this_y = gbl.cfg:get_height(this_section.."y", default_y)
    local this_z = gbl.cfg:get_height(this_section.."z", default_z)
    local this_width = gbl.cfg:get_width(this_section.."width", default_width)
    local this_height = gbl.cfg:get_height(this_section.."height", default_height)
    local this_origin = gbl.cfg:get_string(this_section.."origin", default_origin)

    --[[
    print("default_section = "..tostring(default_section))
    print("this_section = "..tostring(this_section))

    print("default x = "..tostring(default_x))
    print("default y = "..tostring(default_y))
    print("default z = "..tostring(default_z))
    print("default width = "..tostring(default_width))
    print("default height = "..tostring(default_height))
    print("default origin = "..tostring(default_origin))

    print("x = "..tostring(this_x))
    print("y = "..tostring(this_y))
    print("z = "..tostring(this_z))
    print("width = "..tostring(this_width))
    print("height = "..tostring(this_height))
    print("origin = "..tostring(this_origin))
    --]]

    self.x = this_x
    self.y = this_y
    self.z = this_z
    self.width = this_width
    self.height = this_height
    self:set_origin(this_origin)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.get_real_xy(self)
    local o = self.origin
    local ox = o % 16
    local oy = math.floor(o / 16)
    local calc = function(t, val, len)
        if t == _MIN then
            --print("MIN")
            return val
        elseif t == _AVG then
            --print("AVG")
            return val - len/2
        else
            --print("MAX")
            return val - len
        end
    end
    local rx = calc(ox, self.x, self.width)
    local ry = calc(oy, self.y, self.height)
    return rx, ry
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.set_origin(self, origin)
    origin = origin:lower()

    if origin == "c" or origin == "center"  or origin == "centre" then
        self.origin = Widget.ORIGIN_C
        return
    end

    if origin == "n" or origin == "north" then
        self.origin = Widget.ORIGIN_N
        return
    end

    if origin == "s" or origin == "south" then
        self.origin = Widget.ORIGIN_S
        return
    end

    if origin == "w" or origin == "west" then
        self.origin = Widget.ORIGIN_W
        return
    end

    if origin == "e" or origin == "east" then
        self.origin = Widget.ORIGIN_E
        return
    end

    if origin == "nw" or origin == "northwest" then
        self.origin = Widget.ORIGIN_NW
        return
    end

    if origin == "ne" or origin == "northeast" then
        self.origin = Widget.ORIGIN_NE
        return
    end

    if origin == "sw" or origin == "southwest" then
        self.origin = Widget.ORIGIN_SW
        return
    end

    if origin == "se" or origin == "southeast" then
        self.origin = Widget.ORIGIN_SE
        return
    end

    -- TODO: log error
    print("Bad origin: "..tostring(origin))
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.update(self)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.do_draw(self)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.draw(self)
    if self.is_visible or self.always_visible then
        self:do_draw()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.show(self, is_visible)
    self.is_visible = is_visible
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.cursor_is_inside(self)
    if self.outline == nil then
        return false
    else
        local mouseX = of.getMouseX()
        local mouseY = of.getMouseY()
        return self.outline:inside(mouseX, mouseY)
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Widget.check_click(self, x, y, button)
    if self.is_visible and self.outline ~= nil and self.click_fnc ~= nil and self.outline:inside(x, y) then
        self.click_fnc()
    end
end

return Widget
