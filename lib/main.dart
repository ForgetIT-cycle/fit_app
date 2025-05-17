import 'package:fit_app/services/free_roam_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FreeRoamTimerState())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitApp',
      theme: appTheme,
      darkTheme: appTheme, // Using same theme for both light and dark for now
      themeMode: ThemeMode.dark, // Default to dark theme
      home: const MainScreen(),
    );
  }
}
