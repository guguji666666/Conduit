import 'package:conduit/features/app_lock/domain/app_authenticator.dart';
import 'package:flutter/foundation.dart';

enum AppLockStatus { locked, checking, unlocked, unavailable }

class AppLockController extends ChangeNotifier {
  AppLockController(this._authenticator);

  final AppAuthenticator _authenticator;

  AppLockStatus _status = AppLockStatus.locked;
  String? _message;

  AppLockStatus get status => _status;
  String? get message => _message;
  bool get isUnlocked => _status == AppLockStatus.unlocked;

  Future<void> unlock() async {
    if (_status == AppLockStatus.checking) {
      return;
    }

    _status = AppLockStatus.checking;
    _message = null;
    notifyListeners();

    if (!await _authenticator.canAuthenticate()) {
      _status = AppLockStatus.unavailable;
      _message =
          'Device authentication is not configured. '
          'Set a screen lock to keep saved hosts private.';
      notifyListeners();
      return;
    }

    final result = await _authenticator.authenticate();
    switch (result) {
      case AppAuthenticationResult.success:
        _status = AppLockStatus.unlocked;
        _message = null;
      case AppAuthenticationResult.cancelled:
        _status = AppLockStatus.locked;
        _message = 'Authentication was cancelled.';
      case AppAuthenticationResult.unavailable:
        _status = AppLockStatus.unavailable;
        _message =
            'Device authentication is unavailable on this device. '
            'Set a screen lock for better protection.';
    }
    notifyListeners();
  }

  void continueWithoutAuth() {
    if (_status != AppLockStatus.unavailable) {
      return;
    }
    _status = AppLockStatus.unlocked;
    notifyListeners();
  }

  void lock() {
    _status = AppLockStatus.locked;
    _message = null;
    notifyListeners();
  }
}
