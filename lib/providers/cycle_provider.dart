import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/models/entry_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CycleProvider extends ChangeNotifier {
  late Box<CycleEntry> _cyclesBox;
  Map<DateTime, CycleEntry> _entries = {};
  Map<DateTime, CycleEntry> get entries =>
      Map.unmodifiable(_entries); // Add this getter (unmodifiable for safety)
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

  List<DateRange> getDateRanges() {
    final ranges = <DateRange>[];
    final sorted = entries.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.isEmpty) return ranges;

    DateTime? currentStart = sorted.first.date;
    String? currentPhase = sorted.first.phase;
    Color currentColor = getPhaseColor(currentPhase);

    for (int i = 1; i < sorted.length; i++) {
      final entry = sorted[i];
      if (entry.phase == currentPhase &&
          entry.date.difference(sorted[i - 1].date).inDays == 1) {
        // Consecutive same phase
        continue; // Extend range
      } else {
        // End current range, start new
        ranges.add(
          DateRange(
            start: currentStart!,
            end: sorted[i - 1].date,
            color: currentColor,
            phase: currentPhase,
          ),
        );
        currentStart = entry.date;
        currentPhase = entry.phase;
        currentColor = getPhaseColor(currentPhase);
      }
    }
    // Add last range
    ranges.add(
      DateRange(
        start: currentStart!,
        end: sorted.last.date,
        color: currentColor,
        phase: currentPhase,
      ),
    );
    return ranges;
  }

  Color _getPhaseColor(String? phase) {
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
        return Colors.grey[400]!;
    }
  }
}
