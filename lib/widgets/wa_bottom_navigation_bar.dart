import 'package:flutter/material.dart';
import '../models/wa_bottom_navigation_bar_item_model.dart';
import '../services/settings_service.dart';
import '../theme/wa_theme.dart';
import 'bottom_navigation_bars/wa_bottom_navigation_bar_pills.dart';
import 'bottom_navigation_bars/wa_bottom_navigation_bar_simple.dart';

class WaBottomNavigationBar extends StatelessWidget {
  WaBottomNavigationBar({
    Key? key,
    this.selectedIndex = 0,
    this.containerHeight = 60,
    required this.items,
    required this.onItemSelected,
  }) : super(key: key);

  final int selectedIndex;
  final double containerHeight;
  final List<WaBottomNavigationBarItemModel> items;
  final ValueChanged<int> onItemSelected;

  final settingsService = SettingsService();

  @override
  Widget build(BuildContext context) {

    final style = settingsService.getString('bottom_bar_style');

    switch (style) {
      case 'simple':
        return WaBottomNavigationBarSimple(
          selectedIndex: selectedIndex,
          items: items,
          onItemSelected: onItemSelected,
        );
      case 'simple-without-title':
        return WaBottomNavigationBarSimple(
          selectedIndex: selectedIndex,
          items: items,
          onItemSelected: onItemSelected,
          showTitle: false,
          showActiveTitle: false,
        );
      case 'simple-active-title':
        return WaBottomNavigationBarSimple(
          selectedIndex: selectedIndex,
          items: items,
          onItemSelected: onItemSelected,
          showTitle: false,
          showActiveTitle: true,
        );
      case 'pills':
        return WaBottomNavigationBarPills(
          selectedIndex: selectedIndex,
          items: items,
          onItemSelected: onItemSelected,
          borderRadius: WaTheme().borderRadius,
        );
      case 'pills-round':
        return WaBottomNavigationBarPills(
          selectedIndex: selectedIndex,
          items: items,
          onItemSelected: onItemSelected,
        );
      default:
        return WaBottomNavigationBarSimple(
          selectedIndex: selectedIndex,
          items: items,
          onItemSelected: onItemSelected,
        );
    }
  }
}
