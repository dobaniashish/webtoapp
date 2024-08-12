import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/wa_home_item_model.dart';
import '../../theme/wa_theme.dart';
import '../wa_button.dart';

class WaHomeItemsCards extends StatelessWidget {
  const WaHomeItemsCards({
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
        case 'cards-primary':
          buttonStyle = WaButtonStyle().primary;
          break;
        default:
      }

      returnItems.add(
        WaButton(
          style: buttonStyle,
          onTap: () {
            onTap(item);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (item.icon != null && item.icon!.containsKey('svg')) {
                    final String svg = item.icon?['svg'] ?? '';

                    return Padding(
                      padding: EdgeInsets.only(bottom: WaTheme().smallSpace),
                      child: SvgPicture.string(
                        svg,
                        width: 40,
                        height: 40,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              Text(
                item.title,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return returnItems;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: WaTheme().smallSpace,
      mainAxisSpacing: WaTheme().smallSpace,
      crossAxisCount: 2,
      children: _buildItems(),
    );
  }
}
