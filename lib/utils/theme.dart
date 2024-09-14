import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  static const primary = Color(0xFF00A67E);
  static const secondary = Color(0xFF3B76F6);
  static const accent = Color(0xFFD6755B);
  static const textDark = Color(0xFF53585A);
  static const textLight = Color(0xFFF5F5F5);
  static const textFaded = Color(0xFF9899A5);
  static const iconLight = Color(0xFFB1B4C0);
  static const iconDark = Color(0xFFB1B3C1);
  static const iconRed = Color(0xFFE57373);
  static const textHighlight = secondary;
  static const cardLight = Color(0xFFF1F3F4);
  static const cardDark = Color(0xFF303334);

  static const successGreen = primary;
  static const errorRed = Color(0xFFEf5350);
}

abstract class _LightColors {
  static const background = Colors.white;
  static const card = AppColors.cardLight;
}

abstract class _DarkColors {
  static const background = Color(0xFF1B1E1F);
  static const card = AppColors.cardDark;
}

/// Reference to the application theme.
class AppTheme {
  static const accentColor = AppColors.primary;
  static final visualDensity = VisualDensity.adaptivePlatformDensity;

  static final darkBase = ThemeData.dark();
  static final lightBase = ThemeData.light();

  /// Light theme and its settings.
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        visualDensity: visualDensity,
        textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: AppColors.textDark),
        dialogBackgroundColor: AppColors.cardLight,
        appBarTheme: lightBase.appBarTheme.copyWith(
          iconTheme: lightBase.iconTheme,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.textDark,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        scaffoldBackgroundColor: _LightColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
        cardColor: _LightColors.card,
        primaryTextTheme: const TextTheme(
          titleLarge: TextStyle(color: AppColors.textDark),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(AppColors.textDark),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconDark),
        colorScheme: lightBase.colorScheme.copyWith(secondary: accentColor).copyWith(surface: _LightColors.background),
      );

  /// Dark theme and its settings.
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        visualDensity: visualDensity,
        textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: AppColors.textLight),
        dialogBackgroundColor: AppColors.cardDark,
        appBarTheme: darkBase.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        scaffoldBackgroundColor: _DarkColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
        cardColor: _DarkColors.card,
        primaryTextTheme: const TextTheme(
          titleLarge: TextStyle(color: AppColors.textLight),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(AppColors.textLight),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconLight),
        colorScheme: darkBase.colorScheme.copyWith(secondary: accentColor).copyWith(surface: _DarkColors.background),
      );
}
