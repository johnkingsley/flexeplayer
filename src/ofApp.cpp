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

#include "ofApp.h"

#ifndef DATA_PATH_ROOT
#define DATA_PATH_ROOT "../runtime/"
#endif

#ifndef MAIN_SCRIPT
#define MAIN_SCRIPT "scripts/flexeplayer.lua"
#endif

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::setup() {
    // Set data path root, as relative to the exe file
    ofSetDataPathRoot(std::filesystem::canonical(ofFilePath::join(ofFilePath::getCurrentExeDir(),  DATA_PATH_ROOT)).string());

    _lua.init();
    _lua.addListener(this);

    // Store the configuration file name in gbl.cfg_file_name
    _lua.newTable("gbl");
    _lua.pushTable("gbl");
    _lua.setString("cfg_file_name", _cfg_file_name);
    _lua.popTable();

    // Run the main lua script
    _lua.doScript(MAIN_SCRIPT, true);
    _lua.scriptSetup();

    // Setup the touchscreen object, using the "touch" table
    // set in lua to configure it.
    _lua.pushTable("touch");
    bool enabled = _lua.getBool("enabled", true);
    std::string dev_name = _lua.getString("dev_name");
    int min_x = (int)_lua.getNumber("min_x");
    int max_x = (int)_lua.getNumber("max_x");
    int min_y = (int)_lua.getNumber("min_y");
    int max_y = (int)_lua.getNumber("max_y");
    if (enabled) {
    	_touch.init(dev_name.c_str(), min_x, max_x, min_y, max_y);
    }
    _lua.popTable();
}

//--------------------------------------------------------------
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::update() {
    _touch.flushEvents();
    _lua.scriptUpdate();
}

//--------------------------------------------------------------
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::draw() {
    _lua.scriptDraw();
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::exit() {
    _touch.exit();
    _lua.scriptExit();
    _lua.clear();
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::keyPressed(int key) {
    _lua.scriptKeyPressed(key);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::mouseMoved(int x, int y) {
    _lua.scriptMouseMoved(x, y);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::mouseDragged(int x, int y, int button) {
    _lua.scriptMouseDragged(x, y, button);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::mousePressed(int x, int y, int button) {
    _lua.scriptMousePressed(x, y, button);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::mouseReleased(int x, int y, int button) {
    _lua.scriptMouseReleased(x, y, button);
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
void ofApp::errorReceived(string& msg) {
    ofLogError() << "script error: " << msg;
}
