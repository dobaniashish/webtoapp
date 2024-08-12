import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'models/wa_action_item_model.dart';
import 'services/ad_interstitial_service.dart';
import 'services/downloader_service.dart';
import 'services/preferences_service.dart';
import 'services/push_notification_service.dart';
import 'services/settings_service.dart';
import 'utils/common.dart';
import 'widgets/wa_dashboard.dart';
import 'widgets/wa_home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<WaDashboardState> dashboardKey = GlobalKey<WaDashboardState>();

  final settingsService = SettingsService();
  final preferencesService = PreferencesService();
  AdInterstitialService? adInterstitialService;

  @override
  void initState() {
    super.initState();

    _initNotificationMessage();
    _initUniLinks();

    // Settings reload
    settingsService.remoteConfig.onConfigUpdated.listen((event) async {
      await settingsService.remoteConfig.activate();
      _showAppReloadDialog();
    });

    if (showAds()) {
      _loadAds();
    }
  }

  void _loadAds() async {
    // Interstitial Ads
    final String? adInterstitialId = defaultTargetPlatform == TargetPlatform.android
        ? settingsService.getString('ad_interstitial_id_android')
        : settingsService.getString('ad_interstitial_id_ios');

    final int? adInterstitialInterval = settingsService.getInt('ad_interstitial_interval');

    if (showAdInterstitial() &&
        adInterstitialId != null &&
        adInterstitialId.isNotEmpty &&
        adInterstitialInterval != null &&
        adInterstitialInterval > 0) {
      adInterstitialService = AdInterstitialService(adInterstitialId, adInterstitialInterval);
    }
  }

  Future<void> _initNotificationMessage() async {
    // Firebase and local notification
    await PushNotificationService().initialize();

    // Firebase: Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleRemoteNotificationMessage(initialMessage);
    }

    // Local: Getting details on if the app was launched via a notification created by this plugin
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await PushNotificationService()
            .flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.didNotificationLaunchApp) {
      final notificationResponse = notificationAppLaunchDetails.notificationResponse;

      if (notificationResponse != null) {
        _handleLocalNotificationMessage(notificationResponse);
      }
    }

    // Also handle any interaction when the app is in the background via a stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteNotificationMessage);

    // Handle any interaction with local notification when the app is in the background
    PushNotificationService().onDidReceiveNotificationResponse = _handleLocalNotificationMessage;
  }

  void _handleRemoteNotificationMessage(RemoteMessage message) {
    if (message.data['url'] is String && message.data['url'].isNotEmpty) {
      _handleNotificationMessage(message.data);
    }
  }

  void _handleLocalNotificationMessage(NotificationResponse notificationResponse) {
    if (notificationResponse.payload is String && notificationResponse.payload!.isNotEmpty) {
      Map<String, dynamic> data;

      try {
        data = jsonDecode(notificationResponse.payload ?? '{}');
      } catch (e) {
        data = {};
      }

      if (data['url'] is String && data['url'].isNotEmpty) {
        _handleNotificationMessage(data);
      }
    }
  }

  void _handleNotificationMessage(Map<String, dynamic> data) {
    if (data['url'] is String && data['url'].isNotEmpty) {
      handleAction(WaActionItemModel(target: 'webview', url: data['url']));
    }
  }

  Future<void> _initUniLinks() async {
    // Get initial link
    try {
      final String? initialLink = await getInitialLink();

      if (initialLink is String) {
        _handleUnilinks(initialLink);
      }
    } catch (e) {
      // Do nothing.
    }

    // Subscribe to link stream
    linkStream.listen((String? link) {
      if (link is String) {
        _handleUnilinks(link);
      }
    }, onError: (err) {
      // Do nothing.
    });
  }

  void _handleUnilinks(String url) {
    if (url.isNotEmpty) {
      handleAction(WaActionItemModel(target: 'webview', url: url));
    }
  }

  void handleAction(WaActionItemModel item) async {
    final String target = item.target;

    switch (target) {
      case 'webview-navigation':
        adInterstitialService?.show();
        break;
      case 'webview':
        // If show home screen and a dashboard page is not pushed, push a new page
        if (showHomeScreen() && dashboardKey.currentState == null) {
          pushDashboard(item.url);
        } else {
          // Change the current url
          dashboardKey.currentState!.webViewController?.loadUrl(
            urlRequest: URLRequest(
              url: WebUri(item.url),
            ),
          );
        }

        // Show ad only for webview action
        adInterstitialService?.show();

        break;
      case 'in-app-webview':
        if (await canLaunchUrl(WebUri(item.url))) {
          // Launch the App
          await launchUrl(
            WebUri(item.url),
            mode: LaunchMode.inAppWebView,
          );
        }
        break;
      case 'external':
        if (await canLaunchUrl(WebUri(item.url))) {
          // Launch the App
          await launchUrl(
            WebUri(item.url),
            mode: LaunchMode.externalApplication,
          );
        }
        break;
      case 'download':
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Download requested.'),
          ));
        }

        DownloaderService().download(WebUri(item.url));
        break;
      default:
        break;
    }
  }

  void pushDashboard(String? url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WaDashboard(
          key: dashboardKey,
          handleAction: handleAction,
          url: url,
        ),
      ),
    );
  }

  Future<void> _showAppReloadDialog() async {
    return showDialog<void>(
      context: context,
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
  void dispose() {
    adInterstitialService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showHomeScreen()
        ? WaHome(handleAction: handleAction)
        : WaDashboard(key: dashboardKey, handleAction: handleAction);
  }
}
