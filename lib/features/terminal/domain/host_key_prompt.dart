import 'package:conduit/features/terminal/domain/host_key_verifier.dart';

enum HostKeyPromptKind { firstTrust, mismatch }

enum HostKeyDecision { trust, reject }

class HostKeyPromptRequest {
  const HostKeyPromptRequest({
    required this.host,
    required this.port,
    required this.type,
    required this.fingerprint,
    required this.kind,
    this.existing,
  });

  final String host;
  final int port;
  final String type;
  final String fingerprint;
  final HostKeyPromptKind kind;
  final HostKeyRecord? existing;
}

abstract interface class HostKeyPrompt {
  Future<HostKeyDecision> request(HostKeyPromptRequest request);
}
