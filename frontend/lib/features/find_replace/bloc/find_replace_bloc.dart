import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/text_processor.dart';

part 'find_replace_event.dart';
part 'find_replace_state.dart';

class FindReplaceBloc extends Bloc<FindReplaceEvent, FindReplaceState> {
  FindReplaceBloc() : super(const FindReplaceState()) {
    on<FindNext>(_onFindNext);
    on<FindPrevious>(_onFindPrevious);
    on<ReplaceAll>(_onReplaceAll);
    on<ReplaceExceptQuotes>(_onReplaceExceptQuotes);
    on<ClearSearch>(_onClearSearch);
  }

  void _onFindNext(FindNext event, Emitter<FindReplaceState> emit) {
    if (event.searchTerm.isEmpty) return;

    final escaped = RegExp.escape(event.searchTerm);
    final matches = escaped.allMatches(event.text).toList();

    if (matches.isEmpty) {
      emit(state.copyWith(
        searchTerm: event.searchTerm,
        totalMatches: 0,
        currentMatchIndex: 0,
        clearMatch: true,
      ));
      return;
    }

    // Find next match after startPosition
    int? foundMatch;
    int foundIndex = 0;
    for (var i = 0; i < matches.length; i++) {
      if (matches[i].start >= event.startPosition) {
        foundMatch = matches[i];
        foundIndex = i;
        break;
      }
    }

    // Wrap around if at end
    foundMatch ??= matches.first;
    foundIndex = foundMatch == matches.first && matches.first.start < event.startPosition
        ? 0
        : foundIndex;

    emit(state.copyWith(
      searchTerm: event.searchTerm,
      totalMatches: matches.length,
      currentMatchIndex: foundIndex,
      matchPosition: foundMatch.start,
      matchLength: foundMatch.end - foundMatch.start,
    ));
  }

  void _onFindPrevious(FindPrevious event, Emitter<FindReplaceState> emit) {
    if (event.searchTerm.isEmpty) return;

    final escaped = RegExp.escape(event.searchTerm);
    final matches = escaped.allMatches(event.text).toList();

    if (matches.isEmpty) {
      emit(state.copyWith(
        searchTerm: event.searchTerm,
        totalMatches: 0,
        currentMatchIndex: 0,
        clearMatch: true,
      ));
      return;
    }

    // Find match before startPosition
    int? foundMatch;
    int foundIndex = 0;
    for (var i = matches.length - 1; i >= 0; i--) {
      if (matches[i].start < event.startPosition) {
        foundMatch = matches[i];
        foundIndex = i;
        break;
      }
    }

    // Wrap around
    foundMatch ??= matches.last;
    foundIndex = foundMatch == matches.last && matches.last.start >= event.startPosition
        ? matches.length - 1
        : foundIndex;

    emit(state.copyWith(
      searchTerm: event.searchTerm,
      totalMatches: matches.length,
      currentMatchIndex: foundIndex,
      matchPosition: foundMatch.start,
      matchLength: foundMatch.end - foundMatch.start,
    ));
  }

  void _onReplaceAll(ReplaceAll event, Emitter<FindReplaceState> emit) {
    if (event.oldWord.isEmpty) return;
    emit(state.copyWith(isProcessing: true, clearError: true, clearReplace: true));

    try {
      final lines = event.text.split('\n');
      final (result, count) = TextProcessor.replaceAllWord(lines, event.oldWord, event.newWord);
      emit(state.copyWith(
        isProcessing: false,
        replacedText: result.join('\n'),
        replaceCount: count,
      ));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: e.toString()));
    }
  }

  void _onReplaceExceptQuotes(ReplaceExceptQuotes event, Emitter<FindReplaceState> emit) {
    if (event.oldWord.isEmpty) return;
    emit(state.copyWith(isProcessing: true, clearError: true, clearReplace: true));

    try {
      final lines = event.text.split('\n');
      final (result, count) = TextProcessor.replaceExceptInQuotes(lines, event.oldWord, event.newWord);
      emit(state.copyWith(
        isProcessing: false,
        replacedText: result.join('\n'),
        replaceCount: count,
      ));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<FindReplaceState> emit) {
    emit(const FindReplaceState());
  }
}
