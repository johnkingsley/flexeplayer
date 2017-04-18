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

Timer = Class()

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Timer._init(self, timeout, fire_cb)
    self.timeout = timeout
    self.fire_cb = fire_cb
    self.fire_time = nil
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Timer.update(self)
    if self.fire_time ~= nil then
        local now = of.getElapsedTimef()
        if now >= self.fire_time then
            self:stop()
            self:fire_cb()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Timer.start(self)
    local now = of.getElapsedTimef()
    self.fire_time = now + self.timeout
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Timer.stop(self)
    self.fire_time = nil
end

return Timer
