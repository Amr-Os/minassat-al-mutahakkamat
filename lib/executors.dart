// Input executors: translate a [GamepadReading] into OS-level events via
// uinput devices. One executor instance (and therefore one set of virtual
// devices) exists per connected phone.

import 'dart:math';

import 'buttons.dart';
import 'keycodes.dart';
import 'linux_input.dart';
import 'protocol.dart';

/// Something that turns gamepad readings into system input.
abstract class Executor {
  void inject(GamepadReading reading);
  void dispose();
}

/// Discards input. Used when virtual devices are unavailable (e.g. in
/// tests) so sessions can still parse and count requests.
class NullExecutor implements Executor {
  @override
  void inject(GamepadReading reading) {}

  @override
  void dispose() {}
}

int _clampAxis(double v, int max) => (v * max).round().clamp(-max - 1, max);

/// Virtual gamepad device (Xbox 360 compatible IDs), one per phone.
/// Axis polarity matches the previous Qt implementation.
class GamepadExecutor implements Executor {
  final UinputDevice _dev;

  GamepadExecutor(String name)
      : _dev = UinputDevice.create(name, (dev) {
          LinuxInput.setIdBustype(dev, Bus.usb);
          LinuxInput.setIdVendor(dev, 0x045e);
          LinuxInput.setIdProduct(dev, 0x028e);
          LinuxInput.setIdVersion(dev, 0x0110);
          UinputDevice.enableType(dev, Ev.key);
          UinputDevice.enableType(dev, Ev.abs);
          UinputDevice.enableType(dev, Ev.ff);
          for (final code in [
            Btn.a,
            Btn.b,
            Btn.x,
            Btn.y,
            Btn.tl,
            Btn.tr,
            Btn.select,
            Btn.start,
            Btn.thumbl,
            Btn.thumbr,
            Btn.mode,
            Btn.dpadUp,
            Btn.dpadDown,
            Btn.dpadLeft,
            Btn.dpadRight,
          ]) {
            UinputDevice.enable(dev, Ev.key, code, null);
          }
          const stick = AbsSpec(-32768, 32767, 16, 128);
          const hat = AbsSpec(-1, 1);
          const trigger = AbsSpec(0, 255);
          UinputDevice.enable(dev, Ev.abs, Abs.x, stick);
          UinputDevice.enable(dev, Ev.abs, Abs.y, stick);
          UinputDevice.enable(dev, Ev.abs, Abs.rx, stick);
          UinputDevice.enable(dev, Ev.abs, Abs.ry, stick);
          UinputDevice.enable(dev, Ev.abs, Abs.hat0x, hat);
          UinputDevice.enable(dev, Ev.abs, Abs.hat0y, hat);
          UinputDevice.enable(dev, Ev.abs, Abs.z, trigger);
          UinputDevice.enable(dev, Ev.abs, Abs.rz, trigger);
        });

  void _press(int code) => _dev.write(Ev.key, code, 1);
  void _release(int code) => _dev.write(Ev.key, code, 0);

  void _button(int flag, int down, int up, int code) {
    if (down & flag != 0) _press(code);
    if (up & flag != 0) _release(code);
  }

  void _dpad(int flag, int down, int up, int code, int hatAxis, int hatValue) {
    if (down & flag != 0) {
      _press(code);
      _dev.write(Ev.abs, hatAxis, hatValue);
    }
    if (up & flag != 0) {
      _release(code);
      _dev.write(Ev.abs, hatAxis, 0);
    }
  }

  @override
  void inject(GamepadReading r) {
    _dev.write(Ev.abs, Abs.x, _clampAxis(r.leftX, 32767));
    _dev.write(Ev.abs, Abs.y, _clampAxis(r.leftY, 32767));
    _dev.write(Ev.abs, Abs.rx, _clampAxis(r.rightX, 32767));
    _dev.write(Ev.abs, Abs.ry, _clampAxis(r.rightY, 32767));
    _dev.write(Ev.abs, Abs.z, (r.leftTrigger * 255).round().clamp(0, 255));
    _dev.write(Ev.abs, Abs.rz, (r.rightTrigger * 255).round().clamp(0, 255));

    final down = r.buttonsDown;
    final up = r.buttonsUp;
    _button(GamepadButtons.menu, down, up, Btn.start);
    _button(GamepadButtons.view, down, up, Btn.select);
    _button(GamepadButtons.a, down, up, Btn.a);
    _button(GamepadButtons.b, down, up, Btn.b);
    _button(GamepadButtons.x, down, up, Btn.x);
    _button(GamepadButtons.y, down, up, Btn.y);
    _dpad(GamepadButtons.dpadUp, down, up, Btn.dpadUp, Abs.hat0y, -1);
    _dpad(GamepadButtons.dpadDown, down, up, Btn.dpadDown, Abs.hat0y, 1);
    _dpad(GamepadButtons.dpadLeft, down, up, Btn.dpadLeft, Abs.hat0x, -1);
    _dpad(GamepadButtons.dpadRight, down, up, Btn.dpadRight, Abs.hat0x, 1);
    _button(GamepadButtons.leftShoulder, down, up, Btn.tl);
    _button(GamepadButtons.rightShoulder, down, up, Btn.tr);
    _button(GamepadButtons.leftThumbstick, down, up, Btn.thumbl);
    _button(GamepadButtons.rightThumbstick, down, up, Btn.thumbr);

    _dev.sync();
  }

  @override
  void dispose() => _dev.dispose();
}

// ---------------------------------------------------------------------------
// Keyboard/mouse executor with the default keymap. (The previous app allowed
// custom per-game profiles; the editor UI is not ported yet.)
// ---------------------------------------------------------------------------

/// A keyboard key or a mouse button.
class ButtonInput {
  final int code;
  final bool isMouse;
  const ButtonInput(this.code, [this.isMouse = false]);
}

class ThumbstickMapping {
  final bool mouseMove;
  final ButtonInput up;
  final ButtonInput down;
  final ButtonInput left;
  final ButtonInput right;
  const ThumbstickMapping({
    required this.mouseMove,
    required this.up,
    required this.down,
    required this.left,
    required this.right,
  });
}

class TriggerMapping {
  final ButtonInput button;
  final double threshold;
  const TriggerMapping(this.button, [this.threshold = 0.5]);
}

/// Default mapping, ported from KeymapProfile::initializeDefaultMappings.
class DefaultKeymap {
  static const Map<int, ButtonInput> buttons = {
    GamepadButtons.menu: ButtonInput(Key.menu),
    GamepadButtons.view: ButtonInput(Key.tab),
    GamepadButtons.a: ButtonInput(Key.enter),
    GamepadButtons.b: ButtonInput(Key.esc),
    GamepadButtons.x: ButtonInput(Key.leftShift),
    GamepadButtons.y: ButtonInput(Key.leftCtrl),
    GamepadButtons.dpadUp: ButtonInput(Key.up),
    GamepadButtons.dpadDown: ButtonInput(Key.down),
    GamepadButtons.dpadLeft: ButtonInput(Key.left),
    GamepadButtons.dpadRight: ButtonInput(Key.right),
    GamepadButtons.leftShoulder: ButtonInput(Btn.left, true),
    GamepadButtons.rightShoulder: ButtonInput(Btn.right, true),
    GamepadButtons.leftThumbstick: ButtonInput(Key.leftShift),
    GamepadButtons.rightThumbstick: ButtonInput(Key.leftCtrl),
  };

  static const leftStick = ThumbstickMapping(
    mouseMove: false,
    up: ButtonInput(Key.w),
    down: ButtonInput(Key.s),
    left: ButtonInput(Key.a),
    right: ButtonInput(Key.d),
  );

  static const rightStick = ThumbstickMapping(
    mouseMove: false,
    up: ButtonInput(Key.up),
    down: ButtonInput(Key.down),
    left: ButtonInput(Key.left),
    right: ButtonInput(Key.right),
  );

  static const leftTrigger = TriggerMapping(ButtonInput(Key.leftShift));
  static const rightTrigger = TriggerMapping(ButtonInput(Key.leftCtrl));

  /// Every key code the default map can emit (for device setup).
  static Set<int> get allKeyCodes {
    final codes = <int>{};
    for (final b in buttons.values) {
      if (!b.isMouse) codes.add(b.code);
    }
    for (final stick in [leftStick, rightStick]) {
      for (final b in [stick.up, stick.down, stick.left, stick.right]) {
        if (!b.isMouse) codes.add(b.code);
      }
    }
    for (final t in [leftTrigger, rightTrigger]) {
      if (!t.button.isMouse) codes.add(t.button.code);
    }
    return codes;
  }
}

class _XY {
  final double x;
  final double y;
  const _XY(this.x, this.y);
}

/// Maps the circular stick range onto a square so diagonals reach (1,1).
_XY _circleToSquare(double x, double y) {
  if (x == 0 && y == 0) return const _XY(0, 0);
  final mag = sqrt(x * x + y * y);
  if (mag == 0) return const _XY(0, 0);
  final nx = x / mag;
  final ny = y / mag;
  final scale = (nx.abs() > ny.abs() ? 1 / nx.abs() : 1 / ny.abs());
  final clamped = min(mag, 1);
  return _XY(nx * scale * clamped, ny * scale * clamped);
}

class KeyboardMouseExecutor implements Executor {
  static const double threshold = 0.5;
  final UinputDevice _keyboard;
  final UinputDevice _mouse;
  final int mouseSensitivity;

  KeyboardMouseExecutor({this.mouseSensitivity = 1000})
      : _keyboard = UinputDevice.create('Minassat Keyboard', (dev) {
          UinputDevice.enableType(dev, Ev.key);
          for (final code in DefaultKeymap.allKeyCodes) {
            UinputDevice.enable(dev, Ev.key, code, null);
          }
        }),
        _mouse = UinputDevice.create('Minassat Mouse', (dev) {
          UinputDevice.enableType(dev, Ev.key);
          UinputDevice.enableType(dev, Ev.rel);
          for (final code in [Btn.left, Btn.right, Btn.middle]) {
            UinputDevice.enable(dev, Ev.key, code, null);
          }
          // REL_X / REL_Y need no abs spec; enabling the type is enough for
          // relative axes, but register the codes explicitly for clarity.
          UinputDevice.enable(dev, Ev.rel, Rel.x, null);
          UinputDevice.enable(dev, Ev.rel, Rel.y, null);
        });

  void _down(ButtonInput b) {
    if (b.isMouse) {
      _mouse.write(Ev.key, b.code, 1);
      _mouse.sync();
    } else {
      _keyboard.write(Ev.key, b.code, 1);
      _keyboard.sync();
    }
  }

  void _up(ButtonInput b) {
    if (b.isMouse) {
      _mouse.write(Ev.key, b.code, 0);
      _mouse.sync();
    } else {
      _keyboard.write(Ev.key, b.code, 0);
      _keyboard.sync();
    }
  }

  void _stick(ThumbstickMapping m, double x, double y) {
    if (m.mouseMove) {
      final sq = _circleToSquare(x, y);
      final ox = (sq.x * mouseSensitivity).round();
      final oy = (sq.y * mouseSensitivity).round();
      final thresholdPx = threshold * mouseSensitivity;
      if (ox.abs() < thresholdPx && oy.abs() < thresholdPx) return;
      final steps = max(ox.abs(), oy.abs());
      if (steps > 0) {
        for (var s = 1; s <= steps; s++) {
          final sx = (ox * s) ~/ steps - (ox * (s - 1)) ~/ steps;
          final sy = (oy * s) ~/ steps - (oy * (s - 1)) ~/ steps;
          if (sx != 0) _mouse.write(Ev.rel, Rel.x, sx);
          if (sy != 0) _mouse.write(Ev.rel, Rel.y, sy);
        }
        _mouse.sync();
      }
      return;
    }
    if (x > threshold) {
      _down(m.right);
    } else if (x < -threshold) {
      _down(m.left);
    } else {
      _up(m.right);
      _up(m.left);
    }
    if (y > threshold) {
      _down(m.down);
    } else if (y < -threshold) {
      _down(m.up);
    } else {
      _up(m.down);
      _up(m.up);
    }
  }

  void _trigger(TriggerMapping t, double value) {
    if (value >= t.threshold) {
      _down(t.button);
    } else {
      _up(t.button);
    }
  }

  @override
  void inject(GamepadReading r) {
    for (final button in GamepadButtons.all) {
      final mapping = DefaultKeymap.buttons[button];
      if (mapping == null || mapping.code == 0) continue;
      if (r.buttonsDown & button != 0) _down(mapping);
      if (r.buttonsUp & button != 0) _up(mapping);
    }
    _stick(DefaultKeymap.leftStick, r.leftX, r.leftY);
    _stick(DefaultKeymap.rightStick, r.rightX, r.rightY);
    _trigger(DefaultKeymap.leftTrigger, r.leftTrigger);
    _trigger(DefaultKeymap.rightTrigger, r.rightTrigger);
  }

  @override
  void dispose() {
    _keyboard.dispose();
    _mouse.dispose();
  }
}
