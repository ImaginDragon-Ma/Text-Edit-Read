part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateFontSize extends SettingsEvent {
  final double fontSize;
  const UpdateFontSize(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}

class UpdateEncoding extends SettingsEvent {
  final String encoding;
  const UpdateEncoding(this.encoding);

  @override
  List<Object?> get props => [encoding];
}

class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}

class SetTheme extends SettingsEvent {
  final String theme;
  const SetTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}
