# 2026Spring-25307116-Lab1

中山大学开源软件开发设计课程仓库。本仓库包含三个 HarmonyOS NEXT 应用项目，分别位于三个分支。

---

## 分支说明

### 主要成果：知域 ZhiYu（master 分支）— 从零构建

冷知识卡片科普 App。73 张预设卡片 + AI 异步生成，4 套配色主题，分类筛选、收藏、点赞、附近圈、个人中心、桌面 Widget 等功能。

- **PR**: [#5](https://github.com/OSSD-Course-SYSU-1/2026Spring-25307116-Lab1/pull/5)
- **演示视频**: 仓库内 `知域完整演示视频.mp4`
- **技术栈**: ArkTS · ArkUI · @ObservedV2 · DeepSeek API + Vercel 代理
- **特点**: 从零完整构建，18+ 项功能，20 次提交，架构解耦清晰

### OnTrack（ky 分支）— 从零构建

火车路线查询应用。全国 16,109 趟列车数据，Dijkstra 最小堆换乘搜索 + 直达标 O(n) 扫描，站名自动补全，Canvas 路线图，桌面 Widget，原子化服务。

- **PR**: [#6](https://github.com/OSSD-Course-SYSU-1/2026Spring-25307116-Lab1/pull/6)
- **演示视频**: 仓库内 `ontrack视频演示.mp4`
- **技术栈**: ArkTS · ArkUI · 时间扩展图 · Dijkstra 最小堆

### 健康生活（dev-health 分支）— 基于现有项目改动

基于开源健康生活应用的二次开发，新增功能。

---

## 课程信息

- **课程**: 开源软件开发设计
- **学校**: 中山大学
- **学生**: watersail777
- **学期**: 2026 Spring

---

## 如何查看

每个分支都是一个完整的 DevEco Studio 项目，Clone 后在 DevEco Studio 中打开对应分支即可运行：

```bash
# 查看知域（主要成果）
git checkout master

# 查看 OnTrack
git checkout ky

# 查看健康生活
git checkout dev-health
```

> HarmonyOS API Level: 22+ · DevEco Studio 5.0+
