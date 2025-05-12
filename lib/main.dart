import "package:fit_app/screens/splash_screen.dart";
import "package:fit_app/theme/theme.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart"; // Or Riverpod if preferred later

// Example Provider (can be expanded later)
class AppState extends ChangeNotifier {
  // Add app state variables and methods here
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: "FitApp",
        theme: fitAppTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(), // Start with a splash screen
        // Define routes if using named navigation
        // routes: {
        //   '/home': (context) => HomeScreen(),
        //   '/progress': (context) => ProgressTrackingScreen(),
        // },
      ),
    );
  }
}
