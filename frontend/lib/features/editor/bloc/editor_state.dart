part of 'editor_bloc.dart';

class EditorState extends Equatable {
  final TextFile? currentFile;
  final String text;
  final double fontSize;
  final int cursorPosition;
  final int selectionStart;
  final int selectionEnd;
  final int currentChapter;
  final int totalChapters;
  final int wordCount;
  final int selectedCharCount;
  final bool isLoading;
  final String? error;
  final bool isDarkTheme;
  final List<TextFile> openFiles;

  const EditorState({
    this.currentFile,
    this.text = '',
    this.fontSize = 16.0,
    this.cursorPosition = 0,
    this.selectionStart = -1,
    this.selectionEnd = -1,
    this.currentChapter = -1,
    this.totalChapters = 0,
    this.wordCount = 0,
    this.selectedCharCount = 0,
    this.isLoading = false,
    this.error,
    this.isDarkTheme = false,
    this.openFiles = const [],
  });

  EditorState copyWith({
    TextFile? currentFile,
    String? text,
    double? fontSize,
    int? cursorPosition,
    int? selectionStart,
    int? selectionEnd,
    int? currentChapter,
    int? totalChapters,
    int? wordCount,
    int? selectedCharCount,
    bool? isLoading,
    String? error,
    bool? isDarkTheme,
    List<TextFile>? openFiles,
    bool clearError = false,
  }) {
    return EditorState(
      currentFile: currentFile ?? this.currentFile,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      selectionStart: selectionStart ?? this.selectionStart,
      selectionEnd: selectionEnd ?? this.selectionEnd,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters ?? this.totalChapters,
      wordCount: wordCount ?? this.wordCount,
      selectedCharCount: selectedCharCount ?? this.selectedCharCount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      openFiles: openFiles ?? this.openFiles,
    );
  }

  @override
  List<Object?> get props => [
        currentFile, text, fontSize, cursorPosition, selectionStart,
        selectionEnd, currentChapter, totalChapters, wordCount,
        selectedCharCount, isLoading, error, isDarkTheme, openFiles,
      ];
}
