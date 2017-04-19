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
local json = require ("dkjson")
local Path = require ("Path")

local Video = Class()

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Video._init(self, json_file_path)
    self.loaded_ok = false

    print("loading video '"..json_file_path.."'")

    local dirname = Path.dirname(json_file_path)
    local basename = Path.basename(json_file_path)

    local json_contents = Path.slurp(json_file_path)
    local json_obj, json_pos, json_err = json.decode(json_contents)
    if (json_err) then
        print("Error loading json: ", json_err)
        return
    end

    local image = json_obj.image
    local video = json_obj.video
    local srt_file = json_obj.srt_file
    local title = json_obj.title
    local desc = json_obj.desc
    local duration = json_obj.duration

    if image == nil then
        image = basename..".jpg"
    end

    if video == nil then
        video = basename..".mp4"
    end

    if srt_file == nil then
        srt_file = basename..".srt"
    end
    srt_file = dirname..srt_file
    if not Path.file_exists(srt_file) then
        srt_file = nil
    end

    local screenshot_path = dirname..image
    local screenshot = of.Image()
    screenshot:load(screenshot_path)

    local desc_img_path = dirname..basename..".desc.png"
    local desc_img
    if (Path.file_exists(desc_img_path)) then
        desc_img = of.Image()
        desc_img:load(desc_img_path)
    end

    local video_path = dirname..video
    if (not Path.file_exists(video_path)) then
        print("Video not found: '"..video_path.."'")
        return
    end

    self.loaded_ok = true
    self.path = video_path
    self.srt_file = srt_file
    self.title = title
    self.desc = desc
    self.duration = duration
    self.screenshot = screenshot
    self.desc_img = desc_img
end

return Video
