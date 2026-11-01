import 'package:flutter/foundation.dart';
import 'package:jarvis_app/core/auth/pin_service.dart';

enum AuthStatus { loading, needsSetup, locked, unlocked }

class AuthController extends ChangeNotifier {
  AuthController(this._pins);

  static const autoLockAfter = Duration(seconds: 30);

  final PinService _pins;
  AuthStatus _status = AuthStatus.loading;
  DateTime? _backgroundedAt;

  AuthStatus get status => _status;

  Future<void> init() async {
    final has = await _pins.hasPin();
    _status = has ? AuthStatus.locked : AuthStatus.needsSetup;
    notifyListeners();
  }

  Future<void> createPin(String pin) async {
    await _pins.setPin(pin);
    _status = AuthStatus.unlocked;
    notifyListeners();
  }

  Future<VerifyResult> unlock(String pin) async {
    final result = await _pins.verify(pin);
    if (result.ok) {
      _status = AuthStatus.unlocked;
      notifyListeners();
    }
    return result;
  }

  void lock() {
    if (_status == AuthStatus.unlocked) {
      _status = AuthStatus.locked;
      notifyListeners();
    }
  }

  void onBackgrounded() => _backgroundedAt = DateTime.now();

  void onResumed() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since != null && DateTime.now().difference(since) >= autoLockAfter) {
      lock();
    }
  }
}
