import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SystemLocale {
  static Locale getDefault() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final langCode = systemLocale.languageCode;

    if (langCode == 'ar') {
      return const Locale('ar');
    }

    return const Locale('en');
  }
}
