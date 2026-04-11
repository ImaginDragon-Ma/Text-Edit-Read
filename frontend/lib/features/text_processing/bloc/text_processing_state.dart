part of 'text_processing_bloc.dart';

class TextProcessingState extends Equatable {
  final bool isProcessing;
  final String? cleanedText;
  final String? error;

  const TextProcessingState({
    this.isProcessing = false,
    this.cleanedText,
    this.error,
  });

  TextProcessingState copyWith({
    bool? isProcessing,
    String? cleanedText,
    String? error,
    bool clearError = false,
  }) {
    return TextProcessingState(
      isProcessing: isProcessing ?? this.isProcessing,
      cleanedText: cleanedText ?? this.cleanedText,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isProcessing, cleanedText, error];
}
