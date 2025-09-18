import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:travel_planner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('应用可以启动并显示时间轴', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('时间轴'), findsOneWidget);

    // 检查顶部控件存在
    expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
  });
}
