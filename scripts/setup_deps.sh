#!/usr/bin/env bash
set -euo pipefail

# 使用 FVM 优先，否则回退到 flutter 命令
if command -v fvm >/dev/null 2>&1; then
  FLUTTER="fvm flutter"
else
  FLUTTER="flutter"
fi

echo "[1/5] 添加状态管理与代码生成依赖..."
$FLUTTER pub add hooks_riverpod riverpod_annotation
$FLUTTER pub add -d riverpod_generator build_runner

echo "[2/5] 添加数据模型与序列化依赖..."
$FLUTTER pub add freezed_annotation json_annotation
$FLUTTER pub add -d freezed json_serializable

echo "[3/5] 添加网络层依赖..."
$FLUTTER pub add dio retrofit
$FLUTTER pub add -d retrofit_generator

echo "[4/5] 添加函数式工具依赖..."
$FLUTTER pub add fpdart

echo "[5/5] 获取依赖并执行代码生成（若有）..."
$FLUTTER pub get
# 若当前还没有注解/生成器文件，build_runner 将快速结束
$FLUTTER pub run build_runner build -d || true

echo "✅ 依赖安装与代码生成完成。"
