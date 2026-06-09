import { preferences } from '@kit.ArkData'

// ═══════════════════════════════════════
// 本地持久化存储 — preferences 封装
// ═══════════════════════════════════════

export class LocalStore {
  private static store: preferences.Preferences | null = null

  static init(context: Context): void {
    LocalStore.store = preferences.getPreferencesSync(context, { name: 'ontrack_store' })
  }

  private static ensure(): preferences.Preferences {
    if (LocalStore.store === null) throw new Error('LocalStore not initialized')
    return LocalStore.store
  }

  // ── 最近查询 ──

  static getRecentQueries(): string[] {
    try {
      const raw = LocalStore.ensure().getSync('recent_queries', '[]') as string
      return JSON.parse(raw) as string[]
    } catch (_) {
      return []
    }
  }

  static addRecentQuery(dep: string, arr: string): void {
    const key = `${dep} → ${arr}`
    let list = LocalStore.getRecentQueries()
    list = list.filter(q => q !== key)
    list.unshift(key)
    if (list.length > 20) list = list.slice(0, 20)
    LocalStore.ensure().putSync('recent_queries', JSON.stringify(list))
    LocalStore.ensure().flush()
  }

  // ── 收藏路线 ──

  static getFavorites(): string[] {
    try {
      const raw = LocalStore.ensure().getSync('favorites', '[]') as string
      return JSON.parse(raw) as string[]
    } catch (_) {
      return []
    }
  }

  static toggleFavorite(routeJson: string): boolean {
    let list = LocalStore.getFavorites()
    const idx = list.indexOf(routeJson)
    if (idx >= 0) {
      list.splice(idx, 1)
      LocalStore.ensure().putSync('favorites', JSON.stringify(list))
      LocalStore.ensure().flush()
      return false
    } else {
      list.unshift(routeJson)
      if (list.length > 50) list = list.slice(0, 50)
      LocalStore.ensure().putSync('favorites', JSON.stringify(list))
      LocalStore.ensure().flush()
      return true
    }
  }
}