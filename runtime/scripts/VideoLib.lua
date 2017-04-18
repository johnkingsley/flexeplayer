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
local posix = require("posix")
local Video = require("Video")

local VideoLib = Class()

--------------------------------------------
--------------------------------------------
--------------------------------------------
function VideoLib._init(self)
    self.path = nil
    self.videos = {}
    self.num = 0
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function VideoLib.load(self, path)
    self.path = path
    self.videos = {}

    -- TODO - check to make sure path exists

    -- TODO - figure out better way to find videos, maybe "find" command?
    local files = posix.glob(path.."/*.json")
    local n = 0
    for idx,file in pairs(files) do
--        print(idx, file)
        local video = Video(file)
        if (video.loaded_ok) then
            table.insert(self.videos, video)
            n = n + 1
        end
    end
    self.num = n
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function VideoLib.get_video(self, n)
    return self.videos[n]
end

return VideoLib
