import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repo;

  SettingsBloc({required SettingsRepository repo})
      : _repo = repo,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateEncoding>(_onUpdateEncoding);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    emit(state.copyWith(isLoading: true));
    try {
      emit(SettingsState(
        fontSize: _repo.getFontSize(),
        encoding: _repo.getEncoding(),
        theme: _repo.getTheme(),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateFontSize(UpdateFontSize event, Emitter<SettingsState> emit) {
    final clamped = event.fontSize.clamp(12.0, 72.0);
    _repo.setFontSize(clamped);
    emit(state.copyWith(fontSize: clamped));
  }

  void _onUpdateEncoding(UpdateEncoding event, Emitter<SettingsState> emit) {
    _repo.setEncoding(event.encoding);
    emit(state.copyWith(encoding: event.encoding));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) {
    final newTheme = state.isDark
        ? 'light'
        : state.isLight
            ? 'system'
            : 'dark';
    _repo.setTheme(newTheme);
    emit(state.copyWith(theme: newTheme));
  }

  void _onSetTheme(SetTheme event, Emitter<SettingsState> emit) {
    _repo.setTheme(event.theme);
    emit(state.copyWith(theme: event.theme));
  }
}
