import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/chapter_detector.dart';
import '../../../core/file_handler.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/text_file.dart';

part 'editor_event.dart';
part 'editor_state.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  List<Chapter> _chapters = [];

  EditorBloc() : super(const EditorState()) {
    on<LoadFile>(_onLoadFile);
    on<UpdateText>(_onUpdateText);
    on<SaveFile>(_onSaveFile);
    on<SaveFileAs>(_onSaveFileAs);
    on<Undo>(_onUndo);
    on<SetFontSize>(_onSetFontSize);
    on<CursorChanged>(_onCursorChanged);
    on<OpenFilePicker>(_onOpenFilePicker);
    on<CloseTab>(_onCloseTab);
    on<SwitchTab>(_onSwitchTab);
    on<ToggleTheme>(_onToggleTheme);
  }

  void _onLoadFile(LoadFile event, Emitter<EditorState> emit) {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final encoding = FileHandler.detectEncoding(event.filePath);
      final content = FileHandler.readFile(event.filePath, encoding: encoding);
      final fileName = event.filePath.split('/').last;

      final textFile = TextFile(
        filePath: event.filePath,
        fileName: fileName,
        content: content,
        encoding: encoding,
      );

      _chapters = ChapterDetector.detectChapters(content);

      final newOpenFiles = [...state.openFiles];
      final existingIndex = newOpenFiles.indexWhere(
        (f) => f.filePath == event.filePath,
      );
      if (existingIndex >= 0) {
        newOpenFiles[existingIndex] = textFile;
      } else {
        newOpenFiles.add(textFile);
      }

      emit(state.copyWith(
        currentFile: textFile,
        text: content,
        openFiles: newOpenFiles,
        totalChapters: _chapters.length,
        wordCount: content.replaceAll(RegExp(r'\s'), '').length,
        isLoading: false,
        currentChapter: 0,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateText(UpdateText event, Emitter<EditorState> emit) {
    emit(state.copyWith(
      text: event.text,
      currentFile: state.currentFile?..content = event.text..isModified = true,
      wordCount: event.text.replaceAll(RegExp(r'\s'), '').length,
    ));

    _chapters = ChapterDetector.detectChapters(event.text);
    emit(state.copyWith(
      totalChapters: _chapters.length,
      currentChapter: ChapterDetector.findCurrentChapter(_chapters, state.cursorPosition),
    ));
  }

  Future<void> _onSaveFile(SaveFile event, Emitter<EditorState> emit) async {
    final file = state.currentFile;
    if (file == null) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      FileHandler.saveFile(file.filePath, file.content);
      file.isModified = false;
      emit(state.copyWith(isLoading: false, currentFile: file));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSaveFileAs(SaveFileAs event, Emitter<EditorState> emit) async {
    final content = state.text;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      FileHandler.saveFile(event.filePath, content);
      final fileName = event.filePath.split('/').last;
      final textFile = TextFile(
        filePath: event.filePath,
        fileName: fileName,
        content: content,
      );

      final newOpenFiles = [...state.openFiles];
      final existingIndex = newOpenFiles.indexWhere(
        (f) => f.filePath == event.filePath,
      );
      if (existingIndex >= 0) {
        newOpenFiles[existingIndex] = textFile;
      } else {
        newOpenFiles.add(textFile);
      }

      emit(state.copyWith(
        currentFile: textFile,
        openFiles: newOpenFiles,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUndo(Undo event, Emitter<EditorState> emit) {
    // Undo is handled by the TextField controller; this is a placeholder
    // for future undo stack implementation.
  }

  void _onSetFontSize(SetFontSize event, Emitter<EditorState> emit) {
    final clamped = event.size.clamp(12.0, 72.0);
    emit(state.copyWith(fontSize: clamped));
  }

  void _onCursorChanged(CursorChanged event, Emitter<EditorState> emit) {
    final selectedChars = (event.selectionStart >= 0 && event.selectionEnd >= 0)
        ? (event.selectionEnd - event.selectionStart).abs()
        : 0;
    final chapterIndex = ChapterDetector.findCurrentChapter(_chapters, event.position);
    emit(state.copyWith(
      cursorPosition: event.position,
      selectionStart: event.selectionStart,
      selectionEnd: event.selectionEnd,
      selectedCharCount: selectedChars,
      currentChapter: chapterIndex,
    ));
  }

  Future<void> _onOpenFilePicker(OpenFilePicker event, Emitter<EditorState> emit) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'text'],
    );
    if (result != null && result.files.single.path != null) {
      add(LoadFile(result.files.single.path!));
    }
  }

  void _onCloseTab(CloseTab event, Emitter<EditorState> emit) {
    final newOpenFiles = state.openFiles.where(
      (f) => f.filePath != event.filePath,
    ).toList();

    if (state.currentFile?.filePath == event.filePath) {
      final newCurrent = newOpenFiles.isNotEmpty ? newOpenFiles.last : null;
      emit(state.copyWith(openFiles: newOpenFiles, currentFile: newCurrent));
      if (newCurrent != null) {
        add(LoadFile(newCurrent.filePath));
      }
    } else {
      emit(state.copyWith(openFiles: newOpenFiles));
    }
  }

  void _onSwitchTab(SwitchTab event, Emitter<EditorState> emit) {
    final file = state.openFiles.firstWhere(
      (f) => f.filePath == event.filePath,
      orElse: () => state.currentFile!,
    );
    if (file != state.currentFile) {
      add(LoadFile(file.filePath));
    }
  }

  void _onToggleTheme(ToggleTheme event, Emitter<EditorState> emit) {
    emit(state.copyWith(isDarkTheme: !state.isDarkTheme));
  }
}
