# 知域 P0 重构 — 需求与实施计划

## 决策摘要

| 决策项 | 结论 |
|---|---|
| 架构 | @ComponentV2 + Tabs + 共享 AppViewModel |
| 目标设备 | Phone · 折叠屏展开 · Tablet 横屏 · Watch |
| 登录 | 华为 Account Kit（延后），Dev 模式 Mock |
| UGC | 延后至 P2 |
| 附近圈 | 准实时拉取（延后至 P1） |
| 数据同步 | 本地优先（CloudDB 延后至 P1） |
| AI API | 移除 DeepSeek Key，纯预设卡片 |
| 图片策略 | 纯文字卡片 + 分类 SVG 插画点缀 |
| 服务端 | CloudDB（延后至 P1） |

---

## 一、架构解耦

### 当前问题

- `pages/Index.ets` 694 行，4 个 Tab 全部内联 `@Builder`
- `pages/FavoritesPage.ets` / `NearbyPage.ets` / `ProfilePage.ets` 存在但未被使用（死代码）
- 卡片状态（收藏/点赞）散落在 Index 中，KnowledgeCard 组件不闭环
- 无法独立测试单个 Tab，修改一处影响全部

### 目标架构

```
entry/src/main/ets/
├── model/
│   └── KnowledgeItem.ets          # 数据模型（保留，扩展）
│   └── AppViewModel.ets           # 新增：全局共享状态
├── pages/
│   └── Index.ets                  # 主容器（精简到 ~100 行）
│   └── tabs/
│       └── BrowseTab.ets          # 发现页（卡片浏览 + AI 生成入口）
│       └── FavoritesTab.ets       # 收藏页
│       └── NearbyTab.ets          # 附近圈
│       └── ProfileTab.ets         # 我的
├── components/
│   └── KnowledgeCard.ets          # 卡片（重构：自包含交互按钮）
│   └── CardActionBar.ets          # 新增：卡片底部操作栏
│   └── CategoryIcon.ets           # 新增：分类 SVG 插画
│   └── BottomNavBar.ets           # 新增：底部导航栏（独立组件）
│   └── EmptyPlaceholder.ets       # 新增：空状态插画
├── data/
│   └── LocalStore.ets             # 保留，接口层不变
│   └── FallbackData.ets           # 保留，18 张预设卡
├── utils/
│   └── ColorPool.ets              # 保留
│   └── GlobalThis.ets             # 保留
│   └── LocationHelper.ets         # 保留
│   └── NFCExchange.ets            # 保留
│   └── ResponsiveBreakpoints.ets  # 新增：多端断点工具
├── watch/                          # 新增：Watch 独立目录
│   └── pages/
│       └── WatchCardPage.ets      # Watch 单卡片 glance
├── widget/                         # 保留
│   └── pages/
│       └── DailyCardWidget.ets
│       └── DailyCardWidgetLarge.ets
```

### AppViewModel 设计（@ObservedV2）

```typescript
// model/AppViewModel.ets
@ObservedV2
export class AppViewModel {
  @Trace cards: KnowledgeItem[] = []          // 所有卡片
  @Trace currentIndex: number = 0             // 当前卡片索引
  @Trace favorites: KnowledgeItem[] = []      // 收藏列表
  @Trace nearbyCards: KnowledgeItem[] = []    // 附近圈列表
  @Trace profile: UserProfile = new UserProfile()
  @Trace isGenerating: boolean = false        // AI 生成状态（P1 恢复）
  @Trace toastMsg: string = ''

  // 方法：切换卡片 / 收藏 / 点赞 / 分享
  // 内部调用 LocalStore，UI 层只读 this.xxx
}
```

Index.ets 精简后只负责：创建 AppViewModel 实例 → 渲染 Tabs + BottomNavBar → 按 currentTab 显示对应子组件。

### 保留的独立页面文件

现有的 `FavoritesPage.ets` / `NearbyPage.ets` / `ProfilePage.ets` 删除（Index 的 @Builder 已替代它们），改用新的 `tabs/` 下组件。

---

## 二、UI 设计流程

### 工作流

1. **找参考**（Dribbble / Behance / Mobbin）
   - 卡片式内容浏览：知识卡片、阅读 App 的卡片交互
   - 毛玻璃 + 渐变：iOS 风格参考
   - 暗色 + 低饱和度配色：深色模式参考
   - 目标风格关键词：**"Soft Editorial"** — 马卡龙渐变 + 毛玻璃 + 圆角

2. **Excalidraw 线框图**（每个 Tab + 关键交互）
   - 发现页：卡片堆叠 + 滑动 + 操作栏
   - 收藏页：列表 + 取消收藏
   - 附近圈：位置标签 + 卡片列表 + 下拉刷新
   - 我的：头像 + 统计 + 分类分布 + 设置入口
   - Watch：单卡片 + 旋转表冠翻页

3. **MD 视觉规格文档**（每个页面的精确数值）
   - 颜色色板（主色 / 辅色 / 背景 / 文字 / 分割线）
   - 字体系统（字号 / 行高 / 字重）
   - 间距系统（8dp 网格）
   - 圆角 / 阴影 / 毛玻璃参数
   - 动效参数（时长 / 曲线）

4. **DevEco Previewer 直接实现**
   - 不做 HTML 原型，直接在 ArkUI 里调
   - Previewer 热重载逐页验证

### 视觉规格（草案，待参考图确认）

```
颜色
  背景:       #f5f4f0 (暖白，保留)
  卡片底色:    rgba(255,255,255,0.45) + backdrop-blur 22px
  主文字:      #2a2a38
  次文字:      #585868
  辅助文字:    #a0a0b0
  分割线:      #e8e6e0
  渐变池:      马卡龙色系 6-8 组（保留 ColorPool）
  强调色:      #8c8cb0 (导航激活态)

字体
  标题:        fontSize 20, fontWeight 700, lineHeight 28
  正文:        fontSize 14, fontWeight 400, lineHeight 23
  标签:        fontSize 11, fontWeight 400
  导航文字:    fontSize 10

间距 (8dp 网格)
  页面边距:    20dp
  卡片内边距:  22dp
  组件间距:    8dp / 14dp / 16dp

圆角
  卡片:        22dp
  按钮:        21dp (圆形) / 10-14dp (胶囊)
  小标签:      10dp

阴影
  卡片:        radius 28, offsetY 8, color gradientStart + 28
```

---

## 三、多端适配方案

### 断点系统

```typescript
// utils/ResponsiveBreakpoints.ets
export enum Breakpoint { SM, MD, LG }

export function getBreakpoint(width: number): Breakpoint {
  if (width < 600) return Breakpoint.SM      // Phone
  if (width < 840) return Breakpoint.MD      // Phone 折叠展开 / 小平板
  return Breakpoint.LG                        // Tablet 横屏
}
```

### 各断点布局差异

| 区域 | SM (Phone) | MD (折叠展开) | LG (Tablet) |
|---|---|---|---|
| 卡片列数 | 1 | 1 (居中 80% 宽) | 2 (瀑布流) |
| 底部导航 | 固定底部 | 固定底部 | 侧边栏 |
| 收藏列表 | 单列 | 双列 | 双列 + 更大间距 |
| 附近圈 | 单列 | 双列 | 双列 |
| 我的 | 单列 | 居中 70% | 居中 60% + 双列统计 |

### Watch 独立方案

- 新建 `watch/` 目录，独立 `@Entry` 页面
- 单卡片显示：标题 + 正文（节选 40 字）+ 分类标签
- 旋转表冠翻卡（Watch 默认交互）
- 不支持收藏/点赞（交互太重），仅浏览

---

## 四、安全修复

1. **删除** `entry/src/main/ets/api/DeepSeekAPI.ets` 文件
2. **去 DeepSeek 后台重置 API Key**（已泄露到 GitHub commit 历史）
3. `Index.ets` 中移除 `generateCard()` 调用和 "AI 生成" 按钮
4. 卡片来源仅保留 18 张预设卡（`FallbackData.getAll(18)`）
5. 后续 P2 恢复时：用 AGC Cloud Functions 代理 API 调用，Key 存函数环境变量

---

## 五、剔除清单

以下文件/代码将被删除：

| 文件/代码 | 原因 |
|---|---|
| `api/DeepSeekAPI.ets` | 安全：API Key 已泄露 |
| `pages/FavoritesPage.ets` | 死代码，未被使用 |
| `pages/NearbyPage.ets` | 死代码，未被使用 |
| `pages/ProfilePage.ets` | 死代码，未被使用 |
| `components/CardStack.ets` | 空文件，无实际逻辑 |
| `Index.ets` 中 `isGenerating` / `generateCard()` 相关 | 移除 AI 生成入口 |
| `Index.ets` 中 `@Builder buildBrowse/Favorites/Nearby/Profile` | 迁移至独立 Tab 组件 |

---

## 六、实施步骤

### Phase 1：架构解耦（纯重构，不改 UI）

1. 创建 `model/AppViewModel.ets`
2. 创建 `tabs/BrowseTab.ets`（迁移 `buildBrowse`）
3. 创建 `tabs/FavoritesTab.ets`（迁移 `buildFavorites`）
4. 创建 `tabs/NearbyTab.ets`（迁移 `buildNearby`）
5. 创建 `tabs/ProfileTab.ets`（迁移 `buildProfile`）
6. 创建 `components/BottomNavBar.ets`（提取导航栏）
7. 重构 `Index.ets`（精简为容器，仅持有 AppViewModel + Tabs）
8. 删除死代码文件
9. 删除 `DeepSeekAPI.ets` + 移除 AI 生成入口
10. 验证：功能与 V1 完全一致

### Phase 2：UI 重新设计

1. 收集 UI 参考 → 输出 Excalidraw 线框图 → MD 视觉规格
2. 逐个 Tab 重写 UI（新配色/间距/字体/动效）
3. 创建 `CategoryIcon.ets`（分类 SVG 插画，替换网络图片）
4. 创建 `EmptyPlaceholder.ets`（空状态几何插画，统一风格）
5. 重构 `KnowledgeCard.ets`（纯文字 + 渐变 + 自包含操作栏）
6. 验证：Previewer 逐页对比视觉规格

### Phase 3：多端适配

1. 创建 `ResponsiveBreakpoints.ets`（断点工具）
2. 每个 Tab 增加断点逻辑（SM/MD/LG 布局分支）
3. Tablet 横屏：卡片双列 + 侧边导航
4. 折叠屏展开态：居中宽卡片
5. 创建 `watch/WatchCardPage.ets`（单卡片 glance）
6. 验证：不同设备 Previewer 逐一检查

---

## 七、暂不涉及

以下内容明确不在 P0 范围内：

- 华为账号登录 / Account Kit 集成
- CloudDB 云端存储
- 真正的附近圈（服务器端地理围栏）
- 用户上传卡片（UGC）
- NFC 实际通信
- AI 卡片恢复（Cloud Function）
- Widget 点击跳转调试
