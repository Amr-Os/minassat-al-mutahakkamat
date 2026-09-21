// Shared test helpers.
import 'package:minassat_al_mutahakkamat/executors.dart';

bool? _uinputCache;

/// True when a real uinput device can actually be created (file presence
/// alone is not enough — CI machines have /dev/uinput without permission).
bool uinputUsable() {
  final cached = _uinputCache;
  if (cached != null) return cached;
  try {
    GamepadExecutor('VGP probe').dispose();
    _uinputCache = true;
  } catch (_) {
    _uinputCache = false;
  }
  return _uinputCache!;
}
