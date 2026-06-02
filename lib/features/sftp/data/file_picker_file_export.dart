import 'dart:typed_data';

import 'package:conduit/features/sftp/domain/file_export.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerFileExport implements FileExport {
  const FilePickerFileExport();

  @override
  Future<String?> save(String fileName, Uint8List bytes) {
    return FilePicker.saveFile(fileName: fileName, bytes: bytes);
  }
}
