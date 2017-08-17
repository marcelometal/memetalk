#include "ctrl.hpp"

ProcessControl::ProcessControl() {
  _running = true;
  _ev = EV_DEFAULT;
}

void ProcessControl::pause() {
  if (_running) {
    _running = false;
    ev_run (_ev, 0);
  }
}

void ProcessControl::resume() {
  if (!_running) {
    _running = true;
    ev_break (_ev, EVBREAK_ALL);
  }
}
