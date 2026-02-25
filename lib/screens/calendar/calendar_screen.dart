import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/entry_model.dart';
import 'package:tracker/providers/cycle_provider.dart';
import 'package:tracker/screens/calendar/phase_calendar.dart';
import 'package:tracker/screens/entry_screen.dart'; // Your entry form
import './stat_item.dart'; // Separate widget
import './legend_row.dart'; // Separate widget

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CycleProvider cycleProvider;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showStats = true;
  bool _showLegendTutorial = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    final settingsBox = Hive.box('settings');
    _showLegendTutorial =
        settingsBox.get('showLegendTutorial', defaultValue: true) as bool;
    cycleProvider = Provider.of<CycleProvider>(context, listen: false);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
    });
    _showDayDetails(selectedDay);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
    });
    if (start != null && end != null) {
      _promptPhaseForRange(start, end);
    }
  }

  void _promptPhaseForRange(DateTime start, DateTime end) {
    final t = AppLocalizations.of(context)!;
    String selectedPhase = 'menstruation'; // Default
    Color? selectedColor = Colors.red[300]; // Default color (customizable)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${t.selectPhase} for ${DateFormat.yMd().format(start)} - ${DateFormat.yMd().format(end)}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedPhase,
                onChanged: (value) {
                  selectedPhase = value ?? 'menstruation';
                  selectedColor = cycleProvider.getPhaseColor(
                    selectedPhase,
                  ); // Sync color from provider
                },
                items: [
                  DropdownMenuItem(
                    value: 'menstruation',
                    child: Text(t.menstruation),
                  ),
                  DropdownMenuItem(
                    value: 'follicular',
                    child: Text(t.follicular),
                  ),
                  DropdownMenuItem(
                    value: 'ovulation',
                    child: Text(t.ovulation),
                  ),
                  DropdownMenuItem(value: 'luteal', child: Text(t.luteal)),
                  // Add 'custom' option if you want full control
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text(
                      'Custom Phase',
                    ), // TODO: Localize if needed (t.customPhase)
                  ),
                ],
              ),
              if (selectedPhase ==
                  'custom') // Optional: Custom color picker for full control
                ColorPicker(
                  // Use flutter_colorpicker package; add to pubspec if needed
                  pickerColor: selectedColor ?? Colors.grey,
                  onColorChanged: (color) => selectedColor = color,
                ),
              SizedBox(height: 8),
              // Preview what will be applied
              Container(
                height: 20,
                color: selectedColor,
                child: Center(
                  child: Text(
                    'Preview: $selectedPhase',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () {
                // Modified to pass color (fix for custom phases)
                // TODO: Update CycleProvider.addOrUpdatePhaseRange to accept optional Color? color
                cycleProvider.addOrUpdatePhaseRange(
                  start,
                  end,
                  selectedPhase,
                  color: selectedColor,
                );
                Navigator.pop(context);
                setState(() {}); // Refresh calendar
              },
              child: Text(t.confirm), // Localized
            ),
          ],
        );
      },
    );
  }

  void _showDayDetails(DateTime day) {
    final t = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final entry = cycleProvider.getEntry(day);
    showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day} / ${day.month} / ${day.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (entry != null) ...[
                Text('${t.phase}: ${entry.phase ?? t.noPhase}'),
                Text('${t.flow}: ${entry.flowIntensity}'),
                Text('${t.mood}: ${entry.moodRating ?? 'N/A'}'),
                Text('${t.pain}: ${entry.painLevel ?? 'N/A'}'),
                Text('${t.feeling}: ${entry.overallFeeling ?? 'N/A'}'),
                if (entry.photoPaths.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.photoPaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.file(
                            File(entry.photoPaths[index]),
                            height: 50,
                            width: 50,
                          ),
                        );
                      },
                    ),
                  ),
                Text('${t.notes}: ${entry.notes ?? t.noNotes}'),
              ] else
                Text(t.noEntry),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.close),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntryScreen(selectedDate: day),
                        ),
                      );
                    },
                    child: Text(t.editAdd),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLegend() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.legend),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LegendRow(Colors.red[300]!, t.menstruation),
              LegendRow(Colors.pink[200]!, t.follicular),
              LegendRow(Colors.yellow[300]!, t.ovulation),
              LegendRow(Colors.purple[300]!, t.luteal),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _showLegendTutorial = false);
                Hive.box('settings').put('showLegendTutorial', false);
                Navigator.pop(context);
              },
              child: Text(t.gotIt),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context);
    if (_showLegendTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLegend());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(t.calendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showLegend,
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible stats bar
          ListTile(
            title: Text(t.cycleStats),
            trailing: Icon(_showStats ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _showStats = !_showStats),
          ),
          if (_showStats)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatItem(
                    t.currentCycleDay,
                    '${cycleProvider.currentCycleDay}',
                  ),
                  StatItem(
                    t.daysUntilPeriod,
                    '${cycleProvider.daysUntilPeriod}',
                  ),
                  StatItem(
                    t.averageCycleLength,
                    '${cycleProvider.averageCycleLength} days',
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                PhaseCalendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  rangeStart: _rangeStart,
                  rangeEnd: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() => _calendarFormat = format);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                if (cycleProvider.entries.isEmpty)
                  IgnorePointer(
                    child: Center(
                      child: Text(
                        t.emptyStateMessage,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EntryScreen(selectedDate: _selectedDay ?? DateTime.now()),
            ),
          );
        },
      ),
    );
  }
}
