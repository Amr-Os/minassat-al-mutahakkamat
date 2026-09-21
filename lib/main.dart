import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'device_server.dart';
import 'l10n.dart';
import 'settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(1100, 720),
    minimumSize: Size(960, 640),
    title: 'Virtual Gamepad',
  );
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setTitle('منصة المتحكمات');
    await windowManager.show();
    await windowManager.focus();
  });

  final settings = AppSettings.load();
  final language = ValueNotifier<AppLanguage>(settings.language);
  final server = DeviceServer(settings: settings);
  await server.start();

  runApp(VirtualGamepadApp(server: server, language: language));
}

class VirtualGamepadApp extends StatelessWidget {
  final DeviceServer server;
  final ValueNotifier<AppLanguage> language;
  const VirtualGamepadApp(
      {super.key, required this.server, required this.language});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة المتحكمات',
      debugShowCheckedModeBanner: false,
      theme: monoTheme(),
      home: ManagerShell(server: server, language: language),
    );
  }
}
