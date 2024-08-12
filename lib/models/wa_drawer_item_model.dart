import 'wa_action_item_model.dart';

class WaDrawerItemModel extends WaActionItemModel {
  WaDrawerItemModel({
    required target,
    required url,
    required this.icon,
    required this.title,
    this.activeColor,
    this.inactiveColor,
    this.activeBackgroundColor,
  }) : super(target: target, url: url);

  final Map<String, dynamic>? icon;
  final String title;
  final String? activeColor;
  final String? inactiveColor;
  final String? activeBackgroundColor;
}
