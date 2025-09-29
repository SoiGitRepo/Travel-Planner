import 'package:flutter/widgets.dart';

/// 已弃用：密集覆盖层。现统一使用 Google Map Marker 渲染。
class PlaceDenseOverlayLayer extends StatelessWidget {
  const PlaceDenseOverlayLayer({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
