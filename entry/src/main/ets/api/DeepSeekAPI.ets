import http from '@ohos.net.http'
import { KnowledgeItem } from '../model/KnowledgeItem'

interface GeneratedCard {
  title: string
  content: string
  category: string
}

const API_URL = 'https://vercel-deepseek-proxy.vercel.app/api/deepseek'
const APP_SECRET = 'zhiyu-2026'
const MAX_RETRIES = 3

export class DeepSeekAPI {
  /**
   * 调 Vercel 云函数生成一张冷知识卡片
   * @param prompt 主题词（如"蚊子""金字塔"）
   * @returns 成功返回 KnowledgeItem，失败返回 null
   */
  static async generateCard(prompt: string): Promise<KnowledgeItem | null> {
    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        const client = http.createHttp()
        const res = await client.request(API_URL, {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ prompt: prompt, secret: APP_SECRET }),
          connectTimeout: 10000,
          readTimeout: 30000
        })
        client.destroy()

        if (res.responseCode !== 200) {
          console.error(`[DeepSeekAPI] HTTP ${res.responseCode} on attempt ${attempt}`)
          if (attempt < MAX_RETRIES) {
            await sleep(1000 * attempt) // 指数退避
          }
          continue
        }

        const json: GeneratedCard = JSON.parse(res.result as string) as GeneratedCard
        if (!json.title || !json.content || !json.category) {
          console.error('[DeepSeekAPI] Incomplete response:', JSON.stringify(json))
          if (attempt < MAX_RETRIES) {
            await sleep(1000 * attempt)
          }
          continue
        }

        const card = new KnowledgeItem(generateId(), json.title, json.content, json.category)
        card.source = 'ai'
        return card
      } catch (e) {
        console.error(`[DeepSeekAPI] Attempt ${attempt} failed:`, JSON.stringify(e))
        if (attempt < MAX_RETRIES) {
          await sleep(1000 * attempt)
        }
      }
    }
    console.error('[DeepSeekAPI] All retries exhausted')
    return null
  }
}

function generateId(): string {
  return 'ai-xxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
    const r = Math.random() * 16 | 0
    const v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}
