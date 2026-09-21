// Creates REAL uinput devices. Needs /dev/uinput access (the developer is
// in the input/uinput groups). Skips gracefully without it.

import 'package:flutter_test/flutter_test.dart';
import 'package:minassat_al_mutahakkamat/executors.dart';
import 'package:minassat_al_mutahakkamat/protocol.dart';

import 'test_helpers.dart';

void main() {
  group('uinput executors', () {
    test('gamepad device injects a reading', () {
      if (!uinputUsable()) {
        markTestSkipped('uinput not usable on this machine');
        return;
      }
      final exec = GamepadExecutor('VGP Test Gamepad');
      exec.inject(const GamepadReading(
        buttonsDown: 0x4,
        leftTrigger: 0.5,
        leftX: 0.25,
        leftY: -0.5,
      ));
      exec.inject(const GamepadReading(buttonsUp: 0x4));
      exec.dispose();
    });

    test('keyboard/mouse devices inject a reading', () {
      if (!uinputUsable()) {
        markTestSkipped('uinput not usable on this machine');
        return;
      }
      final exec = KeyboardMouseExecutor(mouseSensitivity: 1000);
      // Left trigger only: taps Left Shift down then up. No other keys,
      // arrows or clicks are emitted, so the host session is unaffected.
      exec.inject(const GamepadReading(leftTrigger: 0.6));
      exec.inject(const GamepadReading());
      exec.dispose();
    });
  });
}
