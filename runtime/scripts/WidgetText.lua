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
local Font = require("Font")
local Widget = require("Widget")

WidgetText = Class(Widget)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetText._init(self, name)
    Widget._init(self, "timer")
    self:load_cfg(name)

    local font = Font.load(name)
    self.font = font
    -- TODO: get default colour
    local colour = gbl.cfg:get_int("colors/"..name.."/text", 0x000000)
    self.colour = colour

    -- Get the top, left corner of the widget
    local real_x, real_y = self:get_real_xy()

    -- Save centre location of the widget
    self.cx = real_x + self.width/2
    self.cy = real_y + self.height/2

    self.text = ""
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetText.do_draw(self)
    of.setHexColor(self.colour)
    local text = self.text
    local rect = self.font:getStringBoundingBox(text, 0, 0);
    local x = self.cx - rect.width/2
    local y = self.cy + rect.height/2
    self.font:drawString(text, x, y)
end

return WidgetText
