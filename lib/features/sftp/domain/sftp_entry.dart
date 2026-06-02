enum SftpEntryKind { directory, file, symlink, other }

class SftpEntry {
  const SftpEntry({
    required this.name,
    required this.path,
    required this.kind,
    this.size,
    this.modifiedAt,
    this.permissions,
  });

  final String name;
  final String path;
  final SftpEntryKind kind;
  final int? size;
  final DateTime? modifiedAt;

  final int? permissions;

  bool get isDirectory => kind == SftpEntryKind.directory;
  bool get isSymlink => kind == SftpEntryKind.symlink;

  bool get isNavigable => isDirectory || isSymlink;

  String get permissionString {
    final mode = permissions;
    if (mode == null) return '';
    const flags = ['r', 'w', 'x'];
    final buffer = StringBuffer();
    for (var group = 2; group >= 0; group--) {
      for (var bit = 2; bit >= 0; bit--) {
        final isSet = (mode & (1 << (group * 3 + bit))) != 0;
        buffer.write(isSet ? flags[2 - bit] : '-');
      }
    }
    return buffer.toString();
  }
}
