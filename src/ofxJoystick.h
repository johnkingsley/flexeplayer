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
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <stdio.h>
#include <syslog.h>
#include <fcntl.h>
#include <linux/joystick.h>

class ofxJoystick : public ofThread {
    public:
    ofxJoystick(): _fd(-1) {}

    // Event source
    int _fd;

    // Character to use for button 0
    char _first_key;

    // Events saved up
    queue<ofKeyEventArgs> _event_queue;

    bool init(const char * device, char first_key) {
        if ((_fd = open(device, O_RDONLY)) < 0) {
            return true;
        }
        _first_key = first_key;
        startThread();
        return false;
    }

    void exit(){
        stopThread();
        waitForThread(true);
    }

    // Do a timed read, waiting for no more than 100ms
    bool do_read(struct js_event *ev) {
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(_fd, &fds);

        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 100000;

        int ret = select(_fd+1, &fds, NULL, NULL, &tv);

        if (ret > 0 && FD_ISSET(_fd, &fds)) {
            const ssize_t ev_size = sizeof(struct js_event);
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
        while(isThreadRunning()) {
            struct js_event ev;
            if (!do_read(&ev)) {
                // noop - no data to read
            } else if ((ev.type & ~JS_EVENT_INIT) == JS_EVENT_BUTTON) {
                int button = ev.number;
                int pressed = ev.value;
//                ofLog() << "EVENT(button) = " << button << " pressed="<<pressed;

                ofKeyEventArgs event;
                event.type = pressed ? ofKeyEventArgs::Pressed : ofKeyEventArgs::Released;
                event.key = _first_key + button;

                lock();
                _event_queue.push(event);
                unlock();
            }
        }
    }

    // This is called from the main thread, in update()
    void flushEvents() {
        queue<ofKeyEventArgs> keyEventsCopy;

        // Move the events from the thread to here.
        lock();
        keyEventsCopy = _event_queue;
        while (!_event_queue.empty()) {
            _event_queue.pop();
        }
        unlock();

        // And then set them free.
        auto &events = ofEvents();
        while (!keyEventsCopy.empty()) {
            ofKeyEventArgs event = keyEventsCopy.front();
            events.notifyKeyEvent(event);
            keyEventsCopy.pop();
        }
    }
};
