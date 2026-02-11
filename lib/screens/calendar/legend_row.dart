import 'package:flutter/material.dart';

class LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const LegendRow(this.color, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
