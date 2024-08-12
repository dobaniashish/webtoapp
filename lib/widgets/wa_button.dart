import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/wa_theme.dart';
import '../utils/common.dart';

class WaButton extends StatefulWidget {
  const WaButton({
    Key? key,
    this.onTap,
    this.style,
    required this.child,
    this.icon,
  }) : super(key: key);

  final Widget child;
  final Widget? icon;
  final Function()? onTap;
  final WaButtonStyle? style;

  @override
  State<WaButton> createState() => _WaButtonState();
}

class _WaButtonState extends State<WaButton> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    Color? color = _active ? widget.style?.activeColor : widget.style?.color;
    Color? backgroundColor =
        _active ? widget.style?.activeBackgroundColor : widget.style?.backgroundColor;

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _active = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          _active = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _active = false;
        });
      },
      onTap: widget.onTap,
      child: DefaultSvgTheme(
        theme: SvgTheme(
          currentColor: color ?? Colors.black,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: color,
            fontSize: widget.style?.fontSize,
          ),
          child: AnimatedContainer(
            width: widget.style?.width,
            height: widget.style?.height,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: widget.style?.borderRadius,
            ),
            padding: widget.style?.padding,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class WaButtonStyle {
  WaButtonStyle({
    this.color = Colors.blue,
    this.backgroundColor = Colors.white,
    this.activeColor = Colors.blue,
    this.activeBackgroundColor = Colors.white,
    this.fontSize = 14,
    this.width,
    this.height = 60,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 32,
    ),
    this.borderRadius,
  });

  final Color color;
  final Color backgroundColor;
  final Color activeColor;
  final Color activeBackgroundColor;
  final double fontSize;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  WaButtonStyle get button {
    return copyWith(
      color: WaTheme().buttonColor,
      backgroundColor: WaTheme().buttonBackgroundColor,
      activeColor: WaTheme().buttonColor,
      activeBackgroundColor: darken(WaTheme().buttonBackgroundColor, 0.1),
      fontSize: WaTheme().fontSize,
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: WaTheme().rem * 2,
      ),
      borderRadius: BorderRadius.circular(WaTheme().borderRadius),
    );
  }

  WaButtonStyle get primary {
    return button.copyWith(
      color: WaTheme().primaryButtonColor,
      backgroundColor: WaTheme().primaryButtonBackgroundColor,
      activeColor: WaTheme().primaryButtonColor,
      activeBackgroundColor: darken(WaTheme().primaryButtonBackgroundColor, 0.1),
    );
  }

  WaButtonStyle get text {
    return button.copyWith(
      backgroundColor: Colors.transparent,
      activeBackgroundColor: WaTheme().buttonBackgroundColor.withOpacity(0.1),
    );
  }

  WaButtonStyle get small {
    return copyWith(
      fontSize: WaTheme().smallFontSize,
      height: 40,
      padding: EdgeInsets.symmetric(
        horizontal: WaTheme().rem * 1.2,
      ),
    );
  }

  WaButtonStyle copyWith({
    Color? color,
    Color? backgroundColor,
    Color? activeColor,
    Color? activeBackgroundColor,
    final double? fontSize,
    final double? width,
    final double? height,
    final EdgeInsetsGeometry? padding,
    final BorderRadius? borderRadius,
  }) {
    return WaButtonStyle(
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      activeBackgroundColor: activeBackgroundColor ?? this.activeBackgroundColor,
      fontSize: fontSize ?? this.fontSize,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
