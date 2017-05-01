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
local Pipe = require("Pipe")
local Path = require("Path")

local OMXVideo = Class()

-- TODO
--local OMX_CMD = gbl.cfg:get_string("general/omx_cmd", "stdbuf --output=0 omxplayer --adev alsa --layer -10 --no-keys --no-osd --blank")
local OMX_CMD = gbl.cfg:get_string("general/omx_cmd", "stdbuf --output=0 omxplayer --layer -10 --no-keys --no-osd --blank")

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo._init(self)
    self.path = ""
    self.pipe_pid = nil
    self.pipe_stdin = nil
    self.pipe_stdout = nil
    self.pipe_stderr = nil
    self.fds = nil
    self.video_started = false
    self.video_duration = nil
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.load(self, path, srt_file, vol)
    self.path = path

    print("Loading video '"..path.."'")
    print("SRT file: '"..tostring(srt_file).."'")
    print("vol: '"..tostring(vol).."'")
    self.video_duration = nil

    local cmd_table = {}
    local cmd_word
    for cmd_word in OMX_CMD:gmatch("%S+") do
        table.insert(cmd_table, cmd_word)
    end
    if srt_file ~= nil then
        table.insert(cmd_table, "--subtitles")
        table.insert(cmd_table, srt_file)
    end
    if vol ~= nil then
        table.insert(cmd_table, "--vol")
        table.insert(cmd_table, vol)
    end
    table.insert(cmd_table, path)

    self.pipe_pid, self.pipe_stdin, self.pipe_stdout, self.pipe_stderr = Pipe.open3(unpack(cmd_table))
    self.fds = {
        [self.pipe_stdout] = { events = { IN = true } },
        [self.pipe_stderr] = { events = { IN = true } },
    }

    ---------------------------------------------------------------------------
    -- Need to set DBUS_SESSION_* environment variables so that dbus-send works
    ---------------------------------------------------------------------------

    local user = posix.getenv("USER")
    if (user == nil) then
        user = "root"
    end

    -- Wait for tmp files to exist
    while (not self.video_started) do
        if (self:update()) then
            break
        end
    end


    local dbus_addr = Path.slurp("/tmp/omxplayerdbus."..user, true)
    posix.setenv("DBUS_SESSION_BUS_ADDRESS", dbus_addr)
    --print("DBUS_SESSION_BUS_ADDRESS = '"..dbus_addr.."'")

    local dbus_pid = Path.slurp("/tmp/omxplayerdbus."..user..".pid", true)
    posix.setenv("DBUS_SESSION_BUS_PID", dbus_pid)
    --print("DBUS_SESSION_BUS_PID = '"..dbus_pid.."'")
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.stop(self)
    self:dbus_cmd_stop()
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.pause_toggle(self)
    self:dbus_cmd_pause()
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd(self, ...)
    -- TODO: this could be more effecient -- no need to fork()
    local cmd = {
        "dbus-send",
        "--print-reply=literal",
        "--session",
        "--reply-timeout=500",
        "--dest=org.mpris.MediaPlayer2.omxplayer",
        "/org/mpris/MediaPlayer2",
        ...
    }
    local status, stdout, stderr = Pipe.simple("", unpack(cmd))
    -- TODO: check for errors
    return stdout
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_get(self, ...)
    local args = {...}
    local val = self:dbus_cmd(unpack(args))
    val = val:gsub("^ *int64 *", "")
    val = tonumber(val)
    return val
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_duration_get(self)
    return self:dbus_cmd_get("org.freedesktop.DBus.Properties.Get", "string:org.mpris.MediaPlayer2.Player", "string:Duration")
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_status_get(self)
    return self:dbus_cmd("org.freedesktop.DBus.Properties.Get", "string:org.mpris.MediaPlayer2.Player", "string:PlaybackStatus")
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_volume_get(self)
    return self:dbus_cmd_get("org.freedesktop.DBus.Properties.Get", "string:org.mpris.MediaPlayer2.Player", "string:Volume")
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_volume_set(self, volume)
    self:dbus_cmd("org.freedesktop.DBus.Properties.Set", "string:org.mpris.MediaPlayer2.Player", "string:Volume", "double:"..tostring(volume))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_send(self, name, ...)
    local args = {...}
    self:dbus_cmd("org.mpris.MediaPlayer2.Player."..name, unpack(args))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_send_action(self, action_num)
    self:dbus_cmd_send("Action", "int32:"..tostring(action_num))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_pause(self)
    self:dbus_cmd_send_action(16)
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_stop(self)
    self:dbus_cmd_send_action(15)
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_seek(self, amount)
    self:dbus_cmd_send("Seek", "int64:"..tostring(amount))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_position_get(self)
    local pos = self:dbus_cmd_get("org.freedesktop.DBus.Properties.Get", "string:org.mpris.MediaPlayer2.Player", "string:Position")
    if (pos == nil) then
        pos = 0
    end
    return pos
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_position_set(self, amount)
    self:dbus_cmd("Seek", "objpath:/not/used", "int64:"..tostring(amount))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_alpha_set(self, amount)
    self:dbus_cmd_send("SetAlpha", "objpath:/not/used", "int64:"..tostring(amount))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_videopos_set(self, x1, y1, x2, y2)
    self:dbus_cmd_send("VideoPos", "objpath:/not/used", "string:"..string.format("%d %d %d %d", x1, y1, x2, y2))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_croppos_set(self, x1, y1, x2, y2)
    self:dbus_cmd_send("SetVideoCropPos", "objpath:/not/used", "string:"..string.format("%d %d %d %d", x1, y1, x2, y2))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_aspect_set(self, mode)
    self:dbus_cmd_send("SetVideoCropPos", "objpath:/not/used", "string:"..tostring(mode))
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_video_show(self, hide)
    if (hide) then
        self:dbus_cmd_send_action(28)
    else
        self:dbus_cmd_send_action(29)
    end
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_volume_change(self, up)
    if (up) then
        self:dbus_cmd_send_action(18)
    else
        self:dbus_cmd_send_action(17)
    end
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.dbus_cmd_subtitles_show(self, show)
    if (show) then
        self:dbus_cmd_send_action(31)
    else
        self:dbus_cmd_send_action(30)
    end
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.percent_done(self)
    local dur = self.video_duration
    if dur == nil then
        dur = self:dbus_cmd_duration_get()
        print("dur="..tostring(dur))
        self.video_duration = dur
    end

    local percent_done
    if dur == nil then
        percent_done = 0
    else
        local pos = self:dbus_cmd_position_get()
        percent_done = pos/dur
    end
    --print("percent_done="..tostring(percent_done))
    return percent_done
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function OMXVideo.update(self)
    local closed = false

    local fds = self.fds
    local events = posix.poll(fds,0)
    if events < 0 then
        -- TODO - log error
    elseif events > 0 then
        for fd in pairs(fds) do
            if  fds[fd].revents.IN then
                local data = posix.read(fd,1024)
                data = data:gsub("\r", "\n")
                posix.write(2,data);
                if (fd == self.pipe_stdout) then
                    self.video_started = true
                end
            end
            if fds[fd].revents.HUP then
                closed = true
                posix.close(fd)
                posix.wait(self.pipe_pid, WNOHANG)
                self.pipe_pid = nil
                self.video_started = false
                fds[fd] = nil
                if not next(fds) then
                    break
                end
            end
        end
    end

    return closed
end

return OMXVideo
