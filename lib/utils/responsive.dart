import 'package:flutter/material.dart';

class Breakpoints {
  static const double compact = 360;
  static const double medium = 600;
  static const double expanded = 840;
}

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isSmallPhone => screenWidth < 360 || screenHeight < 700;
  bool get isTablet => screenWidth >= Breakpoints.medium;
  bool get isWide => screenWidth >= Breakpoints.expanded;

  double get pagePadding {
    if (screenWidth < Breakpoints.compact) return 16;
    if (screenWidth < Breakpoints.medium) return 24;
    return 32;
  }

  EdgeInsets get pageInsets => EdgeInsets.symmetric(
        horizontal: pagePadding,
        vertical: isSmallPhone ? 12 : 20,
      );

  double get maxContentWidth {
    if (isWide) return 560;
    if (isTablet) return 520;
    return screenWidth;
  }

  /// Scale a value designed for a 390pt-wide phone.
  double sp(double size) {
    final scale = (screenWidth / 390).clamp(0.88, 1.12);
    return size * scale;
  }

  Widget constrainContent({required Widget child}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
