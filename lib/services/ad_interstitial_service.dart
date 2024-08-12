import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdInterstitialService {
  AdInterstitialService(this._adInterstitialId, this._adInterstitialInterval) {
    // Create initial Ad
    _createAd();

    // Wait for interval
    _setTimer();
  }

  // Variables
  final String _adInterstitialId;
  final int _adInterstitialInterval;
  final int _maxFailedLoadAttempts = 3;
  InterstitialAd? _interstitialAd;
  bool _showAd = false; // Will be set to true after initial timer
  Timer? _timer;
  int _numFailedLoadAttempts = 0;

  _createAd() {
    if (_adInterstitialId.isEmpty) {
      return;
    }

    InterstitialAd.load(
      adUnitId: _adInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numFailedLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numFailedLoadAttempts += 1;
          _interstitialAd = null;
          if (_numFailedLoadAttempts < _maxFailedLoadAttempts) {
            _createAd();
          }
        },
      ),
    );
  }

  _setTimer() {
    // Cancel previous timer
    _timer?.cancel();

    // Set to true to show ad
    _showAd = false;

    // Wait for interval and then enable ad
    _timer = Timer(Duration(seconds: _adInterstitialInterval), () {
      _showAd = true;
    });
  }

  show() {
    // Do we have a loaded Ad
    if (_interstitialAd == null) {
      return;
    }

    // Waited enough time?
    if (_showAd == false) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createAd();
      },
    );

    // Show Ad
    _interstitialAd!.show();

    // Wait for interval
    _setTimer();

    // Cant use current Ad again so reset
    _interstitialAd = null;
  }

  dispose() {
    _interstitialAd?.dispose();
    _timer?.cancel();
  }
}
