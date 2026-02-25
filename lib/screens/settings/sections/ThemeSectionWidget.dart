import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/settings_provider.dart';

import '../../../custom/app_theme.dart';
import '../widets/section_header.dart';

class ThemeSectionWidget extends StatelessWidget {
  const ThemeSectionWidget({super.key});

  static final Map<FlexScheme, ColorScheme> _schemeColors = {
    for (final scheme in AppTheme.availableSchemes)
      scheme: FlexColorScheme.light(scheme: scheme).colorScheme!,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, prov, _) {
        return ExpansionTile(
          key: const PageStorageKey('themeStyle'),
          initiallyExpanded: prov.isSectionExpanded('themeStyle'),
          onExpansionChanged: (expanded) =>
              prov.setSectionExpanded('themeStyle', expanded),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          title: SectionHeader(title: t.themeStyle),
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 16),
          children: List.generate(AppTheme.availableSchemes.length, (index) {
            final scheme = AppTheme.availableSchemes[index];
            final cs = _schemeColors[scheme];

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
                      AppSettingsProvider.getThemeDisplayName(context, scheme),
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
        );
      },
    );
  }
}

class ColorSquare extends StatelessWidget {
  final Color color;

  const ColorSquare(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
    );
  }
}
