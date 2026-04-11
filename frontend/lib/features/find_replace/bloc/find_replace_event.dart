part of 'find_replace_bloc.dart';

abstract class FindReplaceEvent extends Equatable {
  const FindReplaceEvent();

  @override
  List<Object?> get props => [];
}

class FindNext extends FindReplaceEvent {
  final String text;
  final String searchTerm;
  final int startPosition;
  const FindNext({
    required this.text,
    required this.searchTerm,
    this.startPosition = 0,
  });

  @override
  List<Object?> get props => [text, searchTerm, startPosition];
}

class FindPrevious extends FindReplaceEvent {
  final String text;
  final String searchTerm;
  final int startPosition;
  const FindPrevious({
    required this.text,
    required this.searchTerm,
    this.startPosition = 0,
  });

  @override
  List<Object?> get props => [text, searchTerm, startPosition];
}

class ReplaceAll extends FindReplaceEvent {
  final String text;
  final String oldWord;
  final String newWord;
  const ReplaceAll({
    required this.text,
    required this.oldWord,
    required this.newWord,
  });

  @override
  List<Object?> get props => [text, oldWord, newWord];
}

class ReplaceExceptQuotes extends FindReplaceEvent {
  final String text;
  final String oldWord;
  final String newWord;
  const ReplaceExceptQuotes({
    required this.text,
    required this.oldWord,
    required this.newWord,
  });

  @override
  List<Object?> get props => [text, oldWord, newWord];
}

class ClearSearch extends FindReplaceEvent {
  const ClearSearch();
}
