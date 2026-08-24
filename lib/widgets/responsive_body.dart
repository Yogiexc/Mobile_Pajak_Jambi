import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scroll;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.padding,
    this.scroll = false,
  });

  @override
  Widget build(BuildContext context) {
    final insets = padding ?? context.pageInsets;
    final content = context.constrainContent(child: child);

    if (scroll) {
      return SingleChildScrollView(
        padding: insets,
        child: content,
      );
    }

    return Padding(
      padding: insets,
      child: content,
    );
  }
}
