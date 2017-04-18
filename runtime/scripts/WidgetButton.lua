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

WidgetButton = Class(Widget)

local font_button = Font.load("button")

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetButton._init(self, name, click_fnc)
    Widget._init(self, "button", nil, click_fnc)
    self:load_cfg(name)

    local this_section = "widgets/"..name.."/"
    local text = gbl.cfg:get_string(this_section.."text")

    local width = self.width
    local height = self.height

    local real_x, real_y = self:get_real_xy()
    self.cx = real_x + width/2
    self.cy = real_y + height/2

    local path = of.Path()
    path:moveTo(real_x,       real_y)
    path:lineTo(real_x+width, real_y)
    path:lineTo(real_x+width, real_y+height)
    path:lineTo(real_x,       real_y+height)
    path:close()
    path:setFillHexColor(0x8f7f8f)
    path:setStrokeHexColor(0x000000)

    self.text = text
    self.path = path
    local outline = path:getOutline():front()
    self.outline = outline
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetButton.do_draw(self)
    if self:cursor_is_inside() then
        self.path:setFillHexColor(0x9f9f9f)
    else
        self.path:setFillHexColor(0x8f8f8f)
    end
    self.path:draw(0,0)

    of.setHexColor(0x000000)
    local rect = font_button:getStringBoundingBox(self.text, 0, 0);
    local tx = self.cx - rect.width/2
    local ty = self.cy + rect.height/2
    font_button:drawString(self.text, tx, ty)
end

return WidgetButton
