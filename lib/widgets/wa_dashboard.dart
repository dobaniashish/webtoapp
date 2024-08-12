import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/wa_action_item_model.dart';
import '../models/wa_bottom_navigation_bar_item_model.dart';
import '../models/wa_drawer_item_model.dart';
import '../services/settings_service.dart';
import '../theme/wa_theme.dart';
import '../utils/common.dart';
import 'wa_bottom_navigation_bar.dart';
import 'wa_drawer.dart';

class WaDashboard extends StatefulWidget {
  final void Function(WaActionItemModel item) handleAction;
  final String? url;

  const WaDashboard({super.key, required this.handleAction, this.url});

  @override
  State<WaDashboard> createState() => WaDashboardState();
}

class WaDashboardState extends State<WaDashboard> {
  final settingsService = SettingsService();

  BannerAd? _adBannerTop;
  BannerAd? _adBannerBottom;

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  String currentUrl = '';
  String currentTitle = '';
  int progress = 0;

  List<WaDrawerItemModel> drawerItems = [];
  int _currentDrawerIndex = 0;

  List<WaBottomNavigationBarItemModel> bottomBarItems = [];
  int _currentBottomBarIndex = 0;

  @override
  void initState() {
    super.initState();

    if (showAds()) {
      _loadAds();
    }

    if (settingsService.getBool('webview_pull_to_refresh') ?? false) {
      pullToRefreshController = PullToRefreshController(
        settings: PullToRefreshSettings(
          color: WaTheme().primaryColor,
        ),
        onRefresh: () async {
          if (defaultTargetPlatform == TargetPlatform.android) {
            webViewController?.reload();
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            webViewController?.loadUrl(
              urlRequest: URLRequest(
                url: await webViewController?.getUrl(),
              ),
            );
          }
        },
      );
    }

    _initDrawerItems();
    _initBottomBarItems();
  }

  void _loadAds() async {
    final adBannerId = defaultTargetPlatform == TargetPlatform.android
        ? settingsService.getString('ad_banner_id_android')
        : settingsService.getString('ad_banner_id_ios');

    if (showAdBannerTop() && adBannerId != null && adBannerId.isNotEmpty) {
      BannerAd(
        adUnitId: adBannerId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _adBannerTop = ad as BannerAd;
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            // Dispose the ad here to free resources.
            ad.dispose();
          },
        ),
      ).load();
    }

    if (showAdBannerBottom() && adBannerId != null && adBannerId.isNotEmpty) {
      BannerAd(
        adUnitId: adBannerId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _adBannerBottom = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, err) {
            // Dispose the ad here to free resources.
            ad.dispose();
          },
        ),
      ).load();
    }
  }

  void _initDrawerItems() {
    List<dynamic> drawerItemsSettings = settingsService.get('drawer_items') is List<dynamic>
        ? settingsService.get('drawer_items')
        : [];

    drawerItems = [];

    for (var (index, drawerItem) in drawerItemsSettings.indexed) {
      final target = drawerItem.containsKey('target') ? drawerItem['target'] : '';
      final url = drawerItem.containsKey('url') ? drawerItem['url'] : '';
      final Map<String, dynamic>? icon = drawerItem.containsKey('icon') ? drawerItem['icon'] : null;
      final title = drawerItem.containsKey('title') ? drawerItem['title'] : '';

      drawerItems.add(WaDrawerItemModel(
        target: target,
        url: url,
        icon: icon,
        title: title,
      ));

      // Set selected
      final selected = drawerItem.containsKey('selected') && (drawerItem['selected'] is bool)
          ? drawerItem['selected']
          : false;
      if (selected) {
        _currentDrawerIndex = index;
      }
    }
  }

  void _initBottomBarItems() {
    List<dynamic> bottomBarItemsSettings = settingsService.get('bottom_bar_items') is List<dynamic>
        ? settingsService.get('bottom_bar_items')
        : [];

    bottomBarItems = [];

    for (var (index, bottomBarItem) in bottomBarItemsSettings.indexed) {
      final target = bottomBarItem.containsKey('target') ? bottomBarItem['target'] : '';
      final url = bottomBarItem.containsKey('url') ? bottomBarItem['url'] : '';
      final Map<String, dynamic>? icon =
          bottomBarItem.containsKey('icon') ? bottomBarItem['icon'] : null;
      final title = bottomBarItem.containsKey('title') ? bottomBarItem['title'] : '';

      final color = bottomBarItem.containsKey('color') ? bottomBarItem['color'] : null;
      final activeColor =
          bottomBarItem.containsKey('active_color') ? bottomBarItem['active_color'] : null;
      final activeBackgroundColor = bottomBarItem.containsKey('active_background_color')
          ? bottomBarItem['active_background_color']
          : null;

      bottomBarItems.add(WaBottomNavigationBarItemModel(
        target: target,
        url: url,
        icon: icon,
        title: title,
        color: color,
        activeColor: activeColor,
        activeBackgroundColor: activeBackgroundColor,
      ));

      // Set selected
      final selected = bottomBarItem.containsKey('selected') && (bottomBarItem['selected'] is bool)
          ? bottomBarItem['selected']
          : false;
      if (selected) {
        _currentBottomBarIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _adBannerTop?.dispose();
    _adBannerBottom?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // App bar
    final bool? enableAppBar = settingsService.getBool('enable_app_bar');
    final bool? appBarBackButton = settingsService.getBool('app_bar_back_button');
    final String? appBarTitleSettings = settingsService.getString('app_bar_title');
    final bool? appBarWebPageTitle = settingsService.getBool('app_bar_web_page_title');

    String appBarTitle = appBarTitleSettings ?? '';
    if (appBarWebPageTitle == true) {
      appBarTitle = currentTitle.isNotEmpty ? currentTitle : appBarTitle;
    }

    // App bar drawer
    final bool? enableDrawer = settingsService.getBool('enable_drawer');

    // Bottom bar
    final bool? enableBottomBar = settingsService.getBool('enable_bottom_bar');

    // Allowed urls
    final List<String> allowedUrlsRegexStrings = [];
    final List<dynamic>? allowedUrlsRegexStringsSetting = settingsService.getList('allowed_urls');
    if (allowedUrlsRegexStringsSetting != null) {
      for (final allowedUrlsRegexString in allowedUrlsRegexStringsSetting) {
        allowedUrlsRegexStrings.add(allowedUrlsRegexString['regex'].toString());
      }
    }

    // Inject code
    final String? injectCSS = settingsService.getString('inject_css');
    final String? injectJavascript = settingsService.getString('inject_javascript');

    // User agent
    final String? userAgent = defaultTargetPlatform == TargetPlatform.android
        ? settingsService.getString('user_agent_android')
        : settingsService.getString('user_agent_ios');
    String defaultUserAgent = '';
    String? currentUserAgent = userAgent;

    // User agent regexes
    final List<Map<String, String>> userAgentRegexStrings = [];
    final List<dynamic>? userAgentRegexStringsSetting =
        settingsService.getList('user_agent_regexes');
    if (userAgentRegexStringsSetting != null) {
      for (final userAgentRegexString in userAgentRegexStringsSetting) {
        userAgentRegexStrings.add({
          'regex': userAgentRegexString['regex'],
          'android': userAgentRegexString['android'],
          'ios': userAgentRegexString['ios'],
        });
      }
    }

    // Extract the arguments from the current ModalRoute settings and cast them as Map<String, dynamic>
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Use Widgets's url parameter first, next, route argument, next settings main_url, next example url
    final String url = widget.url ??
        args?['url'] ??
        settingsService.getString('main_url') ??
        'https://example.com';

    InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      useHybridComposition: true,
      allowsBackForwardNavigationGestures: true,

      // From settings
      clearCache: settingsService.getBool('webview_clear_cache'),
      verticalScrollBarEnabled: settingsService.getBool('webview_vertical_scroll_bar_enabled'),
      horizontalScrollBarEnabled: settingsService.getBool('webview_horizontal_scroll_bar_enabled'),
      disableVerticalScroll: settingsService.getBool('webview_disable_vertical_scroll'),
      disableHorizontalScroll: settingsService.getBool('webview_disable_horizontal_scroll'),
      mediaPlaybackRequiresUserGesture:
          settingsService.getBool('webview_media_playback_requires_user_gesture'),
      disableContextMenu: settingsService.getBool('webview_disable_context_menu'),
      allowsLinkPreview: settingsService.getBool('webview_allows_link_preview'),
      supportZoom: settingsService.getBool('webview_support_zoom'),
      userAgent: userAgent,
    );

    return WillPopScope(
      onWillPop: () async {
        if (await webViewController!.canGoBack()) {
          webViewController!.goBack();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: enableAppBar == true
            ? AppBar(
                leading: (enableDrawer == false &&
                        appBarBackButton == true &&
                        // Has back page?
                        (ModalRoute.of(context)?.impliesAppBarDismissal ?? false))
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
                // Try to automatically add leading only when Drawer is shown
                automaticallyImplyLeading: enableDrawer == true,
                title: Text(appBarTitle),
                elevation: 0,
                backgroundColor: WaTheme().appBarBackgroundColor,
                foregroundColor: WaTheme().appBarColor,
              )
            : null,
        drawer: enableDrawer == true
            ? WaDrawer(
                selectedIndex: _currentDrawerIndex,
                items: drawerItems,
                onItemSelected: (index) {
                  setState(() {
                    Navigator.of(context).pop();
                    _currentDrawerIndex = index;

                    widget.handleAction(drawerItems[index]);
                  });
                },
              )
            : null,
        bottomNavigationBar: (enableBottomBar == true && bottomBarItems.isNotEmpty)
            ? WaBottomNavigationBar(
                selectedIndex: _currentBottomBarIndex,
                items: bottomBarItems,
                onItemSelected: (index) {
                  setState(() {
                    _currentBottomBarIndex = index;

                    widget.handleAction(bottomBarItems[index]);
                  });
                },
              )
            : null,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (_adBannerTop != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: SizedBox(
                      width: _adBannerTop!.size.width.toDouble(),
                      height: _adBannerTop!.size.height.toDouble(),
                      child: AdWidget(ad: _adBannerTop!),
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(
                        url: WebUri(url),
                      ),
                      initialSettings: settings,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) async {
                        currentTitle = await controller.getTitle() ?? '';

                        if (mounted) {
                          setState(() {
                            currentUrl = url.toString();
                            currentTitle = currentTitle;
                          });
                        }
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                          resources: request.resources,
                          action: PermissionResponseAction.GRANT,
                        );
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        final url = navigationAction.request.url!;
                        final urlString = url.toString();

                        // Determine useragent
                        String? userAgentForCurrentRequest = userAgent;

                        if (['http', 'https'].contains(url.scheme)) {
                          for (final userAgentRegexString in userAgentRegexStrings) {
                            final regexp = RegExp(r'' + userAgentRegexString['regex'].toString());

                            if (regexp.hasMatch(urlString)) {
                              String userAgentMatch =
                                  defaultTargetPlatform == TargetPlatform.android
                                      ? userAgentRegexString['android'].toString()
                                      : userAgentRegexString['ios'].toString();

                              userAgentForCurrentRequest =
                                  userAgentMatch.isNotEmpty ? userAgentMatch : userAgent;
                            }
                          }
                        }

                        if (userAgentForCurrentRequest != currentUserAgent) {
                          // Set current user agent
                          setState(() {
                            currentUserAgent = userAgentForCurrentRequest;
                          });

                          // If the user agent is empty or null, we need to set default user agent other wise it will not replace the previously set user agent.
                          if (userAgentForCurrentRequest == null ||
                              userAgentForCurrentRequest.isEmpty) {
                            // If we have not set defaultUserAgent previously, set it now
                            if (defaultUserAgent.isEmpty) {
                              defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
                            }

                            userAgentForCurrentRequest = defaultUserAgent;
                          }

                          // Update settings with new user agent
                          settings.userAgent = userAgentForCurrentRequest;

                          await controller.setSettings(
                            settings: settings,
                          );
                        }

                        // Allowed protocols
                        if (['http', 'https', 'chrome', 'data', 'javascript', 'about']
                            .contains(url.scheme)) {
                          for (final regexString in allowedUrlsRegexStrings) {
                            final regexp = RegExp(r'' + regexString);

                            if (regexp.hasMatch(urlString)) {
                              // Tell the parent to show ad
                              widget.handleAction(WaActionItemModel(
                                target: 'webview-navigation',
                                url: urlString,
                              ));

                              // Allow navigation
                              return NavigationActionPolicy.ALLOW;
                            }
                          }
                        }

                        // Maps intent on Android
                        if (defaultTargetPlatform == TargetPlatform.android &&
                            urlString.startsWith('intent://maps')) {
                          String mapsUrlString = urlString.replaceAll("intent://", "https://");
                          Uri mapsUrl = Uri.parse(mapsUrlString);
                          if (await canLaunchUrl(mapsUrl)) {
                            await launchUrl(
                              mapsUrl,
                              mode: LaunchMode.externalApplication,
                            );

                            // Reset progress
                            if (mounted) {
                              setState(() {
                                progress = 100;
                              });
                            }

                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        // Launch externally
                        if (await canLaunchUrl(url)) {
                          // Launch the App
                          await launchUrl(url);

                          // Reset progress
                          if (mounted) {
                            setState(() {
                              progress = 100;
                            });
                          }

                          return NavigationActionPolicy.CANCEL;
                        }

                        // Try to launch even if canLaunchUrl returns false
                        try {
                          await launchUrl(url);

                          // Reset progress
                          if (mounted) {
                            setState(() {
                              progress = 100;
                            });
                          }

                          return NavigationActionPolicy.CANCEL;
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Cannot launch url.'),
                            ));
                          }

                          // Reset progress
                          if (mounted) {
                            setState(() {
                              progress = 100;
                            });
                          }

                          return NavigationActionPolicy.CANCEL;
                        }
                      },
                      onLoadStop: (controller, url) async {
                        if (injectCSS != null) {
                          await controller.injectCSSCode(source: injectCSS);
                        }
                        if (injectJavascript != null) {
                          await controller.evaluateJavascript(source: injectJavascript);
                        }

                        pullToRefreshController?.endRefreshing();

                        currentTitle = await controller.getTitle() ?? '';

                        if (mounted) {
                          setState(() {
                            currentUrl = url.toString();
                            currentTitle = currentTitle;
                          });
                        }
                      },
                      onReceivedError: (controller, request, error) {
                        pullToRefreshController?.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress;
                        });
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        setState(() {
                          currentUrl = url.toString();
                        });
                      },
                      onTitleChanged: (controller, title) {
                        setState(() {
                          currentTitle = title ?? '';
                        });
                      },
                      onDownloadStartRequest: (controller, downloadStartRequest) async {
                        // Reset progress
                        if (mounted) {
                          setState(() {
                            progress = 100;
                          });
                        }

                        widget.handleAction(WaActionItemModel(
                          target: 'download',
                          url: downloadStartRequest.url.toString(),
                        ));
                      },
                      onGeolocationPermissionsShowPrompt: (controller, origin) async {
                        return GeolocationPermissionShowPromptResponse(
                          origin: origin,
                          allow: true,
                          retain: true,
                        );
                      },
                    ),
                    if (progress < 80)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Center(
                          child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(
                              color: WaTheme().primaryColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_adBannerBottom != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: SizedBox(
                      width: _adBannerBottom!.size.width.toDouble(),
                      height: _adBannerBottom!.size.height.toDouble(),
                      child: AdWidget(ad: _adBannerBottom!),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
