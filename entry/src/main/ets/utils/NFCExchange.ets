import { KnowledgeItem } from '../model/KnowledgeItem'
import { LocalStore } from '../data/LocalStore'

interface CardPayload {
  title: string
  content: string
}

interface ExchangePayload {
  current: CardPayload
  recentFavorite: CardPayload | null
}

export class NFCExchange {
  static async prepareExchangeData(currentCard: KnowledgeItem): Promise<string> {
    const favIds: string[] = await LocalStore.getFavoriteIds()
    let recentFav: KnowledgeItem | null = null
    if (favIds.length > 0) {
      recentFav = LocalStore.getCard(favIds[favIds.length - 1])
    }
    const payload: ExchangePayload = {
      current: { title: currentCard.title, content: currentCard.content },
      recentFavorite: recentFav !== null ? { title: recentFav.title, content: recentFav.content } : null
    }
    return JSON.stringify(payload)
  }

  static parseExchangeData(rawData: string): KnowledgeItem[] {
    try {
      const parsed: ExchangePayload = JSON.parse(rawData) as ExchangePayload
      const cards: KnowledgeItem[] = []
      cards.push(new KnowledgeItem('', parsed.current.title, parsed.current.content))
      if (parsed.recentFavorite !== null) {
        cards.push(new KnowledgeItem('', parsed.recentFavorite.title, parsed.recentFavorite.content))
      }
      return cards
    } catch (_) {
      return []
    }
  }
}
