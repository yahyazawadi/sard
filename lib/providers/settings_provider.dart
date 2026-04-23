import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  double _textScale = 1.0;
  bool _hasTextScaleOverride = false;
  String _fontFamily = 'DG-Sahabah'; // Default font

  
  set hasTextScaleOverride(bool value) {
    _hasTextScaleOverride = value;
    notifyListeners();
  }

  static const Map<String, bool> _defaultExpansionStates = {
    'themeStyle': true,
    'appearanceMode': false,
    'language': false,
  };
  Map<String, bool> _expansionStates = Map<String, bool>.from(
    _defaultExpansionStates,
  );

  AppSettingsProvider(this._prefs) {
    _loadSettings();
  }

  void _loadSettings() {
    // Theme mode
    final modeIndex = _prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[modeIndex];

    // Locale
    final lang = _prefs.getString('language') ?? 'en';
    _locale = Locale(lang);

    // Text scale
    _hasTextScaleOverride = _prefs.containsKey('textScale');
    if (_hasTextScaleOverride) {
      _textScale = _prefs.getDouble('textScale') ?? 1.0;
    }

    // Font family
    _fontFamily = _prefs.getString('fontFamily') ?? 'DG-Sahabah';

    final savedExpansion = _prefs.getString('expansion_states');
    if (savedExpansion != null) {
      try {
        final decoded = jsonDecode(savedExpansion);
        if (decoded is Map) {
          final map = decoded.map(
            (key, value) => MapEntry(key.toString(), value == true),
          );
          _expansionStates = {..._defaultExpansionStates, ...map};
        }
      } catch (_) {
        _expansionStates = Map<String, bool>.from(_defaultExpansionStates);
      }
    } else {
      _expansionStates = Map<String, bool>.from(_defaultExpansionStates);
    }

    notifyListeners();
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  double get textScale => _textScale;
  bool get hasTextScaleOverride => _hasTextScaleOverride;
  String get fontFamily => _fontFamily;
  bool isSectionExpanded(String key) => _expansionStates[key] ?? false;


  // ── Setters ────────────────────────────────────────────────────────────────
  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  set locale(Locale loc) {
    _locale = loc;
    _prefs.setString('language', loc.languageCode);
    notifyListeners();
  }

  set textScale(double scale) {
    _textScale = scale.clamp(0.8, 2.0);
    _hasTextScaleOverride = true;
    _prefs.setDouble('textScale', _textScale);
    notifyListeners();
  }

  set fontFamily(String family) {
    _fontFamily = family;
    _prefs.setString('fontFamily', family);
    notifyListeners();
  }

  void resetTextScale() {
    _hasTextScaleOverride = false;
    _textScale = 1.0;
    _prefs.remove('textScale');
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await Future.wait([
      _prefs.remove('themeMode'),
      _prefs.remove('language'),
      _prefs.remove('textScale'),
      _prefs.remove('fontFamily'),
      _prefs.remove('expansion_states'),
    ]);
    _loadSettings();
  }

  void setSectionExpanded(String key, bool expanded) {
    if (_expansionStates[key] == expanded) return;
    _expansionStates[key] = expanded;
    _saveExpansionStates();
    notifyListeners();
  }

  void _saveExpansionStates() {
    _prefs.setString('expansion_states', jsonEncode(_expansionStates));
  }
}
