#ifndef CONTROL_HPP
#define CONTROL_HPP

#include <ev.h>

class ProcessControl {
public:
  ProcessControl();
  void pause();
  void resume();
private:
  bool _running;
  struct ev_loop *_ev;
};

#endif
