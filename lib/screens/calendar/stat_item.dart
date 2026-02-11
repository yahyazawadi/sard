import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  StatItem(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('StatItem fontSize value: 12, label: 8');
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }
}
