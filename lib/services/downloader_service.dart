import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../utils/wa_chrome_safari_browser.dart';

class DownloaderService {
  // Singleton instance
  static DownloaderService? _instance;

  // Constructor
  DownloaderService._();

  // Factory for singleton
  factory DownloaderService() {
    return _instance ??= DownloaderService._();
  }

  // Variables
  WaChromeSafariBrowser browser = WaChromeSafariBrowser();

  download(WebUri url) async {
    await browser.open(
      url: url,
      settings: ChromeSafariBrowserSettings(
        shareState: CustomTabsShareState.SHARE_STATE_ON,
        barCollapsingEnabled: true,
      ),
    );
  }
}
