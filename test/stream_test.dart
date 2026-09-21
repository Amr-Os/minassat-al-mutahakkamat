import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minassat_al_mutahakkamat/device_server.dart';
import 'package:minassat_al_mutahakkamat/executors.dart';
import 'package:minassat_al_mutahakkamat/protocol.dart';
import 'package:minassat_al_mutahakkamat/settings.dart';

Executor _nullFactory({
  required ExecutorType type,
  required String deviceName,
  required int mouseSensitivity,
}) =>
    NullExecutor();

void main() {
  test('180 packets at 60Hz all processed', () async {
    final server = DeviceServer(
        settings: AppSettings(port: 0), executorFactory: _nullFactory);
    await server.start();
    final s = await Socket.connect('127.0.0.1', server.actualPort);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(server.sessions.length, 1);

    s.add(encodeGamepadReading(const GamepadReading(buttonsDown: 0x4)));
    for (var i = 0; i < 179; i++) {
      final x = (i ~/ 30) % 2 == 0 ? 0.5 : -0.5;
      s.add(encodeGamepadReading(GamepadReading(leftX: x, leftY: 0.25)));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    s.add(encodeGamepadReading(const GamepadReading(buttonsUp: 0x4)));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(server.sessions[0].requestCount, 181);
    s.destroy();
    await server.stop();
  });
}
