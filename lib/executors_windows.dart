// Windows keyboard/mouse injection via SendInput (user32.dll, Dart FFI).
//
// This file is only *used* on Windows (see the factory in
// device_server.dart). It compiles everywhere: user32 is opened lazily,
// so importing this file on Linux/macOS has no side effects.
//
// Virtual gamepads are NOT implemented on Windows: the WinRT preview
// injection API needs COM/WinRT activation that Dart FFI cannot do
// sanely, and third-party drivers are against this project's no-drivers
// principle. Gamepad mode on Windows reports "limited".

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'buttons.dart';
import 'executors.dart' show Executor;
import 'protocol.dart';

// --- Win32 constants (winuser.h) ---
class _InputType {
  static const int mouse = 0;
  static const int keyboard = 1;
}

class _KeyFlag {
  static const int extendedKey = 0x0001;
  static const int keyUp = 0x0002;
}

class _MouseFlag {
  static const int leftDown = 0x0002;
  static const int leftUp = 0x0004;
  static const int rightDown = 0x0008;
  static const int rightUp = 0x0010;
  static const int middleDown = 0x0020;
  static const int middleUp = 0x0040;
}

/// Virtual-key codes used by the default map (WinUser.h).
class WinVk {
  static const int lButton = 0x01;
  static const int rButton = 0x02;
  static const int mButton = 0x04;
  static const int tab = 0x09;
  static const int ret = 0x0D;
  static const int shift = 0x10;
  static const int control = 0x11;
  static const int menu = 0x12;
  static const int esc = 0x1B;
  static const int left = 0x25;
  static const int up = 0x26;
  static const int right = 0x27;
  static const int down = 0x28;
  static const int w = 0x57;
  static const int a = 0x41;
  static const int s = 0x53;
  static const int d = 0x44;

  static bool isMouse(int code) =>
      code == lButton || code == rButton || code == mButton;

  /// Arrow keys need KEYEVENTF_EXTENDEDKEY to register correctly.
  static bool isExtended(int code) =>
      code == left || code == up || code == right || code == down;
}

// --- SendInput structs (x64: sizeof(INPUT) == 40) ---
final class _MouseInput extends Struct {
  @Int32()
  external int dx;
  @Int32()
  external int dy;
  @Uint32()
  external int mouseData;
  @Uint32()
  external int flags;
  @Uint32()
  external int time;
  @IntPtr()
  external int extra;
}

final class _KeybdInput extends Struct {
  @Uint16()
  external int vk;
  @Uint16()
  external int scan;
  @Uint32()
  external int flags;
  @Uint32()
  external int time;
  @IntPtr()
  external int extra;
}

final class _InputUnion extends Union {
  external _MouseInput mi;
  external _KeybdInput ki;
}

final class _WinInput extends Struct {
  @Uint32()
  external int type;
  external _InputUnion u;
}

typedef _SendInputNative = Uint32 Function(
    Uint32 cInputs, Pointer<_WinInput> pInputs, Int32 cbSize);

/// Default map, mirroring the old Qt app's Windows defaults.
class WinDefaultKeymap {
  static const Map<int, int> buttons = {
    GamepadButtons.menu: WinVk.menu,
    GamepadButtons.view: WinVk.tab,
    GamepadButtons.a: WinVk.ret,
    GamepadButtons.b: WinVk.esc,
    GamepadButtons.x: WinVk.shift,
    GamepadButtons.y: WinVk.control,
    GamepadButtons.dpadUp: WinVk.up,
    GamepadButtons.dpadDown: WinVk.down,
    GamepadButtons.dpadLeft: WinVk.left,
    GamepadButtons.dpadRight: WinVk.right,
    GamepadButtons.leftShoulder: WinVk.lButton,
    GamepadButtons.rightShoulder: WinVk.rButton,
    GamepadButtons.leftThumbstick: WinVk.shift,
    GamepadButtons.rightThumbstick: WinVk.control,
  };

  // (up, down, left, right); negative = mouse-as-direction unused here.
  static const List<int> leftStick = [WinVk.w, WinVk.s, WinVk.a, WinVk.d];
  static const List<int> rightStick = [
    WinVk.up,
    WinVk.down,
    WinVk.left,
    WinVk.right
  ];
  static const int leftTrigger = WinVk.shift;
  static const int rightTrigger = WinVk.control;
  static const double triggerThreshold = 0.5;
}

class WindowsKeyboardMouseExecutor implements Executor {
  static const double threshold = 0.5;
  final int mouseSensitivity;
  final int Function(int, Pointer<_WinInput>, int) _sendInput;

  WindowsKeyboardMouseExecutor({this.mouseSensitivity = 1000})
      : _sendInput = DynamicLibrary.open('user32.dll').lookupFunction<
            _SendInputNative,
            int Function(int, Pointer<_WinInput>, int)>('SendInput');

  void _send(Pointer<_WinInput> input) {
    _sendInput(1, input, sizeOf<_WinInput>());
  }

  void _key(int vk, bool down) {
    final p = calloc<_WinInput>();
    try {
      p.ref.type = _InputType.keyboard;
      p.ref.u.ki.vk = vk;
      p.ref.u.ki.scan = 0;
      var flags = down ? 0 : _KeyFlag.keyUp;
      if (WinVk.isExtended(vk)) flags |= _KeyFlag.extendedKey;
      p.ref.u.ki.flags = flags;
      p.ref.u.ki.time = 0;
      p.ref.u.ki.extra = 0;
      _send(p);
    } finally {
      calloc.free(p);
    }
  }

  void _mouseButton(int vk, bool down) {
    final flag = switch ((vk, down)) {
      (WinVk.lButton, true) => _MouseFlag.leftDown,
      (WinVk.lButton, false) => _MouseFlag.leftUp,
      (WinVk.rButton, true) => _MouseFlag.rightDown,
      (WinVk.rButton, false) => _MouseFlag.rightUp,
      (WinVk.mButton, true) => _MouseFlag.middleDown,
      (WinVk.mButton, false) => _MouseFlag.middleUp,
      _ => 0,
    };
    if (flag == 0) return;
    final p = calloc<_WinInput>();
    try {
      p.ref.type = _InputType.mouse;
      p.ref.u.mi.dx = 0;
      p.ref.u.mi.dy = 0;
      p.ref.u.mi.mouseData = 0;
      p.ref.u.mi.flags = flag;
      p.ref.u.mi.time = 0;
      p.ref.u.mi.extra = 0;
      _send(p);
    } finally {
      calloc.free(p);
    }
  }

  void _button(int vk, bool down) {
    if (WinVk.isMouse(vk)) {
      _mouseButton(vk, down);
    } else {
      _key(vk, down);
    }
  }

  void _stick(List<int> map, double x, double y) {
    // Default map never uses mouse-move on Windows; directions only.
    if (x > threshold) {
      _key(map[3], true);
    } else if (x < -threshold) {
      _key(map[2], true);
    } else {
      _key(map[3], false);
      _key(map[2], false);
    }
    if (y > threshold) {
      _key(map[1], true);
    } else if (y < -threshold) {
      _key(map[0], true);
    } else {
      _key(map[1], false);
      _key(map[0], false);
    }
  }

  @override
  void inject(GamepadReading r) {
    for (final button in GamepadButtons.all) {
      final vk = WinDefaultKeymap.buttons[button];
      if (vk == null || vk == 0) continue;
      if (r.buttonsDown & button != 0) _button(vk, true);
      if (r.buttonsUp & button != 0) _button(vk, false);
    }
    _stick(WinDefaultKeymap.leftStick, r.leftX, r.leftY);
    _stick(WinDefaultKeymap.rightStick, r.rightX, r.rightY);
    _button(WinDefaultKeymap.leftTrigger,
        r.leftTrigger >= WinDefaultKeymap.triggerThreshold);
    _button(WinDefaultKeymap.rightTrigger,
        r.rightTrigger >= WinDefaultKeymap.triggerThreshold);
  }

  @override
  void dispose() {
    // SendInput is stateless; nothing to tear down.
  }
}
