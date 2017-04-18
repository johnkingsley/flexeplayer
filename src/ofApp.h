/*
 * Flex.E.Player: Video kiosk for the Raspberry Pi
 * Copyright (C) 2017 John Kingsley
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include "ofMain.h"
#include "ofxLua.h"
#include "ofxELOTouch.h"

class ofApp : public ofBaseApp, ofxLuaListener {
public:
    ofApp(std::string cfg_file_name) : _cfg_file_name(cfg_file_name) {}

    // main
    void setup();
    void update();
    void draw();
    void exit();

    // input
    void keyPressed(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);

    // ofxLua error callback
    void errorReceived(string& msg);

    std::string _cfg_file_name;
    ofxLua _lua;
    ofxELOTouch _touch;
};
