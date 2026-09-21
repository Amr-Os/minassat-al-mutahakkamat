import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_gamepad_pc/device_server.dart';
import 'package:virtual_gamepad_pc/executors.dart';
import 'package:virtual_gamepad_pc/protocol.dart';
import 'package:virtual_gamepad_pc/settings.dart';

Executor _nullFactory({
  required ExecutorType type,
  required String deviceName,
  required int mouseSensitivity,
}) =>
    NullExecutor();

void main() {
  group('device server', () {
    test('two phones connect, stream, disconnect', () async {
      final settings = AppSettings(port: 0);
      final server = DeviceServer(
          settings: settings, executorFactory: _nullFactory);
      await server.start();
      expect(server.isRunning, isTrue);
      expect(server.actualPort, isNot(0));

      final s1 = await Socket.connect('127.0.0.1', server.actualPort);
      final s2 = await Socket.connect('127.0.0.1', server.actualPort);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(server.sessions.length, 2);
      expect(server.sessions[0].displayName('Device'), 'Device 1');
      expect(server.sessions[1].displayName('Device'), 'Device 2');
      expect(server.sessions[1].deviceName, 'Virtual Gamepad PC 2');

      // Split write: header in one TCP segment, body in the next.
      final packet = encodeGamepadReading(
          const GamepadReading(buttonsDown: 0x4, leftX: 0.5));
      s1.add(packet.sublist(0, 1));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(server.sessions[0].requestCount, 0);
      s1.add(packet.sublist(1));
      // Second phone sends two packets at once.
      s2.add(packet);
      s2.add(encodeGamepadReading(
          const GamepadReading(buttonsUp: 0x4, rightY: -1)));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(server.sessions[0].requestCount, 1);
      expect(server.sessions[1].requestCount, 2);

      await server.disconnect(server.sessions[0]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(server.sessions.length, 1);

      s2.destroy();
      await server.stop();
      s1.destroy();
      expect(server.isRunning, isFalse);
    });

    test('restart drops sessions and rebinds', () async {
      final settings = AppSettings(port: 0);
      final server = DeviceServer(
          settings: settings, executorFactory: _nullFactory);
      await server.start();
      final firstPort = server.actualPort;
      final s = await Socket.connect('127.0.0.1', firstPort);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(server.sessions.length, 1);

      await server.restart();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(server.isRunning, isTrue);
      expect(server.sessions, isEmpty);

      final s2 = await Socket.connect('127.0.0.1', server.actualPort);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(server.sessions.length, 1);
      s.destroy();
      s2.destroy();
      await server.stop();
    });

    test('bind conflict reports error', () async {      final a = DeviceServer(
          settings: AppSettings(port: 0), executorFactory: _nullFactory);
      await a.start();
      final b = DeviceServer(
          settings: AppSettings(port: a.actualPort),
          executorFactory: _nullFactory);
      await b.start();
      expect(b.isRunning, isFalse);
      expect(b.lastError, isNotNull);
      await a.stop();
    });
  });
}
