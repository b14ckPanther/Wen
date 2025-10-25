import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import '../data/settings_repository.dart';
import 'settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._repository) : super(SettingsState.initial()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    final theme = _repository.loadThemeMode();
    final locale = _repository.loadLocale();
    state = state.copyWith(themeMode: theme, locale: locale, initialized: true);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.saveThemeMode(mode);
  }

  Future<void> updateLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _repository.saveLocale(locale);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('Must override settingsRepositoryProvider in main');
});

final settingsControllerProvider =
    legacy.StateNotifierProvider<SettingsController, SettingsState>((ref) {
      final repository = ref.watch(settingsRepositoryProvider);
      return SettingsController(repository);
    });
