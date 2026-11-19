import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// PIN / pattern (tuzlangan SHA-256 hash, Keystore'da) va barmoq izi.
class SecurityService {
  final _store = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  static const _kPin = 'pin_hash', _kPat = 'pat_hash', _kSalt = 'salt';

  Future<String> _salt() async {
    var s = await _store.read(key: _kSalt);
    if (s == null) {
      final r = Random.secure();
      s = base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
      await _store.write(key: _kSalt, value: s);
    }
    return s;
  }

  Future<String> _hash(String v) async =>
      sha256.convert(utf8.encode('${await _salt()}:$v')).toString();

  Future<bool> get hasPin => _store.containsKey(key: _kPin);
  Future<bool> get hasPattern => _store.containsKey(key: _kPat);

  Future<void> setPin(String v) async =>
      _store.write(key: _kPin, value: await _hash(v));
  Future<void> setPattern(String v) async =>
      _store.write(key: _kPat, value: await _hash(v));

  Future<bool> checkPin(String v) async =>
      await _store.read(key: _kPin) == await _hash(v);
  Future<bool> checkPattern(String v) async =>
      await _store.read(key: _kPat) == await _hash(v);

  /// Tizim biometrikasi (barmoq izi). Muvaffaqiyatda true.
  Future<bool> biometric(String reason) async {
    try {
      if (!await _auth.canCheckBiometrics) return false;
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
