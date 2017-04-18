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
local Widget = require("Widget")

WidgetImage = Class(Widget)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetImage._init(self, name)
    Widget._init(self, "image")
    self:load_cfg(name)

    local this_section = "widgets/"..name.."/"
    local src = gbl.cfg:get_string(this_section.."src")

    -- Load the image
    self.logo_img = of.Image()
    self.logo_img:load(src)

    -- Resize the image
    Win.img_resize(self.logo_img, self.width, self.height)
    self.width = self.logo_img:getWidth()
    self.height = self.logo_img:getHeight()

    -- Save the x,y for drawing
    local real_x, real_y = self:get_real_xy()
    self.real_x = real_x
    self.real_y = real_y
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetImage.do_draw(self)
    of.setColor(255)
    self.logo_img:draw(self.real_x, self.real_y)
end

return WidgetImage
