// Colfer binary protocol for `VGP_Data_Exchange.GamepadReading`.
//
// Dart port of the generated C decoder in VGP_Data_Exchange/C/Colfer.c
// (schema: VGP_Data_Exchange/GamePadReading.colf). The wire format is a
// sequence of (field index, value) pairs in ascending field order,
// terminated by the header byte 127:
//
//   field 0,1 (uint32): header == index followed by a varint, or
//                       header == index|128 followed by 4 big-endian bytes.
//   field 2..7 (float32): header == index followed by 4 big-endian bytes.
//   Fields with zero values are omitted by the encoder.
//
// Mirrors the C decoder semantics: truncated input -> incomplete,
// oversize input -> dataTooLarge, any other mismatch -> schemaMismatch.

import 'dart:typed_data';

/// Decoded gamepad state. Field order matches the .colf schema.
class GamepadReading {
  final int buttonsUp;
  final int buttonsDown;
  final double leftTrigger;
  final double rightTrigger;
  final double leftX;
  final double leftY;
  final double rightX;
  final double rightY;

  const GamepadReading({
    this.buttonsUp = 0,
    this.buttonsDown = 0,
    this.leftTrigger = 0,
    this.rightTrigger = 0,
    this.leftX = 0,
    this.leftY = 0,
    this.rightX = 0,
    this.rightY = 0,
  });
}

enum DecodeFailure { none, incomplete, schemaMismatch, dataTooLarge }

class DecodeResult {
  final GamepadReading reading;
  final int bytesConsumed;
  final bool success;
  final DecodeFailure failure;

  const DecodeResult({
    required this.reading,
    required this.bytesConsumed,
    required this.success,
    this.failure = DecodeFailure.none,
  });
}

/// Upper bound for a single packet, same as colfer_size_max in Colfer.c.
const int colferSizeMax = 16 * 1024 * 1024;

class _Reader {
  final Uint8List data;
  final int end;
  final bool tooLarge;
  int pos;
  _Reader(this.data, this.pos)
      : tooLarge = data.length - pos > colferSizeMax,
        end = (data.length - pos > colferSizeMax)
            ? pos + colferSizeMax
            : data.length;

  DecodeFailure? need(int n) {
    if (pos + n > end) {
      return tooLarge ? DecodeFailure.dataTooLarge : DecodeFailure.incomplete;
    }
    return null;
  }
}

/// Reads a varint value. Returns null when more bytes are needed.
/// The caller must ensure a header byte follows (see [needHeader]).
int? _readUint32Varint(_Reader r) {
  int x = r.data[r.pos++];
  if (x > 127) {
    x &= 127;
    var shift = 7;
    while (true) {
      if (r.need(1) != null) return null;
      final b = r.data[r.pos++];
      if (b <= 127) {
        x |= b << shift;
        break;
      }
      x |= (b & 127) << shift;
      shift += 7;
    }
  }
  return x;
}

/// A value is always followed by the next header byte; the C decoder fails
/// with EWOULDBLOCK/EFBIG when it is missing.
DecodeFailure? _needHeader(_Reader r) => r.need(1);

double _readFloat32(_Reader r) {
  final bits = (r.data[r.pos++] << 24) |
      (r.data[r.pos++] << 16) |
      (r.data[r.pos++] << 8) |
      r.data[r.pos++];
  final bd = ByteData(4)..setUint32(0, bits);
  return bd.getFloat32(0);
}

/// Decodes one packet starting at [offset]. Returns the number of bytes
/// consumed on success, mirroring `..._unmarshal` in Colfer.c.
DecodeResult decodeGamepadReading(Uint8List data, [int offset = 0]) {
  const empty = GamepadReading();
  final r = _Reader(data, offset);

  var fail = r.need(1);
  if (fail != null) {
    return DecodeResult(
        reading: empty, bytesConsumed: 0, success: false, failure: fail);
  }
  var header = r.data[r.pos++];

  var buttonsUp = 0;
  var buttonsDown = 0;
  var leftTrigger = 0.0;
  var rightTrigger = 0.0;
  var leftX = 0.0;
  var leftY = 0.0;
  var rightX = 0.0;
  var rightY = 0.0;

  DecodeResult incomplete(DecodeFailure f) => DecodeResult(
      reading: empty, bytesConsumed: 0, success: false, failure: f);

  int? readVarint() {
    final v = _readUint32Varint(r);
    if (v == null) return null;
    final h = _needHeader(r);
    if (h != null) return null;
    return v;
  }

  int? readFixed32() {
    final x = (r.data[r.pos++] << 24) |
        (r.data[r.pos++] << 16) |
        (r.data[r.pos++] << 8) |
        r.data[r.pos++];
    return x;
  }

  // Field 0: ButtonsUp
  if (header == 0) {
    fail = r.need(2);
    if (fail != null) return incomplete(fail);
    final v = readVarint();
    if (v == null) {
      return incomplete(r.tooLarge
          ? DecodeFailure.dataTooLarge
          : DecodeFailure.incomplete);
    }
    buttonsUp = v;
    header = r.data[r.pos++];
  } else if (header == (0 | 128)) {
    fail = r.need(5);
    if (fail != null) return incomplete(fail);
    buttonsUp = readFixed32()!;
    header = r.data[r.pos++];
  }

  // Field 1: ButtonsDown
  if (header == 1) {
    fail = r.need(2);
    if (fail != null) return incomplete(fail);
    final v = readVarint();
    if (v == null) {
      return incomplete(r.tooLarge
          ? DecodeFailure.dataTooLarge
          : DecodeFailure.incomplete);
    }
    buttonsDown = v;
    header = r.data[r.pos++];
  } else if (header == (1 | 128)) {
    fail = r.need(5);
    if (fail != null) return incomplete(fail);
    buttonsDown = readFixed32()!;
    header = r.data[r.pos++];
  }

  // Fields 2..7: float32 values.
  final setters = <void Function(double)>[
    (v) => leftTrigger = v,
    (v) => rightTrigger = v,
    (v) => leftX = v,
    (v) => leftY = v,
    (v) => rightX = v,
    (v) => rightY = v,
  ];
  for (var i = 0; i < 6; i++) {
    if (header == i + 2) {
      fail = r.need(5);
      if (fail != null) {
        return DecodeResult(
            reading: empty, bytesConsumed: 0, success: false, failure: fail);
      }
      setters[i](_readFloat32(r));
      header = r.data[r.pos++];
    }
  }

  if (header != 127) {
    return const DecodeResult(
        reading: empty,
        bytesConsumed: 0,
        success: false,
        failure: DecodeFailure.schemaMismatch);
  }

  return DecodeResult(
    reading: GamepadReading(
      buttonsUp: buttonsUp,
      buttonsDown: buttonsDown,
      leftTrigger: leftTrigger,
      rightTrigger: rightTrigger,
      leftX: leftX,
      leftY: leftY,
      rightX: rightX,
      rightY: rightY,
    ),
    bytesConsumed: r.pos - offset,
    success: true,
  );
}

/// Encodes a reading (used by tests and any Dart senders). Zero fields are
/// omitted, exactly like the generated C marshaller.
Uint8List encodeGamepadReading(GamepadReading r) {
  final out = <int>[];
  void putVarint(int index, int value) {
    out.add(index);
    var x = value;
    if (x < 128) {
      out.add(x);
      return;
    }
    out.add((x & 127) | 128);
    x >>= 7;
    while (x > 127) {
      out.add((x & 127) | 128);
      x >>= 7;
    }
    out.add(x);
  }

  void putFloat(int index, double value) {
    out.add(index);
    final bd = ByteData(4)..setFloat32(0, value);
    final bits = bd.getUint32(0);
    out.addAll(
        [(bits >> 24) & 255, (bits >> 16) & 255, (bits >> 8) & 255, bits & 255]);
  }

  if (r.buttonsUp != 0) putVarint(0, r.buttonsUp);
  if (r.buttonsDown != 0) putVarint(1, r.buttonsDown);
  if (r.leftTrigger != 0) putFloat(2, r.leftTrigger);
  if (r.rightTrigger != 0) putFloat(3, r.rightTrigger);
  if (r.leftX != 0) putFloat(4, r.leftX);
  if (r.leftY != 0) putFloat(5, r.leftY);
  if (r.rightX != 0) putFloat(6, r.rightX);
  if (r.rightY != 0) putFloat(7, r.rightY);
  out.add(127);
  return Uint8List.fromList(out);
}
