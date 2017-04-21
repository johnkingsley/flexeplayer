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

local STATE_IDLE = 0
local STATE_PLAYING = 1
local STATE_WAITING_FOR_RESTART = 2
local STATE_WAITING_FOR_STOP = 3

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer._init(self, wmanager)
    Win._init(self, wmanager, true)
    self:load_widgets("win_player")

    -- Set up the video player
    self.omx_video = OMXVideo()
    self.curr_video = nil
    self.state = STATE_IDLE

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
    self.state = STATE_WAITING_FOR_STOP
    self.omx_video:stop()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.lang_changed(self)
    -- Restart the video in the new language
    self.state = STATE_WAITING_FOR_RESTART
    self.omx_video:stop()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.activate_and_play(self, video)
    self.state = STATE_PLAYING
    self.curr_video = video
    self:activate()
    self.curr_video:play(self.omx_video)
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

    local closed = self.omx_video:update()

    if self.state == STATE_PLAYING then
        if closed then
            -- The video ended naturally
            self.state = STATE_IDLE
            gbl.win_chooser:activate()
        else
            if self.progbar then
                self.progbar.percent_done = self.omx_video:percent_done()
            end
        end

    elseif self.state == STATE_WAITING_FOR_STOP then
        if closed then
            -- The video was ended by the user
            self.state = STATE_IDLE
            gbl.win_chooser:activate()
        end

    elseif self.state == STATE_WAITING_FOR_RESTART then
        if closed then
            -- The language changed, we need to restart the video
            self.state = STATE_PLAYING
            self.curr_video:play(self.omx_video)
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinPlayer.exit(self)
    -- TODO: the program is exiting, should we wait for the OMXplayer to stop?
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
