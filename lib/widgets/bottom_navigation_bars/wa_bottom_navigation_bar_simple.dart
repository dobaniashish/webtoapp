import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/wa_bottom_navigation_bar_item_model.dart';
import '../../theme/wa_theme.dart';

class WaBottomNavigationBarSimple extends StatelessWidget {
  const WaBottomNavigationBarSimple({
    Key? key,
    this.selectedIndex = 0,
    this.containerHeight = 60,
    this.showTitle = true,
    this.showActiveTitle = true,
    required this.items,
    required this.onItemSelected,
  }) : super(key: key);

  final int selectedIndex;
  final double containerHeight;
  final bool showTitle;
  final bool showActiveTitle;
  final List<WaBottomNavigationBarItemModel> items;
  final ValueChanged<int> onItemSelected;

  List<Widget> _buildItems() {
    List<Widget> returnItems = [];

    for (var (index, item) in items.indexed) {
      final bool isSelected = index == selectedIndex;

      final Color color = WaTheme().getColor(item.color, WaTheme().colorHex);
      final Color activeColor = WaTheme().getColor(item.activeColor, WaTheme().primaryColorHex);

      final placeTitle = showTitle || showActiveTitle;

      Color titleColor = isSelected ? activeColor : color;
      double opacity = 1;

      if (showTitle != showActiveTitle) {
        titleColor = isSelected ? activeColor : Colors.transparent;
        opacity = isSelected ? 1 : 0;
      }

      returnItems.add(Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onItemSelected(index);
          },
          child: Semantics(
            container: true,
            selected: isSelected,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      if (item.icon != null && item.icon!.containsKey('svg')) {
                        final String svg = item.icon?['svg'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1.0),
                          child: SvgPicture.string(
                            svg,
                            width: 24,
                            height: 24,
                            colorFilter:
                                ColorFilter.mode(isSelected ? activeColor : color, BlendMode.srcIn),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  if (placeTitle)
                    Flexible(
                      child: AnimatedOpacity(
                        opacity: opacity,
                        duration: const Duration(milliseconds: 150),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: WaTheme().xxsmallFontSize,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            child: Text(
                              item.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ));
    }

    return returnItems;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WaTheme().bottomBarBackgroundColor,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: containerHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildItems(),
          ),
        ),
      ),
    );
  }
}
