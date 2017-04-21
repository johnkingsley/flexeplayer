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

    -------------------------------------------------------------------
    -- Check if file exists, if yes return full path
    -------------------------------------------------------------------
    local check_file = function(path)
        local file
        if path ~= nil then
            path = dirname .. path
            if Path.file_exists(path) then
                file = path
            end
        end
        return file
    end

    -------------------------------------------------------------------
    -- Check if image exists, if yes load it and return the object
    -- (parameter 'default' is returned if file is not found)
    -------------------------------------------------------------------
    local load_img = function(path, default)
        local img = default
        if path ~= nil then
            path = dirname .. path
            if Path.file_exists(path) then
                img = of.Image()
                img:load(path)
            end
        end
        return img
    end

    -------------------------------------------------------------------
    -- Lookup a setting in the .json file.
    -- If not set, then figure out a good default
    -- Paramters:
    --   'name' is the name of the setting
    --   'lang' is the language code
    --   'file_ending' is the file extension to use when picking a default
    --   'default' is what is used if all else fails
    -------------------------------------------------------------------
    local lookup = function(name, lang, file_ending, default)
        if lang ~= "" then
            name = name .. ":" .. lang
            if file_ending ~= nil then
                file_ending = "." .. lang .. file_ending
            end
        end

        local val = json_obj[name]
        if val == nil then
            if file_ending ~= nil then
                local path = basename..file_ending
                if check_file(path) ~= nil then
                    val = path
                end
            end
            if val == nil then
                val = default
            end
        end
        return val
    end

    -------------------------------------------------------------------
    -- Load the settings for a particular language, as set in 'lang'.
    -- If 'lang' is "" then this is the default for all languages.
    -- Use the table 'default' for finding default values.
    -------------------------------------------------------------------
    local do_load = function(lang, default)
        local image    = lookup("image",    lang, ".jpg", default.image)
        local video    = lookup("video",    lang, ".mp4", default.video)
        local srt_file = lookup("srt_file", lang, ".srt", default.srt_file)
        local title    = lookup("title",    lang, nil,    default.title)

        local image_obj
        local image_fullpath = check_file(image)
        if image_fullpath == nil then
            image = nil
        else
            if lang ~= "" then
                image_obj = load_img(image)
                if image_obj == nil then
                    image = nil
                    image_fullpath = nil
                end
            end
        end
        local video_fullpath = check_file(video)
        local srt_file_fullpath = check_file(srt_file)

        if title == nil then
            title = video_name
        end

        return {
            image = image,
            image_fullpath = image_fullpath,
            image_obj = image_obj,

            video = video,
            video_fullpath = video_fullpath,

            srt_file = srt_file,
            srt_file_fullpath = srt_file_fullpath,

            title = title
        }
    end

    -- First, load the default settings for all lanuages.
    local default_info = do_load("", {})

    -- Then load the settings for each language.
    local info_by_lang = {}
    local langs = gbl.lang.langs()
    for lang,lang_desc in pairs(langs) do
        info_by_lang[lang] = do_load(lang, default_info)
    end

    self.loaded_ok = true
    self.info_by_lang = info_by_lang
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Video.get_title(self, lang)
    if lang == nil then
        lang = gbl.lang.code
    end
    return self.info_by_lang[lang].title
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Video.get_image(self, lang)
    if lang == nil then
        lang = gbl.lang.code
    end
    return self.info_by_lang[lang].image_obj
end

--------------------------------------------
--------------------------------------------
--------------------------------------------
function Video.play(self, omx_video, lang)
    if lang == nil then
        lang = gbl.lang.code
    end
    local info = self.info_by_lang[lang]
    omx_video:load(info.video_fullpath, info.srt_file_fullpath)
end

return Video
