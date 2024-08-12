import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/wa_bottom_navigation_bar_item_model.dart';
import '../../theme/wa_theme.dart';

class WaBottomNavigationBarPills extends StatelessWidget {
  const WaBottomNavigationBarPills({
    Key? key,
    this.selectedIndex = 0,
    this.containerHeight = 60,
    this.borderRadius = 50,
    required this.items,
    required this.onItemSelected,
  }) : super(key: key);

  final int selectedIndex;
  final double containerHeight;
  final double borderRadius;
  final List<WaBottomNavigationBarItemModel> items;
  final ValueChanged<int> onItemSelected;

  List<Widget> _buildItems() {
    List<Widget> returnItems = [];

    for (var (index, item) in items.indexed) {
      final bool isSelected = index == selectedIndex;

      final color = WaTheme().getColor(item.color, WaTheme().colorHex);
      final activeColor = WaTheme().getColor(item.activeColor, WaTheme().buttonColorHex);
      final activeBackgroundColor =
          WaTheme().getColor(item.activeBackgroundColor, WaTheme().buttonBackgroundColorHex);

      double width = isSelected ? 130 : 50;

      returnItems.add(Flexible(
        flex: isSelected ? 2 : 1,
        child: GestureDetector(
          onTap: () {
            onItemSelected(index);
          },
          child: Semantics(
            container: true,
            selected: isSelected,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: WaTheme().xsmallSpace, horizontal: WaTheme().xsmallSpace),
              child: AnimatedContainer(
                width: width,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: WaTheme().xsmallSpace),
                decoration: BoxDecoration(
                  color: isSelected ? activeBackgroundColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          if (item.icon != null && item.icon!.containsKey('svg')) {
                            final String svg = item.icon?['svg'] ?? '';

                            return SvgPicture.string(
                              svg,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  isSelected ? activeColor : color, BlendMode.srcIn),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                      if (isSelected)
                        Flexible(
                          child: Container(
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                color: activeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: WaTheme().xsmallFontSize,
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
                    ],
                  ),
                ),
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
