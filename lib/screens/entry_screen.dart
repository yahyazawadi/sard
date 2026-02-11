// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/providers/cycle_provider.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key, required DateTime selectedDate});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Entry Screen')),
      body: Center(child: Text('Cycle entries will be displayed here.')),
    );
  }
}
