import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prefs_provider.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final double textScale;
  final bool hasTextScaleOverride;
  final String fontFamily;
  final String selectedBranch;
  final Map<String, bool> expansionStates;

  AppSettings({
    required this.themeMode,
    required this.locale,
    required this.textScale,
    required this.hasTextScaleOverride,
    required this.fontFamily,
    required this.selectedBranch,
    required this.expansionStates,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    double? textScale,
    bool? hasTextScaleOverride,
    String? fontFamily,
    String? selectedBranch,
    Map<String, bool>? expansionStates,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      textScale: textScale ?? this.textScale,
      hasTextScaleOverride: hasTextScaleOverride ?? this.hasTextScaleOverride,
      fontFamily: fontFamily ?? this.fontFamily,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      expansionStates: expansionStates ?? this.expansionStates,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<AppSettings> {
  static const Map<String, bool> _defaultExpansionStates = {
    'themeStyle': true,
    'appearanceMode': false,
    'language': false,
  };

  @override
  AppSettings build() {
    final prefs = ref.watch(prefsProvider);
    
    // Theme mode
    final modeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[modeIndex];

    // Locale
    final lang = prefs.getString('language') ?? 'en';
    final locale = Locale(lang);

    // Text scale
    final hasTextScaleOverride = prefs.containsKey('textScale');
    final textScale = hasTextScaleOverride ? (prefs.getDouble('textScale') ?? 1.0) : 1.0;

    // Font family
    final fontFamily = prefs.getString('fontFamily') ?? 'DG-Sahabah';

    // Branch
    final selectedBranch = prefs.getString('selectedBranch') ?? 'nablus';

    // Expansion states
    Map<String, bool> expansionStates = Map<String, bool>.from(_defaultExpansionStates);
    final savedExpansion = prefs.getString('expansion_states');
    if (savedExpansion != null) {
      try {
        final decoded = jsonDecode(savedExpansion);
        if (decoded is Map) {
          final map = decoded.map((key, value) => MapEntry(key.toString(), value == true));
          expansionStates = {..._defaultExpansionStates, ...map};
        }
      } catch (_) {}
    }

    return AppSettings(
      themeMode: themeMode,
      locale: locale,
      textScale: textScale,
      hasTextScaleOverride: hasTextScaleOverride,
      fontFamily: fontFamily,
      selectedBranch: selectedBranch,
      expansionStates: expansionStates,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    ref.read(prefsProvider).setInt('themeMode', mode.index);
  }

  void setLocale(Locale loc) {
    state = state.copyWith(locale: loc);
    ref.read(prefsProvider).setString('language', loc.languageCode);
  }

  void setTextScale(double scale) {
    final newScale = scale.clamp(0.8, 2.0);
    state = state.copyWith(textScale: newScale, hasTextScaleOverride: true);
    ref.read(prefsProvider).setDouble('textScale', newScale);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
    ref.read(prefsProvider).setString('fontFamily', family);
  }

  void setBranch(String branch) {
    state = state.copyWith(selectedBranch: branch);
    ref.read(prefsProvider).setString('selectedBranch', branch);
  }

  void resetTextScale() {
    state = state.copyWith(textScale: 1.0, hasTextScaleOverride: false);
    ref.read(prefsProvider).remove('textScale');
  }

  void setSectionExpanded(String key, bool expanded) {
    final newStates = Map<String, bool>.from(state.expansionStates);
    newStates[key] = expanded;
    state = state.copyWith(expansionStates: newStates);
    ref.read(prefsProvider).setString('expansion_states', jsonEncode(newStates));
  }

  Future<void> resetToDefaults() async {
    final prefs = ref.read(prefsProvider);
    await Future.wait([
      prefs.remove('themeMode'),
      prefs.remove('language'),
      prefs.remove('textScale'),
      prefs.remove('fontFamily'),
      prefs.remove('expansion_states'),
      prefs.remove('selectedBranch'),
    ]);
    ref.invalidateSelf();
  }
}
