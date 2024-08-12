import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/wa_home_item_model.dart';
import '../../theme/wa_theme.dart';
import '../wa_button.dart';

class WaHomeItemsButtons extends StatelessWidget {
  const WaHomeItemsButtons({
    Key? key,
    required this.items,
    required this.style,
    required this.onTap,
  }) : super(key: key);

  final List<WaHomeItemModel> items;
  final String? style;
  final Function(WaHomeItemModel) onTap;

  List<Widget> _buildItems() {
    List<Widget> returnItems = [];

    for (var item in items) {
      WaButtonStyle buttonStyle = WaButtonStyle().button;

      switch (style) {
        case 'button-primary':
          buttonStyle = WaButtonStyle().primary;
          break;
        default:
      }

      returnItems.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: WaTheme().xsmallSpace),
          child: WaButton(
            style: buttonStyle,
            onTap: () {
              onTap(item);
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
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
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                Text(item.title),
              ],
            ),
          ),
        ),
      );
    }

    return returnItems;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildItems(),
    );
  }
}
