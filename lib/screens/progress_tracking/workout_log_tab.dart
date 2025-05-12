import "package:fit_app/services/database_helper.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart"; // For date formatting

class WorkoutLogTab extends StatefulWidget {
  const WorkoutLogTab({super.key});

  @override
  State<WorkoutLogTab> createState() => _WorkoutLogTabState();
}

class _WorkoutLogTabState extends State<WorkoutLogTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _activitiesForSelectedDay = [];

  @override
  void initState() {
    super.initState();
    _loadActivitiesForDay(_selectedDay);
  }

  Future<void> _loadActivitiesForDay(DateTime day) async {
    final String dateStr = DateFormat("yyyy-MM-dd").format(day);
    final activities = await _dbHelper.getWorkoutLogsForDate(dateStr);
    // Assuming icons are stored or mapped elsewhere, for now, use a default
    // Or add an icon_name column to the DB and map it to IconData here
    setState(() {
      _activitiesForSelectedDay =
          activities.map((activity) {
            return {
              ...activity, // Spread existing activity data
              "icon": _getIconForActivity(
                activity[DatabaseHelper.columnActivityName] as String? ??
                    "Unknown Activity",
              ),
              // Ensure duration and calories are handled correctly if they are not strings
              "duration":
                  activity[DatabaseHelper.columnDurationMinutes] != null
                      ? "${activity[DatabaseHelper.columnDurationMinutes]} Mins"
                      : "N/A",
              "calories": activity[DatabaseHelper.columnCaloriesBurned] ?? 0,
            };
          }).toList();
    });
  }

  IconData _getIconForActivity(String activityName) {
    // Simple mapping, can be expanded
    if (activityName.toLowerCase().contains("run")) return Icons.directions_run;
    if (activityName.toLowerCase().contains("swim")) return Icons.pool;
    if (activityName.toLowerCase().contains("lift") ||
        activityName.toLowerCase().contains("workout"))
      return Icons.fitness_center;
    if (activityName.toLowerCase().contains("cycle") ||
        activityName.toLowerCase().contains("bike"))
      return Icons.directions_bike;
    return Icons.fitness_center; // Default icon
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary:
                  Theme.of(
                    context,
                  ).colorScheme.secondary, // limeGreen for header
              onPrimary: Colors.black87, // Text on header
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
      });
      _loadActivitiesForDay(picked);
    }
  }

  // Placeholder for adding a new workout log
  Future<void> _addWorkoutLogDialog() async {
    // For now, let's add a dummy entry to test
    final newLog = {
      DatabaseHelper.columnUserId: 1, // Assuming a default user for now
      DatabaseHelper.columnActivityName: "Evening Walk",
      DatabaseHelper.columnDateCompleted: DateFormat(
        "yyyy-MM-dd",
      ).format(_selectedDay),
      DatabaseHelper.columnDurationMinutes: 30,
      DatabaseHelper.columnCaloriesBurned: 150,
      DatabaseHelper.columnSteps: 3000,
    };
    await _dbHelper.insertWorkoutLog(newLog);
    _loadActivitiesForDay(_selectedDay); // Refresh the list
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Dummy workout log added!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_selectedDay),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text("Choose Date"),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              "Activities",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _activitiesForSelectedDay.isEmpty
                      ? Center(
                        child: Text(
                          "No activities logged for this day.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                      : ListView.builder(
                        itemCount: _activitiesForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final activity = _activitiesForSelectedDay[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                activity["icon"] as IconData? ?? Icons.help,
                                color: Theme.of(context).colorScheme.primary,
                                size: 40,
                              ),
                              title: Text(
                                activity[DatabaseHelper.columnActivityName]
                                        as String? ??
                                    "N/A",
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 18),
                              ),
                              subtitle: Text(
                                "${activity["calories"]} Kcal - ${activity["duration"]}",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkoutLogDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary, // limeGreen
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}
