# 知域 ZhiYu · 冷知识卡片科普 App

HarmonyOS NEXT 纯血鸿蒙应用，浏览冷知识卡片像拆盲盒一样未知而有趣。

> 完整功能演示请观看：[知域完整演示视频.mp4](./知域完整演示视频.mp4)

---

## 架构

```
entry/src/main/ets/
├── model/
│   ├── KnowledgeItem.ets          # 数据模型：卡片 + 用户资料（@ObservedV2）
│   └── AppViewModel.ets           # 全局共享状态：卡片池、筛选、收藏、统计
├── pages/
│   ├── Index.ets                  # 根容器：Tabs 路由 + AppViewModel 注入
│   └── tabs/
│       ├── BrowseTab.ets          # 发现页：沉浸/发现双模式 + 分类筛选 + AI 生成
│       ├── DiscoverTab.ets        # （保留占位）
│       ├── FavoritesTab.ets       # 收藏页
│       ├── NearbyTab.ets          # 附近圈
│       └── ProfileTab.ets         # 个人中心：统计 + 历史 + 主题 + 数据管理
├── components/
│   ├── KnowledgeCard.ets          # 知识卡片（@ComponentV2，自包含操作按钮）
│   ├── BottomNavBar.ets           # 底部导航栏
│   ├── DotIndicator.ets           # 轮播圆点指示器（可点击跳转）
│   ├── AnimatedHeart.ets          # 点赞粒子爆发动效
│   └── AnimatedBookmark.ets       # 收藏填充变色动效
├── api/
│   └── DeepSeekAPI.ets            # AI 卡片生成：Vercel 云函数代理 DeepSeek API
├── data/
│   ├── LocalStore.ets             # 本地持久化（preferences）：卡片/收藏/历史/设置
│   └── FallbackData.ets           # 71 张预设冷知识卡片（7 大分类）
├── utils/
│   ├── ColorPool.ets              # 配色工具
│   ├── LocationHelper.ets         # 定位获城市名
│   ├── NFCExchange.ets            # NFC 数据交换
│   └── GlobalThis.ets             # 全局上下文（Widget 通信）
└── widget/pages/                  # 桌面卡片 Widget（小 + 大两种尺寸）
```

**状态管理**：`@ObservedV2` + `@Trace`，AppViewModel 为唯一数据源，所有 Tab 通过 `@Require @Param` 注入共享实例。

---

## 已实装功能

### 卡片浏览
- **沉浸模式** — 单张大卡片居中展示，圆点指示器可点击跳转任意卡片，左右箭头顺序翻页
- **发现模式** — 手机端垂直层叠布局，平板端 2~3 列网格，点击进入详情覆盖层
- **分类筛选** — 横滚条 7 大类（人体·医学 / 生物·自然 / 天文·物理 / 饮食 / 文化·历史 / 化学·材料 / 万象），支持子分类前缀匹配
- **71 张预设卡片** — 每张含标题 + 详细正文 + 分类标签 + 渐变配色

### 卡片交互
- **收藏** — 书签按钮 toggle，填充变色动画，数据持久化
- **点赞** — 心形按钮 toggle，粒子爆发动效，可取消
- **分享** — 复制标题+正文到系统剪贴板，Toast 提示去 QQ/微信粘贴
- **附近圈分享** — 将当前卡片发布到本地附近圈

### AI 异步生成
- 定时检测未读卡片数量，低于 20 张时自动触发 DeepSeek AI 生成
- Vercel 云函数代理 API Key（前端不泄露密钥），3 次重试 + 指数退避
- 生成不跳转当前浏览位置，新卡片追加到池尾

### 个人中心
- **头像昵称签名** — 系统相册选取头像、自定义昵称和个性签名
- **背景图** — 固定 240px 头部，Cover 裁剪，不影响布局占比
- **阅读统计** — 三组环形图：阅读完成率 / 收藏率 / 本周活跃天数
- **连续天数** — 每日首次阅读自动更新连续打卡
- **阅读历史** — 时间线列表，长期按进入管理模式批量删除
- **分类分布** — 柱状图展示各分类卡片数量

### 配色主题
- 4 套完整主题：马卡龙暖 / 夜间霓虹 / 极简素白 / 森林晨露
- 每套含 6 种卡片渐变配色 + 个人中心配色联动
- 个人中心头部渐变、统计面板、环形图色系跟随主题变化

### 附近圈
- 定位获取城市名（如"广州"）
- 本地存储附近圈卡片列表
- 支持下拉刷新

### 桌面 Widget
- 每日卡片小部件（2×2）
- 每日卡片大部件（4×4）
- 点击 Widget 跳转 App 对应卡片

### 其他
- **震动反馈** — 收藏/点赞时轻触震动，个人中心可开关
- **NFC 分享** — 准备 NFC 数据交换
- **Toast 反馈** — 所有操作 1.8s 浮层提示
- **数据管理** — 清除阅读历史 / 重置统计数据
- **多端适配** — Phone / 折叠屏 / Tablet 响应式布局

---

## 技术栈

| 层 | 技术 |
|---|---|
| 框架 | HarmonyOS NEXT · ArkTS · ArkUI |
| 状态管理 | @ObservedV2 / @Trace / @ComponentV2 |
| 持久化 | @kit.ArkData · preferences |
| 网络 | @ohos.net.http |
| 定位 | @kit.LocationKit |
| 剪贴板 | @ohos.pasteboard |
| 震动 | @kit.SensorServiceKit |
| NFC | @ohos.nfc.tag |
| AI | DeepSeek API ⮕ Vercel 云函数代理 |
| 构建 | hvigor · oh-package |

---

## 构建运行

1. DevEco Studio 打开本目录
2. 等待依赖同步（oh_modules）
3. 选择模拟器或真机，点击 Run

HarmonyOS API Level: 22+
