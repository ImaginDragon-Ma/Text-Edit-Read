part of 'file_manager_bloc.dart';

abstract class FileManagerEvent extends Equatable {
  const FileManagerEvent();

  @override
  List<Object?> get props => [];
}

class OpenFile extends FileManagerEvent {
  const OpenFile();
}

class NewFile extends FileManagerEvent {
  const NewFile();
}

class CloseFile extends FileManagerEvent {
  final String filePath;
  const CloseFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class LoadRecentFiles extends FileManagerEvent {
  const LoadRecentFiles();
}

class RemoveRecentFile extends FileManagerEvent {
  final String filePath;
  const RemoveRecentFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
