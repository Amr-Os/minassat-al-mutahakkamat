// Single-window shell: sidebar navigation over a persistent server page.
// Arabic (RTL) by default, switchable to English in Preferences.

import 'package:flutter/material.dart';

import 'device_server.dart';
import 'l10n.dart';
import 'page_about.dart';
import 'page_devices.dart';
import 'page_prefs.dart';
import 'theme.dart';

class ManagerShell extends StatefulWidget {
  final DeviceServer server;
  final ValueNotifier<AppLanguage> language;
  const ManagerShell({super.key, required this.server, required this.language});

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _page = 0; // 0 devices, 1 preferences, 2 about

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.language,
      builder: (context, _) {
        final lang = widget.language.value;
        final s = stringsFor(lang);
        return Directionality(
          textDirection: lang == AppLanguage.arabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Mono.bg,
            body: Row(
              children: [
                _sidebar(s),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListenableBuilder(
                          listenable: widget.server,
                          builder: (context, _) => Text(_title(s),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 8),
                        Expanded(child: _currentPage(s)),
                        const SizedBox(height: 6),
                        ListenableBuilder(
                          listenable: widget.server,
                          builder: (context, _) => Text(
                            widget.server.isRunning
                                ? s.serverRunningSnack(
                                    widget.server.sessions.length)
                                : (widget.server.lastError ??
                                    s.serverStoppedSnack),
                            style: const TextStyle(
                                color: Mono.muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _title(Strings s) {
    switch (_page) {
      case 1:
        return s.preferencesTitle;
      case 2:
        return s.aboutTitle;
      default:
        return s.devicesTitle(widget.server.sessions.length);
    }
  }

  Widget _currentPage(Strings s) {
    switch (_page) {
      case 1:
        return PreferencesPage(
          server: widget.server,
          language: widget.language,
          onDone: () => setState(() => _page = 0),
        );
      case 2:
        return AboutPage(language: widget.language.value);
      default:
        return DevicesPage(server: widget.server, language: widget.language);
    }
  }

  Widget _sidebar(Strings s) {
    return Container(
      width: 208,
      decoration: const BoxDecoration(
        color: Mono.sideBg,
        border: Border(right: BorderSide(color: Mono.border)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('منصة المتحكمات',
              style: TextStyle(
                  color: Mono.bright,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          Text(s.brandSub,
              style: const TextStyle(color: Mono.muted, fontSize: 11)),
          const Divider(color: Mono.border, height: 24),
          _navItem(0, s.navDevices),
          _navItem(1, s.navPreferences),
          _navItem(2, s.navAbout),
          const Spacer(),
          const Text('v$appVersion',
              style: TextStyle(color: Mono.faint, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _navItem(int index, String label) {
    final active = _page == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: active ? Mono.selectedBg : Colors.transparent,
        border: Border.all(
            color: active ? const Color(0xFF333333) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        title: Text(label,
            style: TextStyle(
                color: active ? Colors.white : const Color(0xFFC9C9C9),
                fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        onTap: () => setState(() => _page = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
