# AGENTS.md

## Project Overview

**منصة المتحكمات (Minassat Al-Mutahakkamat)** is a desktop server
application (Flutter/Dart) that enables mobile devices to function as
virtual game controllers for PC. It receives gamepad input over TCP and
translates it into system-level input events. One app window manages every
connected phone. Linux input injection is implemented (uinput/libevdev);
other desktop OSes are planned — keep the input layer behind `Executor` so
new platforms plug in cleanly.

- **Language**: Dart with Flutter (desktop; Linux first)
- **Build/test**: `flutter pub get`, `flutter analyze`, `flutter test`,
  `flutter run -d linux`, `flutter build linux`
- **Communication**: TCP server using the custom Colfer binary protocol
  (`GamepadReading` packets, decoded in `lib/protocol.dart`)
- **Input injection**: Dart FFI to `libevdev.so.2` + libc
  (`lib/linux_input.dart`); needs `/dev/uinput` access (see Build.md)
- **UI**: Arabic by default (RTL), English optional — `lib/l10n.dart`
- **Version**: `version:` in `pubspec.yaml` (mirrored in
  `lib/page_about.dart` as `appVersion`)

## Source Layout

```text
Mobile Client (TCP) -> DeviceServer (dart:io) -> Colfer decoder
  -> Executor (FFI uinput gamepad | keyboard+mouse) -> Linux kernel
```
(Windows/macOS executors plug in behind `Executor` later.)

- `lib/protocol.dart` - Colfer `GamepadReading` decoder/encoder
  (port of `VGP_Data_Exchange/C/Colfer.c` semantics; read that file before
  touching the decoder)
- `lib/linux_input.dart` - FFI bindings + managed uinput device
- `lib/executors.dart` - `GamepadExecutor`, `KeyboardMouseExecutor`
  (default keymap), `NullExecutor` (tests/fallback)
- `lib/device_server.dart` - TCP server + `DeviceSession` (buffering,
  stats, custom names by peer IP)
- `lib/settings.dart` - JSON settings at
  `~/.config/minassat-al-mutahakkamat/settings.json`
- `lib/l10n.dart`, `lib/app.dart`, `lib/page_*.dart`, `lib/theme.dart`,
  `lib/widgets.dart` - UI (add every user-visible string to BOTH locales)
- `test/` - unit + integration tests (Colfer, loopback server incl.
  restart/rename, real uinput devices, 60 Hz stream)
- `packaging/` - Linux `.desktop` launcher entry
- `assets/` - logo

## Instructions

1. Build.md contains build instructions.
2. Do not modify anything in VGP_Data_Exchange (protocol submodule).
3. Every user-visible string must exist in Arabic AND English (`l10n.dart`).
4. Never break the Colfer wire format — the mobile clients depend on it.
5. Verify with `flutter analyze` and `flutter test` before finishing.
   (`flutter test` runs real uinput tests when `/dev/uinput` is accessible.)
6. Do not commit, push, or create PRs unless explicitly requested.
