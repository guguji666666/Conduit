import 'dart:typed_data';

import 'package:conduit/features/sftp/domain/sftp_entry.dart';

abstract class SftpSession {
  Future<List<SftpEntry>> list(String path);

  Future<String> resolve(String path);

  Future<Uint8List> read(
    String path, {
    void Function(int bytesRead, int? total)? onProgress,
  });

  Future<void> write(
    String path,
    Stream<Uint8List> data,
    int length, {
    void Function(int bytesSent)? onProgress,
  });

  Future<void> makeDirectory(String path);

  Future<void> rename(String from, String to);

  Future<void> delete(SftpEntry entry);

  Future<void> close();
}
