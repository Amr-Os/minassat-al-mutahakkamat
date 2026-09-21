// Devices page: server status, connect-a-phone panel (IPs + QR) and the
// multi-device list. One server manages every phone; no second instance.
// Devices can be renamed; names are remembered by IP address.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'device_server.dart';
import 'l10n.dart';
import 'theme.dart';
import 'widgets.dart';

class DevicesPage extends StatefulWidget {
  final DeviceServer server;
  final ValueNotifier<AppLanguage> language;
  const DevicesPage({super.key, required this.server, required this.language});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<String> _ips = [];
  int _selectedIp = 0;
  int _selectedDevice = 0;
  Timer? _refresh;

  Strings get s => stringsFor(widget.language.value);

  /// Prefix for default names ("Device"/"جهاز").
  String get _prefix =>
      widget.language.value == AppLanguage.arabic ? 'جهاز' : 'Device';

  String _name(DeviceSession session) => session.displayName(_prefix);

  @override
  void initState() {
    super.initState();
    _loadIps();
    // Live per-device stats, like the old 500 ms detail refresh.
    _refresh = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadIps() async {
    final ips = await DeviceServer.localIPv4();
    if (mounted) setState(() => _ips = ips);
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final server = widget.server;
    return ListenableBuilder(
      listenable: Listenable.merge([server, widget.language]),
      builder: (context, _) {
        if (_selectedDevice >= server.sessions.length) {
          _selectedDevice =
              server.sessions.isEmpty ? 0 : server.sessions.length - 1;
        }
        final running = server.isRunning;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusCard(server, running),
              const SizedBox(height: 8),
              if (server.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(s.startFailed(server.lastError!),
                      style: const TextStyle(color: Mono.bright)),
                ),
              _connectCard(server),
              const SizedBox(height: 12),
              _devicesCard(server),
            ],
          ),
        );
      },
    );
  }

  Widget _statusCard(DeviceServer server, bool running) {
    return Container(
      decoration: BoxDecoration(
        color: Mono.cardBg,
        border: Border.all(color: Mono.border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              running
                  ? s.runningStatus(server.actualPort, server.sessions.length)
                  : s.stoppedStatus(server.sessions.length),
              style: const TextStyle(
                  color: Color(0xFFFAFAFA), fontWeight: FontWeight.w700),
            ),
          ),
          PrimaryButton(
            label: running ? s.stopServer : s.startServer,
            onPressed: () async {
              if (running) {
                await server.stop();
              } else {
                await server.start();
                if (server.lastError != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(s.startFailed(server.lastError!))));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _connectCard(DeviceServer server) {
    final qrData = _ips.isEmpty
        ? 'localhost:${server.actualPort}'
        : '${_ips[_selectedIp.clamp(0, _ips.length - 1)]}:${server.actualPort}';
    return MonoCard(
      title: s.connectPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 120),
                  decoration: BoxDecoration(
                    color: Mono.inputBg,
                    border: Border.all(color: Mono.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _ips.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(s.noAddresses,
                              style: const TextStyle(color: Mono.muted)),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < _ips.length; i++)
                              ListTile(
                                dense: true,
                                title: Text(_ips[i],
                                    style: const TextStyle(
                                        color: Color(0xFFEDEDED))),
                                subtitle: Text(
                                    '${_ips[i]}:${server.actualPort}',
                                    style: const TextStyle(
                                        color: Mono.muted, fontSize: 11)),
                                selected: i == _selectedIp,
                                selectedTileColor: Mono.pressed,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                onTap: () => setState(() => _selectedIp = i),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Mono.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: server.isRunning
                    ? QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                      )
                    : Center(
                        child: Text(s.qrStartServerFirst,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.qrHint,
            style: const TextStyle(color: Mono.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _renameDialog(DeviceSession session) async {
    final controller = TextEditingController(text: session.customName ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Mono.cardBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Mono.border)),
        title: Text(s.renameTitle, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Color(0xFFF0F0F0)),
          decoration: InputDecoration(
            hintText: s.renameHint,
            hintStyle: const TextStyle(color: Mono.faint),
            filled: true,
            fillColor: Mono.inputBg,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Mono.borderStrong),
            ),
          ),
          onSubmitted: (_) => Navigator.of(context).pop(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(s.cancel, style: const TextStyle(color: Mono.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: Text(s.clear, style: const TextStyle(color: Mono.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(s.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      widget.server.rename(session, result.isEmpty ? null : result);
    }
  }

  Widget _devicesCard(DeviceServer server) {
    final sessions = server.sessions;
    final selected = sessions.isEmpty
        ? null
        : sessions[_selectedDevice.clamp(0, sessions.length - 1)];
    return MonoCard(
      title: s.connectedDevices,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Mono.inputBg,
              border: Border.all(color: Mono.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(s.colDevice,
                              style: const TextStyle(
                                  color: Color(0xFF9A9A9A), fontSize: 11))),
                      Expanded(
                          child: Text(s.colAddress,
                              style: const TextStyle(
                                  color: Color(0xFF9A9A9A), fontSize: 11))),
                      Expanded(
                          child: Text(s.colStatus,
                              style: const TextStyle(
                                  color: Color(0xFF9A9A9A), fontSize: 11))),
                    ],
                  ),
                ),
                const Divider(color: Mono.border, height: 1),
                if (sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(s.noDevices,
                        style: const TextStyle(color: Mono.muted)),
                  ),
                for (var i = 0; i < sessions.length; i++)
                  InkWell(
                    onTap: () => setState(() => _selectedDevice = i),
                    onDoubleTap: () => _renameDialog(sessions[i]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: i == _selectedDevice
                            ? Mono.pressed
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(_name(sessions[i]),
                                  style: const TextStyle(
                                      color: Color(0xFFEDEDED)))),
                          Expanded(
                              child: Text(
                                  '${sessions[i].peerAddress} : ${sessions[i].peerPort}',
                                  style: const TextStyle(
                                      color: Color(0xFFEDEDED), fontSize: 12))),
                          Expanded(
                              child: Text(
                                  sessions[i].isLimited
                                      ? s.statusLimited
                                      : s.statusConnected,
                                  style: const TextStyle(
                                      color: Color(0xFFEDEDED), fontSize: 12))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selected == null
                ? s.selectDeviceHint
                : (selected.isLimited
                    ? s.detailLimited(
                        _name(selected),
                        selected.peerAddress,
                        selected.peerPort,
                        selected.isPlatformUnsupported
                            ? s.platformUnsupported
                            : (selected.limitReason ?? ''))
                    : selected.requestCount == 0
                        ? s.detailWaiting(_name(selected), selected.peerAddress,
                            selected.peerPort)
                        : s.detailStats(
                            _name(selected),
                            selected.peerAddress,
                            selected.peerPort,
                            selected.requestCount,
                            selected.averageIntervalMs)),
            style: const TextStyle(color: Mono.muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GhostButton(
                label: s.disconnectSelected,
                onPressed:
                    selected == null ? null : () => server.disconnect(selected),
              ),
              GhostButton(
                label: s.disconnectAll,
                onPressed:
                    sessions.isEmpty ? null : () => server.disconnectAll(),
              ),
              GhostButton(
                label: s.rename,
                onPressed:
                    selected == null ? null : () => _renameDialog(selected),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
