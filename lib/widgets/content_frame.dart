import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Centres [child] in a column no wider than [maxWidth] once the screen is wider
/// than that (tablets, landscape); on phones it passes [child] through untouched.
class ContentFrame extends StatelessWidget {
  final Widget child; final double maxWidth;
  const ContentFrame({super.key, required this.child, this.maxWidth = AppLayout.maxContentWidth});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) => c.maxWidth <= maxWidth
      ? child
      : Center(child: SizedBox(width: maxWidth, height: c.maxHeight, child: child)));
}
