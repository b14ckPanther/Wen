import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.initialized,
  });

  factory SettingsState.initial() => const SettingsState(
    themeMode: ThemeMode.system,
    locale: Locale('en'),
    initialized: false,
  );

  final ThemeMode themeMode;
  final Locale locale;
  final bool initialized;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? initialized,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      initialized: initialized ?? this.initialized,
    );
  }
}
