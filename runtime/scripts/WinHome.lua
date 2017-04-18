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
local Win = require("Win")

WinHome = Class(Win)

local COLOR_BG = gbl.cfg:get_int("colors/bg", 0x7f7f7f)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinHome._init(self, wmanager)
    Win._init(self, wmanager)
    self:load_widgets("win_home")

    -- Wire up "Allez!" button
    local button_fr = self:widget_lookup("button.allez")
    if button_fr then
        button_fr.click_fnc = function()
            gbl.lang:set("fr")
            gbl.win_chooser:reset_and_activate()
        end
    end

    -- Wire up "Go!" button
    local button_en = self:widget_lookup("button.go")
    if button_en then
        button_en.click_fnc = function()
            gbl.lang:set("en")
            gbl.win_chooser:reset_and_activate()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinHome.do_activate(self, is_active)
    if (is_active) then
        of.background(COLOR_BG)
    end
end

return WinHome
