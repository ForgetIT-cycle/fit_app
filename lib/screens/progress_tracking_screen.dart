import "package:flutter/material.dart";
import "package:fit_app/screens/progress_tracking/workout_log_tab.dart";
import "package:fit_app/screens/progress_tracking/charts_tab.dart";

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Tracking"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary, // limeGreen
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          tabs: const [
            Tab(text: "Workout Log"),
            Tab(text: "Charts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WorkoutLogTab(), // To be created
          ChartsTab(),     // To be created
        ],
      ),
    );
  }
}

