part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadLibrary extends LibraryEvent {
  const LoadLibrary();
}

class ImportFile extends LibraryEvent {
  final String filePath;
  final String fileName;
  final String content;
  final int fileSize;
  final DateTime lastModified;

  const ImportFile({
    required this.filePath,
    required this.fileName,
    required this.content,
    required this.fileSize,
    required this.lastModified,
  });

  @override
  List<Object?> get props => [filePath];
}

class DeleteFile extends LibraryEvent {
  final String filePath;
  const DeleteFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ToggleFavorite extends LibraryEvent {
  final String filePath;
  const ToggleFavorite(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class SetViewFilter extends LibraryEvent {
  final LibraryFilter filter;
  const SetViewFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchFiles extends LibraryEvent {
  final String query;
  const SearchFiles(this.query);

  @override
  List<Object?> get props => [query];
}

class OpenFile extends LibraryEvent {
  final String filePath;
  final String content;
  const OpenFile({required this.filePath, required this.content});

  @override
  List<Object?> get props => [filePath];
}

enum LibraryFilter { all, favorites, recent, trash }
