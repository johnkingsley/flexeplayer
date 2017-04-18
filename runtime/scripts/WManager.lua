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

WManager = Class()

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager._init(self)
    self.windows = {}
    self.active_win = nil
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.add(self, win)
    table.insert(self.windows, win)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.activate(self, win)
    if (self.active_win) then
        -- Tell the current window we are leaving them
        self.active_win:activate(false)
    end
    self.active_win = win
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.update(self)
    local win = self.active_win
    win:update()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.draw(self)
    local win = self.active_win
    win:draw()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.exit(self)
    -- Tell the current window it's being closed
    self:activate(nil)

    -- Tell *all* the windows we are exiting
    for idx,win in pairs(self.windows) do
        win:exit()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.mouseMoved(self, x, y)
    local win = self.active_win
    win:mouseMoved(x, y)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.mouseDragged(self, x, y, button)
    local win = self.active_win
    win:mouseDragged(x, y, button)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.mousePressed(self, x, y, button)
    local win = self.active_win
    win:mousePressed(x, y, button)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.mouseReleased(self, x, y, button)
    local win = self.active_win
    win:mouseReleased(x, y, button)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WManager.keyPressed(self, key)
    local win = self.active_win
    win:keyPressed(key)
end

return WManager
