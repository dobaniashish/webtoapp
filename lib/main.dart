import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'home.dart';
import 'onboarding.dart';
import 'services/in_app_review_service.dart';
import 'services/preferences_service.dart';
import 'services/settings_service.dart';
import 'theme/wa_theme.dart';
import 'utils/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SettingsService and PreferencesService before anything else

  // Initialize firebase, required by SettingsService
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize PreferencesService to load local shared preferences
  final preferencesService = PreferencesService();
  await preferencesService.initialize();

  final settingsService = SettingsService();

  // If settings were initialised atleast once, we wont wait for settings to load.
  if (preferencesService.getBool('remote_config_initialised') == null) {
    await settingsService.initialize(fetch: true);
    await preferencesService.sharedPreferences.setBool('remote_config_initialised', true);
  } else {
    await settingsService.initialize();
  }

  // Initialise Admob
  if (showAds()) {
    MobileAds.instance.initialize();
  }

  // Initialize done

  // Request permissions
  // Request them one by one to prevent ios glitch
  await Permission.notification.request();
  await Permission.location.request();
  // await Permission.storage.request(); // Probably not required
  await Permission.camera.request(); // Required for camera upload only
  await Permission.microphone.request(); // Required for camera upload only

  // Preload fonts
  await WaTheme().preloadFonts();

  // Preload images in cache if required
  // https://stackoverflow.com/a/65544259/7389619
  if (showOnboardingScreen() || showHomeScreen()) {
    final DefaultCacheManager defaultCacheManager = DefaultCacheManager();
    var futures = <Future>[];

    // Onboarding images
    if (showOnboardingScreen()) {
      final onboardingScreens = settingsService.getList('onboarding_screens');
      if (onboardingScreens is List<dynamic>) {
        for (var onboardingScreen in onboardingScreens) {
          if (onboardingScreen.containsKey('image') &&
              onboardingScreen['image'] is String &&
              onboardingScreen['image'].isNotEmpty) {
            // Save image to cache if required
            futures.add(defaultCacheManager.getSingleFile(onboardingScreen['image']));
          }
        }
      }
    }

    // Home logo image
    if (showHomeScreen()) {
      final homeScreenLogo = settingsService.getString('home_screen_logo');
      if (homeScreenLogo is String && homeScreenLogo.isNotEmpty) {
        // Save image to cache if required
        futures.add(defaultCacheManager.getSingleFile(homeScreenLogo));
      }

      final homeScreenBackgroundImage = settingsService.getString('home_screen_background_image');
      if (homeScreenBackgroundImage is String && homeScreenBackgroundImage.isNotEmpty) {
        // Save image to cache if required
        futures.add(defaultCacheManager.getSingleFile(homeScreenBackgroundImage));
      }
    }

    // Drawer logo cache
    if (settingsService.getBool('enable_drawer') == true) {
      final drawerLogo = settingsService.getString('drawer_logo');
      if (drawerLogo is String && drawerLogo.isNotEmpty) {
        // Save image to cache if required
        futures.add(defaultCacheManager.getSingleFile(drawerLogo));
      }
    }

    // Wait for images to get cached
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  // In app review request
  InAppReviewService().initialize();

  runApp(
    const RestartWidget(
      child: MyApp(),
    ),
  );
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  @override
  State<RestartWidget> createState() => _RestartWidgetState();

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ConnectivityResult _connectionStatus = ConnectivityResult.wifi;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final settingsService = SettingsService();
  final preferencesService = PreferencesService();

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    result = await _connectivity.checkConnectivity();

    if (!mounted) {
      return Future.value(null);
    }

    setState(() {
      _connectionStatus = result;
    });
  }

  Future<void> _showAppReloadDialog() async {
    return showDialog<void>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Updated'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('App has been updated. Please reload the app to get the latest changes.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reload'),
              onPressed: () {
                settingsService.getSettings(reload: true);
                preferencesService.initialize();
                RestartWidget.restartApp(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Check connectivity
    initConnectivity();

    // Subscribe to changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((e) async {
      await settingsService.fetchAndActivate();
      setState(() {
        _connectionStatus = e;
      });
    });

    // Settings reload
    settingsService.remoteConfig.onConfigUpdated.listen((event) async {
      await settingsService.remoteConfig.activate();
      _showAppReloadDialog();
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _connectionStatus == ConnectivityResult.none
        ? MaterialApp(
            title: 'App',
            theme: WaTheme().lightTheme,
            home: const InternetConnectionError(),
          )
        : MaterialApp(
            navigatorKey: navigatorKey,
            title: 'App',
            theme: WaTheme().lightTheme,
            initialRoute: showOnboardingScreen() ? 'onboarding' : '/',
            routes: {
              '/': (context) => const Home(),
              'onboarding': (context) => const Onboarding(),
            },
          );
  }
}

class InternetConnectionError extends StatelessWidget {
  const InternetConnectionError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.string(
              WaTheme().wifiExclamationIcon,
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(WaTheme().primaryColor, BlendMode.srcIn),
            ),
            Text(
              'No Connection',
              style: WaTheme().noInternetTitle,
            ),
            SizedBox(height: WaTheme().smallSpace),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: WaTheme().mediumSpace),
              child: const Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
