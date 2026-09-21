// Gamepad button flags. Same values as the GamepadButtons enum in the
// Windows API and VGP_Data_Exchange/C/GameButtons.h
class GamepadButtons {
  static const int menu = 0x1;
  static const int view = 0x2;
  static const int a = 0x4;
  static const int b = 0x8;
  static const int x = 0x10;
  static const int y = 0x20;
  static const int dpadUp = 0x40;
  static const int dpadDown = 0x80;
  static const int dpadLeft = 0x100;
  static const int dpadRight = 0x200;
  static const int leftShoulder = 0x400;
  static const int rightShoulder = 0x800;
  static const int leftThumbstick = 0x1000;
  static const int rightThumbstick = 0x2000;

  static const List<int> all = [
    menu,
    view,
    a,
    b,
    x,
    y,
    dpadUp,
    dpadDown,
    dpadLeft,
    dpadRight,
    leftShoulder,
    rightShoulder,
    leftThumbstick,
    rightThumbstick,
  ];
}
