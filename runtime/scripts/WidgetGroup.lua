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
local Widget = require("Widget")
local Log = require("Log")
require("binsert")

WidgetGroup = Class(Widget)

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup._init(self, type_name, outline, click_fnc)
    Widget._init(self, type_name, outline, click_fnc)
    self.widgets = {}
    self.widgets_by_name = {}
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup.widgets_clear(self)
    self.widgets = {}
    self.widgets_by_name = {}
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup.widget_add(self, widget)
    -- Make sure the widgets are sorted in increasing Z
    -- (for drawing purposes -- higher Z is on top)
    local order_by_z = function(a,b)
        if a.z == nil then
            return true
        end
        if b.z == nil then
            return false
        end
        return a.z < b.z
    end
    table.binsert(self.widgets, widget, order_by_z)
    if widget.name ~= nil then
        self.widgets_by_name[widget.name] = widget
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup.widget_lookup(self, name)
    return self.widgets_by_name[name]
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup.update(self)
    for i,widget in ipairs(self.widgets) do
        widget:update()
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup.draw(self)
    local draw_it = self.is_visible or self.always_visible
    if draw_it then
        self:do_draw()
    end

    for i,widget in ipairs(self.widgets) do
        if draw_it or widget.always_visible then
            widget:draw()
        end
    end
end

----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
function WidgetGroup.check_click(self, x, y, button)
    local draw_it = self.is_visible or self.always_visible
    if draw_it then
        Widget.check_click(self, x, y, button)
    end
    for i,widget in ipairs(self.widgets) do
        if draw_it or widget.always_visible then
            widget:check_click(x, y, button)
        end
    end
end

return WidgetGroup
