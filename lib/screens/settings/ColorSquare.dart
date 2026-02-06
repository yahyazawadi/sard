import 'package:flutter/material.dart';

class ColorSquare extends StatelessWidget {
  final Color color;

  const ColorSquare(this.color);

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