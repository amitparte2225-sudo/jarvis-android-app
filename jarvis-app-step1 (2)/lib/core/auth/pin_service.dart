import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:jarvis_app/core/auth/secure_store.dart';

class VerifyResult {
  const VerifyResult({required this.ok, this.lockedFor, this.attemptsLeft = 0});
  final bool ok;
  final Duration? lockedFor;
  final int attemptsLeft;
}

/// Saves a PIN as a salted hash (never the PIN itself) and checks it.
/// Too many wrong tries lock the app for a short time.
class PinService {
  PinService(
    this._store, {
    this.iterations = 20000,
    this.maxAttempts = 5,
    this.lockDuration = const Duration(seconds: 60),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SecureStore _store;
  final int iterations;
  final int maxAttempts;
  final Duration lockDuration;
  final DateTime Function() _now;

  static const _kSalt = 'pin_salt';
  static const _kHash = 'pin_hash';
  static const _kFails = 'pin_fails';
  static const _kLockedUntil = 'pin_locked_until';

  static bool isValidFormat(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

  static bool isTooWeak(String pin) => RegExp(r'^(\d)\1*$').hasMatch(pin);

  Future<bool> hasPin() async => (await _store.read(_kHash)) != null;

  Future<void> setPin(String pin) async {
    if (!isValidFormat(pin)) {
      throw ArgumentError('PIN must be 4 to 8 digits.');
    }
    final rng = Random.secure();
    final salt = List<int>.generate(16, (_) => rng.nextInt(256));
    final hash = _derive(pin, salt);
    await _store.write(_kSalt, base64Encode(salt));
    await _store.write(_kHash, base64Encode(hash));
    await _store.delete(_kFails);
    await _store.delete(_kLockedUntil);
  }

  Future<VerifyResult> verify(String pin) async {
    final now = _now();
    final lockedMs = int.tryParse(await _store.read(_kLockedUntil) ?? '');
    if (lockedMs != null) {
      final until = DateTime.fromMillisecondsSinceEpoch(lockedMs);
      if (now.isBefore(until)) {
        return VerifyResult(ok: false, lockedFor: until.difference(now));
      }
    }

    final saltB64 = await _store.read(_kSalt);
    final hashB64 = await _store.read(_kHash);
    if (saltB64 == null || hashB64 == null) {
      return const VerifyResult(ok: false);
    }

    final candidate = _derive(pin, base64Decode(saltB64));
    final ok = _sameBytes(candidate, base64Decode(hashB64));
    if (ok) {
      await _store.delete(_kFails);
      await _store.delete(_kLockedUntil);
      return VerifyResult(ok: true, attemptsLeft: maxAttempts);
    }

    final fails = (int.tryParse(await _store.read(_kFails) ?? '') ?? 0) + 1;
    if (fails >= maxAttempts) {
      await _store.write(
        _kLockedUntil,
        now.add(lockDuration).millisecondsSinceEpoch.toString(),
      );
      await _store.write(_kFails, '0');
      return VerifyResult(ok: false, lockedFor: lockDuration);
    }
    await _store.write(_kFails, fails.toString());
    return VerifyResult(ok: false, attemptsLeft: maxAttempts - fails);
  }

  // PBKDF2-HMAC-SHA256, one 32-byte block.
  List<int> _derive(String pin, List<int> salt) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final result = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
