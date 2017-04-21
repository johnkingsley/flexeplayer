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

local posix = require("posix")
local Class = require("Class")
local VideoLib = require("VideoLib")
local WidgetGroup = require("WidgetGroup")
local WidgetVideoDesc = require("WidgetVideoDesc")

WidgetVideoList = Class(WidgetGroup)

local HOME_DIR  = posix.getenv("HOME")
local VIDEO_DIR = gbl.cfg:get_string("general/video_dir", HOME_DIR.."/Videos")

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoList._init(self, name, page_change_cb)
    WidgetGroup._init(self, "videolist")
    self:load_cfg(name)

    local this_section = "widgets/"..name.."/"
    local num_col = gbl.cfg:get_int(this_section.."num_col", 3)
    local num_row = gbl.cfg:get_int(this_section.."num_row", 3)
    local border_width = gbl.cfg:get_width(this_section.."border_width", 2)
    local border_space = gbl.cfg:get_width(this_section.."border_space", 4)
    local space_x = gbl.cfg:get_width(this_section.."space_x", "2%")
    local space_y = gbl.cfg:get_height(this_section.."space_y", "2%")

    -- Get the top, left corner of the widget
    local real_x, real_y = self:get_real_xy()

    self.page_num = 1
    self.page_curr = 1
    self.pages = {}
    self.page_change_cb = page_change_cb
    self.videolib = VideoLib()
    self.num_col = num_col
    self.num_row = num_row
    self.real_x = real_x
    self.real_y = real_y
    self.space_x = space_x
    self.space_y = space_y
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoList.load(self)
    self.videolib:load(VIDEO_DIR)
    -- TODO: worry about case if number of videos is 0

    self:widgets_clear()
    self.pages = {}
    local num_video_per_page = self.num_col * self.num_row
    local col_width = (self.width - self.space_x) / self.num_col
    local row_height = (self.height - self.space_y) / self.num_row
    local col = 1
    local row = 1
    local page_widget = nil
    for idx,vid in pairs(self.videolib.videos) do
        if (col == 1 and row == 1) then
            page_widget = WidgetGroup()
            page_widget:show(false)
            self:widget_add(page_widget)
            table.insert(self.pages, page_widget)
        end
        print(string.format("[%d] %s", idx, vid:get_title()))
        local min_x = self.real_x + self.space_x + (col-1) * col_width
        local max_x = min_x + col_width - self.space_x
        local min_y = self.real_y + self.space_y + (row-1) * row_height
        local max_y = min_y + row_height - self.space_y
        local vdesc = WidgetVideoDesc(self.name, vid, idx, min_x, max_x, min_y, max_y)
        page_widget:widget_add(vdesc)

        col = col + 1
        if col > self.num_col then
            col = 1
            row = row + 1
            if row > self.num_row then
                row = 1
            end
        end
    end

    -- Figure out how many pages we need
    self.page_num = math.floor(self.videolib.num / num_video_per_page)
    if self.videolib.num % num_video_per_page ~= 0 then
        self.page_num = self.page_num + 1
    end

    self:goto_page(1)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoList.goto_page(self, page)
    self.pages[self.page_curr]:show(false)
    self.page_curr = page
    self.pages[self.page_curr]:show(true)

    if self.page_change_cb ~= nil then
        self.page_change_cb(self.page_curr, self.page_num)
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoList.goto_page_prev(self, page)
    local new_page = self.page_curr - 1
    if (new_page == 0) then
        new_page = self.page_num
    end
    self:goto_page(new_page)
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetVideoList.goto_page_next(self, page)
    local new_page = self.page_curr + 1
    if (new_page > self.page_num) then
        new_page = 1
    end
    self:goto_page(new_page)
end

return WidgetVideoList
