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
local OMXVideo = require("OMXVideo")

WinPlayer = Class(Win)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer._init(self, wmanager)
    Win._init(self, wmanager, true)
    self:load_widgets("win_player")

    -- Set up the video player
    self.omx_video = OMXVideo()

    -- Wire up the progress bar
    local progbar = self:widget_lookup("progbar.progbar")
    if progbar then
        progbar.always_visible = true
    end
    self.progbar = progbar

    -- Wire up the "back" button
    local button_back = self:widget_lookup("button.back")
    if button_back then
        button_back.click_fnc = function()
            self:go_stop()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.go_stop(self)
    self.omx_video:stop()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.lang_changed(self)
    -- TODO: handle case when lang changes -- need to restart video
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.activate_and_play(self, path)
    self:activate()
    self.omx_video:load(path)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.do_activate(self, is_active)
    if (is_active) then
        -- Make background transparent, so that video shows
        of.background(0, 0, 0, 0)
    else
        self.omx_video:stop()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.update(self)
    Win.update(self)

    if (self.omx_video:update()) then
        gbl.win_chooser:activate()
    else
        if self.progbar then
            self.progbar.percent_done = self.omx_video:percent_done()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.exit(self)
    self.omx_video:stop()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.keyPressed(self, key)
    if (key == of.KEY_DEL) then
        self:go_stop()
    end
end

return WinPlayer
