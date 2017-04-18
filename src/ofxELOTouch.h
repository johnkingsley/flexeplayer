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
#include <linux/input.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <stdio.h>
#include <syslog.h>
#include <fcntl.h>


#define EVENT_CODE_X    ABS_X
#define EVENT_CODE_Y    ABS_Y
#define EVENT_CODE_P    ABS_MISC

class ofxELOTouch : public ofThread {
	public:
	ofxELOTouch(): _fd(-1) {}

	// Event source
	int _fd;

	// Mapping of touchscreen
	int _minX;
       	int _maxX;
	int _minY;
       	int _maxY;

	// Screen Resolution
	int _width;
	int _height;

	// Events saved up
        queue<ofMouseEventArgs> _event_queue;

	bool init(const char * device, int minX, int maxX, int minY, int maxY, int width=-1, int height=-1) {
        	if ((_fd = open(device, O_RDONLY)) < 0) {
                	return true;
		}

		if (width <= 0) {
			width = ofGetScreenWidth();
		}
		if (height <= 0) {
			height = ofGetScreenHeight();
		}
		_width = width;
		_height = height;
		_minX = minX;
		_maxX = maxX;
		_minY = minY;
		_maxY = maxY;

		startThread();

		return false;
	}

	string getName(){
		if (_fd < 0) {
			return("unknown");
		} else {
			char name[500];
			ioctl(_fd, EVIOCGNAME(sizeof(name)), name);
			string str(name);
			return str;
		}
	}

	void exit(){
		stopThread();
		waitForThread(true);
	}

	// Do a timed read, waiting for no more than 100ms
	bool do_read(struct input_event *ev) {
		fd_set fds;
		FD_ZERO(&fds);
		FD_SET(_fd, &fds);

		struct timeval tv;
		tv.tv_sec = 0;
		tv.tv_usec = 100000;

		int ret = select(_fd+1, &fds, NULL, NULL, &tv);

		if (ret > 0 && FD_ISSET(_fd, &fds)) {
			const ssize_t ev_size = sizeof(struct input_event);
			ssize_t n = read(_fd, ev, ev_size);
			if (n < 0 && (errno == EAGAIN || errno == EINTR)) {
				// no-op
			} else if (n  != ev_size) {
				ofLogError() << "Error reading event input";
			} else {
				// got data!
				return true;
			}
		}
		return false;
	}

	void threadedFunction(){
		bool got_movement;
		bool got_press;
		ofVec3f pos;
		bool pressed = false;

		while(isThreadRunning()) {
  			struct input_event ev;

			if (!do_read(&ev)) {
			    // noop - no data to read

		        } else if (ev.type == EV_ABS) {
				if(ev.code == ABS_X) {
					pos.x = ofMap(ev.value, _minX, _maxX, 0, _width, true);
					got_movement = true;

				} else if(ev.code == ABS_Y) {
					pos.y = ofMap(ev.value, _minY, _maxY, 0, _height, true);
					got_movement = true;

				} else if(ev.code == ABS_MISC) {
					pos.z = ev.value;
					got_movement = true;
				}
//				ofLog() << "pos = " << pos;
//				std::shared_ptr<ofAppBaseWindow> ofGetCurrentWindow();

		        } else if (ev.type == EV_KEY) {
				if(ev.code == BTN_LEFT) {
					got_press = true;
					pressed = ev.value != 0;
				}

		        } else if (ev.type == EV_SYN) {
				if (got_movement) {
//					ofLog() << "EVENT(move) = " << pos << " pressed="<<pressed;
					got_movement = false;

					ofMouseEventArgs event;
					event.type = pressed ? ofMouseEventArgs::Dragged : ofMouseEventArgs::Moved;
					event.button = OF_MOUSE_BUTTON_LEFT;
					event.x = pos.x;
					event.y = pos.y;

					lock();
					_event_queue.push(event);
					unlock();
				}
				if (got_press) {
//					ofLog() << "EVENT(press) = " << pos << " pressed="<<pressed;
					got_press = false;

					ofMouseEventArgs event;
					event.type = pressed ? ofMouseEventArgs::Pressed : ofMouseEventArgs::Released;
					event.button = OF_MOUSE_BUTTON_LEFT;
					event.x = pos.x;
					event.y = pos.y;

					lock();
					_event_queue.push(event);
					unlock();
				}
		        }
		}
	}

	// This is called from the main thread, in update()
	void flushEvents() {
		queue<ofMouseEventArgs> mouseEventsCopy;

		// Move the events from the thread to here.
		lock();
		mouseEventsCopy = _event_queue;
		while (!_event_queue.empty()) {
			_event_queue.pop();
		}
		unlock();

		// And then set them free.
		auto &events = ofEvents();
		while (!mouseEventsCopy.empty()) {
			ofMouseEventArgs event = mouseEventsCopy.front();
//			ofLog() << "EVENT = " << event;
			events.notifyMouseEvent(event);
			mouseEventsCopy.pop();
		}
	}
};
