import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'services/auth_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const LakePassApp(),
    ),
  );
}

class LakePassApp extends StatelessWidget {
  const LakePassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LakePass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          secondary: AppColors.accent,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.jostTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: AppColors.textPrimary, letterSpacing: 0.5),
          bodyMedium: const TextStyle(color: AppColors.textSecondary, letterSpacing: 0.5),
          titleLarge: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.textPrimary),
        ),
        // Force lakepass.app input styling everywhere
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        // Force lakepass.app button styling everywhere
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
        ),
        // Force lakepass.app card styling
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.textSecondary.withOpacity(0.1)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
