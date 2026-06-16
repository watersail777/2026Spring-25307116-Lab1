interface KnowledgeItemPlain {
  id: string
  title: string
  content: string
  category: string
  source: string
  authorId: string
  authorName: string
  locationCode: string
  imageUrl: string
  isLiked: boolean
  likeCount: number
  isFavorited: boolean
  createdAt: number
}

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

  // JSON.stringify 不会枚举 @Trace 装饰的属性，必须显式 toJSON
  toJSON(): KnowledgeItemPlain {
    return {
      id: this.id,
      title: this.title,
      content: this.content,
      category: this.category,
      source: this.source,
      authorId: this.authorId,
      authorName: this.authorName,
      locationCode: this.locationCode,
      imageUrl: this.imageUrl,
      isLiked: this.isLiked,
      likeCount: this.likeCount,
      isFavorited: this.isFavorited,
      createdAt: this.createdAt
    } as KnowledgeItemPlain
  }

  static fromPlain(obj: Record<string, Object>): KnowledgeItem {
    const item = new KnowledgeItem(
      (obj['id'] as string) ?? '',
      (obj['title'] as string) ?? '',
      (obj['content'] as string) ?? '',
      (obj['category'] as string) ?? '',
      (obj['imageUrl'] as string) ?? ''
    )
    item.source = (obj['source'] as string) ?? ''
    item.authorId = (obj['authorId'] as string) ?? ''
    item.authorName = (obj['authorName'] as string) ?? ''
    item.locationCode = (obj['locationCode'] as string) ?? ''
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
  bio: string = '好奇心是最好的老师'
  totalLikes: number = 0
  totalFavorites: number = 0
  avatarUri: string = ''
  bgUri: string = ''
}
