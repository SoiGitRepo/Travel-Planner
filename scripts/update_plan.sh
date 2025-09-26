#!/usr/bin/env bash
set -euo pipefail

PLAN="plan.md"
if [ ! -f "$PLAN" ]; then
  echo "plan.md 不存在，跳过。"
  exit 0
fi

# 勾选修复项 1/2/3
sed -i '' 's/- \[ \] 修复项1：设置 iOS 最低版本为 13.0（GoogleMaps iOS SDK 8+ 要求）。/- [x] 修复项1：设置 iOS 最低版本为 13.0（GoogleMaps iOS SDK 8+ 要求）。/' "$PLAN"
sed -i '' 's/- \[ \] 修复项2：为 `Info.plist` 的 `GMSApiKey` 使用 xcconfig 注入（不将密钥入库）。/- [x] 修复项2：为 `Info.plist` 的 `GMSApiKey` 使用 xcconfig 注入（不将密钥入库）。/' "$PLAN"
sed -i '' 's/- \[ \] 修复项3：创建并忽略 `ios\/Runner\/Environment.xcconfig`，通过 `Debug.xcconfig\/Release.xcconfig` 包含。/- [x] 修复项3：创建并忽略 `ios\/Runner\/Environment.xcconfig`，通过 `Debug.xcconfig\/Release.xcconfig` 包含。/' "$PLAN"

# 在“执行 pod install ...”行之后插入“下一步验证”段落（若未插入过）
if ! grep -q "^## 下一步验证$" "$PLAN"; then
  awk 'BEGIN{added=0} {
    print $0
    if ($0 ~ /执行 `pod install` 并重新运行到 iOS 设备，观察是否消除白屏。/ && added==0) {
      print ""
      print "## 下一步验证"
      print "- 在 `ios/Runner/Environment.xcconfig` 中填入有效的 `GMS_API_KEY`。"
      print "- 执行依赖安装与构建："
      print "  - 使用 FVM：`fvm flutter clean`、`fvm flutter pub get`。"
      print "  - iOS 目录安装 Pods：`pod install`。"
      print "  - 运行到设备：`fvm flutter run` 或通过 Xcode 运行。"
      print "- 如仍白屏，请收集 `fvm flutter run -v` 或 Xcode 控制台日志，以便进一步定位。"
      added=1
    }
  }' "$PLAN" > "$PLAN.tmp" && mv "$PLAN.tmp" "$PLAN"
fi

echo "plan.md 已更新。"
