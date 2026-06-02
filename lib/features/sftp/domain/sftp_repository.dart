import 'package:conduit/features/hosts/domain/saved_host.dart';
import 'package:conduit/features/sftp/domain/sftp_session.dart';

abstract class SftpRepository {
  Future<SftpSession> connect(SavedHost host);
}
