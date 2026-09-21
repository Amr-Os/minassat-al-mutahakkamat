// Linux input event codes (linux/input-event-codes.h). Values verified
// against /usr/include/linux/input-event-codes.h.
class Ev {
  static const int syn = 0x00;
  static const int key = 0x01;
  static const int rel = 0x02;
  static const int abs = 0x03;
  static const int ff = 0x15;
}

class Syn {
  static const int report = 0;
}

class Rel {
  static const int x = 0x00;
  static const int y = 0x01;
}

class Abs {
  static const int x = 0x00;
  static const int y = 0x01;
  static const int z = 0x02;
  static const int rx = 0x03;
  static const int ry = 0x04;
  static const int rz = 0x05;
  static const int hat0x = 0x10;
  static const int hat0y = 0x11;
}

class Key {
  static const int esc = 1;
  static const int tab = 15;
  static const int w = 17;
  static const int enter = 28;
  static const int leftCtrl = 29;
  static const int a = 30;
  static const int s = 31;
  static const int d = 32;
  static const int leftShift = 42;
  static const int up = 103;
  static const int left = 105;
  static const int right = 106;
  static const int down = 108;
  static const int menu = 139;
}

class Btn {
  static const int left = 0x110;
  static const int right = 0x111;
  static const int middle = 0x112;
  // Gamepad buttons (BTN_SOUTH/EAST/NORTH/WEST aliases).
  static const int a = 0x130;
  static const int b = 0x131;
  static const int x = 0x133;
  static const int y = 0x134;
  static const int tl = 0x136;
  static const int tr = 0x137;
  static const int select = 0x13a;
  static const int start = 0x13b;
  static const int mode = 0x13c;
  static const int thumbl = 0x13d;
  static const int thumbr = 0x13e;
  static const int dpadUp = 0x220;
  static const int dpadDown = 0x221;
  static const int dpadLeft = 0x222;
  static const int dpadRight = 0x223;

  static bool isMouse(int code) =>
      code == left || code == right || code == middle;
}

class Bus {
  static const int usb = 0x03;
}
