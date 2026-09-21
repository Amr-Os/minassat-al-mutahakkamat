import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_gamepad_pc/device_server.dart';
import 'package:virtual_gamepad_pc/executors.dart';
import 'package:virtual_gamepad_pc/l10n.dart';
import 'package:virtual_gamepad_pc/settings.dart';

Executor _nullFactory({
  required ExecutorType type,
  required String deviceName,
  required int mouseSensitivity,
}) =>
    NullExecutor();

void main() {
  group('localization', () {
    test('arabic is default and has translations', () {
      final ar = stringsFor(AppLanguage.arabic);
      expect(ar.navDevices, 'الأجهزة');
      expect(ar.devicesTitle(0), 'الأجهزة');
      expect(ar.devicesTitle(2), isNotEmpty);
      final en = stringsFor(AppLanguage.english);
      expect(en.navDevices, 'Devices');
      // Same key set, different text.
      expect(ar.startServer, isNot(en.startServer));
    });

    test('settings persist language and device names', () async {
      final dir =
          await Directory.systemTemp.createTemp('vgp_settings_test');
      AppSettings.testDir = dir.path;
      try {
        final s = AppSettings(
          port: 1234,
          language: AppLanguage.english,
          deviceNames: {'192.168.1.5': 'هاتف عمرو'},
        );
        s.save();
        final loaded = AppSettings.load();
        expect(loaded.port, 1234);
        expect(loaded.language, AppLanguage.english);
        expect(loaded.deviceNames['192.168.1.5'], 'هاتف عمرو');
        // Defaults: arabic, empty names.
        expect(AppSettings().language, AppLanguage.arabic);
      } finally {
        AppSettings.testDir = null;
        await dir.delete(recursive: true);
      }
    });
  });

  group('device naming', () {
    test('rename sticks and reapplies by IP', () async {
      final settings = AppSettings(port: 0);
      final server = DeviceServer(
          settings: settings, executorFactory: _nullFactory);
      await server.start();
      final s = await Socket.connect('127.0.0.1', server.actualPort);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(server.sessions.length, 1);
      final session = server.sessions[0];
      expect(session.displayName('Device'), 'Device 1');

      server.rename(session, 'هاتف عمرو');
      expect(session.customName, 'هاتف عمرو');
      expect(session.displayName('جهاز'), 'هاتف عمرو');
      expect(settings.deviceNames[session.peerAddress], 'هاتف عمرو');

      server.rename(session, null);
      expect(session.customName, isNull);
      expect(settings.deviceNames.containsKey(session.peerAddress),
          isFalse);

      s.destroy();
      await server.stop();
    });
  });
}
