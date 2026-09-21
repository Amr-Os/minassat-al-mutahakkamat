import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_gamepad_pc/protocol.dart';

void main() {
  group('colfer gamepad_reading', () {
    test('roundtrip full reading', () {
      const r = GamepadReading(
        buttonsUp: 0x4,
        buttonsDown: 0x8 | 0x40,
        leftTrigger: 0.5,
        rightTrigger: 1.0,
        leftX: -0.25,
        leftY: 0.75,
        rightX: 1.0,
        rightY: -1.0,
      );
      final bytes = encodeGamepadReading(r);
      final res = decodeGamepadReading(bytes);
      expect(res.success, isTrue);
      expect(res.bytesConsumed, bytes.length);
      expect(res.reading.buttonsUp, r.buttonsUp);
      expect(res.reading.buttonsDown, r.buttonsDown);
      expect(res.reading.leftTrigger, closeTo(0.5, 1e-6));
      expect(res.reading.rightTrigger, closeTo(1.0, 1e-6));
      expect(res.reading.leftX, closeTo(-0.25, 1e-6));
      expect(res.reading.leftY, closeTo(0.75, 1e-6));
      expect(res.reading.rightX, closeTo(1.0, 1e-6));
      expect(res.reading.rightY, closeTo(-1.0, 1e-6));
    });

    test('empty reading encodes to terminator only', () {
      final bytes = encodeGamepadReading(const GamepadReading());
      expect(bytes, Uint8List.fromList([127]));
      final res = decodeGamepadReading(bytes);
      expect(res.success, isTrue);
      expect(res.bytesConsumed, 1);
    });

    test('large varint buttons', () {
      const r = GamepadReading(buttonsDown: 0x2000 | 0x12345);
      final bytes = encodeGamepadReading(r);
      final res = decodeGamepadReading(bytes);
      expect(res.success, isTrue);
      expect(res.reading.buttonsDown, r.buttonsDown);
    });

    test('fixed-form uint32 (header|128) decodes', () {
      // buttons_up = 0x01020304, fixed 4-byte big-endian form.
      final bytes = Uint8List.fromList([128, 1, 2, 3, 4, 127]);
      final res = decodeGamepadReading(bytes);
      expect(res.success, isTrue);
      expect(res.reading.buttonsUp, 0x01020304);
      expect(res.bytesConsumed, 6);
    });

    test('truncated input is incomplete', () {
      expect(decodeGamepadReading(Uint8List(0)).failure,
          DecodeFailure.incomplete);
      final bytes = encodeGamepadReading(
          const GamepadReading(buttonsDown: 4, leftX: 0.5));
      for (var i = 0; i < bytes.length - 1; i++) {
        final res = decodeGamepadReading(bytes.sublist(0, i));
        expect(res.success, isFalse, reason: 'prefix length $i');
        expect(res.failure, DecodeFailure.incomplete,
            reason: 'prefix length $i');
      }
      expect(decodeGamepadReading(bytes).success, isTrue);
    });

    test('bad header is schema mismatch', () {
      final res = decodeGamepadReading(Uint8List.fromList([9, 127]));
      expect(res.success, isFalse);
      expect(res.failure, DecodeFailure.schemaMismatch);
    });

    test('two packets in one buffer', () {
      final a = encodeGamepadReading(const GamepadReading(buttonsDown: 4));
      final b = encodeGamepadReading(const GamepadReading(leftX: 1));
      final buf = Uint8List.fromList([...a, ...b]);
      final first = decodeGamepadReading(buf, 0);
      expect(first.success, isTrue);
      expect(first.reading.buttonsDown, 4);
      final second = decodeGamepadReading(buf, first.bytesConsumed);
      expect(second.success, isTrue);
      expect(second.reading.leftX, closeTo(1.0, 1e-6));
      expect(first.bytesConsumed + second.bytesConsumed, buf.length);
    });
  });
}
