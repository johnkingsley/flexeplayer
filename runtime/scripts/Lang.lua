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

Lang = Class()

local LANGS = {
    en = "ENGLISH",
    fr = "FRANÇAIS",
}
local LANGS_OPPOSITE = {
    en = "fr",
    fr = "en",
}

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Lang._init(self)
    self.code = "en"
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Lang.langs(self)
    return LANGS
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Lang.set(self, code)
    --print("setting lang to "..code)
    self.code = code
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Lang.opposite(code)
    return LANGS_OPPOSITE[code]
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Lang.get_desc(self, opposite)
    local l = self.code
    if opposite then
        l = Lang.opposite(l)
    end
    return LANGS[l]
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function Lang.toggle(self)
    self:set(Lang.opposite(self.code))
end

return Lang
