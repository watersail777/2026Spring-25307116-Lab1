# 知域 UI 视觉规格文档

基于 `design-preview/zhiyu-v2-prototype.html` 逐元素提取。

---

## 一、全局

| 属性 | 值 |
|---|---|
| 页面底色 | `#f5f4f0`（暖白） |
| 字体族 | 系统默认无衬线（`HarmonyOS Sans` / `Noto Sans SC`） |
| 标题字体 | Bold（700），模拟衬线笔锋 |
| 正文字体 | Light（300） |

---

## 二、状态栏（顶部）

| 元素 | 位置 | 样式 |
|---|---|---|
| 时间 "09:41" | 左侧 | 12px，SemiBold(600)，`#1F2937` |
| 信号/WiFi/电池图标 | 右侧 | 16×16 SVG，`#1F2937` fill |
| 区域 | `px:24 top:12 bottom:4` | z-index 高于卡片 |

---

## 三、模式切换（TopNav）

**位置：** 状态栏下方，居中

| 元素 | 默认态 | 激活态 |
|---|---|---|
| "沉浸" 文字 | 14px，`#9CA3AF`，Regular(400) | `#111827`，SemiBold(600) |
| "发现" 文字 | 同上 | 同上 |
| 激活指示点 | 无 | 4×4 圆点，`#1F2937`，在文字下方 mt:4 |

**间距：** 两个按钮之间 `gap:24`，上方 `pt:16`，下方 `pb:8`

---

## 四、沉浸模式卡片（ImmersiveCard）

### 4.1 容器

| 属性 | 值 |
|---|---|
| 圆角 | 28px |
| 边框 | 1px solid `grad.border`（与当前卡片渐变色对应） |
| 阴影（card-emboss） | **左上亮边：** `0 -6px 16px rgba(255,255,255,0.95)` + `-4px -4px 12px rgba(255,255,255,0.7)` |
|  | **右下暗边：** `0 14px 32px rgba(160,150,130,0.18)` + `4px 6px 20px rgba(160,150,130,0.10)` |
|  | **边缘微凸：** `0 0 0 1px rgba(0,0,0,0.03)` |
| 高光线（card-highlight） | 顶部 1.5px，left:14 right:14，渐变：`transparent → rgba(255,255,255,0.8) → transparent` |
| 内边距 | `px:24 pt:20 pb:20` |
| 背景 | CSS渐变（见4.2） |

### 4.2 卡片渐变配色（4组）

```
薰衣草暖紫：linear-gradient(165deg, #f0e6f4 0%, #e5d7ec 30%, #e0d2e8 60%, #ece0f0 100%)
暖金奶油：  linear-gradient(165deg, #f6f0e0 0%, #efe6d2 30%, #ebe0c8 60%, #f4eedc 100%)
鼠尾草绿：  linear-gradient(165deg, #e6f0e6 0%, #d8e8d8 30%, #d0e2d0 60%, #e2ece2 100%)
蜜桃暖粉：  linear-gradient(165deg, #f4e6e4 0%, #eedad8 30%, #e8d2d0 60%, #f0e2e0 100%)
```

每张卡片使用一组渐变，对应 accent / border 色：
| 名称 | accent（分类标签色） | border（边框/分割线色） |
|---|---|---|
| 薰衣草暖紫 | `#8b6098` | `#d8c8e0` |
| 暖金奶油 | `#b09048` | `#ddd0b8` |
| 鼠尾草绿 | `#568858` | `#c0d4c0` |
| 蜜桃暖粉 | `#a86860` | `#dcc4c0` |

### 4.3 卡片内容（从上到下）

| # | 元素 | 字体 | 颜色 | 间距 |
|---|---|---|---|---|
| 1 | 分类标签 `# 生物奇观` | 11px Medium(500)，letter-spacing:1.2 | `accent` | pb:4 |
| 2 | 标题 | 19px Medium(500)，line-height:1.5 | `#1F2937` | px:24 mb:12 |
| 3 | 装饰分割线 | 32×4px 圆角 2px | `grad.border` | px:24 mb:16 |
| 4 | 正文 | 13.5px，line-height:1.75 | `#6B7280` | px:24 flex-1 mb:12 |
| 5 | 操作栏分割线 | 1px top border | `grad.border + 80%` 透明度 | mx:20 |
| 6 | 操作按钮（3个） | 见 4.4 | — | 靠右，gap:20，pt:16 pb:20 |

### 4.4 卡片内操作按钮

3 个圆形按钮（收藏 / 点赞 / 转发），水平排列靠右。

| 属性 | 值 |
|---|---|
| 尺寸 | 36×36（w-9 h-9） |
| 圆角 | 50%（圆形） |
| 背景 | `rgba(255,255,255,0.4)` 半透白 |
| 边框 | 1px solid `rgba(255,255,255,0.4)` |
| 阴影（btn-emboss） | **亮边：** `0 -3px 6px rgba(255,255,255,0.9)` |
|  | **暗边：** `0 6px 14px rgba(160,150,130,0.14)` |
| 高光线（btn-highlight） | 顶部 1px，left:10 right:10，`rgba(255,255,255,0.5)` |
| 按下态（active） | scale:0.9，阴影变为 inset |
| 内部图标 | 24×24 SVG（见4.5） |

### 4.5 图标规格

**收藏图标（BookmarkCardIcon）：**
- 书签形状 Path：`M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z`
- 默认：fill:none / stroke:`#4B5563` / strokeWidth:2
- 已收藏：fill:`#F59E0B` / stroke:`#F59E0B`

**点赞图标（HeartIcon）：**
- 心形 Path：`M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z`
- 默认：fill:none / stroke:`#4B5563`
- 已点赞：fill:`#EF4444` / stroke:`#EF4444`

**转发图标（ShareIcon）：**
- 3个圆 + 2条连线：
  - 圆1：中心(18,5)，r:3
  - 圆2：中心(6,12)，r:3
  - 圆3：中心(18,19)，r:3
  - 连线1：(8.59,13.51)→(15.42,17.49)
  - 连线2：(15.41,6.51)→(8.59,10.49)
- stroke:`#4B5563` / strokeWidth:2 / fill:none

### 4.6 卡片交互

| 操作 | 效果 |
|---|---|
| 收藏点击 | 图标变金色实心 `#F59E0B`，Toast"已添加到收藏" |
| 再次收藏点击 | 图标变空心，Toast"已取消收藏" |
| 点赞点击 | 图标变红色实心 `#EF4444`，Toast"已点赞" |
| 再次点赞点击 | Toast"已经点过赞啦"，不变 |
| 转发点击 | Toast"已复制到剪贴板，去分享吧" |
| 左右滑动 | 卡片平移+淡出，300ms后切换内容+恢复 |

---

## 五、页码指示器（Pager）

**位置：** 卡片下方，居中

| 状态 | 样式 |
|---|---|
| 当前页 | 24×6px 圆角胶囊，`#9CA3AF` |
| 非当前页 | 6×6px 圆形，`#D1D5DB` |
| 间距 | 每个 dot 之间 gap:8 |
| 动画 | transition 300ms |
| 容器 padding | `py:16` |

---

## 六、浮动翻页按钮（FloatNav）

**位置：** 页码指示器下方，居中水平排列

3 个圆形按钮：左箭头 / 转发 / 右箭头

| 属性 | 值 |
|---|---|
| 尺寸 | 44×44（w-11 h-11） |
| 圆角 | 50% |
| 背景 | `rgba(255,255,255,0.8)` + `backdrop-blur` |
| 边框 | 1px solid `rgba(255,255,255,0.6)` |
| 阴影 | btn-emboss（同4.4卡片按钮） |
| 图标 | ChevronLeft(20×20 SVG) / ShareIcon / ChevronRight |
| 图标颜色 | `#6B7280` |
| 禁用态 | opacity:0.25 |
| 按下态 | scale:0.9，300ms transition |
| 按钮间距 | gap:16 |
| 容器 padding | `pb:8` |

**箭头图标：**
- 左箭头 Path：`M15 18l-6-6 6-6`
- 右箭头 Path：`M9 18l6-6-6-6`
- stroke:`currentColor` / strokeWidth:2 / strokeLinecap:round / strokeLinejoin:round

---

## 七、Toast 提示

**位置：** 底部导航上方（`bottom:112`），水平居中，浮动层 z:30

| 属性 | 值 |
|---|---|
| 背景 | `rgba(31,41,55,0.9)` |
| 圆角 | 9999px（胶囊） |
| 内边距 | `px:20 py:10` |
| 阴影 | lg |
| 文字 | 14px，白色，左侧绿色 ✓ 图标 |
| 图标 | 16×16 对勾 SVG，stroke:`#A7F3D0`，strokeWidth:3 |
| 动画 | animate-bounce（弹入） |
| 消失 | 1.8s 后自动消失 |

---

## 八、底部导航栏（BottomNav）

**位置：** 页面底部，`absolute bottom:0`

| 属性 | 值 |
|---|---|
| 高度 | 80px（h-20） |
| 背景 | `rgba(255,255,255,0.9)` + `backdrop-blur:md` |
| 上边框 | 1px `#F3F4F6` |
| 浮雕感 | `inset 0 2px 6px rgba(0,0,0,0.03)` + `inset 0 -1px 3px rgba(255,255,255,0.6)` |
| 布局 | flex，水平均分（justify-around） |
| 内边距 | `px:16 pb:16` |

**每个 Tab 项（图标+文字，垂直排列，gap:4）：**

| Tab | 图标（24×24 SVG） | 文字 |
|---|---|---|
| 发现 | **CompassIcon：** Circle(r:10) + Polygon(指南针) | "发现" 10px Medium |
| 收藏 | **BookmarkNavIcon：** 书签 Path (同4.5) | "收藏" 10px |
| 附近圈 | **MapPinIcon：** 水滴 Path + Circle(r:3 中心点) | "附近圈" 10px |
| 我的 | **UserIcon：** Circle(r:4 头部) + 弧形 Path(身体) | "我的" 10px |

**激活态：** 图标 fill:`#1F2937` / stroke:`#1F2937`，文字 `#111827` SemiBold
**默认态：** 图标 fill:none / stroke:`#9CA3AF`，文字 `#9CA3AF` Regular

---

## 九、发现模式（双列网格）

### 9.1 布局

| 属性 | 值 |
|---|---|
| 列数 | 2 |
| 列间距 | 12px |
| 行间距 | 12px |
| 容器 padding | `px:16 pt:8 pb:96`（pb留出导航空间） |
| 可滚动 | overflow-y:auto，隐藏滚动条 |

### 9.2 网格卡片（GridCard）

| 属性 | 值 |
|---|---|
| 圆角 | 16px（rounded-2xl） |
| 阴影 | card-emboss-sm |
| 高光线 | card-highlight（同4.1） |
| 边框 | 1px solid `grad.border` |
| 背景 | `grad.gradient`（同卡片渐变） |
| 内边距 | 20px |

**内容排列：**
| # | 元素 | 样式 |
|---|---|---|
| 1 | 分类标签 `# 物种档案` | 10px Medium，letter-spacing:0.5，`accent`，mb:8 |
| 2 | 标题 | 14px Medium，`#1F2937`，line-height:1.4，max-lines:3 |
| 3 | Emoji 点缀 | 24px，opacity:0.25，靠右下，mt:auto |

**卡片高度：** 第1、4张 192px，第2、3张 224px，第4张上移 -24px 产生错落

**交互：** 点击 → 切换到沉浸模式显示该卡片，active:scale:0.95

---

## 十、手机框（PhoneFrame）

仅用于原型展示，非 App 内元素。

| 属性 | 值 |
|---|---|
| 尺寸 | 320×650px |
| 圆角 | 40px |
| 边框 | 8px solid `#111827` |
| 外阴影 | `0 20px 50px -12px rgba(0,0,0,0.15)` |
| 刘海 | 128×24px，黑色，底部圆角 24px |

---

## 十一、交互汇总

| 触发 | 效果 |
|---|---|
| 点击"沉浸"标签 | 切换到沉浸模式 |
| 点击"发现"标签 | 切换到双列网格模式 |
| 沉浸模式左滑 | 卡片左移+淡出→下一张 |
| 沉浸模式右滑 | 卡片右移+淡出→上一张 |
| 点击 ‹ | 上一张 |
| 点击 › | 下一张 |
| 点击 ♡ 书签 | 切换收藏状态 + Toast |
| 点击 ♥ 心形 | 点赞（不可取消）+ Toast |
| 点击 转发 | 复制文本到剪贴板 + Toast |
| 网格卡片点击 | 进入该卡片的沉浸模式 |
| 底部Tab点击 | 切换Tab页面 |

---

## 十二、动画

| 动画 | 参数 |
|---|---|
| 卡片切换 fadeIn | opacity 0→1，translateY 14→0，350ms ease |
| 按钮按下 | scale 1→0.9，200ms |
| 页码指示器 | width 过渡 300ms |
| Toast 弹入 | animate-bounce |
| Toast 消失 | 1.8s 后 opacity 0→1 反向 |

---

## 十三、卡片后方虚影

在沉浸模式当前卡片后方，显示下一张卡片的半透明虚影：

| 属性 | 值 |
|---|---|
| 背景 | 下一张卡片的渐变 |
| 不透明度 | 0.3 |
| 缩放 | 0.95 |
| 向下偏移 | 24px |
| 位置 | absolute，z:-10，在卡片容器内部 |

---

## 十四、配色速查表

```
底色         #f5f4f0
标题文字     #1F2937  (gray-800)
正文文字     #6B7280  (gray-500)
辅助文字     #9CA3AF  (gray-400)
激活图标     #1F2937
未激活图标   #9CA3AF
点赞红       #EF4444
收藏金       #F59E0B
转发灰       #4B5563
Toast 背景   rgba(31,41,55,0.9)
Toast 对勾   #A7F3D0
按钮背景     rgba(255,255,255,0.8)
导航背景     rgba(255,255,255,0.9)
阴影色       rgba(160,150,130,0.14~0.18)  暖灰
亮边色       rgba(255,255,255,0.7~0.95)   白
```
