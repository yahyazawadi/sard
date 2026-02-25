import 'package:flutter/material.dart';
import 'sections/ThemeSectionWidget.dart';
import 'sections/ModeSectionWidget.dart';
import 'sections/LanguageSectionWidget.dart';
import 'sections/WeekendSectionWidget.dart';
import 'sections/TextSizeSectionWidget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const ThemeSectionWidget(),
      const SizedBox(height: 8),
      const ModeSectionWidget(),
      const SizedBox(height: 8),
      const LanguageSectionWidget(),
      const SizedBox(height: 8),
      const WeekendSectionWidget(),
      const SizedBox(height: 16),
      const TextSizeSectionWidget(),
      const SizedBox(height: 40),
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'DG Sahabah'),
      ),
      child: Scaffold(
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        ),
      ),
    );
  }
}
