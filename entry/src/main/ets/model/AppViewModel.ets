import { KnowledgeItem, UserProfile } from './KnowledgeItem'
import { LocalStore } from '../data/LocalStore'
import { NFCExchange } from '../utils/NFCExchange'
import { LocationHelper } from '../utils/LocationHelper'
import { FallbackData } from '../data/FallbackData'
import pasteboard from '@ohos.pasteboard'

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
  @Trace categoryStats: [string, number][] = []

  private dotColors: string[] = ['#c5e8d5', '#dcd0f0', '#f8d8d4', '#d0e4f4', '#f8f0d0', '#f0d8e4']

  // ── 初始化 ──

  init(): void {
    const saved = LocalStore.getAllCards()
    if (saved.length >= 3) {
      this.cards = saved
    } else {
      const all = FallbackData.getAll(18)
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
    if (card.isLiked) {
      this.showToast('已点过赞')
      return
    }
    LocalStore.toggleLike(card.id)
    card.isLiked = true
    card.likeCount++
    this.showToast('已点赞')
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
    for (let i = 0; i < Math.min(this.cards.length, 10); i++) {
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
