export class KnowledgeItem {
  id: string = ''
  title: string = ''
  content: string = ''
  category: string = ''
  source: string = ''
  authorId: string = ''
  authorName: string = ''
  locationCode: string = ''
  imageUrl: string = ''
  isLiked: boolean = false
  likeCount: number = 0
  isFavorited: boolean = false
  createdAt: number = Date.now()

  constructor(id: string, title: string, content: string, category: string = '', imageUrl: string = '') {
    this.id = id
    this.title = title
    this.content = content
    this.category = category
    this.imageUrl = imageUrl
  }
}

export class UserProfile {
  emoji: string = '🐼'
  nickname: string = '知域用户'
  totalLikes: number = 0
  totalFavorites: number = 0
}
