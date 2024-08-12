import 'wa_action_item_model.dart';

class WaHomeItemModel extends WaActionItemModel {
  WaHomeItemModel({
    required target,
    required url,
    required this.icon,
    required this.title,
    this.color,
    this.backgroundColor,
  }) : super(target: target, url: url);

  final Map<String, dynamic>? icon;
  final String title;
  final String? color;
  final String? backgroundColor;
}
