import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/providers/settings_provider.dart';

import '../widets/section_header.dart';

class TextSizeSectionWidget extends StatelessWidget {
  const TextSizeSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, prov, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: t.textSize),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prov.hasTextScaleOverride
                        ? '${prov.textScale.toStringAsFixed(1)}×'
                        : t.usingSystemSize,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface,
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
                      child: Text(
                        t.resetToSystem,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontFamily: 'DG Sahabah',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
