import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc() : super(const LibraryState()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<ImportFile>(_onImportFile);
    on<DeleteFile>(_onDeleteFile);
    on<ToggleFavorite>(_onToggleFavorite);
    on<SetViewFilter>(_onSetViewFilter);
    on<SearchFiles>(_onSearchFiles);
    on<OpenFile>(_onOpenFile);
  }

  void _onLoadLibrary(LoadLibrary event, Emitter<LibraryState> emit) {
    // Library loaded from storage — placeholder for future persistence
    emit(state.copyWith(isLoading: false));
  }

  void _onImportFile(ImportFile event, Emitter<LibraryState> emit) {
    final file = LibraryFile(
      filePath: event.filePath,
      fileName: event.fileName,
      content: event.content,
      fileSize: event.fileSize,
      lastModified: event.lastModified,
      addedAt: DateTime.now(),
    );
    final existing = state.files.indexWhere((f) => f.filePath == event.filePath);
    final newFiles = [...state.files];
    if (existing >= 0) {
      newFiles[existing] = file;
    } else {
      newFiles.add(file);
    }
    emit(state.copyWith(files: newFiles));
  }

  void _onDeleteFile(DeleteFile event, Emitter<LibraryState> emit) {
    final newFiles = state.files.map((f) {
      if (f.filePath == event.filePath) return f.copyWith(isDeleted: true);
      return f;
    }).toList();
    emit(state.copyWith(files: newFiles));
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<LibraryState> emit) {
    final newFiles = state.files.map((f) {
      if (f.filePath == event.filePath) return f.copyWith(isFavorite: !f.isFavorite);
      return f;
    }).toList();
    emit(state.copyWith(files: newFiles));
  }

  void _onSetViewFilter(SetViewFilter event, Emitter<LibraryState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onSearchFiles(SearchFiles event, Emitter<LibraryState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onOpenFile(OpenFile event, Emitter<LibraryState> emit) {
    // Navigation handled by UI layer
  }
}
