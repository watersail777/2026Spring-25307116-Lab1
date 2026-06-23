# OnTrack · 火车路线查询应用

HarmonyOS NEXT 纯血鸿蒙应用，支持全国 16,109 趟列车的实时路线查询与换乘规划。

> 完整功能演示请观看：[ontrack视频演示.mp4](./ontrack视频演示.mp4)

---

## 架构

```
entry/src/main/ets/
├── model/
│   ├── DataModels.ets              # 数据模型：车站/列车/经停/路线节点/行程段
│   └── AppViewModel.ets            # 全局状态：搜索/筛选/收藏/Toast/进度
├── data/
│   ├── DataLoader.ets              # 异步批量解析 5 个原始数据文件 → 内存索引
│   ├── GraphBuilder.ets            # 时间扩展图构造：发车索引 + 同城换乘
│   ├── RouteFinder.ets             # 两阶段搜索：直达标扫描 O(n) + Dijkstra 最小堆
│   └── LocalStore.ets              # preferences 持久化：最近查询 + 收藏
├── pages/
│   ├── Index.ets                   # 根容器：启动屏 + 手机/平板自适应布局
│   └── tabs/
│       ├── SearchTab.ets           # 站名自动补全 + 筛选面板 + 最近查询 + 列车类型说明
│       ├── ResultsTab.ets          # 路线结果分页 + 换乘标签 + 收藏切换
│       └── FavoritesTab.ets        # 收藏路线管理：删除/重新搜索
├── components/
│   ├── StationPicker.ets           # 站名自动补全输入框
│   ├── RouteCard.ets               # 单段列车卡片（可展开经停列表）
│   ├── RouteCardList.ets           # 多段路线卡片组
│   ├── RouteMapCanvas.ets          # Canvas 地铁式路线图
│   └── BottomNavBar.ets            # 三 Tab 底部导航
├── utils/
│   └── GlobalThis.ets              # 跨 Ability 共享数据：原始字节缓冲 + 解码字符串
└── widget/pages/
    ├── OnTrackWidget.ets           # 2×2 桌面卡片：Top 3 收藏路线
    ├── OnTrackWidget4x4.ets        # 4×4 桌面卡片：详细收藏路线
    └── EntryFormAbility.ets        # 卡片数据更新（每日 10:30）
```

**状态管理**：`@ObservedV2` + `@Trace`，AppViewModel 为唯一数据源，通过 `@Require @Param` 注入子组件。

---

## 已实装功能

### 路线搜索
- **站名自动补全** — 输入城市/站名，三级匹配（精确 > 前缀 > 包含），按发车频次排序
- **直达标扫描** — O(n) 线性扫描发车索引，秒出直达结果
- **换乘搜索** — Dijkstra 最小堆搜索时间扩展图，种子启发式优先长途列车
- **同城换乘** — 自动识别同城不同站换乘（如广州南→广州站 43 分钟），过滤假同城对
- **双向编号** — 支持 K 字头等奇偶编号列车的双向查询

### 筛选与过滤
- **列车类型** — G/D/C/Z/T/K 复选框，同步检查双向编号前缀
- **换乘次数** — 0~7 次（或不限）
- **最小换乘间隔** — 10/15/20/30/60 分钟
- **仅直达** — 跳过 Dijkstra，只显示直达路线
- **起终点互换** — 一键交换出发站和到达站

### 路线展示
- **分页浏览** — 结果按换乘次数→总时间排序，上一页/下一页翻看
- **多段卡片** — 每段显示车次号、发到时间、历时，换乘类型标签（同站/过夜/长间隔）
- **经停展开** — 点击展开完整经停表，显示每站到发时刻
- **Canvas 路线图** — 地铁式水平线路图，圆点标注站名，虚线标注换乘

### 收藏系统
- **路线收藏** — 最多保存 50 条，持久化存储
- **收藏管理** — 列表查看、删除、重新搜索
- **桌面 Widget** — 2×2 和 4×4 两种尺寸，每日 10:30 自动更新
- **Widget 跳转** — 点击 Widget 直接打开收藏页

### 启动与数据
- **启动屏** — 进度条 + 加载状态提示
- **5 个原始数据文件** — 16,109 趟列车、数千车站、同城换乘时间表
- **分批异步解析** — 每 200 趟列车 yield 一次 UI，避免阻塞
- **内存索引** — 按车站聚合的发车索引，O(log n) 二分查找

### 智能反馈
- **无结果建议** — 列出同城其他车站 + 建议使用更宽泛的城市名
- **最近查询** — 最近 20 条查询记录，可点击重新搜索
- **列车类型说明** — 弹窗解释 G/D/C/Z/T/K 各类列车速度与示例

### 多端适配
- **手机** — 底部导航三 Tab 切换
- **平板** — 侧边栏布局，搜索与结果同屏显示
- **原子化服务** — 免安装即时体验（InstantAbility）
- **跨设备流转** — Continuable，切换设备保持当前 Tab

---

## 技术栈

| 层 | 技术 |
|---|---|
| 框架 | HarmonyOS NEXT · ArkTS · ArkUI |
| 状态管理 | @ObservedV2 / @Trace / @ComponentV2 |
| 路由算法 | Dijkstra 最小堆 + 直达标线性扫描 |
| 数据解析 | 5 个 rawfile 分批异步解析 |
| 持久化 | @kit.ArkData · preferences |
| Canvas | Canvas2D 地铁式路线图绘制 |
| 桌面卡片 | FormExtensionAbility + 2×2/4×4 Widget |
| 原子化服务 | InstantAbility 免安装入口 |
| 流转 | Continuable 跨设备接续 |
| 构建 | hvigor · oh-package |

---

## 数据来源

全国铁路列车时刻表（截至 2025-12-30），含 16,109 趟列车、数千车站。格式为 tab 分隔文本文件：

| 文件 | 大小 | 内容 |
|---|---|---|
| `station_coords.txt` | 136 KB | 站名 + 经纬度 |
| `train_schedule.txt` | 2.8 MB | 列车车次 + 经停表 |
| `same_city.txt` | 1.4 KB | 同城换乘站对 + 耗时 |
| `train_dual_numbers.txt` | 62 KB | 列车奇偶编号对 |
| `false_same_city.txt` | 0.2 KB | 伪同城站名黑名单 |

## 构建运行

1. DevEco Studio 打开本目录
2. 等待依赖同步
3. 选择模拟器或真机，点击 Run

HarmonyOS API Level: 22+
