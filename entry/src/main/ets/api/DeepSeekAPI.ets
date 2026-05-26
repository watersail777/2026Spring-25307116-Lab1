import { http } from '@kit.NetworkKit'
import { KnowledgeItem } from '../model/KnowledgeItem'
import { FallbackData } from '../data/FallbackData'

const API_KEY = 'sk-b19e9821caa64e74ae0e59e12c6adac7'
const API_URL = 'https://api.deepseek.com/chat/completions'

function generateId(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
    const r = Math.random() * 16 | 0
    const v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

export class DeepSeekAPI {
  static async generateCard(): Promise<KnowledgeItem> {
    try {
      const httpRequest = http.createHttp()
      const response = await httpRequest.request(API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${API_KEY}`
        },
        extraData: {
          model: 'deepseek-chat',
          messages: [
            {
              role: 'system',
              content: '你是趣味谈资生成助手，输出JSON：{"title":"标题","content":"正文","category":"分类"}。要求：有趣、反直觉、可作为社交谈资（让人听完想说"真的假的？"）、有真实科学依据或文化典故、带具体细节。标题≤18字勾住好奇心，正文80-150字。领域不限：医学/生物/天文/人体/文化/饮食/语言/历史/自然等。不确定标"科学假说"。'
            },
            { role: 'user', content: '来一条冷知识' }
          ],
          temperature: 0.9,
          max_tokens: 256
        },
        connectTimeout: 15000,
        readTimeout: 20000
      })

      httpRequest.destroy()
      if (response.responseCode === 200) {
        const raw = response.result as string
        const data = JSON.parse(raw) as Record<string, object>
        const text: string = data.choices[0].message.content as string
        const cleaned = text.replace(/```json|```/g, '').trim()
        const parsed = JSON.parse(cleaned) as Record<string, string>

        return new KnowledgeItem(
          generateId(),
          parsed['title'] ?? '冷知识',
          parsed['content'] ?? '一条有趣的冷知识',
          parsed['category'] ?? ''
        )
      }
    } catch (e) {
      console.error('[DeepSeekAPI] failed:', JSON.stringify(e))
    }
    return FallbackData.getRandomCard()
  }

  static getImageUrl(category: string): string {
    // 用 category 作随机种子生成配图 URL（Picsum 稳定且免费）
    const seed: string = category.length > 0 ? category.replace(/\s+/g, '-') : 'knowledge'
    return `https://picsum.photos/seed/${seed}/600/400`
  }
}
