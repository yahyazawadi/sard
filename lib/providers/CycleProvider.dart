import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/models/entry_model.dart';

class CycleProvider extends ChangeNotifier {
  late Box<CycleEntry> _cyclesBox;
  Map<DateTime, CycleEntry> _entries = {};

  CycleProvider() {
    _init();
  }

  Future<void> _init() async {
    _cyclesBox = Hive.box<CycleEntry>('cycles');
    _loadEntries();
  }

  void _loadEntries() {
    _entries.clear();
    for (var key in _cyclesBox.keys) {
      final entry = _cyclesBox.get(key);
      if (entry != null) {
        _entries[entry.date] = entry;
      }
    }
    notifyListeners();
  }

  CycleEntry? getEntry(DateTime day) {
    return _entries[day];
  }

  void addOrUpdateEntry(DateTime day, CycleEntry entry) {
    _cyclesBox.put(day.toIso8601String(), entry);
    _entries[day] = entry;
    notifyListeners();
  }

  void addOrUpdatePhaseRange(DateTime start, DateTime end, String phase) {
    for (
      var d = start;
      d.isBefore(end.add(const Duration(days: 1)));
      d = d.add(const Duration(days: 1))
    ) {
      final existing = getEntry(d);
      if (existing != null) {
        existing.phase = phase;
        addOrUpdateEntry(d, existing);
      } else {
        addOrUpdateEntry(d, CycleEntry(date: d, phase: phase));
      }
    }
  }

  Color getPhaseColor(String? phase) {
    switch (phase) {
      case 'menstruation':
        return Colors.red[300]!;
      case 'follicular':
        return Colors.pink[200]!;
      case 'ovulation':
        return Colors.yellow[300]!;
      case 'luteal':
        return Colors.purple[300]!;
      default:
        return Colors.grey;
    }
  }

  int get currentCycleDay {
    // Logic: Find last menstruation start, count days since
    // Placeholder: Scan entries for last 'menstruation' start
    return 0; // Implement
  }

  int get daysUntilPeriod {
    // Logic: Predict based on averageCycleLength
    return 0; // Implement
  }

  double get averageCycleLength {
    // Logic: Average from past cycle starts
    return 28.0; // Default
  }

  // More methods as needed (deleteEntry, searchBySymptom, etc.)
}
