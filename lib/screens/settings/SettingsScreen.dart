import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:tracker/providers/theme_provider.dart';

import '../../custom/app_theme.dart';
import 'SectionHeader.dart';
import 'ColorSquare.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppSettingsProvider>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'DG Sahabah'),
      ),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // === Theme Style ===
            const SectionHeader(title: 'Theme Style'),
            ...List.generate(AppTheme.availableSchemes.length, (index) {
              final scheme = AppTheme.availableSchemes[index];
              final cs = FlexColorScheme.light(scheme: scheme).colorScheme;

              return RadioListTile<FlexScheme>(
                value: scheme,
                groupValue: prov.selectedScheme,
                dense: true,
                visualDensity: const VisualDensity(vertical: -2.0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: [
                          ColorSquare(cs?.primary ?? Colors.transparent),
                          ColorSquare(cs?.secondary ?? Colors.transparent),
                          ColorSquare(cs?.error ?? Colors.transparent),
                          ColorSquare(cs?.surface ?? Colors.transparent),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        scheme.name.replaceAllMapped(
                          RegExp(r'(?<!^)(?=[A-Z])'),
                          (m) => ' ${m.group(0)}',
                        ),
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                onChanged: (newScheme) {
                  if (newScheme != null) prov.setScheme(newScheme);
                },
              );
            }),

            const SizedBox(height: 32),

            // === Appearance Mode ===
            const SectionHeader(title: 'Appearance Mode'),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: prov.themeMode,
              title: const Text('System (auto)'),
              onChanged: (mode) {
                if (mode != null) prov.themeMode = mode;
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: prov.themeMode,
              title: const Text('Light'),
              onChanged: (mode) {
                if (mode != null) prov.themeMode = mode;
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: prov.themeMode,
              title: const Text('Dark'),
              onChanged: (mode) {
                if (mode != null) prov.themeMode = mode;
              },
            ),

            const SizedBox(height: 32),

            // === Language ===
            const SectionHeader(title: 'Language'),
            RadioListTile<String>(
              value: 'en',
              groupValue: prov.locale.languageCode,
              title: const Text('English'),
              onChanged: (code) {
                if (code != null) prov.locale = Locale(code);
              },
            ),
            RadioListTile<String>(
              value: 'ar',
              groupValue: prov.locale.languageCode,
              title: const Text('العربية'),
              onChanged: (code) {
                if (code != null) prov.locale = Locale(code);
              },
            ),

            const SizedBox(height: 32),

            // === Text Size ===
            const SectionHeader(title: 'Text Size'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prov.hasTextScaleOverride
                        ? '${prov.textScale.toStringAsFixed(1)}×'
                        : 'Using system size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontFamily: 'DG Sahabah',
                    ),
                  ),
                  Slider(
                    value: prov.hasTextScaleOverride ? prov.textScale : 1.0,
                    min: 0.8,
                    max: 2.0,
                    divisions: 12,
                    label: prov.hasTextScaleOverride
                        ? prov.textScale.toStringAsFixed(1)
                        : null,
                    onChanged: (value) {
                      prov.textScale = value;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: prov.resetTextScale,
                      child: const Text(
                        'Reset to System',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontFamily: 'DG Sahabah',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
