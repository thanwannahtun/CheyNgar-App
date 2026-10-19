import 'package:flutter/material.dart';

abstract final class AppThemeData {
  static ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: colorScheme.onSurface, // Material 3 baseline standard
          fontFamily: "Pyidaungsu",
        ),
      ),
      fontFamily: "Pyidaungsu",
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme
            .surfaceContainer, // Dark mode အတွက် သဘာဝကျတဲ့ dark gray/green Tint container base
        elevation: 0,
        scrolledUnderElevation:
            0, // Scroll လုပ်တဲ့အခါ အရောင်မပြောင်းအောင် ထိန်းထားခြင်း
        surfaceTintColor: Colors
            .transparent, // M3 ရဲ့ မလိုလားအပ်တဲ့ ခရမ်းရောင် သန်းတာတွေကို ဖျောက်ရန်
        iconTheme: const IconThemeData(
          size: 20,
        ), // 15 က သေးလွန်းလို့ standard 20 ပြောင်းပေးထားပါတယ်
        actionsIconTheme: const IconThemeData(size: 20),
        titleTextStyle: TextStyle(
          fontSize: 18, // Title size ကို ပိုဖတ်ရလွယ်အောင် ပြင်ထားပါတယ်
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: "Pyidaungsu",
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontFamily: "Pyidaungsu",
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.3,
        space: 24,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.3),
        ),
      ),
    );
  }

  static ThemeData buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontFamily: "Pyidaungsu",
        ),
      ),
      fontFamily: "Pyidaungsu",
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme
            .surface, // Light mode အတွက် သန့်ရှင်းတဲ့ ဖြူစင်စင်အရောင် (သို့) အစိမ်းဖျော့ Tint
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(size: 20),
        actionsIconTheme: const IconThemeData(size: 20),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: "Pyidaungsu",
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.3,
        space: 24,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.3),
        ),
      ),
    );
  }
}
