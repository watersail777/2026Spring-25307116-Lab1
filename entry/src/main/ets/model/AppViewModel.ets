import { KnowledgeItem, UserProfile } from './KnowledgeItem'
import { LocalStore, ReadHistoryEntry } from '../data/LocalStore'
import { NFCExchange } from '../utils/NFCExchange'
import { LocationHelper } from '../utils/LocationHelper'
import { FallbackData } from '../data/FallbackData'
import { DeepSeekAPI } from '../api/DeepSeekAPI'
import pasteboard from '@ohos.pasteboard'
import { vibrator } from '@kit.SensorServiceKit'

export interface CardGradient {
  gradientStart: string
  gradientEnd: string
  borderColor: string
  borderRgb: string
  accentColor: string
  titleColor: string
  bodyColor: string
  name: string
}

@ObservedV2
export class AppViewModel {
  @Trace currentTab: number = 0
  @Trace cards: KnowledgeItem[] = []
  @Trace cardIndex: number = 0
  @Trace toastMsg: string = ''
  @Trace favorites: KnowledgeItem[] = []
  @Trace isTablet: boolean = false
  @Trace nearbyCards: KnowledgeItem[] = []
  @Trace locationLabel: string = '定位中...'
  @Trace nearbyLoading: boolean = true
  @Trace profile: UserProfile = new UserProfile()
  @Trace favCount: number = 0
  @Trace likeCount: number = 0
  @Trace readCount: number = 0
  @Trace categoryStats: [string, number][] = []
  @Trace readHistory: ReadHistoryEntry[] = []
  @Trace streak: number = 0
  @Trace weeklyDays: number = 0
  @Trace readPercent: number = 0
  @Trace favPercent: number = 0
  @Trace avatarUri: string = ''
  @Trace bgUri: string = ''
  @Trace vibrateEnabled: boolean = true

  // ── AI 卡片生成 ──
  private generating: boolean = false

  static readonly TOPICS: string[] = [
    '人体·医学', '生物·自然', '天文·物理', '饮食', '文化·历史', '化学·材料', '万象'
  ]

  /**
   * 尝试触发 AI 卡片生成（由 UI 层在切换卡片后调用）
   * 剩余未浏览 < 20 且未在生成中时，异步生成一张
   */
  tryGenerate(): void {
    if (this.cards.length === 0 || this.generating) {
      return
    }
    const history = LocalStore.getReadHistory()
    const readIds: Set<string> = new Set()
    for (const h of history) {
      readIds.add(h.cardId)
    }
    let unread = 0
    for (const c of this.cards) {
      if (!readIds.has(c.id)) {
        unread++
      }
    }
    if (unread < 20) {
      this.generateCard()
    }
  }

  private async generateCard(): Promise<void> {
    this.generating = true
    const topic = AppViewModel.TOPICS[Math.floor(Math.random() * AppViewModel.TOPICS.length)]
    try {
      const card = await DeepSeekAPI.generateCard(topic)
      if (card !== null) {
        const dup = this.cards.some((c: KnowledgeItem) => c.title === card.title)
        if (!dup) {
          card.id = 'ai-' + Date.now().toString(36) + '-' + Math.random().toString(36).substring(2, 6)
          this.cards.push(card)
          LocalStore.saveCard(card)
          // 更新 filteredCards 但不重置位置
          if (this.selectedCategory === '全部' ||
              card.category === this.selectedCategory ||
              card.category.startsWith(this.selectedCategory + '·')) {
            this.filteredCards = [...this.filteredCards, card]
          }
          this.refreshStats()
        }
      }
    } finally {
      this.generating = false
    }
  }

  private dotColors: string[] = ['#c5e8d5', '#dcd0f0', '#f8d8d4', '#d0e4f4', '#f8f0d0', '#f0d8e4']

  // ── 4套卡片配色主题 ──
  static readonly THEMES: Record<string, CardGradient[]> = {
    '马卡龙暖': [
      { gradientStart: '#f0e6f4', gradientEnd: '#e0d2e8', borderColor: '#d8c8e0', borderRgb: '216,200,224', accentColor: '#C9A8D8', titleColor: '#2D1B3D', bodyColor: '#5B3D6E', name: '天文' },
      { gradientStart: '#e6f0e6', gradientEnd: '#d0e2d0', borderColor: '#c0d4c0', borderRgb: '192,212,192', accentColor: '#7DBE7D', titleColor: '#1A3320', bodyColor: '#3A6B3A', name: '生物' },
      { gradientStart: '#f6f0e0', gradientEnd: '#ebe0c8', borderColor: '#ddd0b8', borderRgb: '221,208,184', accentColor: '#D4A843', titleColor: '#3D2A00', bodyColor: '#6B4A10', name: '自然' },
      { gradientStart: '#f4e6e4', gradientEnd: '#e8d2d0', borderColor: '#dcc4c0', borderRgb: '220,196,192', accentColor: '#E08080', titleColor: '#3D1A18', bodyColor: '#8B4040', name: '章鱼' },
      { gradientStart: '#e8e0f8', gradientEnd: '#d8d0f0', borderColor: '#c8c0e0', borderRgb: '200,192,224', accentColor: '#8870C8', titleColor: '#1A1040', bodyColor: '#6040A0', name: '物理' },
      { gradientStart: '#e0f4f0', gradientEnd: '#c8e8e0', borderColor: '#c0e0d8', borderRgb: '192,224,216', accentColor: '#4A9E90', titleColor: '#0A2820', bodyColor: '#2A6A60', name: '历史' },
    ],
    '夜间霓虹': [
      { gradientStart: '#1a1028', gradientEnd: '#241440', borderColor: '#3a2a50', borderRgb: '58,42,80', accentColor: '#c084fc', titleColor: '#e8d8ff', bodyColor: '#c8b8e8', name: '天文' },
      { gradientStart: '#0d1a10', gradientEnd: '#0f2214', borderColor: '#1a3820', borderRgb: '26,56,32', accentColor: '#4ade80', titleColor: '#d8ffe0', bodyColor: '#a8e8b8', name: '生物' },
      { gradientStart: '#1a1008', gradientEnd: '#241808', borderColor: '#3a2810', borderRgb: '58,40,16', accentColor: '#fb923c', titleColor: '#ffe8d0', bodyColor: '#e8c8a0', name: '自然' },
      { gradientStart: '#1a0d10', gradientEnd: '#241018', borderColor: '#3a1a20', borderRgb: '58,26,32', accentColor: '#f472b6', titleColor: '#ffe0f0', bodyColor: '#e8b8d0', name: '章鱼' },
      { gradientStart: '#0d1020', gradientEnd: '#101830', borderColor: '#1a2850', borderRgb: '26,40,80', accentColor: '#60a5fa', titleColor: '#d8e8ff', bodyColor: '#a8c8f0', name: '物理' },
      { gradientStart: '#081418', gradientEnd: '#0a1c20', borderColor: '#103038', borderRgb: '16,48,56', accentColor: '#2dd4bf', titleColor: '#d0fff8', bodyColor: '#a0e8e0', name: '历史' },
    ],
    '极简素白': [
      { gradientStart: '#fafaf8', gradientEnd: '#f4f2f0', borderColor: '#eae8e4', borderRgb: '234,232,228', accentColor: '#a09890', titleColor: '#2c2a26', bodyColor: '#6e6a64', name: '天文' },
      { gradientStart: '#f8faf7', gradientEnd: '#f0f2ee', borderColor: '#e4e6e0', borderRgb: '228,230,224', accentColor: '#8e9688', titleColor: '#282a24', bodyColor: '#5a5e54', name: '生物' },
      { gradientStart: '#faf8f4', gradientEnd: '#f2ece4', borderColor: '#e8e0d6', borderRgb: '232,224,214', accentColor: '#b4a494', titleColor: '#3c3428', bodyColor: '#70624e', name: '自然' },
      { gradientStart: '#faf8f7', gradientEnd: '#f2ecea', borderColor: '#e8e0dc', borderRgb: '232,224,220', accentColor: '#b4a09a', titleColor: '#3c2c28', bodyColor: '#70504a', name: '章鱼' },
      { gradientStart: '#f8f8fa', gradientEnd: '#f0eef4', borderColor: '#e4e0ea', borderRgb: '228,224,234', accentColor: '#9694a8', titleColor: '#201e34', bodyColor: '#4e4a5e', name: '物理' },
      { gradientStart: '#f6faf8', gradientEnd: '#ecf2ee', borderColor: '#dce6e0', borderRgb: '220,230,224', accentColor: '#8c9a92', titleColor: '#1c2a22', bodyColor: '#3e5246', name: '历史' },
    ],
    '森林晨露': [
      { gradientStart: '#e0ece4', gradientEnd: '#d0ded4', borderColor: '#c0d0c4', borderRgb: '192,208,196', accentColor: '#5c8a67', titleColor: '#1a3020', bodyColor: '#3a5a40', name: '天文' },
      { gradientStart: '#e8f0e0', gradientEnd: '#d8e4d0', borderColor: '#c4d4b8', borderRgb: '196,212,184', accentColor: '#7a8e5a', titleColor: '#253018', bodyColor: '#4a5a30', name: '生物' },
      { gradientStart: '#f0e8d4', gradientEnd: '#e4dac0', borderColor: '#d4c8a8', borderRgb: '212,200,168', accentColor: '#b89850', titleColor: '#3a2a10', bodyColor: '#6a4a20', name: '自然' },
      { gradientStart: '#f0e0dc', gradientEnd: '#e4d0c8', borderColor: '#d4bcb0', borderRgb: '212,188,176', accentColor: '#a0705c', titleColor: '#3a2018', bodyColor: '#6a3828', name: '章鱼' },
      { gradientStart: '#dce4f0', gradientEnd: '#ccd4e4', borderColor: '#bcc4d8', borderRgb: '188,196,216', accentColor: '#6b7d8e', titleColor: '#182838', bodyColor: '#384858', name: '物理' },
      { gradientStart: '#f0ead4', gradientEnd: '#e4dcc0', borderColor: '#d4c8a8', borderRgb: '212,200,168', accentColor: '#7a8e68', titleColor: '#2a2810', bodyColor: '#5a5020', name: '历史' },
    ],
  }

  @Trace selectedTheme: string = '马卡龙暖'

  // ── 分类筛选 ──
  @Trace selectedCategory: string = '全部'
  @Trace filteredCards: KnowledgeItem[] = []
  @Trace filteredCardIndex: number = 0

  getAvailableCategories(): string[] {
    const seen: Set<string> = new Set()
    seen.add('全部')
    for (const c of this.cards) {
      const mainCat = c.category.split('·')[0]
      if (mainCat.length > 0 && !seen.has(mainCat)) {
        seen.add(mainCat)
      }
    }
    return Array.from(seen)
  }

  selectCategory(cat: string): void {
    this.selectedCategory = cat
    this.applyCategoryFilter()
  }

  applyCategoryFilter(): void {
    if (this.selectedCategory === '全部') {
      this.filteredCards = this.cards
    } else {
      this.filteredCards = this.cards.filter(c => {
        return c.category === this.selectedCategory ||
          c.category.startsWith(this.selectedCategory + '·')
      })
    }
    this.filteredCardIndex = 0
  }

  stepFilteredCard(dir: number): void {
    if (dir < 0 && this.filteredCardIndex < this.filteredCards.length - 1) {
      this.filteredCardIndex++
    } else if (dir > 0 && this.filteredCardIndex > 0) {
      this.filteredCardIndex--
    }
  }

  jumpToFilteredCard(idx: number): void {
    if (idx >= 0 && idx < this.filteredCards.length) {
      this.filteredCardIndex = idx
    }
  }

  getCardGradient(index: number): CardGradient {
    const theme = AppViewModel.THEMES[this.selectedTheme] ?? AppViewModel.THEMES['马卡龙暖']
    return theme[index % theme.length]
  }

  // ── 主题适配：Profile 页颜色 ──

  /** 个人中心头部渐变（跟随选中主题变化） */
  getProfileHeaderGradient(): [string, number][] {
    switch (this.selectedTheme) {
      case '夜间霓虹':
        return [['#1a1030',0],['#1c143a',0.2],['#1e1844',0.4],['#201c50',0.6],['#1e2058',0.8],['#1c2460',1]]
      case '极简素白':
        return [['#d8d4ce',0],['#d0cbc4',0.2],['#c4beb6',0.4],['#b8b2aa',0.6],['#aca69e',0.8],['#a09a92',1]]
      case '森林晨露':
        return [['#3a5a40',0],['#406048',0.2],['#4a6a50',0.4],['#547458',0.6],['#5e7e60',0.8],['#688868',1]]
      default: // 马卡龙暖
        return [['#d4855e',0],['#c97a6a',0.15],['#b8686e',0.3],['#9b5e78',0.5],['#7d5588',0.7],['#6b4d92',1]]
    }
  }

  /** 主题对应的阅读统计面板背景色 */
  getProfilePanelBg(): string {
    switch (this.selectedTheme) {
      case '夜间霓虹': return '#1e1c2a'
      case '极简素白': return '#fafaf7'
      case '森林晨露': return '#e8f0e8'
      default: return '#fffdf9'
    }
  }

  /** 主题对应的统计标题色 */
  getProfileTitleColor(): string {
    switch (this.selectedTheme) {
      case '夜间霓虹': return '#e0d8f0'
      case '极简素白': return '#2c2a26'
      case '森林晨露': return '#1a3020'
      default: return '#3a3028'
    }
  }

  /** 主题对应的统计副标题色 */
  getProfileBodyColor(): string {
    switch (this.selectedTheme) {
      case '夜间霓虹': return '#8a8098'
      case '极简素白': return '#8a8680'
      case '森林晨露': return '#6a7a68'
      default: return '#a09888'
    }
  }

  /** 主题对应的分割线色 */
  getProfileDividerColor(): string {
    switch (this.selectedTheme) {
      case '夜间霓虹': return '#2a2838'
      case '极简素白': return '#e8e6e2'
      case '森林晨露': return '#c0d0c0'
      default: return '#e8e4dc'
    }
  }

  /** 环形图三色（已阅读 / 收藏率 / 本周活跃） */
  getRingColors(): [string, string, string] {
    switch (this.selectedTheme) {
      case '夜间霓虹':
        return ['#60a5fa', '#fb923c', '#4ade80']
      case '极简素白':
        return ['#908e86', '#b2a696', '#88948a']
      case '森林晨露':
        return ['#5c8a67', '#8e7a5a', '#6a9e78']
      default: // 马卡龙暖
        return ['#5b8cbf', '#c4945a', '#6b9e78']
    }
  }

  /** 环形图背景圈颜色 */
  getRingBgColor(): string {
    switch (this.selectedTheme) {
      case '夜间霓虹': return '#2a2838'
      case '极简素白': return '#e8e6e2'
      case '森林晨露': return '#c8d8c8'
      default: return '#e8e4dc'
    }
  }

  // ── 初始化 ──

  init(): void {
    const saved = LocalStore.getAllCards()
    // 校验数据完整性：序列化损坏的卡片 title/content 为空
    const valid = saved.filter(c => c.title.length > 0 && c.content.length > 0)
    if (valid.length >= 3) {
      this.cards = valid
      // 检测 FallbackData 中新增的预设卡片，追加到本地集合
      this.mergeNewPresetCards()
    } else {
      // 清除损坏数据，重新从 FallbackData 加载
      if (saved.length > 0 && valid.length < saved.length) {
        LocalStore.clearAllCards()
      }
      const all = FallbackData.getAll(99)
      for (const c of all) {
        LocalStore.saveCard(c)
      }
      this.cards = all
    }
    this.selectedTheme = LocalStore.getTheme()
    this.vibrateEnabled = LocalStore.getVibrateEnabled()
    this.streak = LocalStore.updateStreak()
    this.applyCategoryFilter()
  }

  /**
   * 检测 FallbackData 中是否有新增的预设卡片，追加到 cards 并持久化
   */
  private mergeNewPresetCards(): void {
    const existingTitles = new Set<string>()
    for (const c of this.cards) {
      existingTitles.add(c.title)
    }
    const all = FallbackData.getAll(99)
    for (const c of all) {
      if (!existingTitles.has(c.title)) {
        c.id = 'preset-' + Date.now().toString(36) + '-' + Math.random().toString(36).substring(2, 6)
        c.source = 'local'
        this.cards.push(c)
        LocalStore.saveCard(c)
      }
    }
  }

  // ── Tab 切换 ──

  switchTab(idx: number): void {
    if (idx === this.currentTab) {
      return
    }
    this.currentTab = idx
    if (idx === 1) {
      this.loadFavorites()
    }
    if (idx === 2) {
      this.loadNearby()
    }
    if (idx === 3) {
      this.loadProfile()
    }
  }

  // ── 卡片切换 ──

  handleSwipe(dir: number): void {
    if (dir < 0 && this.filteredCardIndex < this.filteredCards.length - 1) {
      this.filteredCardIndex++
    } else if (dir > 0 && this.filteredCardIndex > 0) {
      this.filteredCardIndex--
    }
  }

  // ── 收藏 ──

  handleFavorite(): void {
    if (this.filteredCards.length === 0) {
      return
    }
    const card = this.filteredCards[this.filteredCardIndex]
    const isFav = LocalStore.toggleFavorite(card.id)
    card.isFavorited = isFav
    this.tryVibrate()
    this.showToast(isFav ? '已收藏' : '已取消')
  }

  removeFavorite(cardId: string): void {
    LocalStore.toggleFavorite(cardId)
    this.favorites = this.favorites.filter(c => c.id !== cardId)
  }

  tryVibrate(): void {
    if (!this.vibrateEnabled) return
    try {
      vibrator.startVibration({ type: 'time', duration: 12 }, { usage: 'touch' })
    } catch (_e) { /* 震动调用失败不阻塞 */ }
  }

  loadFavorites(): void {
    const favIds = LocalStore.getFavoriteIds()
    this.favorites = []
    for (const id of favIds) {
      const c = LocalStore.getCard(id)
      if (c !== null) {
        c.isFavorited = true
        this.favorites.push(c)
      }
    }
  }

  // ── 点赞 ──

  handleLike(): void {
    if (this.filteredCards.length === 0) {
      return
    }
    const card = this.filteredCards[this.filteredCardIndex]
    const liked = LocalStore.toggleLike(card.id)
    card.isLiked = liked
    this.tryVibrate()
    if (liked) {
      card.likeCount++
      this.showToast('已点赞')
    } else {
      card.likeCount = Math.max(0, card.likeCount - 1)
      this.showToast('已取消')
    }
  }

  // ── 分享 ──

  shareToSystem(): void {
    if (this.filteredCards.length === 0) {
      return
    }
    const card = this.filteredCards[this.filteredCardIndex]
    const text = `【知域】${card.title}\n\n${card.content}\n\n— 来自「知域」冷知识科普`
    const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
    this.showToast('已复制到剪贴板，去 QQ/微信粘贴吧')
  }

  shareToNearby(): void {
    if (this.filteredCards.length === 0) {
      return
    }
    const card = this.filteredCards[this.filteredCardIndex]
    card.authorName = this.profile.nickname
    const nearby = LocalStore.getNearbyCards()
    nearby.unshift(card)
    LocalStore.saveNearbyCards(nearby)
    this.showToast('已分享到附近圈')
  }

  // ── 附近圈 ──

  async loadNearby(): Promise<void> {
    this.nearbyLoading = true
    this.locationLabel = await LocationHelper.getLocationLabel()
    this.nearbyCards = LocalStore.getNearbyCards()
    this.nearbyLoading = false
  }

  // ── 个人中心 ──

  loadProfile(): void {
    this.profile = LocalStore.getProfile()
    this.avatarUri = this.profile.avatarUri
    this.bgUri = this.profile.bgUri
    const favIds = LocalStore.getFavoriteIds()
    this.favCount = favIds.length
    const all = LocalStore.getAllCards()
    this.likeCount = all.reduce((s, c) => s + c.likeCount, 0)
    this.computeCategoryStats(all)
    this.refreshStats()
  }

  /** 刷新阅读统计：总阅读数、本周活跃天数、百分比 */
  refreshStats(): void {
    const history: ReadHistoryEntry[] = LocalStore.getReadHistory()
    this.readCount = history.length

    // 本周活跃天数
    const now = Date.now()
    const dayMs = 86400000
    const todayStart = new Date(now).setHours(0, 0, 0, 0)
    const weekStart = todayStart - 6 * dayMs // 最近7天
    const activeDays = new Set<number>()
    for (const h of history) {
      if (h.readAt >= weekStart) {
        const day = Math.floor((h.readAt - weekStart) / dayMs)
        activeDays.add(day)
      }
    }
    this.weeklyDays = activeDays.size

    // 百分比
    const total = this.cards.length > 0 ? this.cards.length : 1
    this.readPercent = Math.min(1, this.readCount / total)
    this.favPercent = Math.min(1, this.favCount / total)
  }

  computeCategoryStats(cards: KnowledgeItem[]): void {
    const map: Record<string, number> = {}
    for (const c of cards) {
      const cat: string = c.category.length > 0 ? c.category : '未分类'
      map[cat] = (map[cat] ?? 0) + 1
    }
    const entries: [string, number][] = []
    const keys: string[] = Object.keys(map)
    for (let i = 0; i < keys.length; i++) {
      const k: string = keys[i]
      entries.push([k, map[k]])
    }
    entries.sort((a: [string, number], b: [string, number]) => b[1] - a[1])
    this.categoryStats = entries
  }

  selectEmoji(emoji: string): void {
    this.profile.emoji = emoji
    LocalStore.saveProfile(this.profile)
  }

  saveProfileNickname(name: string): void {
    this.profile.nickname = name || '知域用户'
    LocalStore.saveProfile(this.profile)
  }

  getBarWidth(count: number): string {
    const total: number = this.cards.length > 0 ? this.cards.length : 1
    return Math.max(Math.ceil(count * 100 / total), 5).toString() + '%'
  }

  getDotColor(idx: number): string {
    return this.dotColors[idx % this.dotColors.length]
  }

  // ── 阅读历史 ──

  markAsRead(cardId: string): void {
    LocalStore.addReadHistory(cardId)
    this.streak = LocalStore.updateStreak()
  }

  loadReadHistory(): void {
    this.readHistory = LocalStore.getReadHistory()
    this.readCount = this.readHistory.length
  }

  deleteFromHistory(cardId: string): void {
    LocalStore.removeReadHistory(cardId)
    this.loadReadHistory()
  }

  // ── Toast ──

  showToast(msg: string): void {
    this.toastMsg = msg
    setTimeout(() => {
      this.toastMsg = ''
    }, 1800)
  }

  // ── 工具 ──

  getDotIndices(): number[] {
    const arr: number[] = []
    const total = Math.min(this.cards.length, 10)
    for (let i = 0; i < total; i++) {
      arr.push(i)
    }
    return arr
  }

  // ── Widget 跳转 ──

  jumpToCard(cardId: string): void {
    // 先在全部卡片中查找，重置筛选为"全部"
    this.selectedCategory = '全部'
    this.applyCategoryFilter()
    for (let i = 0; i < this.filteredCards.length; i++) {
      if (this.filteredCards[i].id === cardId) {
        this.filteredCardIndex = i
        this.currentTab = 0
        break
      }
    }
  }
}
