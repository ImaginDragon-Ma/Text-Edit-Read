part of 'find_replace_bloc.dart';

class FindReplaceState extends Equatable {
  final String searchTerm;
  final int currentMatchIndex;
  final int totalMatches;
  final int? matchPosition;
  final int? matchLength;
  final bool isProcessing;
  final String? replacedText;
  final int replaceCount;
  final String? error;

  const FindReplaceState({
    this.searchTerm = '',
    this.currentMatchIndex = 0,
    this.totalMatches = 0,
    this.matchPosition,
    this.matchLength,
    this.isProcessing = false,
    this.replacedText,
    this.replaceCount = 0,
    this.error,
  });

  FindReplaceState copyWith({
    String? searchTerm,
    int? currentMatchIndex,
    int? totalMatches,
    int? matchPosition,
    int? matchLength,
    bool? isProcessing,
    String? replacedText,
    int? replaceCount,
    String? error,
    bool clearError = false,
    bool clearMatch = false,
    bool clearReplace = false,
  }) {
    return FindReplaceState(
      searchTerm: searchTerm ?? this.searchTerm,
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      totalMatches: totalMatches ?? this.totalMatches,
      matchPosition: clearMatch ? null : (matchPosition ?? this.matchPosition),
      matchLength: clearMatch ? null : (matchLength ?? this.matchLength),
      isProcessing: isProcessing ?? this.isProcessing,
      replacedText: clearReplace ? null : (replacedText ?? this.replacedText),
      replaceCount: clearReplace ? 0 : (replaceCount ?? this.replaceCount),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        searchTerm, currentMatchIndex, totalMatches,
        matchPosition, matchLength, isProcessing,
        replacedText, replaceCount, error,
      ];
}
