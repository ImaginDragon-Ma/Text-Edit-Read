part of 'text_processing_bloc.dart';

abstract class TextProcessingEvent extends Equatable {
  const TextProcessingEvent();

  @override
  List<Object?> get props => [];
}

class CleanText extends TextProcessingEvent {
  final String text;
  const CleanText(this.text);

  @override
  List<Object?> get props => [text];
}
