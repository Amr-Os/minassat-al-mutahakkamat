import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_gamepad_pc/device_server.dart';
import 'package:virtual_gamepad_pc/executors.dart';
import 'package:virtual_gamepad_pc/protocol.dart';
import 'package:virtual_gamepad_pc/settings.dart';

class CountingExecutor implements Executor {
  final Executor inner;
  int injects = 0;
  CountingExecutor(this.inner);

  @override
  void inject(GamepadReading reading) {
    injects++;
    inner.inject(reading);
  }

  @override
  void dispose() => inner.dispose();
}

void main() {
  test('real gamepad executor keeps up at 60Hz', () async {
    if (!File('/dev/uinput').existsSync()) {
      markTestSkipped('no /dev/uinput');
      return;
    }
    CountingExecutor? counter;
    final server = DeviceServer(
      settings: AppSettings(port: 0),
      executorFactory: ({
        required type,
        required deviceName,
        required mouseSensitivity,
      }) {
        counter =
            CountingExecutor(GamepadExecutor('VGP Stream Test'));
        return counter!;
      },
    );
    await server.start();
    final s = await Socket.connect('127.0.0.1', server.actualPort);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    s.add(encodeGamepadReading(const GamepadReading(buttonsDown: 0x4)));
    for (var i = 0; i < 179; i++) {
      final x = (i ~/ 30) % 2 == 0 ? 0.5 : -0.5;
      s.add(encodeGamepadReading(GamepadReading(leftX: x, leftY: 0.25)));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    s.add(encodeGamepadReading(const GamepadReading(buttonsUp: 0x4)));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // ignore: avoid_print
    print(
        'requests=${server.sessions[0].requestCount} injects=${counter!.injects}');
    expect(server.sessions[0].requestCount, 181);
    expect(counter!.injects, 181);
    s.destroy();
    await server.stop();
  });
}
