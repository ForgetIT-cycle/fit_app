import 'package:flutter/foundation.dart';

class FreeRoamTimerState extends ChangeNotifier {
  // Timer state
  int _secondsElapsed = 0;
  bool _isTimerRunning = false;
  DateTime? _lastUpdatedTime;
  
  // Selected exercises
  final List<String> _selectedExerciseIds = [];
  
  // Getters
  int get secondsElapsed => _secondsElapsed;
  bool get isTimerRunning => _isTimerRunning;
  List<String> get selectedExerciseIds => List.unmodifiable(_selectedExerciseIds);
  bool get hasActiveWorkout => _secondsElapsed > 0;
  
  // Timer control methods
  void startTimer() {
    _isTimerRunning = true;
    _lastUpdatedTime = DateTime.now();
    notifyListeners();
  }
  
  void pauseTimer() {
    _isTimerRunning = false;
    _lastUpdatedTime = null;
    notifyListeners();
  }
  
  void resetTimer() {
    _secondsElapsed = 0;
    _isTimerRunning = false;
    _lastUpdatedTime = null;
    _selectedExerciseIds.clear();
    notifyListeners();
  }
  
  void updateTimerIfRunning() {
    if (_isTimerRunning && _lastUpdatedTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastUpdatedTime!).inSeconds;
      if (difference > 0) {
        _secondsElapsed += difference;
        _lastUpdatedTime = now;
        notifyListeners();
      }
    }
  }
  
  void incrementTimer(int seconds) {
    _secondsElapsed += seconds;
    notifyListeners();
  }
  
  // Exercise selection methods
  void toggleExerciseSelection(String exerciseId) {
    if (_selectedExerciseIds.contains(exerciseId)) {
      _selectedExerciseIds.remove(exerciseId);
    } else {
      _selectedExerciseIds.add(exerciseId);
    }
    notifyListeners();
  }
  
  bool isExerciseSelected(String exerciseId) {
    return _selectedExerciseIds.contains(exerciseId);
  }
  
  // Format duration as string (HH:MM:SS or MM:SS)
  String formatDuration() {
    final duration = Duration(seconds: _secondsElapsed);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }
}
