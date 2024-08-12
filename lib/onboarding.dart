import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'services/preferences_service.dart';
import 'services/settings_service.dart';
import 'theme/wa_theme.dart';
import 'utils/common.dart';
import 'widgets/wa_button.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final settingsService = SettingsService();
  final preferencesService = PreferencesService();

  final PageController _pageController = PageController();

  List<dynamic> onboardingScreens = [];

  int _currentPage = 0;
  bool _lastPage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _lastPage = _currentPage == onboardingScreens.length - 1 ? true : false;
    });
  }

  void _finishOnboarding() async {
    await preferencesService.setBool('onboarding_screen_shown', true);

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(showHomeScreen() ? '/' : 'dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    onboardingScreens = settingsService.get('onboarding_screens') is List<dynamic>
        ? settingsService.get('onboarding_screens')
        : [];

    Color onboardingScreenBackgroundColor = WaTheme().onboardingScreenBackgroundColor;

    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onboardingScreenBackgroundColor,
          ),
          child: Stack(
            children: <Widget>[
              PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                allowImplicitScrolling: true,
                children: <Widget>[
                  for (var onboardingScreen in onboardingScreens)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              if (onboardingScreen.containsKey('image') &&
                                  onboardingScreen['image'] is String) {
                                return CachedNetworkImage(
                                  imageUrl: onboardingScreen['image'],
                                  height: (MediaQuery.of(context).size.height / 100) * 30,
                                  fadeInDuration: const Duration(milliseconds: 0),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 30),
                          Text(
                            onboardingScreen['title'],
                            style: WaTheme().onboardingTitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            onboardingScreen['description'],
                            style: WaTheme().onboardingDescription,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.all(WaTheme().space),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      WaButton(
                        style: WaButtonStyle().text.small,
                        onTap: () {
                          _finishOnboarding();
                        },
                        child: const Row(
                          children: [
                            Text('Skip'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 150),
                        firstChild: Padding(
                          padding: EdgeInsets.all(WaTheme().space),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Row(
                                  children: List.generate(
                                    onboardingScreens.length,
                                    (index) {
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                        height: 8,
                                        width: index == _currentPage ? 16 : 8,
                                        decoration: BoxDecoration(
                                          color: index == _currentPage
                                              ? WaTheme().primaryBackgroundColor
                                              : WaTheme().primaryBackgroundColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              WaButton(
                                style: WaButtonStyle().button.small,
                                onTap: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Text('Continue'),
                                    SvgPicture.string(
                                      WaTheme().chevronRightIcon,
                                      width: WaButtonStyle().button.small.fontSize * 1.5,
                                      height: WaButtonStyle().button.small.fontSize * 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondChild: Padding(
                          padding: EdgeInsets.all(WaTheme().space),
                          child: Column(
                            children: <Widget>[
                              WaButton(
                                style: WaButtonStyle().primary,
                                onTap: () {
                                  _finishOnboarding();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Continue'),
                                    SvgPicture.string(
                                      WaTheme().chevronRightIcon,
                                      width: WaButtonStyle().button.fontSize * 1.5,
                                      height: WaButtonStyle().button.fontSize * 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        crossFadeState:
                            _lastPage ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
