import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/settings_repo.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepo settingsRepo;

  SettingsCubit(this.settingsRepo)
      : super(
    SettingsState(
      isDarkMode: settingsRepo.getDarkModeSetting(),
    ),
  );

  Future<void> toggleDarkMode(bool isDarkMode) async {
    await settingsRepo.setDarkModeSetting(isDarkMode);
    emit(state.copyWith(isDarkMode: isDarkMode));
  }
}