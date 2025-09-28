# travel_planner

一个本地保存数据的旅游计划工具 App，采用 Flutter + Riverpod，地图默认使用 Google Maps（预留高德切换点）。

## 快速开始

- 依赖管理：使用 fvm 管理 Flutter 版本
- 状态管理：`flutter_riverpod`
- 本地存储：`hive` + `hive_flutter`
- 地图：`google_maps_flutter`（Android/iOS），`google_maps_flutter_web`（Web）

### 必要的 API Key 配置

本项目分为「地图渲染」与「路线计算」两类 Key：

- 地图渲染（必需）：Google Maps API Key
- 路线计算（可选）：Google Directions API Key（若未配置，将使用两点直线连接与无预估时长）

#### Android（地图渲染）

方式一：在 `android/local.properties` 添加（不提交到版本库）：
```
MAPS_API_KEY=你的_Android_Maps_API_Key
```
方式二：以环境变量注入（运行前）：
```
export MAPS_API_KEY=你的_Android_Maps_API_Key
fvm flutter run -d emulator-5554
```
确保在 Google Cloud Console 启用「Maps SDK for Android」。

#### iOS（地图渲染）

编辑 `ios/Runner/Info.plist`，设置：
```
<key>GMSApiKey</key>
<string>你的_iOS_Maps_API_Key</string>
```
并在 Apple 平台配置定位权限描述（本仓库已预置）。

#### Web（地图渲染，可选）

在 `web/index.html` 的 `<head>` 中添加：
```
<script src="https://maps.googleapis.com/maps/api/js?key=你的_Web_Maps_API_Key"></script>
```

#### Directions（路线计算，可选）

将 Directions Key 写入 `.env`（本地不提交）：`assets/env/.env`
```
GOOGLE_DIRECTIONS_API_KEY=你的_Directions_API_Key
```
若未配置，应用会以两点直线相连并无预估时长；你仍可为交通段填写自定义时长（后续界面中提供）。

## 运行与测试

- 运行到安卓模拟器：
```
fvm flutter run -d emulator-5554
```
- 单元测试：
```
fvm flutter test -r compact
```
- 集成测试（在模拟器上）：
```
fvm flutter test integration_test -d emulator-5554 -r compact
```

## 功能概览（当前阶段）

- 计划结构：`PlanGroup`（多天） + `Plan`（单天）
- 地图页面：长按添加节点；添加第二个及后续节点时自动生成交通段
- 交通方式切换：步行 / 驾车 / 公交（用于调用路线服务）
- 时间轴：按节点与交通段交替显示，展示路线预估时长（有 Key 时）
- 本地持久化：Hive 存储计划分组与日程

后续计划：
- 支持为交通段填写自定义时长，并在时间轴优先采用用户时长，同时展示地图预估时长
- 计划分组/多日切换与管理界面
- 抽象地图与路线服务环境切换，接入高德地图

### 覆盖层开关与回退

- 右上角按钮可快速开/关“自定义 POI 覆盖层”（`PlaceDenseOverlayLayer` 与 `PlaceOverlayLayer`）。
- 关闭后：
  - 不再发起附近 Places 检索与覆盖层布局；
  - 地图上仅保留原生 Marker/Polyline 渲染；
  - 便于在出现性能或显示问题时快速回退与对比。
- Provider：`overlayEnabledProvider`（位于 `lib/features/map/view/providers.dart`）。
- 默认：开启。可配合 `onMapCreated -> setMapStyle` 隐藏默认 POI 图层，避免与覆盖层重叠。

### 搜索（Places，可选）

在 `assets/env/.env` 配置 `GOOGLE_PLACES_API_KEY` 可启用地点搜索功能（页面路径 `/search`）：

```
GOOGLE_PLACES_API_KEY=你的_Places_API_Key
```

- 若未配置 Key，搜索将返回空结果，但不会影响地图、时间轴等其他功能。
- 搜索结果支持一键“加入计划”，并返回地图页查看新增节点与自动生成的路线段。
