import 'package:flutter/widgets.dart';

import '../services/preferences_service.dart';
import '../services/settings_service.dart';

bool showOnboardingScreen() {
  final settingsService = SettingsService();
  final preferencesService = PreferencesService();
  bool showOnboardingScreen = false;

  final onboardingScreens = settingsService.getList('onboarding_screens');

  if (onboardingScreens is List<dynamic> &&
      onboardingScreens.isNotEmpty &&
      settingsService.getBool('enable_onboarding_screen') == true &&
      (preferencesService.getBool('onboarding_screen_shown') != true ||
          settingsService.getBool('onboarding_screen_always') == true)) {
    showOnboardingScreen = true;
  }

  return showOnboardingScreen;
}

bool showHomeScreen() {
  final settingsService = SettingsService();
  return settingsService.getBool('enable_home_screen') ?? false;
}

bool showAds() {
  final settingsService = SettingsService();
  return settingsService.getBool('enable_ads') ?? false;
}

bool showAdBannerTop() {
  final settingsService = SettingsService();
  return showAds() && (settingsService.getBool('enable_ad_banner_top') ?? false);
}

bool showAdBannerBottom() {
  final settingsService = SettingsService();
  return showAds() && (settingsService.getBool('enable_ad_banner_bottom') ?? false);
}

bool showAdInterstitial() {
  final settingsService = SettingsService();
  return showAds() && (settingsService.getBool('enable_ad_interstitial') ?? false);
}

int hexColor(String? hexString) {
  int defaultColor = 0xffffffff; // White

  if (hexString == null) {
    return defaultColor;
  }

  hexString = hexString.toUpperCase().replaceAll('#', '');

  if (hexString.length == 6) {
    hexString = 'FF$hexString';
  }

  int hexNum;

  try {
    hexNum = int.parse(hexString, radix: 16);
  } catch (e) {
    hexNum = defaultColor;
  }

  return hexNum == 0 ? defaultColor : hexNum;
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
