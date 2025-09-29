import 'package:flutter/widgets.dart';

/// 已弃用：选中 Place 覆盖层。现统一使用 Marker 的 infoWindow 与面板展示详情。
class PlaceOverlayLayer extends StatelessWidget {
  const PlaceOverlayLayer({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
