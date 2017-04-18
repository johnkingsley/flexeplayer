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

WidgetProgbar = Class(Widget)

local COLOR_FG = gbl.cfg:get_int("colors/progbar/fg", 0xffffff)
local COLOR_BG = gbl.cfg:get_int("colors/progbar/bg", 0x000000)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetProgbar._init(self, name)
    Widget._init(self, "progbar")
    self:load_cfg(name)

    self.percent_done = 0

    -- Save the x,y for drawing
    local real_x, real_y = self:get_real_xy()
    self.real_x = real_x
    self.real_y = real_y

    self.bg_rect = self:make_bar(1, COLOR_BG)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetProgbar.make_bar(self, percent, color)
    local min_x = self.real_x
    local max_x = self.real_x + self.width*percent
    local min_y = self.real_y
    local max_y = self.real_y + self.height

    local bar_path = of.Path()
    bar_path:moveTo(min_x, min_y)
    bar_path:lineTo(max_x, min_y)
    bar_path:lineTo(max_x, max_y)
    bar_path:lineTo(min_x, max_y)
    bar_path:close()
    bar_path:setFillHexColor(color)

    return bar_path
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetProgbar.do_draw(self)
    -- Draw the background
    self.bg_rect:draw(0, 0)

    -- Draw the forground
    local fg_rect = self:make_bar(self.percent_done, COLOR_FG)
    fg_rect:draw(0, 0)
end

return WidgetProgbar
