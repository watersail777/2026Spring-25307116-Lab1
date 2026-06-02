import { KnowledgeItem, UserProfile } from './KnowledgeItem'
import { LocalStore, ReadHistoryEntry } from '../data/LocalStore'
import { NFCExchange } from '../utils/NFCExchange'
import { LocationHelper } from '../utils/LocationHelper'
import { FallbackData } from '../data/FallbackData'
import pasteboard from '@ohos.pasteboard'

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
  @Trace nearbyCards: KnowledgeItem[] = []
  @Trace locationLabel: string = '定位中...'
  @Trace nearbyLoading: boolean = true
  @Trace profile: UserProfile = new UserProfile()
  @Trace favCount: number = 0
  @Trace likeCount: number = 0
  @Trace readCount: number = 0
  @Trace categoryStats: [string, number][] = []
  @Trace readHistory: ReadHistoryEntry[] = []

  private dotColors: string[] = ['#c5e8d5', '#dcd0f0', '#f8d8d4', '#d0e4f4', '#f8f0d0', '#f0d8e4']

  // ── 卡片渐变配色池（马卡龙暖调）──
  static readonly CARD_GRADIENTS: CardGradient[] = [
    { gradientStart: '#f0e6f4', gradientEnd: '#e0d2e8', borderColor: '#d8c8e0', borderRgb: '216,200,224', accentColor: '#C9A8D8', titleColor: '#2D1B3D', bodyColor: '#5B3D6E', name: '天文' },
    { gradientStart: '#e6f0e6', gradientEnd: '#d0e2d0', borderColor: '#c0d4c0', borderRgb: '192,212,192', accentColor: '#7DBE7D', titleColor: '#1A3320', bodyColor: '#3A6B3A', name: '生物' },
    { gradientStart: '#f6f0e0', gradientEnd: '#ebe0c8', borderColor: '#ddd0b8', borderRgb: '221,208,184', accentColor: '#D4A843', titleColor: '#3D2A00', bodyColor: '#6B4A10', name: '自然' },
    { gradientStart: '#f4e6e4', gradientEnd: '#e8d2d0', borderColor: '#dcc4c0', borderRgb: '220,196,192', accentColor: '#E08080', titleColor: '#3D1A18', bodyColor: '#8B4040', name: '章鱼' },
    { gradientStart: '#e8e0f8', gradientEnd: '#d8d0f0', borderColor: '#c8c0e0', borderRgb: '200,192,224', accentColor: '#8870C8', titleColor: '#1A1040', bodyColor: '#6040A0', name: '物理' },
    { gradientStart: '#e0f4f0', gradientEnd: '#c8e8e0', borderColor: '#c0e0d8', borderRgb: '192,224,216', accentColor: '#4A9E90', titleColor: '#0A2820', bodyColor: '#2A6A60', name: '历史' },
  ]

  getCardGradient(index: number): CardGradient {
    return AppViewModel.CARD_GRADIENTS[index % AppViewModel.CARD_GRADIENTS.length]
  }

  // ── 初始化 ──

  init(): void {
    const saved = LocalStore.getAllCards()
    if (saved.length >= 3) {
      this.cards = saved
    } else {
      const all = FallbackData.getAll(31)
      for (const c of all) {
        LocalStore.saveCard(c)
      }
      this.cards = all
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
    if (dir < 0 && this.cardIndex < this.cards.length - 1) {
      this.cardIndex++
    } else if (dir > 0 && this.cardIndex > 0) {
      this.cardIndex--
    }
  }

  // ── 收藏 ──

  handleFavorite(): void {
    if (this.cards.length === 0) {
      return
    }
    const card = this.cards[this.cardIndex]
    const isFav = LocalStore.toggleFavorite(card.id)
    card.isFavorited = isFav
    this.showToast(isFav ? '已收藏' : '已取消')
  }

  removeFavorite(cardId: string): void {
    LocalStore.toggleFavorite(cardId)
    this.favorites = this.favorites.filter(c => c.id !== cardId)
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
    if (this.cards.length === 0) {
      return
    }
    const card = this.cards[this.cardIndex]
    const liked = LocalStore.toggleLike(card.id)
    card.isLiked = liked
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
    if (this.cards.length === 0) {
      return
    }
    const card = this.cards[this.cardIndex]
    const text = `【知域】${card.title}\n\n${card.content}\n\n— 来自「知域」冷知识科普`
    const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
    this.showToast('已复制到剪贴板，去 QQ/微信粘贴吧')
  }

  shareToNearby(): void {
    if (this.cards.length === 0) {
      return
    }
    const card = this.cards[this.cardIndex]
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
    const favIds = LocalStore.getFavoriteIds()
    this.favCount = favIds.length
    const all = LocalStore.getAllCards()
    this.likeCount = all.reduce((s, c) => s + c.likeCount, 0)
    this.computeCategoryStats(all)
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
    for (let i = 0; i < this.cards.length; i++) {
      if (this.cards[i].id === cardId) {
        this.cardIndex = i
        this.currentTab = 0
        break
      }
    }
  }
}
