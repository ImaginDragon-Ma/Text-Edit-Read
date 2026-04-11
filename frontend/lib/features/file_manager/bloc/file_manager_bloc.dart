import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/text_file.dart';
import '../../../data/storage/local_storage.dart';

part 'file_manager_event.dart';
part 'file_manager_state.dart';

class FileManagerBloc extends Bloc<FileManagerEvent, FileManagerState> {
  final LocalStorage _storage;
  static const String _recentFilesKey = 'recent_files';
  static const int _maxRecentFiles = 20;

  FileManagerBloc({required LocalStorage storage})
      : _storage = storage,
        super(const FileManagerState()) {
    on<OpenFile>(_onOpenFile);
    on<NewFile>(_onNewFile);
    on<CloseFile>(_onCloseFile);
    on<LoadRecentFiles>(_onLoadRecentFiles);
    on<RemoveRecentFile>(_onRemoveRecentFile);
  }

  void _onOpenFile(OpenFile event, Emitter<FileManagerState> emit) {
    // Actual file opening is handled by EditorBloc
  }

  void _onNewFile(NewFile event, Emitter<FileManagerState> emit) {
    // New file creation handled by EditorBloc
  }

  void _onCloseFile(CloseFile event, Emitter<FileManagerState> emit) {
    // Tab close handled by EditorBloc
  }

  void _onLoadRecentFiles(LoadRecentFiles event, Emitter<FileManagerState> emit) {
    emit(state.copyWith(isLoading: true));
    try {
      final data = _storage.getObject<List>(_recentFilesKey);
      if (data == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }
      final files = data.map((item) {
        final map = item as Map;
        return TextFile(
          filePath: map['file_path'] as String,
          fileName: map['file_name'] as String,
          content: '',
          encoding: map['encoding'] as String?,
        );
      }).toList();
      emit(state.copyWith(isLoading: false, recentFiles: files));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onRemoveRecentFile(RemoveRecentFile event, Emitter<FileManagerState> emit) {
    final updated = state.recentFiles
        .where((f) => f.filePath != event.filePath)
        .toList();
    emit(state.copyWith(recentFiles: updated));
    _saveRecentFiles(updated);
  }

  /// Add a file to recent files list
  void addRecentFile(TextFile file) {
    final updated = state.recentFiles.where((f) => f.filePath != file.filePath).toList();
    updated.insert(0, file);
    if (updated.length > _maxRecentFiles) {
      updated.removeRange(_maxRecentFiles, updated.length);
    }
    emit(state.copyWith(recentFiles: updated));
    _saveRecentFiles(updated);
  }

  void _saveRecentFiles(List<TextFile> files) {
    final data = files.map((f) => {
      'file_path': f.filePath,
      'file_name': f.fileName,
      'encoding': f.encoding,
    }).toList();
    _storage.setObject(_recentFilesKey, data);
  }
}
