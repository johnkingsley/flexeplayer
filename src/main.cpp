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

#include "ofMain.h"
#include "ofApp.h"
#include "ofAppEGLWindow.h"
#include "cmdparser.hpp"

///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
class Parser : public cli::Parser {
public:
    Parser(int argc, char *argv[]) : cli::Parser(argc, argv) {}

protected:
    std::string usage() const {
        std::stringstream ss { };
	ss << "Usage: flexeplayer [-h|--help] [--cfg <file>]\n";
	ss << "\t--help: Prints this help.\n";
	ss << "\t--cfg <file>: Loads configuration from this file.\n";
	return ss.str();
    }
};

///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
int main(int argc, char *argv[]) {
    Parser parser(argc, argv);
    parser.set_optional<std::string>("cfg", "cfg", "");
    const bool ok = parser.run();
    if (!ok) {
        return 1;
    }
    const std::string cfg = parser.get<std::string>("cfg");

    ofAppEGLWindow::Settings settings;
    settings.eglWindowOpacity = 0;
    settings.windowMode = OF_FULLSCREEN;
    ofCreateWindow(settings);

    return ofRunApp(new ofApp(cfg));
}
