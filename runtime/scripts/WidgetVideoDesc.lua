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

WidgetVideoDesc = Class(WidgetGroup)

local COLOR_TEXT = gbl.cfg:get_int("colors/text", 0x000000)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoDesc._init(self, parent_name, video, idx, min_x, max_x, min_y, max_y)
    self.video = video
    self.idx = idx

    local this_section = "widgets/"..parent_name.."/"
    -- line width (in pixels) to draw around video desc
    local border_width = gbl.cfg:get_int(this_section.."border_width", 2)
    -- space (in pixels) to leave around video desc
    local border_space = gbl.cfg:get_int(this_section.."border_space", 4)
    local colour_highlight = gbl.cfg:get_int("colors/videolist/highlight", 0x000000)

    local font_video_title = Font.load("videolist")
    self.font_video_title = font_video_title

    -- Limits of description
    self.min_x = min_x
    self.max_x = max_x
    self.min_y = min_y
    self.max_y = max_y

    local w = self.max_x - self.min_x - 2*border_space
    local h = self.max_y - self.min_y - 2*border_space
    local th = h * 0.10
    local sw = w
    local sh = h - th

    -- Resize the screenshots in all languages
    local screenshot
    local langs = gbl.lang.langs()
    for lang,lang_desc in pairs(langs) do
        screenshot = self.video:get_image(lang)
        Win.img_resize(screenshot, sw, sh)
    end

    local iw = screenshot:getWidth()
    local ih = screenshot:getHeight()
    self.sx = self.min_x + border_space
    self.sy = self.max_y - border_space - th - ih

    self.tx = self.min_x + border_space
    self.ty = self.max_y - border_space*2

    local path = of.Path()
    local delta = border_width/2
    local path_max_x = self.sx + iw + border_space
    local path_min_y = self.sy - border_space
    path:moveTo(min_x+delta, path_min_y+delta)
    path:lineTo(path_max_x-delta, path_min_y+delta)
    path:lineTo(path_max_x-delta, max_y-delta)
    path:lineTo(min_x+delta, max_y-delta)
    path:close()
    path:setFilled(false)
    path:setStrokeWidth(border_width)
    path:setStrokeHexColor(colour_highlight)
    local outline = path:getOutline():front()
    self.path = path

    local click_fnc = function()
        self:go_play()
    end

    WidgetGroup._init(self, "videodesc", outline, click_fnc)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoDesc.go_play(self)
    gbl.win_player:activate_and_play(self.video)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoDesc.do_draw(self)
    -- Draw the screenshot
    of.setColor(255)
    self.video:get_image():draw(self.sx, self.sy)

    -- Draw the title
    of.setHexColor(COLOR_TEXT)
    self.font_video_title:drawString(self.video:get_title(), self.tx, self.ty)

    -- Highlight if inside the box
    if self:cursor_is_inside() then
        self.path:draw(0,0)
    end
end

return WidgetVideoDesc
