import "package:fit_app/screens/home_screen.dart";
import "package:fit_app/screens/progress_tracking_screen.dart";
import "package:flutter/material.dart";

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Add placeholder screens for other tabs later
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProgressTrackingScreen(),
    Center(child: Text("Favorites Screen - Placeholder")),
    Center(child: Text("Profile Screen - Placeholder")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            activeIcon: Icon(Icons.star),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        // Theme for BottomNavigationBar is already in theme.dart
        // selectedItemColor: Theme.of(context).colorScheme.secondary, // limeGreen
        // unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        onTap: _onItemTapped,
      ),
    );
  }
}

