import 'package:fit_app/screens/home_screen.dart';
import 'package:fit_app/screens/progress_tracking_screen.dart';
import 'package:fit_app/services/free_roam_timer_state.dart';
import 'package:fit_app/widgets/timer_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProgressTrackingScreen(),
    Placeholder(child: Center(child: Text("Favorites - Coming Soon"))),
    Placeholder(child: Center(child: Text("Profile - Coming Soon"))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Show timer status if active
          Consumer<FreeRoamTimerState>(
            builder: (context, timerState, _) {
              if (timerState.hasActiveWorkout) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(child: TimerStatusWidget()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Main content
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Needed for more than 3 items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.7),
        onTap: _onItemTapped,
      ),
    );
  }
}
