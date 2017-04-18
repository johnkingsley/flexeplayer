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
local Timer = require("Timer")

WidgetTimer = Class(Widget)

local FONT_TEXT = Font.load("idle")
local COLOR_BG = gbl.cfg:get_int("colors/idle/bg", 0xffffff)
local COLOR_TEXT = gbl.cfg:get_int("colors/idle/text", 0x000000)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetTimer._init(self, name, timeout_fnc)
    Widget._init(self, "timer")
    self:load_cfg(name)

    local this_section = "widgets/"..name.."/"
    local timeout_start = gbl.cfg:get_int(this_section.."timeout_start")
    local timeout_len = gbl.cfg:get_int(this_section.."timeout_len")
    local diameter = gbl.cfg:get_height(this_section.."diameter")

    self.idle_exit_time = nil
    local fire_cb = function()
        local now = of.getElapsedTimef()
        self.idle_exit_time = now + timeout_len
    end
    self.timer = Timer(timeout_start, fire_cb)

    -- Get the top, left corner of the widget
    self.width = diameter
    self.height = diameter
    local real_x, real_y = self:get_real_xy()

    -- Draw a big circle
    local circle = of.Path()
    local rad = diameter/2
    local cx = real_x + rad
    local cy = real_y + rad
    circle:setCircleResolution(200);
    circle:arc(cx, cy, rad, rad, 0, 360)
    circle:setFillHexColor(COLOR_BG)
    circle:close()

    self.cx = cx
    self.cy = cy
    self.circle = circle
    self.timeout_fnc = timeout_fnc
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetTimer.reset(self)
    self.timer:start()
    self.idle_exit_time = nil
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetTimer.update(self)
    -- See if we have gone idle
    self.timer:update()
    if self.idle_exit_time ~= nil then
        local now = of.getElapsedTimef()
        local secs_left = math.floor(self.idle_exit_time - now + 0.5)
        if secs_left <= 0 then
            -- The countdown has expired!
            self.timeout_fnc()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetTimer.do_draw(self)
    if self.idle_exit_time == nil then
        -- Don't draw the widget if we haven't started the countdown
        return
    end

    local now = of.getElapsedTimef()
    local secs_left = math.floor(self.idle_exit_time - now + 0.5)
    if secs_left <= 0 then
        -- Don't draw the widget if the countdown has expired
        return
    end

    -- Draw the background circle
    self.circle:draw(0, 0)

    -- Show the number of seconds left
    of.setHexColor(COLOR_TEXT)
    local msg = tostring(secs_left)
    local rect = FONT_TEXT:getStringBoundingBox(msg, 0, 0);
    local x = self.cx - rect.width/2
    local y = self.cy + rect.height/2
    FONT_TEXT:drawString(msg, x, y)
end

return WidgetTimer
