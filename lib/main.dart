import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/storage/hive_boxes.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 先加载环境变量，供 Hive 初始化时读取开关
  await dotenv.load(fileName: 'assets/env/.env');
  await HiveBoxes.init();
  runApp(const ProviderScope(child: App()));
}
