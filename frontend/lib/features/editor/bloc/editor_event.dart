part of 'editor_bloc.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadFile extends EditorEvent {
  final String filePath;
  const LoadFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UpdateText extends EditorEvent {
  final String text;
  const UpdateText(this.text);

  @override
  List<Object?> get props => [text];
}

class SaveFile extends EditorEvent {
  const SaveFile();
}

class SaveFileAs extends EditorEvent {
  final String filePath;
  const SaveFileAs(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class Undo extends EditorEvent {
  const Undo();
}

class SetFontSize extends EditorEvent {
  final double size;
  const SetFontSize(this.size);

  @override
  List<Object?> get props => [size];
}

class CursorChanged extends EditorEvent {
  final int position;
  final int selectionStart;
  final int selectionEnd;
  const CursorChanged({
    required this.position,
    this.selectionStart = -1,
    this.selectionEnd = -1,
  });

  @override
  List<Object?> get props => [position, selectionStart, selectionEnd];
}

class OpenFilePicker extends EditorEvent {
  const OpenFilePicker();
}

class CloseTab extends EditorEvent {
  final String filePath;
  const CloseTab(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class SwitchTab extends EditorEvent {
  final String filePath;
  const SwitchTab(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ToggleTheme extends EditorEvent {
  const ToggleTheme();
}
