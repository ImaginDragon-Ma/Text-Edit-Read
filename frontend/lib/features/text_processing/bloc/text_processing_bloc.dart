import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/text_processor.dart';

part 'text_processing_event.dart';
part 'text_processing_state.dart';

class TextProcessingBloc extends Bloc<TextProcessingEvent, TextProcessingState> {
  TextProcessingBloc() : super(const TextProcessingState()) {
    on<CleanText>(_onCleanText);
  }

  void _onCleanText(CleanText event, Emitter<TextProcessingState> emit) {
    emit(state.copyWith(isProcessing: true, clearError: true));
    try {
      final cleaned = TextProcessor.cleanText(event.text);
      emit(state.copyWith(isProcessing: false, cleanedText: cleaned));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: e.toString()));
    }
  }
}
