import 'package:fit_app/services/free_roam_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimerStatusWidget extends StatelessWidget {
  const TimerStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FreeRoamTimerState>(
      builder: (context, timerState, _) {
        if (!timerState.hasActiveWorkout) {
          return const SizedBox.shrink(); // Don't show anything if no active workout
        }
        
        return GestureDetector(
          onTap: () {
            // Navigate to Free Roam page when tapped
            Navigator.pushNamed(context, '/free_roam');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  timerState.isTimerRunning ? Icons.timer : Icons.timer_off,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  timerState.formatDuration(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timerState.isTimerRunning ? "Active" : "Paused",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: timerState.isTimerRunning 
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
