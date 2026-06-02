import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/terminal/domain/ssh_terminal_session.dart';

abstract interface class SshTerminalRepository {
  Future<SshTerminalSession> connect(
    SavedHost host, {
    required int columns,
    required int rows,
  });
}
