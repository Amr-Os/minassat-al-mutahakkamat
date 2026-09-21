import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minassat_al_mutahakkamat/device_server.dart';
import 'package:minassat_al_mutahakkamat/executors.dart';
import 'package:minassat_al_mutahakkamat/protocol.dart';
import 'package:minassat_al_mutahakkamat/settings.dart';

class RecordingExecutor implements Executor {
  final List<GamepadReading> injected = [];
  bool released = false;

  @override
  void inject(GamepadReading reading) => injected.add(reading);

  @override
  void releaseAll() {
    released = true;
    // Mirror GamepadExecutor.releaseAll: everything up, axes centered.
    inject(const GamepadReading(buttonsUp: 0x4 | 0x8));
  }

  @override
  void dispose() {}
}

void main() {
  test('dropped connection releases held inputs', () async {
    RecordingExecutor? rec;
    final server = DeviceServer(
      settings: AppSettings(port: 0),
      executorFactory: ({
        required type,
        required deviceName,
        required mouseSensitivity,
      }) {
        rec = RecordingExecutor();
        return rec!;
      },
    );
    await server.start();
    final s = await Socket.connect('127.0.0.1', server.actualPort);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Press A and hold it (bitmask stays set, like the real client).
    s.add(encodeGamepadReading(const GamepadReading(buttonsDown: 0x4)));
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(rec!.injected.length, 1);

    // Drop without the teardown packet (crash/network loss).
    s.destroy();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(server.sessions, isEmpty);
    expect(rec!.released, isTrue);
    expect(rec!.injected.last.buttonsUp & 0x4, 0x4);

    await server.stop();
  });
}
