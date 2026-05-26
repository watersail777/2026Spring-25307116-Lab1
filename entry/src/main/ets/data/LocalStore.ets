import { preferences } from '@kit.ArkData'
import { KnowledgeItem, UserProfile } from '../model/KnowledgeItem'

const STORE_NAME = 'zhiyu_store'
const INDEX_KEY = '__card_ids'
const FAV_INDEX_KEY = '__fav_ids'

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
    return str.length > 0 ? parseJSON<KnowledgeItem>(str) : null
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
    if (typeof val === 'boolean' && val) return true
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
}
