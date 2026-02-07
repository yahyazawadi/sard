import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import '../l10n/app_localizations.dart'; // ← import for translations

class AppSettingsProvider extends ChangeNotifier {
  late Box _settingsBox;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  double _textScale = 1.0;
  bool _hasTextScaleOverride = false;
  FlexScheme _selectedScheme = FlexScheme.mandyRed;

  AppSettingsProvider(this._settingsBox) {
    _loadSettings();
  }

  // ── Theme display names map ────────────────────────────────────────────────
  // This is the source of truth for nice, translatable theme names
  static String getThemeDisplayName(BuildContext context, FlexScheme scheme) {
    final t = AppLocalizations.of(context)!;

    // Map each enum value → translation key
    switch (scheme) {
      case FlexScheme.mandyRed:
        return t.themeMandyRed;
      case FlexScheme.redWine:
        return t.themeRedWine;
      case FlexScheme.deepPurple:
        return t.themeDeepPurple;
      case FlexScheme.sakura:
        return t.themeSakura;
      case FlexScheme.purpleBrown:
        return t.themePurpleBrown;
      case FlexScheme.jungle:
        return t.themeJungle;
      case FlexScheme.shadBlue:
        return t.themeShadBlue;
      case FlexScheme.sanJuanBlue:
        return t.themeSanJuanBlue;
      case FlexScheme.indigo:
        return t.themeIndigo;
      case FlexScheme.brandBlue:
        return t.themeBrandBlue;
      case FlexScheme.purpleM3:
        return t.themePurpleM3;
      default:
        return scheme.name; // fallback if new schemes added
    }
  }

  void _loadSettings() {
    // Theme mode
    _themeMode =
        ThemeMode.values[_settingsBox.get(
          'themeMode',
          defaultValue: ThemeMode.system.index,
        )];

    // Locale
    final lang = _settingsBox.get('language', defaultValue: 'en') as String?;
    _locale = Locale(lang ?? 'en');

    // Text scale
    _hasTextScaleOverride = _settingsBox.containsKey('textScale');
    if (_hasTextScaleOverride) {
      _textScale = (_settingsBox.get('textScale') as num?)?.toDouble() ?? 1.0;
    }

    // Selected theme scheme (still saved as raw enum name string)
    final schemeName =
        _settingsBox.get('themeScheme', defaultValue: 'mandyRed') as String?;
    _selectedScheme =
        _schemeFromName(schemeName ?? 'mandyRed') ?? FlexScheme.mandyRed;

    notifyListeners();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get textScale => _textScale;
  bool get hasTextScaleOverride => _hasTextScaleOverride;
  FlexScheme get selectedScheme => _selectedScheme;

  // ── Setters ────────────────────────────────────────────────────────────────

  set hasTextScaleOverride(bool value) {
    _hasTextScaleOverride = value;
    if (!value) {
      _textScale = 1.0;
      _settingsBox.delete('textScale');
    }
    notifyListeners();
  }

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _settingsBox.put('themeMode', mode.index);
    notifyListeners();
  }

  set locale(Locale loc) {
    _locale = loc;
    _settingsBox.put('language', loc.languageCode);
    notifyListeners();
  }

  set textScale(double scale) {
    _textScale = scale.clamp(0.8, 2.0);
    _hasTextScaleOverride = true;
    _settingsBox.put('textScale', scale);
    notifyListeners();
  }

  void resetTextScale() {
    _hasTextScaleOverride = false;
    _textScale = 1.0;
    _settingsBox.delete('textScale');
    notifyListeners();
  }

  void setScheme(FlexScheme scheme) {
    _selectedScheme = scheme;
    _settingsBox.put('themeScheme', _nameFromScheme(scheme));
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _settingsBox.deleteAll([
      'themeMode',
      'language',
      'textScale',
      'themeScheme',
    ]);
    _loadSettings();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  FlexScheme? _schemeFromName(String name) {
    const map = {
      'mandyRed': FlexScheme.mandyRed,
      'redWine': FlexScheme.redWine,
      'deepPurple': FlexScheme.deepPurple,
      'sakura': FlexScheme.sakura,
      'purpleBrown': FlexScheme.purpleBrown,
      'jungle': FlexScheme.jungle,
      'shadBlue': FlexScheme.shadBlue,
      'sanJuanBlue': FlexScheme.sanJuanBlue,
      'indigo': FlexScheme.indigo,
      'brandBlue': FlexScheme.brandBlue,
      'purpleM3': FlexScheme.purpleM3,
    };
    return map[name];
  }

  String _nameFromScheme(FlexScheme scheme) {
    const reverseMap = {
      FlexScheme.mandyRed: 'mandyRed',
      FlexScheme.redWine: 'redWine',
      FlexScheme.deepPurple: 'deepPurple',
      FlexScheme.sakura: 'sakura',
      FlexScheme.purpleBrown: 'purpleBrown',
      FlexScheme.jungle: 'jungle',
      FlexScheme.shadBlue: 'shadBlue',
      FlexScheme.sanJuanBlue: 'sanJuanBlue',
      FlexScheme.indigo: 'indigo',
      FlexScheme.brandBlue: 'brandBlue',
      FlexScheme.purpleM3: 'purpleM3',
    };
    return reverseMap[scheme] ?? 'mandyRed';
  }
}
