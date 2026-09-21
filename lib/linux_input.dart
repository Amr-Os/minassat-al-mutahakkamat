// Minimal Dart FFI bindings for libevdev + libc open/close, enough to
// create uinput devices and inject input events on Linux.
//
// Only libevdev.so.2 (runtime) and libc are needed; no dev headers.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// struct input_absinfo (linux/input.h): six signed 32-bit fields.
final class _AbsInfo extends Struct {
  @Int32()
  external int value;
  @Int32()
  external int minimum;
  @Int32()
  external int maximum;
  @Int32()
  external int fuzz;
  @Int32()
  external int flat;
  @Int32()
  external int resolution;
}

class LinuxInput {
  static DynamicLibrary? _evdev;
  static DynamicLibrary? _libc;

  static DynamicLibrary get evdev =>
      _evdev ??= DynamicLibrary.open('libevdev.so.2');
  static DynamicLibrary get libc =>
      _libc ??= DynamicLibrary.open('libc.so.6');

  static final Pointer<Void> Function() newDevice = evdev
      .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
          'libevdev_new');

  static final void Function(Pointer<Void>) freeDevice = evdev
      .lookupFunction<Void Function(Pointer<Void>),
          void Function(Pointer<Void>)>('libevdev_free');

  static final void Function(Pointer<Void>, Pointer<Utf8>) setName = evdev
      .lookupFunction<Void Function(Pointer<Void>, Pointer<Utf8>),
          void Function(Pointer<Void>, Pointer<Utf8>)>('libevdev_set_name');

  static final void Function(Pointer<Void>, int) setIdBustype = evdev
      .lookupFunction<Void Function(Pointer<Void>, Uint32),
          void Function(Pointer<Void>, int)>('libevdev_set_id_bustype');

  static final void Function(Pointer<Void>, int) setIdVendor = evdev
      .lookupFunction<Void Function(Pointer<Void>, Uint32),
          void Function(Pointer<Void>, int)>('libevdev_set_id_vendor');

  static final void Function(Pointer<Void>, int) setIdProduct = evdev
      .lookupFunction<Void Function(Pointer<Void>, Uint32),
          void Function(Pointer<Void>, int)>('libevdev_set_id_product');

  static final void Function(Pointer<Void>, int) setIdVersion = evdev
      .lookupFunction<Void Function(Pointer<Void>, Uint32),
          void Function(Pointer<Void>, int)>('libevdev_set_id_version');

  static final int Function(Pointer<Void>, int) enableEventType = evdev
      .lookupFunction<Int32 Function(Pointer<Void>, Uint32),
          int Function(Pointer<Void>, int)>('libevdev_enable_event_type');

  static final int Function(Pointer<Void>, int, int, Pointer<Void>)
      enableEventCode = evdev.lookupFunction<
          Int32 Function(Pointer<Void>, Uint32, Uint32, Pointer<Void>),
          int Function(Pointer<Void>, int, int,
              Pointer<Void>)>('libevdev_enable_event_code');

  static final int Function(Pointer<Void>, int, Pointer<Pointer<Void>>)
      uinputCreate = evdev.lookupFunction<
          Int32 Function(Pointer<Void>, Int32, Pointer<Pointer<Void>>),
          int Function(Pointer<Void>, int,
              Pointer<Pointer<Void>>)>('libevdev_uinput_create_from_device');

  static final int Function(Pointer<Void>, int, int, int) uinputWrite =
      evdev.lookupFunction<
          Int32 Function(Pointer<Void>, Uint32, Uint32, Int32),
          int Function(Pointer<Void>, int, int,
              int)>('libevdev_uinput_write_event');

  static final void Function(Pointer<Void>) uinputDestroy = evdev
      .lookupFunction<Void Function(Pointer<Void>),
          void Function(Pointer<Void>)>('libevdev_uinput_destroy');

  static final int Function(Pointer<Utf8>, int) open = libc
      .lookupFunction<Int32 Function(Pointer<Utf8>, Int32),
          int Function(Pointer<Utf8>, int)>('open');

  static final int Function(int) close =
      libc.lookupFunction<Int32 Function(Int32), int Function(int)>('close');
}

/// A managed uinput device: creates the kernel device on construction and
/// tears it down on [dispose].
class UinputDevice {
  final Pointer<Void> _dev;
  final Pointer<Void> _uidev;
  final int _fd;
  bool _disposed = false;

  UinputDevice._(this._dev, this._uidev, this._fd);

  /// Creates a uinput device with [name] and lets [setup] enable event
  /// types/codes on the raw libevdev device before it is published.
  factory UinputDevice.create(
      String name, void Function(Pointer<Void> dev) setup) {
    final fdPtr = name.toNativeUtf8();
    late final int fd;
    try {
      // Open /dev/uinput ourselves so we don't depend on
      // LIBEVDEV_UINPUT_OPEN_MANAGED.
      const uinputPath = '/dev/uinput';
      final path = uinputPath.toNativeUtf8();
      try {
        fd = LinuxInput.open(path, 2 /* O_RDWR */);
      } finally {
        calloc.free(path);
      }
      if (fd < 0) {
        throw StateError(
            'Cannot open /dev/uinput. Add your user to the input/uinput '
            'group or fix permissions (see Build.md).');
      }

      final dev = LinuxInput.newDevice();
      if (dev == nullptr) {
        LinuxInput.close(fd);
        throw StateError('libevdev_new() failed.');
      }
      try {
        LinuxInput.setName(dev, fdPtr);
        setup(dev);
        final out = calloc<Pointer<Void>>();
        try {
          final rc = LinuxInput.uinputCreate(dev, fd, out);
          if (rc != 0) {
            throw StateError(
                'libevdev_uinput_create_from_device failed (rc=$rc).');
          }
          return UinputDevice._(dev, out.value, fd);
        } finally {
          calloc.free(out);
        }
      } catch (_) {
        LinuxInput.freeDevice(dev);
        LinuxInput.close(fd);
        rethrow;
      }
    } finally {
      calloc.free(fdPtr);
    }
  }

  /// Enables `type` (+ optional `code`) on the underlying device. Must be
  /// called from the `setup` callback of [UinputDevice.create].
  static void enable(
      Pointer<Void> dev, int type, int code, AbsSpec? absSpec) {
    var rc = LinuxInput.enableEventType(dev, type);
    if (rc != 0) throw StateError('enable_event_type($type) rc=$rc');
    Pointer<Void> data = nullptr;
    final spec = absSpec;
    if (spec != null) {
      final info = calloc<_AbsInfo>();
      info.ref.value = 0;
      info.ref.minimum = spec.minimum;
      info.ref.maximum = spec.maximum;
      info.ref.fuzz = spec.fuzz;
      info.ref.flat = spec.flat;
      info.ref.resolution = 0;
      data = info.cast();
      rc = LinuxInput.enableEventCode(dev, type, code, data);
      calloc.free(info);
    } else {
      rc = LinuxInput.enableEventCode(dev, type, code, nullptr);
    }
    if (rc != 0) throw StateError('enable_event_code($code) rc=$rc');
  }

  static void enableType(Pointer<Void> dev, int type) {
    final rc = LinuxInput.enableEventType(dev, type);
    if (rc != 0) throw StateError('enable_event_type($type) rc=$rc');
  }

  void write(int type, int code, int value) {
    if (_disposed) return;
    LinuxInput.uinputWrite(_uidev, type, code, value);
  }

  /// Commits pending events (EV_SYN / SYN_REPORT).
  void sync() => write(0, 0, 0);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    LinuxInput.uinputDestroy(_uidev);
    LinuxInput.freeDevice(_dev);
    LinuxInput.close(_fd);
  }
}

class AbsSpec {
  final int minimum;
  final int maximum;
  final int fuzz;
  final int flat;
  const AbsSpec(this.minimum, this.maximum, [this.fuzz = 0, this.flat = 0]);
}
