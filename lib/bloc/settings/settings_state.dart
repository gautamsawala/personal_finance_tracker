import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;

  const SettingsState({
    required this.isDarkMode,
  });

  SettingsState copyWith({
    bool? isDarkMode,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [isDarkMode];
}