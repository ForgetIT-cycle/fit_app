import "dart:async";
import "package:flutter/material.dart";

// Data model for a predefined workout
class PredefinedWorkout {
  final String id;
  final String name;
  final String description;
  final String imagePlaceholder; // Could be an asset path or URL later
  // Add other properties like default duration, target muscles, etc.

  PredefinedWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePlaceholder, // For now, just a color or icon name
  });
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // Placeholder list of predefined workouts
  final List<PredefinedWorkout> _predefinedWorkouts = [
    PredefinedWorkout(
      id: "pw1",
      name: "Full Body Blast",
      description: "A quick 20-minute full-body routine to get you moving.",
      imagePlaceholder: "full_body_placeholder.png", // Placeholder asset name
    ),
    PredefinedWorkout(
      id: "pw2",
      name: "Core Crusher",
      description: "15 minutes focused on strengthening your core.",
      imagePlaceholder: "core_placeholder.png",
    ),
    PredefinedWorkout(
      id: "pw3",
      name: "Upper Body Strength",
      description: "Build strength in your arms, chest, and back.",
      imagePlaceholder: "upper_body_placeholder.png",
    ),
    PredefinedWorkout(
      id: "pw4",
      name: "Leg Day Burner",
      description: "Challenge your lower body with this intense routine.",
      imagePlaceholder: "leg_day_placeholder.png",
    ),
  ];

  PredefinedWorkout? _selectedWorkout;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;

  void _selectWorkout(PredefinedWorkout workout) {
    setState(() {
      _selectedWorkout = workout;
      _resetTimer(); // Reset timer when a new workout is selected
    });
  }

  void _startTimer() {
    if (_selectedWorkout == null) return;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
    setState(() {
      _isTimerRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsElapsed = 0;
      _isTimerRunning = false;
    });
  }

  void _finishWorkout() {
    // Here you would typically save the workout session to the database
    // For now, just reset and show a message
    _resetTimer();
    final workoutName = _selectedWorkout?.name ?? "Workout";
    final duration = _formatDuration(_secondsElapsed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$workoutName finished! Duration: $duration")),
    );
    setState(() {
      _selectedWorkout = null; // Go back to workout selection
    });
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedWorkout == null ? "Choose Workout" : _selectedWorkout!.name,
        ),
        centerTitle: true,
        leading:
            _selectedWorkout != null
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () {
                    setState(() {
                      _resetTimer();
                      _selectedWorkout = null;
                    });
                  },
                )
                : null,
      ),
      body:
          _selectedWorkout == null
              ? _buildWorkoutSelectionList()
              : _buildActiveWorkoutView(),
    );
  }

  Widget _buildWorkoutSelectionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _predefinedWorkouts.length,
      itemBuilder: (context, index) {
        final workout = _predefinedWorkouts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: InkWell(
            onTap: () => _selectWorkout(workout),
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Placeholder for Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // Later: Image.asset("assets/images/${workout.imagePlaceholder}") or Image.network(...)
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveWorkoutView() {
    if (_selectedWorkout == null)
      return Container(); // Should not happen if logic is correct

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _selectedWorkout!.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Placeholder for current exercise image or instructions
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Icon(
                Icons.fitness_center,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _formatDuration(_secondsElapsed),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isTimerRunning)
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
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
                  onPressed: _pauseTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.stop_rounded),
                label: const Text("Finish"),
                onPressed: _finishWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          if (_secondsElapsed > 0 && !_isTimerRunning)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextButton(
                onPressed: _resetTimer,
                child: Text(
                  "Reset Timer",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
