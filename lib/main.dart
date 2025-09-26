import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/storage/hive_boxes.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 先加载环境变量，供 Hive 初始化时读取开关
  try {
    await dotenv.load(fileName: 'assets/env/.env');
  } catch (e) {
    // 当 .env 不存在或加载失败时，跳过并使用默认降级策略
    debugPrint('dotenv load skipped: $e');
  }
  await HiveBoxes.init();
  runApp(const ProviderScope(child: App()));
}
