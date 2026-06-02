import 'dart:async';
import 'dart:typed_data';

import 'package:conduit/core/app_failure.dart';
import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/terminal/domain/host_key_verifier.dart';
import 'package:dartssh2/dartssh2.dart';

class SshClientFactory {
  const SshClientFactory(this._hostKeyVerifier);

  final HostKeyVerifier _hostKeyVerifier;

  Future<SSHClient> connect(SavedHost host) async {
    SSHSocket? socket;
    try {
      socket = await SSHSocket.connect(
        host.host.trim(),
        host.port,
        timeout: Duration(seconds: host.connectionTimeoutSeconds),
      );
      return SSHClient(
        socket,
        username: host.username.trim(),
        identities: _identitiesFor(host),
        onPasswordRequest: _passwordRequestFor(host),
        onUserInfoRequest: _userInfoRequestFor(host),
        onVerifyHostKey: (type, fingerprint) {
          return _hostKeyVerifier.verify(
            host: host.host.trim(),
            port: host.port,
            type: type,
            fingerprint: _formatFingerprint(fingerprint),
          );
        },
      );
    } catch (_) {
      unawaited(socket?.close() ?? Future<void>.value());
      rethrow;
    }
  }

  List<SSHKeyPair>? _identitiesFor(SavedHost host) {
    if (host.authMethod != SshAuthMethod.privateKey) {
      return null;
    }
    try {
      return SSHKeyPair.fromPem(
        host.privateKey,
        host.passphrase.isEmpty ? null : host.passphrase,
      );
    } catch (error) {
      throw AppFailure('Private key could not be loaded.', error);
    }
  }

  String Function()? _passwordRequestFor(SavedHost host) {
    return host.authMethod == SshAuthMethod.password
        ? () => host.password
        : null;
  }

  SSHUserInfoRequestHandler? _userInfoRequestFor(SavedHost host) {
    if (host.authMethod != SshAuthMethod.password) {
      return null;
    }
    return (request) {
      var answered = false;
      return [
        for (final prompt in request.prompts)
          if (!prompt.echo && !answered)
            (() {
              answered = true;
              return host.password;
            })()
          else
            '',
      ];
    };
  }

  String _formatFingerprint(Uint8List bytes) {
    final parts = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    return 'MD5:${parts.join(':')}';
  }
}
