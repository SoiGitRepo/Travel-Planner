import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:travel_planner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('应用可以启动并显示时间轴', (WidgetTester tester) async {
    await app.main();
    // 避免 pumpAndSettle 在平台视图场景下永不稳定，改用轮询等待
    final timelineFinder = find.text('时间轴');
    var appeared = false;
    for (var i = 0; i < 100; i++) { // 最长 ~10s
      await tester.pump(const Duration(milliseconds: 100));
      if (timelineFinder.evaluate().isNotEmpty) { appeared = true; break; }
    }
    expect(appeared, isTrue, reason: '时间轴未在预期时间内出现');

    // 检查顶部控件存在
    // 顶部“适配视野”按钮图标
    expect(find.byIcon(Icons.center_focus_strong), findsWidgets);
  });
}
