import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

// App Colors based on image analysis
const Color darkGrey = Color(0xFF3A3A3C); // Primary Background
const Color lightPurple = Color(0xFFC8B6FF); // Accent Background/Cards
const Color saturatedPurple = Color(0xFFA076F9); // Accent Highlights/Icons
const Color limeGreen = Color(0xFFD4FF00); // Secondary Accent/Buttons

const Color textOnDark = Colors.white;
const Color textOnLight = Colors.black87;

ThemeData fitAppTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: saturatedPurple,
  scaffoldBackgroundColor: darkGrey,
  colorScheme: const ColorScheme.dark(
    primary: saturatedPurple,
    secondary: limeGreen,
    surface: darkGrey,
    error: Colors.redAccent,
    onPrimary: textOnDark,
    onSecondary: textOnLight, // Text on limeGreen buttons
    onSurface: textOnDark,
    onError: textOnDark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkGrey,
    elevation: 0,
    iconTheme: const IconThemeData(color: textOnDark),
    titleTextStyle: GoogleFonts.montserrat(
      color: textOnDark,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 96.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontSize: 60.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: 48.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 34.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    bodyLarge: GoogleFonts.montserrat(fontSize: 16.0, color: textOnDark),
    bodyMedium: GoogleFonts.montserrat(fontSize: 14.0, color: textOnDark),
    labelLarge: GoogleFonts.montserrat(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: textOnDark,
    ),
    bodySmall: GoogleFonts.montserrat(fontSize: 12.0, color: textOnDark),
    labelSmall: GoogleFonts.montserrat(fontSize: 10.0, color: textOnDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: limeGreen,
      foregroundColor: textOnLight, // Text color on button
      textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12.0,
        ), // Rounded corners for buttons
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightPurple.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
    hintStyle: GoogleFonts.montserrat(color: textOnDark.withOpacity(0.7)),
  ),
  cardTheme: CardTheme(
    color: lightPurple.withOpacity(
      0.15,
    ), // Slightly transparent light purple for cards
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkGrey, // Or a slightly different shade if needed
    selectedItemColor: limeGreen,
    unselectedItemColor: textOnDark.withOpacity(0.6),
    selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
    unselectedLabelStyle: GoogleFonts.montserrat(),
    type: BottomNavigationBarType.fixed,
  ),
  // Add other theme properties as needed based on image analysis
);
