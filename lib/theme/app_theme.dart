import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryGreen,
        brightness: Brightness.light,
        primary: AppConfig.primaryGreen,
        onPrimary: Colors.white,
        secondary: AppConfig.lightGreen,
        onSecondary: Colors.white,
        surface: AppConfig.bgWhite,
        onSurface: AppConfig.textDark,
        error: AppConfig.errorRed,
      ),
      scaffoldBackgroundColor: AppConfig.bgWhite,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppConfig.textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppConfig.textDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppConfig.textDark,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppConfig.textDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppConfig.textDark,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppConfig.textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppConfig.textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppConfig.textDark,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppConfig.textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppConfig.textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppConfig.textDark,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppConfig.textGrey,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppConfig.textGrey,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConfig.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConfig.primaryGreen,
          side: const BorderSide(color: AppConfig.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConfig.primaryGreen,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          borderSide: const BorderSide(color: AppConfig.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          borderSide: const BorderSide(color: AppConfig.dividerColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          borderSide: const BorderSide(color: AppConfig.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          borderSide: const BorderSide(color: AppConfig.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          borderSide: const BorderSide(color: AppConfig.errorRed, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppConfig.textLight,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppConfig.textGrey,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppConfig.primaryGreen,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppConfig.textGrey,
        suffixIconColor: AppConfig.textGrey,
      ),
      cardTheme: CardThemeData(
        color: AppConfig.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
          side: const BorderSide(color: AppConfig.dividerColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppConfig.surfaceGreen,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppConfig.primaryGreen,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppConfig.surfaceGreen,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryGreen,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppConfig.textGrey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppConfig.primaryGreen, size: 24);
          }
          return const IconThemeData(color: AppConfig.textGrey, size: 24);
        }),
        elevation: 8,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConfig.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppConfig.dividerColor,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusMedium),
        ),
        backgroundColor: AppConfig.textDark,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusLarge),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppConfig.textDark,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppConfig.textGrey,
        ),
      ),
    );
  }
}
