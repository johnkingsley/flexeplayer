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
    local icon = gbl.cfg:get_string(this_section.."icon")

    local width = self.width
    local height = self.height

    local radius = 10
    local shadow = 2

    local real_x, real_y = self:get_real_xy()
    self.cx = real_x + (width-shadow)/2
    self.cy = real_y + (height-shadow)/2

    local image
    local image_x
    local image_y
    if icon ~= nil then
        -- Load the image
        image = of.Image()
        image:load(icon)
        Win.img_resize(image, width, height)
        image_x = self.cx - image:getWidth()/2
        image_y = self.cy - image:getHeight()/2
    end

    local path_fg = of.Path()
    path_fg:rectRounded(real_x, real_y, 0, width-shadow, height-shadow, radius, radius, radius, radius)
    path_fg:setFillHexColor(0x8f7f8f)

    local path_bg = of.Path()
    path_bg:rectRounded(real_x+shadow, real_y+shadow, 0, width-shadow, height-shadow, radius, radius, radius, radius)
    path_bg:setFillHexColor(0x505050)

    self.text = text
    self.image = image
    self.image_x = image_x
    self.image_y = image_y
    self.path_fg = path_fg
    self.path_bg = path_bg
    local outline = path_fg:getOutline():front()
    self.outline = outline
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetButton.do_draw(self)
    self.path_bg:draw(0,0)
    if self:cursor_is_inside() then
        self.path_fg:setFillHexColor(0x9f9f9f)
    else
        self.path_fg:setFillHexColor(0x8f8f8f)
    end
    self.path_fg:draw(0,0)

    if self.image then
        of.setColor(255)
        self.image:draw(self.image_x, self.image_y)
    else
        of.setHexColor(0x000000)

        -- HACK - work around bug in getStringBoundingBox
        local str = self.text
        str = str:gsub("ç", "c")
        str = str:gsub("Ç", "C")

        local rect = font_button:getStringBoundingBox(str, 0, 0);
        local tx = self.cx - rect.width/2
        local ty = self.cy + rect.height/2
        font_button:drawString(self.text, tx, ty)
    end
end

return WidgetButton
