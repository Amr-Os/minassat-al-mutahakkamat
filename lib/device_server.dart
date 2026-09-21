// TCP server managing every connected phone from one window.
// Each phone gets its own [DeviceSession] with a dedicated socket,
// buffer and executor, so several gamepads work simultaneously.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'executors.dart';
import 'executors_windows.dart';
import 'protocol.dart';
import 'settings.dart';

/// Creates the executor for a newly connected device. Overridable in tests.
typedef ExecutorFactory = Executor Function({
  required ExecutorType type,
  required String deviceName,
  required int mouseSensitivity,
});

Executor defaultExecutorFactory({
  required ExecutorType type,
  required String deviceName,
  required int mouseSensitivity,
}) {
  // Input injection is implemented for Linux so far; Windows does
  // keyboard/mouse via SendInput (gamepad mode stays limited there);
  // other desktops are planned. Phones stay connected (parsing/stats)
  // with a clear reason wherever injection is missing.
  if (Platform.isWindows) {
    if (type == ExecutorType.keyboardMouse) {
      try {
        return WindowsKeyboardMouseExecutor(mouseSensitivity: mouseSensitivity);
      } catch (e) {
        return _LimitedExecutor(e.toString());
      }
    }
    return _LimitedExecutor('', isPlatformUnsupported: true);
  }
  if (!Platform.isLinux) {
    return _LimitedExecutor('', isPlatformUnsupported: true);
  }
  try {
    switch (type) {
      case ExecutorType.gamepad:
        return GamepadExecutor(deviceName);
      case ExecutorType.keyboardMouse:
        return KeyboardMouseExecutor(mouseSensitivity: mouseSensitivity);
    }
  } catch (e) {
    // Virtual devices unavailable (permissions, missing uinput): keep the
    // session alive for parsing/stats, but flag it as limited.
    return _LimitedExecutor(e.toString());
  }
}

/// Session kept alive without a virtual device; records why.
class _LimitedExecutor extends NullExecutor {
  final String reason;
  final bool isPlatformUnsupported;
  _LimitedExecutor(this.reason, {this.isPlatformUnsupported = false});
}

class DeviceSession extends ChangeNotifier {
  final Socket socket;
  final int index;
  final String deviceName;
  final Executor executor;
  final DateTime connectedAt = DateTime.now();

  /// User-assigned name (null = default "Device N").
  String? customName;

  List<int> _buffer = [];
  int requestCount = 0;
  double averageIntervalMs = 0;
  DateTime? _lastRequest;
  bool _closed = false;

  DeviceSession({
    required this.socket,
    required this.index,
    required this.deviceName,
    required this.executor,
    this.customName,
  });

  /// Display name: custom name if the user set one, else the fallback
  /// prefix followed by the index (e.g. "Device 1").
  String displayName(String fallbackPrefix) =>
      customName ?? '$fallbackPrefix $index';

  String get peerAddress {
    try {
      return socket.remoteAddress.address;
    } catch (_) {
      return '';
    }
  }

  int get peerPort {
    try {
      return socket.remotePort;
    } catch (_) {
      return 0;
    }
  }

  bool get isLimited => executor is _LimitedExecutor;
  String? get limitReason => executor is _LimitedExecutor
      ? (executor as _LimitedExecutor).reason
      : null;
  bool get isPlatformUnsupported =>
      executor is _LimitedExecutor &&
      (executor as _LimitedExecutor).isPlatformUnsupported;

  bool get isClosed => _closed;

  void feed(Uint8List data) {
    _buffer.addAll(data);
    // Decode against a single snapshot; drop the consumed prefix at the end.
    final buf = Uint8List.fromList(_buffer);
    var offset = 0;
    final now = DateTime.now();
    while (offset < buf.length) {
      final result = decodeGamepadReading(buf, offset);
      if (!result.success) {
        switch (result.failure) {
          case DecodeFailure.incomplete:
            break;
          case DecodeFailure.schemaMismatch:
          case DecodeFailure.dataTooLarge:
            // Skip one byte and try to resync (the old client never sent
            // invalid data; this only triggers on garbage).
            offset += 1;
            continue;
          case DecodeFailure.none:
            break;
        }
        break;
      }
      requestCount++;
      if (_lastRequest != null) {
        final elapsed = now.difference(_lastRequest!).inMicroseconds / 1000.0;
        averageIntervalMs += (elapsed - averageIntervalMs) / requestCount;
      }
      _lastRequest = now;
      executor.inject(result.reading);
      offset += result.bytesConsumed;
    }
    _buffer = buf.sublist(offset).toList(); // growable copy
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      // A dropped socket means "release everything" — without this, inputs
      // held at disconnect time would stay stuck down (the client sends a
      // teardown packet on clean exit, but crashes/network drops don't).
      executor.releaseAll();
    } catch (_) {}
    try {
      await socket.close();
    } catch (_) {}
    executor.dispose();
    notifyListeners();
  }
}

class DeviceServer extends ChangeNotifier {
  ServerSocket? _socket;
  final List<DeviceSession> sessions = [];
  int _deviceCounter = 1;
  AppSettings settings;
  ExecutorFactory executorFactory;
  String? lastError;

  DeviceServer({
    required this.settings,
    this.executorFactory = defaultExecutorFactory,
  });

  bool get isRunning => _socket != null;
  int get actualPort => _socket?.port ?? 0;

  Future<void> start() async {
    if (isRunning) return;
    lastError = null;
    try {
      _socket = await ServerSocket.bind(InternetAddress.anyIPv4, settings.port);
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return;
    }
    _socket!.listen(_accept);
    notifyListeners();
  }

  Future<void> stop() async {
    final copy = List<DeviceSession>.of(sessions);
    for (final s in copy) {
      await s.close();
    }
    sessions.clear();
    await _socket?.close();
    _socket = null;
    notifyListeners();
  }

  Future<void> restart() async {
    await stop();
    await start();
  }

  void _accept(Socket socket) {
    // Low-latency gamepad traffic.
    socket.setOption(SocketOption.tcpNoDelay, true);
    final index = _deviceCounter++;
    final baseName = 'Minassat Gamepad';
    final deviceName = index <= 1 ? baseName : '$baseName $index';
    String peerIp = '';
    try {
      peerIp = socket.remoteAddress.address;
    } catch (_) {}
    final session = DeviceSession(
      socket: socket,
      index: index,
      deviceName: deviceName,
      customName: peerIp.isNotEmpty ? settings.deviceNames[peerIp] : null,
      executor: executorFactory(
        type: settings.executor,
        deviceName: deviceName,
        mouseSensitivity: settings.mouseSensitivity,
      ),
    );
    sessions.add(session);
    socket.listen(
      session.feed,
      onDone: () => _remove(session),
      onError: (_) => _remove(session),
      cancelOnError: true,
    );
    notifyListeners();
  }

  Future<void> _remove(DeviceSession session) async {
    sessions.remove(session);
    await session.close();
    notifyListeners();
  }

  Future<void> disconnect(DeviceSession session) async {
    await _remove(session);
  }

  /// Renames a device. The name is remembered by peer IP so reconnecting
  /// phones keep their names. Pass null/empty to revert to the default.
  void rename(DeviceSession session, String? name) {
    final trimmed = name?.trim() ?? '';
    session.customName = trimmed.isEmpty ? null : trimmed;
    final ip = session.peerAddress;
    if (ip.isNotEmpty) {
      if (trimmed.isEmpty) {
        settings.deviceNames.remove(ip);
      } else {
        settings.deviceNames[ip] = trimmed;
      }
      settings.save();
    }
    session.notifyListeners();
    notifyListeners();
  }

  Future<void> disconnectAll() async {
    final copy = List<DeviceSession>.of(sessions);
    for (final s in copy) {
      await _remove(s);
    }
  }

  /// Non-loopback IPv4 addresses for the "connect a phone" panel.
  static Future<List<String>> localIPv4() async {
    final out = <String>[];
    try {
      final ifs = await NetworkInterface.list();
      for (final i in ifs) {
        for (final a in i.addresses) {
          if (a.type == InternetAddressType.IPv4 &&
              !a.isLoopback &&
              !a.isLinkLocal) {
            out.add(a.address);
          }
        }
      }
    } catch (_) {}
    return out;
  }
}
