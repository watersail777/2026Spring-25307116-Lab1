import { preferences } from '@kit.ArkData'
import { KnowledgeItem, UserProfile } from '../model/KnowledgeItem'

const STORE_NAME = 'zhiyu_store'
const INDEX_KEY = '__card_ids'
const FAV_INDEX_KEY = '__fav_ids'
const READ_HISTORY_KEY = '__read_history'

export interface ReadHistoryEntry {
  cardId: string
  readAt: number
}

function parseJSON<T>(raw: string): T {
  return JSON.parse(raw) as T
}

export class LocalStore {
  private static store: preferences.Preferences | null = null

  static init(context: Context): void {
    LocalStore.store = preferences.getPreferencesSync(context, { name: STORE_NAME })
  }

  // ── 内部：索引管理 ──

  private static getCardIds(): string[] {
    const val: preferences.ValueType = LocalStore.store?.getSync(INDEX_KEY, '[]') ?? '[]'
    const str: string = typeof val === 'string' ? val : '[]'
    return parseJSON<string[]>(str)
  }

  private static setCardIds(ids: string[]): void {
    LocalStore.store?.putSync(INDEX_KEY, JSON.stringify(ids))
  }

  private static getFavIds(): string[] {
    const val: preferences.ValueType = LocalStore.store?.getSync(FAV_INDEX_KEY, '[]') ?? '[]'
    const str: string = typeof val === 'string' ? val : '[]'
    return parseJSON<string[]>(str)
  }

  private static setFavIds(ids: string[]): void {
    LocalStore.store?.putSync(FAV_INDEX_KEY, JSON.stringify(ids))
  }

  // ── 卡片存储 ──

  static saveCard(card: KnowledgeItem): void {
    LocalStore.store?.putSync(`card_${card.id}`, JSON.stringify(card))
    const ids: string[] = LocalStore.getCardIds()
    if (ids.indexOf(card.id) < 0) {
      ids.push(card.id)
      LocalStore.setCardIds(ids)
    }
    LocalStore.store?.flush()
  }

  static getCard(id: string): KnowledgeItem | null {
    const val: preferences.ValueType = LocalStore.store?.getSync(`card_${id}`, '') ?? ''
    const str: string = typeof val === 'string' ? val : ''
    if (str.length === 0) return null
    return KnowledgeItem.fromPlain(parseJSON<Record<string, Object>>(str))
  }

  static getAllCards(): KnowledgeItem[] {
    const cards: KnowledgeItem[] = []
    const ids: string[] = LocalStore.getCardIds()
    for (let i = 0; i < ids.length; i++) {
      const card: KnowledgeItem | null = LocalStore.getCard(ids[i])
      if (card !== null) cards.push(card)
    }
    return cards
  }

  static clearAllCards(): void {
    const ids: string[] = LocalStore.getCardIds()
    for (let i = 0; i < ids.length; i++) {
      LocalStore.store?.deleteSync(`card_${ids[i]}`)
    }
    LocalStore.setCardIds([])
    LocalStore.store?.flush()
  }

  // ── 收藏 ──

  static toggleFavorite(cardId: string): boolean {
    const favIds: string[] = LocalStore.getFavIds()
    const idx: number = favIds.indexOf(cardId)
    if (idx >= 0) {
      favIds.splice(idx, 1)
      LocalStore.setFavIds(favIds)
      LocalStore.store?.flush()
      return false
    }
    favIds.push(cardId)
    LocalStore.setFavIds(favIds)
    LocalStore.store?.flush()
    return true
  }

  static isFavorited(cardId: string): boolean {
    const favIds: string[] = LocalStore.getFavIds()
    return favIds.indexOf(cardId) >= 0
  }

  static getFavoriteIds(): string[] {
    return LocalStore.getFavIds()
  }

  // ── 点赞 ──

  static toggleLike(cardId: string): boolean {
    const key: string = `like_${cardId}`
    const val: preferences.ValueType = LocalStore.store?.getSync(key, false) ?? false
    if (typeof val === 'boolean' && val) {
      LocalStore.store?.putSync(key, false)
      LocalStore.store?.flush()
      return false
    }
    LocalStore.store?.putSync(key, true)
    LocalStore.store?.flush()
    return true
  }

  static isLiked(cardId: string): boolean {
    const val: preferences.ValueType = LocalStore.store?.getSync(`like_${cardId}`, false) ?? false
    return typeof val === 'boolean' ? val : false
  }

  // ── 用户资料 ──

  static saveProfile(profile: UserProfile): void {
    LocalStore.store?.putSync('profile', JSON.stringify(profile))
    LocalStore.store?.flush()
  }

  static getProfile(): UserProfile {
    const val: preferences.ValueType = LocalStore.store?.getSync('profile', '') ?? ''
    const str: string = typeof val === 'string' ? val : ''
    return str.length > 0 ? parseJSON<UserProfile>(str) : new UserProfile()
  }

  static saveTheme(name: string): void {
    LocalStore.store?.putSync('selectedTheme', name)
    LocalStore.store?.flush()
  }

  static getTheme(): string {
    const val: preferences.ValueType = LocalStore.store?.getSync('selectedTheme', '马卡龙暖调') ?? '马卡龙暖调'
    return typeof val === 'string' ? val : '马卡龙暖调'
  }

  // ── 附近圈卡片 ──

  static saveNearbyCards(cards: KnowledgeItem[]): void {
    LocalStore.store?.putSync('nearby_cards', JSON.stringify(cards))
    LocalStore.store?.flush()
  }

  static getNearbyCards(): KnowledgeItem[] {
    const val: preferences.ValueType = LocalStore.store?.getSync('nearby_cards', '[]') ?? '[]'
    const str: string = typeof val === 'string' ? val : '[]'
    return parseJSON<KnowledgeItem[]>(str)
  }

  // ── 阅读历史 ──

  static addReadHistory(cardId: string): void {
    const list: ReadHistoryEntry[] = LocalStore.getReadHistoryInternal()
    for (let i = list.length - 1; i >= 0; i--) {
      if (list[i].cardId === cardId) {
        list.splice(i, 1)
      }
    }
    list.push({ cardId: cardId, readAt: Date.now() })
    LocalStore.store?.putSync(READ_HISTORY_KEY, JSON.stringify(list))
    LocalStore.store?.flush()
  }

  static getReadHistory(): ReadHistoryEntry[] {
    return LocalStore.getReadHistoryInternal()
  }

  static removeReadHistory(cardId: string): void {
    const list: ReadHistoryEntry[] = LocalStore.getReadHistoryInternal()
    const filtered: ReadHistoryEntry[] = []
    for (let i = 0; i < list.length; i++) {
      if (list[i].cardId !== cardId) {
        filtered.push(list[i])
      }
    }
    LocalStore.store?.putSync(READ_HISTORY_KEY, JSON.stringify(filtered))
    LocalStore.store?.flush()
  }

  private static getReadHistoryInternal(): ReadHistoryEntry[] {
    const val: preferences.ValueType = LocalStore.store?.getSync(READ_HISTORY_KEY, '[]') ?? '[]'
    const str: string = typeof val === 'string' ? val : '[]'
    return parseJSON<ReadHistoryEntry[]>(str)
  }

  // ── 连续天数 ──

  static getStreak(): number {
    const val: preferences.ValueType = LocalStore.store?.getSync('streak', 0) ?? 0
    return typeof val === 'number' ? val : 0
  }

  static getLastActiveDate(): string {
    const val: preferences.ValueType = LocalStore.store?.getSync('last_active_date', '') ?? ''
    return typeof val === 'string' ? val : ''
  }

  static updateStreak(): number {
    const today = new Date().toISOString().split('T')[0]
    const lastDate = LocalStore.getLastActiveDate()
    let streak = LocalStore.getStreak()

    if (lastDate === today) {
      return streak
    }

    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0]
    if (lastDate === yesterday) {
      streak += 1
    } else {
      streak = 1
    }

    LocalStore.store?.putSync('streak', streak)
    LocalStore.store?.putSync('last_active_date', today)
    LocalStore.store?.flush()
    return streak
  }
}
