part of 'library_bloc.dart';

class LibraryFile {
  final String filePath;
  final String fileName;
  final String content;
  final int fileSize;
  final DateTime lastModified;
  final DateTime? addedAt;
  final bool isFavorite;
  final bool isDeleted;

  const LibraryFile({
    required this.filePath,
    required this.fileName,
    required this.content,
    required this.fileSize,
    required this.lastModified,
    this.addedAt,
    this.isFavorite = false,
    this.isDeleted = false,
  });

  LibraryFile copyWith({
    String? filePath,
    String? fileName,
    String? content,
    int? fileSize,
    DateTime? lastModified,
    DateTime? addedAt,
    bool? isFavorite,
    bool? isDeleted,
  }) {
    return LibraryFile(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      content: content ?? this.content,
      fileSize: fileSize ?? this.fileSize,
      lastModified: lastModified ?? this.lastModified,
      addedAt: addedAt ?? this.addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  String get displaySize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get displayDate {
    final now = DateTime.now();
    final diff = now.difference(lastModified);
    if (diff.inDays == 0) return '今天';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${lastModified.month}/${lastModified.day}';
  }
}

class LibraryState extends Equatable {
  final List<LibraryFile> files;
  final LibraryFilter filter;
  final String searchQuery;
  final bool isLoading;

  const LibraryState({
    this.files = const [],
    this.filter = LibraryFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<LibraryFile> get filteredFiles {
    var result = files.where((f) {
      if (filter == LibraryFilter.favorites && !f.isFavorite) return false;
      if (filter == LibraryFilter.recent && f.addedAt == null) return false;
      if (filter == LibraryFilter.trash && !f.isDeleted) return false;
      if (filter != LibraryFilter.trash && f.isDeleted) return false;
      return true;
    }).toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((f) => f.fileName.toLowerCase().contains(q)).toList();
    }

    result.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return result;
  }

  int get allCount => files.where((f) => !f.isDeleted).length;
  int get favoriteCount => files.where((f) => f.isFavorite && !f.isDeleted).length;
  int get recentCount => files.where((f) => f.addedAt != null && !f.isDeleted).length;
  int get trashCount => files.where((f) => f.isDeleted).length;

  LibraryState copyWith({
    List<LibraryFile>? files,
    LibraryFilter? filter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return LibraryState(
      files: files ?? this.files,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [files, filter, searchQuery, isLoading];
}
