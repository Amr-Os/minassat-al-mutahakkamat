// App settings persisted as JSON in the platform config dir
// (~/.config/virtual_gamepad_pc/settings.json on Linux).

import 'dart:convert';
import 'dart:io';

import 'l10n.dart';

enum ExecutorType { gamepad, keyboardMouse }

class AppSettings {
  int port; // 0 = auto
  ExecutorType executor;
  int mouseSensitivity;
  AppLanguage language;
  // Custom device names remembered by peer IP address.
  Map<String, String> deviceNames;

  AppSettings({
    this.port = 0,
    this.executor = ExecutorType.gamepad,
    this.mouseSensitivity = 1000,
    this.language = AppLanguage.arabic,
    Map<String, String>? deviceNames,
  }) : deviceNames = deviceNames ?? {};

  static String get _dir {
    if (_testDir != null) return _testDir!;
    final home = Platform.environment['HOME'] ?? '.';
    return '$home/.config/virtual_gamepad_pc';
  }

  /// Test-only override for the config directory.
  static String? _testDir;
  static set testDir(String? value) => _testDir = value;

  static String get filePath => '$_dir/settings.json';

  static AppSettings load() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return AppSettings();
      final json =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final names = <String, String>{};
      final rawNames = json['deviceNames'];
      if (rawNames is Map) {
        rawNames.forEach((k, v) {
          if (k is String && v is String && v.isNotEmpty) {
            names[k] = v;
          }
        });
      }
      return AppSettings(
        port: (json['port'] as num?)?.toInt() ?? 0,
        executor: (json['executor'] as String?) == 'keyboardMouse'
            ? ExecutorType.keyboardMouse
            : ExecutorType.gamepad,
        mouseSensitivity: (json['mouseSensitivity'] as num?)?.toInt() ?? 1000,
        language: (json['language'] as String?) == 'en'
            ? AppLanguage.english
            : AppLanguage.arabic,
        deviceNames: names,
      );
    } catch (_) {
      return AppSettings();
    }
  }

  void save() {
    Directory(_dir).createSync(recursive: true);
    File(filePath).writeAsStringSync(jsonEncode({
      'port': port,
      'executor': executor == ExecutorType.keyboardMouse
          ? 'keyboardMouse'
          : 'gamepad',
      'mouseSensitivity': mouseSensitivity,
      'language': language == AppLanguage.english ? 'en' : 'ar',
      'deviceNames': deviceNames,
    }));
  }
}
