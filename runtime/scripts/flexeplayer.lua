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

-- gbl.cfg_file_name is set in ofApp.cpp
gbl.cfg = nil
gbl.wmanager = nil
gbl.win_home = nil
gbl.win_chooser = nil
gbl.win_player = nil
gbl.lang = nil
gbl.screen_width = of.getWindowWidth()
gbl.screen_height = of.getWindowHeight()

touch = {}

function read_config()
    local Config = require("Config")
    if gbl.cfg_file_name == "" then
        gbl.cfg_file_name = "flexeplayer.json"
    end
    gbl.cfg = Config(gbl.cfg_file_name)
end
read_config()

local WManager = require("WManager")
local WinHome = require("WinHome")
local WinChooser = require("WinChooser")
local WinPlayer = require("WinPlayer")
local Lang = require("Lang")

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function setup()
    touch.enabled = true
    touch.dev_name = gbl.cfg:get_string("touchscreen/dev_name", "/dev/input/by-id/usb-Elo_TouchSystems__Inc._Elo_TouchSystems_2700_IntelliTouch_r__USB_Touchmonitor_Interfac_20L78493-event-mouse")
    touch.min_x = gbl.cfg:get_int("touchscreen/min_x", 4095)
    touch.max_x = gbl.cfg:get_int("touchscreen/max_x", 0)
    touch.min_y = gbl.cfg:get_int("touchscreen/min_y", 4095)
    touch.max_y = gbl.cfg:get_int("touchscreen/max_y", 0)

    local verbose = gbl.cfg:get_bool("log/verbose", false)
    if verbose then
        of.setLogLevel("ofxLua", of.LOG_VERBOSE)
    end
    of.setVerticalSync(true)
    of.setFrameRate(30)

    --TODO turn off ESC key

    gbl.lang = Lang()

    print(string.format("screen size: w=%d h=%d", gbl.screen_width, gbl.screen_height))

    gbl.enable_keyboard    = gbl.cfg:get_bool("general/enable_keyboard", true)
    gbl.enable_cursor      = gbl.cfg:get_bool("general/enable_cursor", true)
    gbl.enable_touchscreen = gbl.cfg:get_bool("general/enable_touchscreen", true)
    if gbl.enable_cursor then
        of.showCursor()
    else
        of.hideCursor()
    end
    touch.enabled = gbl.enable_touchscreen

    gbl.wmanager = WManager()
    gbl.win_home = WinHome(gbl.wmanager)
    gbl.win_chooser = WinChooser(gbl.wmanager)
    gbl.win_player = WinPlayer(gbl.wmanager)

    gbl.win_home:activate()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function update()
    gbl.wmanager:update()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function draw()
    gbl.wmanager:draw()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function exit()
    gbl.wmanager:exit()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function mouseMoved(x, y)
    gbl.wmanager:mouseMoved(x, y)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function mouseDragged(x, y, button)
    gbl.wmanager:mouseDragged(x, y, button)
end


----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function mousePressed(x, y, button)
    gbl.wmanager:mousePressed(x, y, button)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function mouseReleased(x, y, button)
    gbl.wmanager:mouseReleased(x, y, button)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function keyPressed(key)
    if gbl.enable_keyboard then
        gbl.wmanager:keyPressed(key)
    end
end
