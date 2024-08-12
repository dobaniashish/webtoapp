import 'dart:async';

import 'package:in_app_review/in_app_review.dart';

import 'preferences_service.dart';
import 'settings_service.dart';

class InAppReviewService {
  // Singleton instance
  static InAppReviewService? _instance;

  // Variables
  final InAppReview inAppReview;

  // Constructor
  InAppReviewService._() : inAppReview = InAppReview.instance;

  // Factory for singleton
  factory InAppReviewService() {
    return _instance ??= InAppReviewService._();
  }

  final preferencesService = PreferencesService();
  final settingsService = SettingsService();

  static const String _keyInstallTime = 'in_app_review_install_time';
  static const String _keyRequestCount = 'in_app_review_request_count';

  Future<void> initialize() async {
    // If this is first install set first install time
    if (_isFirstLaunch()) {
      await _setInstallTime();
    }

    // Wait days after first launch
    final int initialWaitDays = settingsService.getInt('app_review_wait_days') ?? 1;

    // Wait seconds after starting app
    final int waitSeconds = settingsService.getInt('app_review_wait_seconds') ?? 10;

    // Interval days between each requests
    final int intervalDays = settingsService.getInt('app_review_interval') ?? 7;

    // Number of times we should request user to review
    final int maxRequests = settingsService.getInt('app_review_max_requests') ?? 3;

    final int installTime = _getInstallTime();
    final int requestCount = _getRequestCount();

    // We have requested a lot of times
    if (requestCount >= maxRequests) {
      return;
    }

    // Determine wait days
    // If this is the first request we will wait for initialWaitDays
    int waitDays = requestCount > 0 ? intervalDays : initialWaitDays;

    // We have not waited until waitDays
    if (!_isOverDate(installTime, waitDays)) {
      return;
    }

    Future.delayed(Duration(seconds: waitSeconds), () async {
      // Mark request
      await _setRequestCount(requestCount + 1);

      // Show review
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    });
  }

  // Set install time to current timestamp
  Future<bool> _setInstallTime() async =>
      preferencesService.setInt(_keyInstallTime, DateTime.now().millisecondsSinceEpoch);

  // Check if we have set install time already
  bool _isFirstLaunch() => preferencesService.getInt(_keyInstallTime) == null ? true : false;

  // Get the currently set install time or 0
  int _getInstallTime() => preferencesService.getInt(_keyInstallTime) ?? 0;

  // Set request count
  Future<bool> _setRequestCount(int count) async =>
      preferencesService.setInt(_keyRequestCount, count);

  // Get request count
  int _getRequestCount() => preferencesService.getInt(_keyRequestCount) ?? 0;

  bool _isOverDate(int targetTime, int thresholdDays) {
    return DateTime.now().millisecondsSinceEpoch - targetTime >=
        thresholdDays * 24 * 60 * 60 * 1000;
  }
}
