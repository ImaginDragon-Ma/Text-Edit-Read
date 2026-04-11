part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final double fontSize;
  final String encoding;
  final String theme; // 'light', 'dark', 'system'
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.fontSize = 16.0,
    this.encoding = 'utf-8',
    this.theme = 'system',
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    double? fontSize,
    String? encoding,
    String? theme,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      encoding: encoding ?? this.encoding,
      theme: theme ?? this.theme,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isDark => theme == 'dark';
  bool get isLight => theme == 'light';

  @override
  List<Object?> get props => [fontSize, encoding, theme, isLoading, error];
}
