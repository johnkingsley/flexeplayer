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

WinChooser = Class(Win)

local COLOUR_BG = gbl.cfg:get_int("colors/bg", 0x7f7f7f)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser._init(self, wmanager)
    Win._init(self, wmanager)
    self:load_widgets("win_chooser")

    -- Wire up the video list widget
    local videolist = self:widget_lookup("videolist.videolist")
    if videolist then
        videolist.page_change_cb = function(page_curr, page_num)
            if page_num > 1 and self.text_pagenum ~= nil then
                local cnt = string.format("%d / %d", page_curr, page_num)
                self.text_pagenum.text = cnt
            end
        end
    end
    self.videolist = videolist

    -- Load the video list with the videos
    if videolist then
        videolist:load()
    end

    -- Wire up the "back" button
    local button_back = self:widget_lookup("button.back")
    if button_back then
        button_back.click_fnc = function()
            self:go_back()
        end
    end

    -- Wire up the "left" button
    local button_left = self:widget_lookup("button.left")
    if button_left then
        if self.videolist.page_num > 1 then
            button_left.click_fnc = function()
                self:go_left()
            end
        else
            button_left:show(false)
        end
    end

    -- Wire up the "right" button
    local button_right = self:widget_lookup("button.right")
    if button_right then
        if self.videolist.page_num > 1 then
            button_right.click_fnc = function()
                self:go_right()
            end
        else
            button_right:show(false)
        end
    end

    -- Wire up the timer
    local timer_idle = self:widget_lookup("timer.idle")
    if timer_idle then
        timer_idle.timeout_fnc = function()
            gbl.win_home:activate()
        end
    end
    self.timer_idle = timer_idle

    -- Wire up the text widget for the page number
    local text_pagenum = self:widget_lookup("text.pagenum")
    if text_pagenum then
        if self.videolist.page_num <= 1 then
            text_pagenum:show(false)
        end
    end
    self.text_pagenum = text_pagenum
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.reset_and_activate(self)
    if self.videolist then
        self.videolist:goto_page(1)
    end
    self:activate()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.goto_page(self, page)
    if self.videolist then
        self.videolist:goto_page(page)
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.go_left(self)
    if self.videolist then
        self.videolist:goto_page_prev()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.go_right(self)
    if self.videolist then
        self.videolist:goto_page_next()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.go_back(self)
    gbl.win_home:activate()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.activity(self)
    Win.activity(self)
    if self.timer_idle then
        self.timer_idle:reset()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.do_activate(self, is_active)
    if (is_active) then
        if self.timer_idle then
            self.timer_idle:reset()
        end
        of.background(COLOUR_BG)
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WinChooser.keyPressed(self, key)
    if (key == of.KEY_RIGHT) then
        self:go_right()
    elseif (key == of.KEY_LEFT) then
        self:go_left()
    elseif (key == of.KEY_DEL) then
        self:go_back()
    end
end

return WinChooser
