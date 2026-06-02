import 'dart:typed_data';

abstract class FileExport {
  Future<String?> save(String fileName, Uint8List bytes);
}
