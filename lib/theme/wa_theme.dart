import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/settings_service.dart';
import '../utils/common.dart';

class WaTheme {
  // Singleton instance
  static WaTheme? _instance;

  // Constructor
  WaTheme._();

  // Factory for singleton
  factory WaTheme() {
    return _instance ??= WaTheme._();
  }

  Future<void> preloadFonts() async {
    bodyMediumTextStyle;
    await GoogleFonts.pendingFonts();
  }

  final settingsService = SettingsService();

  ThemeData get lightTheme {
    return ThemeData(
      // useMaterial3: true,
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      textTheme: lightTextTheme,
      // fontFamily: 'notoSans',

      // appBarTheme: const AppBarTheme(),
      // floatingActionButtonTheme: const FloatingActionButtonThemeData(),
      // elevatedButtonTheme: const ElevatedButtonThemeData(style: ElevatedButton.styleFrom()),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  TextTheme get lightTextTheme {
    return TextTheme(
      // bodyMedium is the default font style
      bodyMedium: bodyMediumTextStyle,
    );
  }

  TextStyle get bodyMediumTextStyle {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: fontSize,
      color: color,
    );
  }

  String get fontFamily {
    final String? fontFamilySettings = settingsService.getString('font_family');
    const String fontFamilyDefault = 'Noto Sans';

    String fontFamily = (fontFamilySettings is String && fontFamilySettings.isNotEmpty)
        ? fontFamilySettings
        : fontFamilyDefault;

    final fonts = GoogleFonts.asMap();
    if (!fonts.containsKey(fontFamily)) {
      fontFamily = fontFamilyDefault;
    }
    return fontFamily;
  }

  double get fontSize {
    return 16;
  }

  double get smallFontSize {
    return fontSize * 0.938;
  }

  double get xsmallFontSize {
    return fontSize * 0.875;
  }

  double get xxsmallFontSize {
    return fontSize * 0.75;
  }

  // Color
  String? get colorHex {
    return settingsService.getString('color');
  }

  Color get color {
    return Color(hexColor(colorHex));
  }

  // Muted color
  String? get mutedColorHex {
    return settingsService.getString('muted_color');
  }

  Color get mutedColor {
    return Color(hexColor(mutedColorHex));
  }

  // Emphasis color
  String? get emphasisColorHex {
    return settingsService.getString('emphasis_color');
  }

  Color get emphasisColor {
    return Color(hexColor(emphasisColorHex));
  }

  // Primary color
  String? get primaryColorHex {
    return settingsService.getString('primary_color');
  }

  Color get primaryColor {
    return Color(hexColor(primaryColorHex));
  }

  // Inverse color
  String? get inverseColorHex {
    return settingsService.getString('inverse_color');
  }

  Color get inverseColor {
    return Color(hexColor(inverseColorHex));
  }

  // Background color
  String? get backgroundColorHex {
    return settingsService.getString('background_color');
  }

  Color get backgroundColor {
    return Color(hexColor(backgroundColorHex));
  }

  // Primary background color
  String? get primaryBackgroundColorHex {
    final String? primaryBackgroundColorHex = settingsService.getString('primary_background_color');

    return (primaryBackgroundColorHex ?? '').isNotEmpty
        ? primaryBackgroundColorHex
        : primaryColorHex;
  }

  Color get primaryBackgroundColor {
    return Color(hexColor(primaryBackgroundColorHex));
  }

  // Button background color
  String? get buttonBackgroundColorHex {
    return settingsService.getString('button_background_color');
  }

  Color get buttonBackgroundColor {
    return Color(hexColor(buttonBackgroundColorHex));
  }

  // Button color
  String? get buttonColorHex {
    return settingsService.getString('button_color');
  }

  Color get buttonColor {
    return Color(hexColor(buttonColorHex));
  }

  // Primary button background color
  String? get primaryButtonBackgroundColorHex {
    final String? primaryButtonBackgroundColorHex =
        settingsService.getString('primary_button_background_color');

    return (primaryButtonBackgroundColorHex ?? '').isNotEmpty
        ? primaryButtonBackgroundColorHex
        : primaryBackgroundColorHex;
  }

  Color get primaryButtonBackgroundColor {
    return Color(hexColor(primaryButtonBackgroundColorHex));
  }

  // Primary button color
  String? get primaryButtonColorHex {
    final String? primaryButtonColorHex = settingsService.getString('primary_button_color');

    return (primaryButtonColorHex ?? '').isNotEmpty ? primaryButtonColorHex : inverseColorHex;
  }

  Color get primaryButtonColor {
    return Color(hexColor(primaryButtonColorHex));
  }

  // App Bar background color
  String? get appBarBackgroundColorHex {
    final String? appBarBackgroundColorHex = settingsService.getString('app_bar_background_color');

    return (appBarBackgroundColorHex ?? '').isNotEmpty
        ? appBarBackgroundColorHex
        : primaryBackgroundColorHex;
  }

  Color get appBarBackgroundColor {
    return Color(hexColor(appBarBackgroundColorHex));
  }

  // App Bar color
  String? get appBarColorHex {
    final String? appBarColorHex = settingsService.getString('app_bar_color');

    return (appBarColorHex ?? '').isNotEmpty ? appBarColorHex : inverseColorHex;
  }

  Color get appBarColor {
    return Color(hexColor(appBarColorHex));
  }

  // Onboarding screen background color
  String? get onboardingScreenBackgroundColorHex {
    final String? onboardingScreenBackgroundColorHex =
        settingsService.getString('onboarding_screen_background_color');

    return (onboardingScreenBackgroundColorHex ?? '').isNotEmpty
        ? onboardingScreenBackgroundColorHex
        : backgroundColorHex;
  }

  Color get onboardingScreenBackgroundColor {
    return Color(hexColor(onboardingScreenBackgroundColorHex));
  }

  // Home screen background color
  String? get homeScreenBackgroundColorHex {
    final String? homeScreenBackgroundColorHex =
        settingsService.getString('home_screen_background_color');

    return (homeScreenBackgroundColorHex ?? '').isNotEmpty
        ? homeScreenBackgroundColorHex
        : backgroundColorHex;
  }

  Color get homeScreenBackgroundColor {
    return Color(hexColor(homeScreenBackgroundColorHex));
  }

  // Bottom bar background color
  String? get bottomBarBackgroundColorHex {
    final String? bottomBarBackgroundColorHex =
        settingsService.getString('bottom_bar_background_color');

    return (bottomBarBackgroundColorHex ?? '').isNotEmpty
        ? bottomBarBackgroundColorHex
        : backgroundColorHex;
  }

  Color get bottomBarBackgroundColor {
    return Color(hexColor(bottomBarBackgroundColorHex));
  }

  double get rem {
    return 16;
  }

  TextStyle get textMeta {
    return const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.6,
      letterSpacing: 1.008,
    );
  }

  TextStyle get onboardingTitle {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      height: 1.6,
      color: emphasisColor,
    );
  }

  TextStyle get onboardingDescription {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.6,
      color: color,
    );
  }

  TextStyle get noInternetTitle {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      height: 1.6,
      color: emphasisColor,
    );
  }

  double get space {
    return rem * 1.5;
  }

  double get xsmallSpace {
    return rem * 0.5;
  }

  double get smallSpace {
    return rem;
  }

  double get mediumSpace {
    return rem * 2.5;
  }

  double get largeSpace {
    return rem * 4;
  }

  double get borderRadius {
    final String? borderRadius = settingsService.getString('border_radius');

    try {
      return double.parse(borderRadius ?? '0');
    } catch (e) {
      return 0;
    }
  }

  String get chevronRightIcon {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"><path d="M9.29 6.71a.996.996 0 0 0 0 1.41L13.17 12l-3.88 3.88a.996.996 0 1 0 1.41 1.41l4.59-4.59a.996.996 0 0 0 0-1.41L10.7 6.7c-.38-.38-1.02-.38-1.41.01z"/></svg>';
  }

  String get wifiExclamationIcon {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><path d="M8 2.254a1.173 1.173 0 0 0-1.17 1.255l.372 5.2a.8.8 0 0 0 1.595 0l.373-5.2A1.174 1.174 0 0 0 8 2.254Zm0 11.2a1.6 1.6 0 1 0-1.6-1.6A1.6 1.6 0 0 0 8 13.455Z"/><path d="M6.328 2.379a1.97 1.97 0 0 0-.3 1.19l.035.483a9.59 9.59 0 0 0-4.711 2.477.8.8 0 1 1-1.107-1.152 11.133 11.133 0 0 1 6.083-2.998Zm3.342 0a11.152 11.152 0 0 1 6.083 2.995.8.8 0 1 1-1.107 1.153 9.587 9.587 0 0 0-4.713-2.478l.035-.483a1.977 1.977 0 0 0-.3-1.19ZM6.238 6.472 6.355 8.1A5.586 5.586 0 0 0 4.3 9.254a.8.8 0 0 1-1.06-1.2 7.176 7.176 0 0 1 2.998-1.582ZM9.643 8.1l.115-1.627a7.21 7.21 0 0 1 3 1.582.8.8 0 1 1-1.06 1.2A5.641 5.641 0 0 0 9.64 8.1Z" opacity=".4"/></svg>';
  }

  Color getColor(String? colorHex, String? alternativeColorHex) {
    return Color(hexColor((colorHex ?? '').isNotEmpty ? colorHex : alternativeColorHex));
  }
}
