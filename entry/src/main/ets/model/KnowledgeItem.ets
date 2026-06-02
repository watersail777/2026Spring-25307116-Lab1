@ObservedV2
export class KnowledgeItem {
  @Trace id: string = ''
  @Trace title: string = ''
  @Trace content: string = ''
  @Trace category: string = ''
  @Trace source: string = ''
  @Trace authorId: string = ''
  @Trace authorName: string = ''
  @Trace locationCode: string = ''
  @Trace imageUrl: string = ''
  @Trace isLiked: boolean = false
  @Trace likeCount: number = 0
  @Trace isFavorited: boolean = false
  @Trace createdAt: number = Date.now()

  constructor(id: string, title: string, content: string, category: string = '', imageUrl: string = '') {
    this.id = id
    this.title = title
    this.content = content
    this.category = category
    this.imageUrl = imageUrl
  }

  static fromPlain(obj: Record<string, Object>): KnowledgeItem {
    const item = new KnowledgeItem('', '', '', '', '')
    item.id = (obj['id'] as string) ?? ''
    item.title = (obj['title'] as string) ?? ''
    item.content = (obj['content'] as string) ?? ''
    item.category = (obj['category'] as string) ?? ''
    item.source = (obj['source'] as string) ?? ''
    item.authorId = (obj['authorId'] as string) ?? ''
    item.authorName = (obj['authorName'] as string) ?? ''
    item.locationCode = (obj['locationCode'] as string) ?? ''
    item.imageUrl = (obj['imageUrl'] as string) ?? ''
    item.isLiked = (obj['isLiked'] as boolean) ?? false
    item.likeCount = (obj['likeCount'] as number) ?? 0
    item.isFavorited = (obj['isFavorited'] as boolean) ?? false
    item.createdAt = (obj['createdAt'] as number) ?? Date.now()
    return item
  }
}

export class UserProfile {
  emoji: string = '🐼'
  nickname: string = '知域用户'
  totalLikes: number = 0
  totalFavorites: number = 0
}
