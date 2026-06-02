enum AppAuthenticationResult { success, cancelled, unavailable }

abstract interface class AppAuthenticator {
  Future<bool> canAuthenticate();

  Future<AppAuthenticationResult> authenticate();
}
