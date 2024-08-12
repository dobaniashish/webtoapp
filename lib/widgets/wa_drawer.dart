import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/wa_drawer_item_model.dart';
import '../services/settings_service.dart';
import '../theme/wa_theme.dart';

class WaDrawer extends StatelessWidget {
  WaDrawer({
    Key? key,
    this.selectedIndex = 0,
    required this.items,
    required this.onItemSelected,
  }) : super(key: key);

  final int selectedIndex;
  final List<WaDrawerItemModel> items;
  final ValueChanged<int> onItemSelected;

  final settingsService = SettingsService();

  List<Widget> _buildDrawerItems() {
    List<Widget> drawerItems = [];

    for (var (index, item) in items.indexed) {
      final bool isSelected = index == selectedIndex;

      final Color color = WaTheme().getColor(item.inactiveColor, WaTheme().colorHex);
      final activeColor = WaTheme().getColor(item.activeColor, WaTheme().buttonColorHex);
      final activeBackgroundColor =
          WaTheme().getColor(item.activeBackgroundColor, WaTheme().buttonBackgroundColorHex);

      drawerItems.add(GestureDetector(
        onTap: () {
          onItemSelected(index);
        },
        child: Semantics(
          container: true,
          selected: isSelected,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
            width: double.maxFinite,
            margin: EdgeInsets.symmetric(horizontal: WaTheme().space),
            decoration: BoxDecoration(
              color: isSelected ? activeBackgroundColor : Colors.transparent,
              borderRadius: BorderRadius.circular(WaTheme().borderRadius),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: WaTheme().smallSpace,
                vertical: WaTheme().smallSpace,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      if (item.icon != null && item.icon!.containsKey('svg')) {
                        final String svg = item.icon?['svg'] ?? '';

                        return Padding(
                          padding: EdgeInsets.only(right: WaTheme().smallSpace),
                          child: SvgPicture.string(
                            svg,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              isSelected ? activeColor : color,
                              BlendMode.srcIn,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: isSelected ? activeColor : color,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    child: Text(item.title),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }

    return drawerItems;
  }

  @override
  Widget build(BuildContext context) {
    final String? drawerLogo = settingsService.getString('drawer_logo');

    return Drawer(
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: WaTheme().backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (drawerLogo is String)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: WaTheme().mediumSpace,
                    horizontal: WaTheme().space,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: drawerLogo,
                    height: 60,
                    alignment: Alignment.centerLeft,
                    fadeInDuration: const Duration(milliseconds: 0),
                  ),
                ),
              Column(
                children: _buildDrawerItems(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
