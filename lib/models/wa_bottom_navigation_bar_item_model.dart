import 'wa_action_item_model.dart';

class WaBottomNavigationBarItemModel extends WaActionItemModel {
  WaBottomNavigationBarItemModel({
    required target,
    required url,
    required this.icon,
    required this.title,
    this.color,
    this.activeColor,
    this.activeBackgroundColor,
  }) : super(target: target, url: url);

  final Map<String, dynamic>? icon;
  final String title;
  final String? color;
  final String? activeColor;
  final String? activeBackgroundColor;
}
