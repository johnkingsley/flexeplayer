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
local Timer = require("Timer")
local WidgetGroup     = require("WidgetGroup")
local WidgetButton    = require("WidgetButton")
local WidgetImage     = require("WidgetImage")
local WidgetVideoList = require("WidgetVideoList")
local WidgetTimer     = require("WidgetTimer")
local WidgetText      = require("WidgetText")
local WidgetProgbar   = require("WidgetProgbar")

Win = Class(WidgetGroup)

-- TODO - wrong cfg
local HIDE_TIMEOUT = gbl.cfg:get_int("win/button_hide_timeout", 5)

local WIDGET_TYPES = {
    button = WidgetButton,
    image = WidgetImage,
    videolist = WidgetVideoList,
    text = WidgetText,
    timer = WidgetTimer,
    progbar = WidgetProgbar,
}

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win._init(self, wmanager, auto_hide)
    WidgetGroup._init(self, "Win")

    self.wmanager = wmanager
    if auto_hide then
        local fire_cb = function()
            self:show_buttons(false)
        end
        self.timer = Timer(HIDE_TIMEOUT, fire_cb)
    else
        self.timer = nil
    end

    self.button_lang = nil
    wmanager:add(self)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.load_widgets(self, win_name)
    print("loading window >>> "..tostring(win_name).." <<<")

    local widgets = gbl.cfg:get(win_name.."/widgets")
    for idx,widget_name in pairs(widgets) do
        self:load_widget(widget_name)
    end

    -- Wire up language button
    local button_lang = self:widget_lookup("button.lang")
    if button_lang then
        button_lang.click_fnc = function()
            gbl.lang:toggle()
            self.button_lang.text = gbl.lang:get_desc(true)
            self:lang_changed()
        end
    end
    self.button_lang = button_lang
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.load_widget(self, widget_full_name)
    print("loading widget '"..tostring(widget_full_name).."'")
    local widget_type_name, widget_name = string.match(widget_full_name, "^(.-)%.(.*)$")
    local widget_type = WIDGET_TYPES[widget_type_name]
    local widget = widget_type(widget_full_name)
    self:widget_add(widget)
    return widget
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.do_activate(self, is_active)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.activate(self, is_active)
    -- Make sure the cursor is visible
    -- (both activating and deactiviting)
    self:show_buttons(true)

    if is_active or is_active == nil then
        if self.button_lang then
            self.button_lang.text = gbl.lang:get_desc(true)
        end
        self:activity()
        self.wmanager:activate(self)
        self:do_activate(true)
    else
        self:do_activate(false)
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.keyPressed(self, key)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.show_buttons(self, is_visible)
    self:show(is_visible)
    if gbl.enable_cursor then
        if is_visible then
            of.showCursor()
        else
            of.hideCursor()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.lang_changed(self)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.update(self)
    WidgetGroup.update(self)
    if self.timer ~= nil then
        self.timer:update()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.activity(self)
    if self.timer ~= nil then
        self.timer:start()
        self:show_buttons(true)
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.mouseMoved(self, x, y)
    self:activity()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.mouseDragged(self, x, y, button)
    self:activity()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.mousePressed(self, x, y, button)
    self:activity()
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.mouseReleased(self, x, y, button)
    self:check_click(x, y, button)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.exit(self)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.getWidth(width)
    -- If width ends in %, treat it as a percentage of screen width
    local width_s = tostring(width)
    local new_width = width_s:gsub("%s*%%%s*$", "")
    if new_width ~= width_s then
        width = math.floor(gbl.screen_width * tonumber(new_width) / 100.0 + 0.5)
    else
        width = tonumber(width)
    end
    return width
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.getHeight(height)
    -- If height ends in %, treat it as a percentage of screen height
    local height_s = tostring(height)
    local new_height = height_s:gsub("%s*%%%s*$", "")
    if new_height ~= height_s then
        height = math.floor(gbl.screen_height * tonumber(new_height) / 100.0 + 0.5)
    else
        height = tonumber(height)
    end
    return height
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Win.img_resize(img, new_w, new_h)
    local w = img:getWidth()
    local h = img:getHeight()
    local aspect = w/h

    if new_w == nil then
        new_w = w
    end
    if new_h == nil then
        new_h = h
    end

    if new_w/new_h < aspect then
        new_h = math.floor(new_w / aspect)
    else
        new_w = math.floor(new_h * aspect)
    end

    new_w = math.floor(new_w)
    new_h = math.floor(new_h)
--    print("new_w = "..tostring(new_w).." new_h="..tostring(new_h))
    img:resize(new_w, new_h)
end

return Win
