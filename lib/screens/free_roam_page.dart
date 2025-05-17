import 'dart:async';
import 'package:fit_app/services/database_helper.dart';
import 'package:fit_app/services/free_roam_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String difficulty;
  final IconData icon;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.difficulty,
    required this.icon,
  });
}

class FreeRoamPage extends StatefulWidget {
  const FreeRoamPage({super.key});

  @override
  State<FreeRoamPage> createState() => _FreeRoamPageState();
}

class _FreeRoamPageState extends State<FreeRoamPage>
    with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Timer for UI updates
  Timer? _uiUpdateTimer;

  // Exercise list
  final List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _generateExercises();

    // Start a timer to update the UI every second if the timer is running
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final timerState = Provider.of<FreeRoamTimerState>(
        context,
        listen: false,
      );
      timerState.updateTimerIfRunning();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final timerState = Provider.of<FreeRoamTimerState>(context, listen: false);

    if (state == AppLifecycleState.paused) {
      // App is in background, store the current time
      if (timerState.isTimerRunning) {
        timerState.pauseTimer();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground again, update the timer
      timerState.updateTimerIfRunning();
    }
  }

  void _generateExercises() {
    // Generate 30 sample exercises
    final List<String> muscleGroups = [
      'Chest',
      'Back',
      'Shoulders',
      'Arms',
      'Legs',
      'Core',
      'Full Body',
    ];

    final List<String> difficulties = ['Beginner', 'Intermediate', 'Advanced'];

    final List<IconData> icons = [
      Icons.fitness_center,
      Icons.directions_run,
      Icons.sports_gymnastics,
      Icons.sports_handball,
      Icons.sports_martial_arts,
      Icons.sports_kabaddi,
    ];

    final List<String> exerciseNames = [
      'Push-ups',
      'Pull-ups',
      'Squats',
      'Lunges',
      'Plank',
      'Burpees',
      'Mountain Climbers',
      'Jumping Jacks',
      'Crunches',
      'Deadlifts',
      'Bench Press',
      'Shoulder Press',
      'Bicep Curls',
      'Tricep Extensions',
      'Leg Press',
      'Calf Raises',
      'Russian Twists',
      'Side Planks',
      'Glute Bridges',
      'Box Jumps',
      'Kettlebell Swings',
      'Dips',
      'Chin-ups',
      'Leg Raises',
      'Flutter Kicks',
      'Superman',
      'Wall Sits',
      'Step-ups',
      'Lateral Raises',
      'Front Raises',
    ];

    for (int i = 0; i < 30; i++) {
      final String id = 'ex${i + 1}';
      final String name =
          i < exerciseNames.length ? exerciseNames[i] : 'Exercise ${i + 1}';

      final String muscleGroup = muscleGroups[i % muscleGroups.length];
      final String difficulty = difficulties[i % difficulties.length];
      final IconData icon = icons[i % icons.length];

      _exercises.add(
        Exercise(
          id: id,
          name: name,
          description:
              'Detailed instructions for $name. This exercise targets the $muscleGroup muscle group and is suitable for $difficulty level fitness enthusiasts.',
          muscleGroup: muscleGroup,
          difficulty: difficulty,
          icon: icon,
        ),
      );
    }
  }

  Future<void> _saveWorkout() async {
    final timerState = Provider.of<FreeRoamTimerState>(context, listen: false);

    if (timerState.secondsElapsed == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No workout to save. Start the timer first!"),
        ),
      );
      return;
    }

    // Create a workout name based on selected exercises or a default name
    String workoutName = "Free Roam Workout";
    if (timerState.selectedExerciseIds.isNotEmpty) {
      final selectedExercises =
          _exercises
              .where((ex) => timerState.selectedExerciseIds.contains(ex.id))
              .map((ex) => ex.name)
              .toList();

      if (selectedExercises.length == 1) {
        workoutName = selectedExercises.first;
      } else if (selectedExercises.length <= 3) {
        workoutName = selectedExercises.join(", ");
      } else {
        workoutName = "${selectedExercises.length} Exercises";
      }
    }

    // Calculate estimated calories (very rough estimate)
    // Assuming moderate intensity: ~5-7 calories per minute
    final calorieRate = 6; // calories per minute
    final durationMinutes = timerState.secondsElapsed ~/ 60;
    final estimatedCalories = durationMinutes * calorieRate;

    // Save to database
    final workoutLog = {
      DatabaseHelper.columnUserId: 1, // Assuming a default user
      DatabaseHelper.columnActivityName: workoutName,
      DatabaseHelper.columnDateCompleted: DateFormat(
        "yyyy-MM-dd",
      ).format(DateTime.now()),
      DatabaseHelper.columnTimeCompleted: DateFormat(
        "HH:mm",
      ).format(DateTime.now()),
      DatabaseHelper.columnDurationMinutes: durationMinutes,
      DatabaseHelper.columnCaloriesBurned: estimatedCalories,
      DatabaseHelper.columnNotes:
          timerState.selectedExerciseIds.isNotEmpty
              ? "Exercises: ${timerState.selectedExerciseIds.length}"
              : "Free workout",
    };

    await _dbHelper.insertWorkoutLog(workoutLog);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Workout saved: $workoutName"),
          action: SnackBarAction(
            label: 'View in Progress',
            onPressed: () {
              // Navigate to the Progress tab
              Navigator.pop(context); // Go back to home
              // The MainScreen will handle showing the Progress tab
            },
          ),
        ),
      );
      // Reset timer and selections after saving
      timerState.resetTimer();
    }
  }

  void _showExerciseDetails(Exercise exercise) {
    final timerState = Provider.of<FreeRoamTimerState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<FreeRoamTimerState>(
          builder: (context, timerState, _) {
            final isSelected = timerState.isExerciseSelected(exercise.id);

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        exercise.icon,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${exercise.muscleGroup} • ${exercise.difficulty}",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          timerState.toggleExerciseSelection(exercise.id);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Add more details like sets, reps recommendations, etc.
                  // For now, just a placeholder
                  Text(
                    "Recommended",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.difficulty == "Beginner"
                        ? "3 sets of 8-10 reps with 60s rest"
                        : exercise.difficulty == "Intermediate"
                        ? "4 sets of 10-12 reps with 45s rest"
                        : "5 sets of 12-15 reps with 30s rest",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        timerState.toggleExerciseSelection(exercise.id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isSelected ? "Remove from Workout" : "Add to Workout",
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FreeRoamTimerState>(
      builder: (context, timerState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Free Roam Workout"),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Timer section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      timerState.formatDuration(),
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!timerState.isTimerRunning)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Start"),
                            onPressed: timerState.startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            icon: const Icon(Icons.pause),
                            label: const Text("Pause"),
                            onPressed: timerState.pauseTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                          onPressed: _saveWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text("Discard"),
                          onPressed:
                              timerState.secondsElapsed > 0
                                  ? timerState.resetTimer
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            disabledBackgroundColor: Colors.grey.withOpacity(
                              0.3,
                            ),
                            disabledForegroundColor: Colors.white.withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (timerState.selectedExerciseIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "${timerState.selectedExerciseIds.length} exercises selected",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Exercise list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    final isSelected = timerState.isExerciseSelected(
                      exercise.id,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      color:
                          isSelected
                              ? Theme.of(
                                context,
                              ).colorScheme.secondaryContainer.withOpacity(0.3)
                              : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                          child: Icon(
                            exercise.icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${exercise.muscleGroup} • ${exercise.difficulty}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed:
                              () => timerState.toggleExerciseSelection(
                                exercise.id,
                              ),
                        ),
                        onTap: () => _showExerciseDetails(exercise),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
