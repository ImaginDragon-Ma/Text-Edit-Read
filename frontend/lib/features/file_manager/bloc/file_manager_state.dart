part of 'file_manager_bloc.dart';

import '../../../core/models/text_file.dart';

class FileManagerState extends Equatable {
  final List<TextFile> recentFiles;
  final bool isLoading;
  final String? error;

  const FileManagerState({
    this.recentFiles = const [],
    this.isLoading = false,
    this.error,
  });

  FileManagerState copyWith({
    List<TextFile>? recentFiles,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FileManagerState(
      recentFiles: recentFiles ?? this.recentFiles,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [recentFiles, isLoading, error];
}
