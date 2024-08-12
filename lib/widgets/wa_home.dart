import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/wa_action_item_model.dart';
import '../models/wa_home_item_model.dart';
import '../services/settings_service.dart';
import '../theme/wa_theme.dart';
import 'home_items/wa_home_items_cards.dart';
import 'home_items/wa_home_items_buttons.dart';

class WaHome extends StatelessWidget {
  final void Function(WaActionItemModel item) handleAction;

  WaHome({super.key, required this.handleAction});

  final settingsService = SettingsService();

  List<WaHomeItemModel> _getHomeItems() {
    List<dynamic> homeItemsSettings = settingsService.get('home_screen_items') is List<dynamic>
        ? settingsService.get('home_screen_items')
        : [];

    List<WaHomeItemModel> homeItems = [];

    for (var homeItem in homeItemsSettings) {
      final target = homeItem.containsKey('target') ? homeItem['target'] : '';
      final url = homeItem.containsKey('url') ? homeItem['url'] : '';
      final Map<String, dynamic>? icon = homeItem.containsKey('icon') ? homeItem['icon'] : null;
      final title = homeItem.containsKey('title') ? homeItem['title'] : '';

      final color = homeItem.containsKey('color') ? homeItem['color'] : null;
      final backgroundColor =
          homeItem.containsKey('background_color') ? homeItem['background_color'] : null;

      homeItems.add(WaHomeItemModel(
        target: target,
        url: url,
        icon: icon,
        title: title,
        color: color,
        backgroundColor: backgroundColor,
      ));
    }

    return homeItems;
  }

  Widget _buildHomeItems(homeItems) {
    final style = settingsService.getString('home_screen_item_style');

    switch (style) {
      case 'button':
      case 'button-primary':
        return WaHomeItemsButtons(
          items: homeItems,
          style: style,
          onTap: (item) {
            handleAction(item);
          },
        );
      case 'cards':
      case 'cards-primary':
        return WaHomeItemsCards(
          items: homeItems,
          style: style,
          onTap: (item) {
            handleAction(item);
          },
        );
      default:
        return WaHomeItemsButtons(
          items: homeItems,
          style: style,
          onTap: (item) {
            handleAction(item);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? homeScreenLogo = settingsService.getString('home_screen_logo');

    final List<WaHomeItemModel> homeItems = _getHomeItems();

    DecorationImage? backgroundDecorationImage;
    String? backgroundImage = settingsService.getString('home_screen_background_image');

    if (backgroundImage != null && backgroundImage.isNotEmpty) {
      backgroundDecorationImage = DecorationImage(
        image: CachedNetworkImageProvider(backgroundImage),
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: WaTheme().homeScreenBackgroundColor,
            image: backgroundDecorationImage,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (homeScreenLogo is String) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: WaTheme().mediumSpace, vertical: WaTheme().space),
                        child: CachedNetworkImage(
                          imageUrl: homeScreenLogo,
                          fadeInDuration: const Duration(milliseconds: 0),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: WaTheme().mediumSpace, vertical: WaTheme().space),
                  child: _buildHomeItems(homeItems),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
