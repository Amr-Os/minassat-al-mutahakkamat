// Preferences page: executor, port, pointer speed, language. Saved to
// settings.json; a changed port restarts the persistent server, a changed
// executor or language applies immediately (executor: new connections).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'device_server.dart';
import 'l10n.dart';
import 'settings.dart';
import 'theme.dart';
import 'widgets.dart';

class PreferencesPage extends StatefulWidget {
  final DeviceServer server;
  final ValueNotifier<AppLanguage> language;
  final VoidCallback onDone;
  const PreferencesPage({
    super.key,
    required this.server,
    required this.language,
    required this.onDone,
  });

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late ExecutorType _executor;
  late TextEditingController _port;
  late double _sensitivity;
  late AppLanguage _language;

  Strings get s => stringsFor(_language);

  @override
  void initState() {
    super.initState();
    final st = widget.server.settings;
    _executor = st.executor;
    _port = TextEditingController(text: st.port.toString());
    _sensitivity = st.mouseSensitivity.toDouble().clamp(100, 1800);
    _language = widget.language.value;
  }

  @override
  void dispose() {
    _port.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final port = int.tryParse(_port.text.trim()) ?? 0;
    if (port < 0 || port > 65535) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.portRangeError)));
      return;
    }
    final st = widget.server.settings;
    final portChanged = port != st.port;
    st
      ..port = port
      ..executor = _executor == ExecutorType.gamepad
          ? ExecutorType.gamepad
          : ExecutorType.keyboardMouse
      ..mouseSensitivity = _sensitivity.round()
      ..language = _language
      ..save();
    widget.language.value = _language;
    if (portChanged && widget.server.isRunning) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.portChangedRestart)));
      await widget.server.restart();
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MonoCard(
            title: s.inputMethod,
            child: RadioGroup<ExecutorType>(
              groupValue: _executor,
              onChanged: (value) => setState(() => _executor = value!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<ExecutorType>(
                    title: Text(s.gamepadMode,
                        style: const TextStyle(color: Mono.text)),
                    subtitle: Text(s.gamepadModeSub,
                        style:
                            const TextStyle(color: Mono.muted, fontSize: 12)),
                    value: ExecutorType.gamepad,
                  ),
                  RadioListTile<ExecutorType>(
                    title: Text(s.keyboardMode,
                        style: const TextStyle(color: Mono.text)),
                    subtitle: Text(s.keyboardModeSub,
                        style:
                            const TextStyle(color: Mono.muted, fontSize: 12)),
                    value: ExecutorType.keyboardMouse,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          MonoCard(
            title: s.connection,
            child: Row(
              children: [
                SizedBox(
                    width: 140,
                    child: Text(s.serverPort,
                        style: const TextStyle(color: Mono.text))),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: s.portAutoHint,
                      hintStyle: const TextStyle(color: Mono.faint),
                      filled: true,
                      fillColor: Mono.inputBg,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Mono.borderStrong),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MonoCard(
            title: s.pointer,
            child: Row(
              children: [
                SizedBox(
                    width: 140,
                    child: Text(s.pointerSpeed,
                        style: const TextStyle(color: Mono.text))),
                Expanded(
                  child: Slider(
                    value: _sensitivity,
                    min: 100,
                    max: 1800,
                    activeColor: Mono.bright,
                    inactiveColor: Mono.pressed,
                    onChanged: (v) => setState(() => _sensitivity = v),
                  ),
                ),
                SizedBox(
                    width: 48,
                    child: Text(_sensitivity.round().toString(),
                        style: const TextStyle(color: Mono.muted))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MonoCard(
            title: s.language,
            child: RadioGroup<AppLanguage>(
              groupValue: _language,
              onChanged: (value) => setState(() => _language = value!),
              child: const Row(
                children: [
                  Expanded(
                    child: RadioListTile<AppLanguage>(
                      title:
                          Text('العربية', style: TextStyle(color: Mono.text)),
                      value: AppLanguage.arabic,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<AppLanguage>(
                      title:
                          Text('English', style: TextStyle(color: Mono.text)),
                      value: AppLanguage.english,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PrimaryButton(label: s.save, onPressed: _save),
              const SizedBox(width: 8),
              GhostButton(label: s.cancel, onPressed: widget.onDone),
            ],
          ),
        ],
      ),
    );
  }
}
