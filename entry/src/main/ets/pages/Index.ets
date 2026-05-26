import { KnowledgeItem, UserProfile } from '../model/KnowledgeItem'
import { KnowledgeCard } from '../components/KnowledgeCard'
import { DeepSeekAPI } from '../api/DeepSeekAPI'
import { LocalStore } from '../data/LocalStore'
import { NFCExchange } from '../utils/NFCExchange'
import { ColorPool } from '../utils/ColorPool'
import { FallbackData } from '../data/FallbackData'
import { LocationHelper } from '../utils/LocationHelper'
import pasteboard from '@ohos.pasteboard'
import { GlobalThis } from '../utils/GlobalThis'

const EMOJIS = ['🐼', '🐱', '🐶', '🦊', '🐸', '🐙', '🦉', '🐳', '🦋', '🌵']
const BG = '#f5f4f0'
const TEXT = '#3c3c50'
const TEXT_DIM = '#a0a0b0'
const WHITE_GLASS = 'rgba(255,255,255,0.7)'

// ── 图标组件（纯矢量） ──

@Component
struct IconDiscover {
  @Prop active: boolean = false
  build() { // 放大镜
    Stack() {
      Circle({ width: 14, height: 14 })
        .fill('none').stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.6)
      Line().width(6).height(0)
        .stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.6).strokeLineCap(LineCapStyle.Round)
        .position({ x: 12, y: 12 }).rotate({ angle: 45, centerX: 3, centerY: 0 })
    }.width(20).height(20)
  }
}

@Component
struct IconFavorites {
  @Prop active: boolean = false
  build() { // 爱心 — 更大更饱满
    Path()
      .width(21).height(19)
      .commands('M10.5 18 C10.5 18 1 11.5 1 5.5 C1 2.5 3.5 0 6.5 0 C9 0 10.5 1.5 10.5 3 C10.5 1.5 12 0 14.5 0 C17.5 0 20 2.5 20 5.5 C20 11.5 10.5 18 10.5 18 Z')
      .fill(this.active ? '#e06060' : 'none')
      .stroke(this.active ? '#e06060' : '#bfbfcc').strokeWidth(1.5)
  }
}

@Component
struct IconNearby {
  @Prop active: boolean = false
  build() { // 地球
    Stack() {
      Circle({ width: 17, height: 17 })
        .fill('none').stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(1.4)
      Line().width(14).height(0).position({ x: 1.5, y: 8.5 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.8).opacity(0.4)
      Line().width(10).height(0).position({ x: 3.5, y: 5 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.7).opacity(0.35)
      Line().width(10).height(0).position({ x: 3.5, y: 12 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.7).opacity(0.35)
      Line().width(0).height(12).position({ x: 8.5, y: 2.5 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.8).opacity(0.3)
    }.width(20).height(20)
  }
}

@Component
struct IconProfile {
  @Prop active: boolean = false
  build() { // 半身像
    Stack() {
      Circle({ width: 9, height: 9 })
        .fill('none').stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.5)
        .position({ x: 5.5, y: 0 })
      Path()
        .width(20).height(12)
        .commands('M0 22 Q2 10 10 11 Q18 10 20 22')
        .fill('none').stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.5).strokeLineCap(LineCapStyle.Round)
        .position({ x: 0, y: 7 })
    }.width(20).height(20)
  }
}

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  // ── 发现页 ──
  @State cards: KnowledgeItem[] = []
  @State cardIndex: number = 0
  @State translateX: number = 0
  @State cardOpacity: number = 1
  @State isGenerating: boolean = false
  @State toastMsg: string = ''
  private colorPool: ColorPool = new ColorPool()
  private startX: number = 0
  private gradientPair: [string, string] = ['#dcd0f0', '#c8b8e4']
  // ── 收藏 ──
  @State favorites: KnowledgeItem[] = []
  // ── 附近圈 ──
  @State nearbyCards: KnowledgeItem[] = []
  @State locationLabel: string = '定位中...'
  @State nearbyLoading: boolean = true
  // ── 我的 ──
  @State profile: UserProfile = new UserProfile()
  @State showEmojiPicker: boolean = false
  @State showNameEditor: boolean = false
  @State tempName: string = ''
  @State favCount: number = 0
  @State likeCount: number = 0
  @State categoryStats: [string, number][] = []
  @State showSettings: boolean = false
  private dotColors: string[] = ['#c5e8d5','#dcd0f0','#f8d8d4','#d0e4f4','#f8f0d0','#f0d8e4']

  aboutToAppear(): void {
    const saved = LocalStore.getAllCards()
    if (saved.length >= 3) {
      this.cards = saved
    } else {
      // 首次启动：将所有预设卡片存储为本地卡片
      const all = FallbackData.getAll(18)
      for (const c of all) { LocalStore.saveCard(c) }
      this.cards = all
    }
    this.gradientPair = this.colorPool.next()
    this.handleWidgetJump()
  }

  onPageShow(): void {
    // 从 widget 返回前台时重新检查跳转
    this.handleWidgetJump()
  }

  handleWidgetJump(): void {
    if (GlobalThis.widgetCardId.length > 0) {
      const targetId = GlobalThis.widgetCardId
      GlobalThis.widgetCardId = ''
      for (let i = 0; i < this.cards.length; i++) {
        if (this.cards[i].id === targetId) {
          this.cardIndex = i
          this.currentTab = 0  // 切换到发现页
          break
        }
      }
    }
  }

  getBarPct(count: number): number {
    const max = this.categoryStats.length > 0 ? this.categoryStats[0][1] : 1
    return Math.max(Math.ceil(count * 100 / max), 8)
  }

  getDotIndices(): number[] {
    const arr: number[] = []
    for (let i = 0; i < Math.min(this.cards.length, 10); i++) { arr.push(i) }
    return arr
  }

  // ── Tab 切换（仅点击触发） ──

  switchTab(idx: number): void {
    if (idx === this.currentTab) return
    this.currentTab = idx
    if (idx === 1) this.loadFavorites()
    if (idx === 2) this.loadNearby()
    if (idx === 3) this.loadProfile()
  }

  // ═══════════════════════════════════
  // 发现 — 异步生成卡片
  // ═══════════════════════════════════

  generateCard(): void {
    if (this.isGenerating) return
    this.isGenerating = true
    DeepSeekAPI.generateCard().then((card: KnowledgeItem) => {
      if (card !== null) {
        // 去重：检查标题是否已存在
        let dup = false
        for (const c of this.cards) { if (c.title === card.title) { dup = true; break } }
        if (!dup) {
          card.source = 'ai'
          card.imageUrl = DeepSeekAPI.getImageUrl(card.category)
          LocalStore.saveCard(card)
          this.cards.push(card)
        }
      }
      this.isGenerating = false
    }).catch(() => { this.isGenerating = false })
  }

  handleSwipe(dir: number): void {
    if (dir < 0 && this.cardIndex < this.cards.length - 1) {
      this.cardIndex++
    } else if (dir > 0 && this.cardIndex > 0) {
      this.cardIndex--
    }
    this.gradientPair = this.colorPool.next()
    // 异步生成：每切换一张卡片，后台生成一张新的
    if (this.cards.length < 50 && !this.isGenerating) {
      this.generateCard()
    }
  }

  handleFavorite(): void {
    if (this.cards.length === 0) return
    const card = this.cards[this.cardIndex]
    const isFav = LocalStore.toggleFavorite(card.id)
    card.isFavorited = isFav
    this.showToast(isFav ? '已收藏' : '已取消')
  }

  shareToSystem(): void {
    if (this.cards.length === 0) return
    const card = this.cards[this.cardIndex]
    const text = `【知域】${card.title}\n\n${card.content}\n\n— 来自「知域」冷知识科普`
    const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
    this.showToast('已复制到剪贴板，去 QQ/微信粘贴吧')
  }

  shareToNearby(): void {
    if (this.cards.length === 0) return
    const card = this.cards[this.cardIndex]
    card.authorName = this.profile.nickname
    const nearby = LocalStore.getNearbyCards()
    nearby.unshift(card)
    LocalStore.saveNearbyCards(nearby)
    this.showToast('已分享到附近圈')
  }

  handleLike(): void {
    if (this.cards.length === 0) return
    const card = this.cards[this.cardIndex]
    if (card.isLiked) { this.showToast('已点过赞'); return }
    LocalStore.toggleLike(card.id)
    card.isLiked = true
    card.likeCount++
    this.showToast('已点赞')
  }

  showToast(msg: string): void {
    this.toastMsg = msg
    setTimeout(() => { this.toastMsg = '' }, 1800)
  }

  // ═══════════════════════════════════
  // 收藏
  // ═══════════════════════════════════

  loadFavorites(): void {
    const favIds = LocalStore.getFavoriteIds()
    this.favorites = []
    for (const id of favIds) {
      const c = LocalStore.getCard(id)
      if (c !== null) { c.isFavorited = true; this.favorites.push(c) }
    }
  }

  removeFavorite(cardId: string): void {
    LocalStore.toggleFavorite(cardId)
    this.favorites = this.favorites.filter(c => c.id !== cardId)
  }

  // ═══════════════════════════════════
  // 附近圈
  // ═══════════════════════════════════

  async loadNearby(): Promise<void> {
    this.nearbyLoading = true
    this.locationLabel = await LocationHelper.getLocationLabel()
    this.nearbyCards = LocalStore.getNearbyCards()
    this.nearbyLoading = false
  }

  // ═══════════════════════════════════
  // 我的
  // ═══════════════════════════════════

  loadProfile(): void {
    this.profile = LocalStore.getProfile()
    this.tempName = this.profile.nickname
    this.favCount = LocalStore.getFavoriteIds().length
    const all = LocalStore.getAllCards()
    this.likeCount = all.reduce((s, c) => s + c.likeCount, 0)
    this.computeCategoryStats(all)
  }

  computeCategoryStats(cards: KnowledgeItem[]): void {
    const map: Record<string, number> = {}
    const total: number = cards.length
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

  getBarWidth(count: number): string {
    const total: number = this.cards.length > 0 ? this.cards.length : 1
    return Math.max(Math.ceil(count * 100 / total), 5).toString() + '%'
  }

  selectEmoji(emoji: string): void {
    this.profile.emoji = emoji
    this.showEmojiPicker = false
    LocalStore.saveProfile(this.profile)
  }

  saveNickname(): void {
    this.profile.nickname = this.tempName || '知域用户'
    this.showNameEditor = false
    LocalStore.saveProfile(this.profile)
  }

  // ═══════════════════════════════════
  // BUILD
  // ═══════════════════════════════════

  build() {
    Column() {
      // ── 内容区（条件渲染，无 Tabs 滑动干扰） ──
      Column() {
        if (this.currentTab === 0) { this.buildBrowse() }
        else if (this.currentTab === 1) { this.buildFavorites() }
        else if (this.currentTab === 2) { this.buildNearby() }
        else { this.buildProfile() }
      }
      .width('100%').layoutWeight(1)

      // ── 底部导航栏 ──
      Row() {
        Column() {
          if (this.currentTab === 0) { Circle({ width: 4, height: 4 }).fill('#8c8cb0').margin({ bottom: 4 }) }
          else { Row().height(4).margin({ bottom: 4 }) }
          IconDiscover({ active: this.currentTab === 0 })
          Text('发现').fontSize(10).fontWeight(this.currentTab === 0 ? 600 : 400).fontColor(this.currentTab === 0 ? TEXT : TEXT_DIM).margin({ top: 2 })
        }.width('25%').onClick(() => { this.switchTab(0) })
        Column() {
          if (this.currentTab === 1) { Circle({ width: 4, height: 4 }).fill('#e06060').margin({ bottom: 4 }) }
          else { Row().height(4).margin({ bottom: 4 }) }
          IconFavorites({ active: this.currentTab === 1 })
          Text('收藏').fontSize(10).fontWeight(this.currentTab === 1 ? 600 : 400).fontColor(this.currentTab === 1 ? TEXT : TEXT_DIM).margin({ top: 2 })
        }.width('25%').onClick(() => { this.switchTab(1) })
        Column() {
          if (this.currentTab === 2) { Circle({ width: 4, height: 4 }).fill('#5c8c80').margin({ bottom: 4 }) }
          else { Row().height(4).margin({ bottom: 4 }) }
          IconNearby({ active: this.currentTab === 2 })
          Text('附近圈').fontSize(10).fontWeight(this.currentTab === 2 ? 600 : 400).fontColor(this.currentTab === 2 ? TEXT : TEXT_DIM).margin({ top: 2 })
        }.width('25%').onClick(() => { this.switchTab(2) })
        Column() {
          if (this.currentTab === 3) { Circle({ width: 4, height: 4 }).fill('#8c8cb0').margin({ bottom: 4 }) }
          else { Row().height(4).margin({ bottom: 4 }) }
          IconProfile({ active: this.currentTab === 3 })
          Text('我的').fontSize(10).fontWeight(this.currentTab === 3 ? 600 : 400).fontColor(this.currentTab === 3 ? TEXT : TEXT_DIM).margin({ top: 2 })
        }.width('25%').onClick(() => { this.switchTab(3) })
      }
      .width('100%').height(60).padding({ bottom: 4, top: 4 })
      .backgroundColor('rgba(248,247,244,0.85)').backdropBlur(20)
      .border({ width: { top: 1 }, color: '#e8e6e0' })
      .shadow({ radius: 8, color: '#00000006', offsetY: -2 })
    }
    .width('100%').height('100%').backgroundColor(BG).padding({ top: 24 })
  }

  // ═══════════════════════════════════
  // 发现 TAB
  // ═══════════════════════════════════

  @Builder buildBrowse() {
    Column() {
      Row() {
        Text('知域').fontSize(24).fontWeight(700).fontColor(TEXT)
        Blank()
        Text(this.isGenerating ? '...' : `${this.cards.length} 条`).fontSize(12).fontColor('#c0c0c8')
      }
      .width('100%').padding({ left: 20, right: 20, top: 10, bottom: 6 })
      // 顶部分割线
      Row().width('86%').height(1).backgroundColor('#e8e6e0').margin({ bottom: 2 })

      // 卡片
      Stack({ alignContent: Alignment.Center }) {
        if (this.cards.length > 0 && this.cardIndex < this.cards.length) {
          KnowledgeCard({
            card: this.cards[this.cardIndex],
            gradientStart: this.gradientPair[0],
            gradientEnd: this.gradientPair[1]
          })
            .width('92%').height('86%')
            .offset({ x: this.translateX, y: 0 }).opacity(this.cardOpacity)
            .gesture(
              PanGesture({ direction: PanDirection.Horizontal, distance: 60 })
                .onActionStart(() => { this.startX = this.translateX })
                .onActionUpdate((event: GestureEvent) => {
                  this.translateX = this.startX + event.offsetX
                })
                .onActionEnd((event: GestureEvent) => {
                  if (Math.abs(event.offsetX) > 120) {
                    const dir = event.offsetX > 0 ? 1 : -1
                    this.translateX = dir * 400; this.cardOpacity = 0
                    setTimeout(() => { this.handleSwipe(dir); this.translateX = 0; this.cardOpacity = 1 }, 300)
                  } else {
                    animateTo({ duration: 250, curve: Curve.EaseOut }, () => { this.translateX = 0 })
                  }
                })
            )
        } else {
          Column() {
            // 空书架几何插画
            Stack() {
              Line().width(60).height(0).stroke('#ddd').strokeWidth(2).strokeLineCap(LineCapStyle.Round).position({ x: 0, y: 30 })
              Line().width(50).height(0).stroke('#ddd').strokeWidth(2).strokeLineCap(LineCapStyle.Round).position({ x: 5, y: 18 })
              Line().width(40).height(0).stroke('#ddd').strokeWidth(2).strokeLineCap(LineCapStyle.Round).position({ x: 10, y: 6 })
              // 斜靠的书
              Line().width(30).height(0).stroke('#ccc').strokeWidth(2.5).strokeLineCap(LineCapStyle.Round).position({ x: 8, y: 0 }).rotate({ angle: 12, centerX: 0, centerY: 4 })
            }.width(60).height(34).margin({ bottom: 16 })
            Text('暂无卡片').fontSize(15).fontColor('#999')
            Text('左右滑动发现更多').fontSize(12).fontColor('#bbb').margin({ top: 4 })
          }
          .width('92%').height('86%').justifyContent(FlexAlign.Center).borderRadius(22)
          .backgroundColor('rgba(255,255,255,0.45)')
        }
      }
      .width('100%').layoutWeight(1).alignContent(Alignment.Center)

      if (this.cards.length > 1) {
        Row() {
          ForEach(this.getDotIndices(), (i: number) => {
            Circle({ width: i === this.cardIndex ? 6 : 4, height: i === this.cardIndex ? 6 : 4 })
              .fill(i === this.cardIndex ? '#8c8cb0' : '#d8d8e0')
              .margin({ left: 3, right: 3 })
          })
        }.width('100%').justifyContent(FlexAlign.Center).margin({ bottom: 8 })
      }

      Row() {
        Button() { IconFavorites({ active: (this.cards.length > 0 && (this.cards[this.cardIndex]?.isFavorited ?? false)) }) }
          .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
          .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
          .onClick(() => { this.handleFavorite() })
        Button() { Text('👍').fontSize(17) }
          .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
          .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
          .margin({ left: 14, right: 14 }).onClick(() => { this.handleLike() })
        // 转发按钮
        Button() {
          Path().width(16).height(15)
            .commands('M1 7 L10 1 L10 5 L9 5 L9 2.5 L3 7 L9 11.5 L9 9 L10 9 L10 13 L1 7 Z M10 13 L10 15 L15 15 L15 8 L13 8 L13 13 L10 13 Z')
            .fill('none').stroke('#808090').strokeWidth(1.4).strokeLineJoin(LineJoinStyle.Round)
        }
        .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
        .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
        .margin({ right: 14 }).onClick(() => { this.shareToSystem() })
        // NFC 碰一碰
        Button() {
          Stack() {
            Circle({ width: 13, height: 13 }).fill('none').stroke('#808090').strokeWidth(1.4)
            Circle({ width: 3.5, height: 3.5 }).fill('#808090')
          }.width(18).height(18)
        }
        .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
        .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
        .onClick(() => {
          if (this.cards.length > 0) {
            NFCExchange.prepareExchangeData(this.cards[this.cardIndex])
            this.showToast('准备交换... 📱')
          }
        })
      }
      .width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 6, top: 4 })

      if (this.toastMsg) {
        Text(this.toastMsg).fontSize(13).fontColor('#fff')
          .padding({ left: 18, right: 18, top: 9, bottom: 9 })
          .backgroundColor('rgba(60,60,70,0.85)').borderRadius(16).backdropBlur(10)
      }
    }
    .width('100%').height('100%')
  }

  // ═══════════════════════════════════
  // 收藏 TAB
  // ═══════════════════════════════════

  @Builder buildFavorites() {
    Column() {
      Text('我的收藏').fontSize(22).fontWeight(700).fontColor(TEXT)
        .width('100%').padding({ left: 20, top: 14, bottom: 10 })

      if (this.favorites.length === 0) {
        Column() {
          // 空心几何插画
          Stack() {
            Path().width(40).height(36)
              .commands('M20 0 C8 0 0 10 0 17 C0 24 8 34 20 36 C32 34 40 24 40 17 C40 10 32 0 20 0 Z')
              .fill('none').stroke('#ddd').strokeWidth(1.8)
          }.width(40).height(36).margin({ bottom: 14 })
          Text('还没有收藏').fontSize(15).fontColor('#999')
          Text('在发现页点击底部爱心即可收藏').fontSize(12).fontColor('#bbb').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.favorites, (item: KnowledgeItem) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title).fontSize(15).fontWeight(600).fontColor(TEXT)
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.content).fontSize(12).fontColor('#888')
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 4 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Button('取消').fontSize(11).fontColor('#e06060').backgroundColor('#fef0f0')
                  .borderRadius(10).height(30).onClick(() => { this.removeFavorite(item.id) })
              }
              .width('100%').padding(14).borderRadius(14)
              .backgroundColor(WHITE_GLASS).margin({ bottom: 8, left: 16, right: 16 })
            }
          })
        }.width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%')
  }

  // ═══════════════════════════════════
  // 附近圈 TAB
  // ═══════════════════════════════════

  @Builder buildNearby() {
    Column() {
      Row() {
        Text('附近圈').fontSize(22).fontWeight(700).fontColor(TEXT)
        Blank()
        Text(`📍 ${this.locationLabel}`).fontSize(10).fontColor('#999')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(WHITE_GLASS).borderRadius(10)
      }
      .width('100%').padding({ left: 20, right: 20, top: 14, bottom: 6 })

      Text('附近街坊分享的本地小知识：哪家餐馆好吃、哪里修路、附近趣事…')
        .fontSize(12).fontColor('#aaa').width('100%').padding({ left: 20, bottom: 8 })

      if (this.nearbyLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#ccc')
          Text('查找附近...').fontSize(12).fontColor('#aaa').margin({ top: 10 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.nearbyCards.length === 0) {
        Column() {
          // 空地图定位插画
          Stack() {
            Circle({ width: 36, height: 36 }).fill('none').stroke('#ddd').strokeWidth(1.8)
            Circle({ width: 8, height: 8 }).fill('none').stroke('#ddd').strokeWidth(1.8).position({ x: 14, y: 10 })
            Line().width(0).height(8).stroke('#ddd').strokeWidth(1.4).position({ x: 18, y: 18 })
          }.width(36).height(36).margin({ bottom: 14 })
          Text('附近还没有人分享').fontSize(15).fontColor('#999')
          Text('去发现页转发到附近圈吧').fontSize(12).fontColor('#bbb').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.nearbyCards, (item: KnowledgeItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.authorName || '匿名用户').fontSize(11).fontColor('#aaa')
                  Blank()
                }.width('100%').margin({ bottom: 6 })
                Text(item.title).fontSize(15).fontWeight(600).fontColor(TEXT).margin({ bottom: 4 })
                Text(item.content).fontSize(12).fontColor('#888')
                  .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%').padding(14).borderRadius(14)
              .backgroundColor(WHITE_GLASS).margin({ bottom: 8, left: 16, right: 16 })
            }
          })
        }.width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%')
  }

  // ═══════════════════════════════════
  // 我的 TAB
  // ═══════════════════════════════════

  @Builder buildProfile() {
    Column() {
      Text('我的').fontSize(22).fontWeight(700).fontColor(TEXT)
        .width('100%').padding({ left: 20, top: 14, bottom: 14 })

      Text(this.profile.emoji).fontSize(48)
        .onClick(() => { this.showEmojiPicker = !this.showEmojiPicker })

      if (this.showEmojiPicker) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(EMOJIS, (emoji: string) => {
            Text(emoji).fontSize(28).padding(6).onClick(() => { this.selectEmoji(emoji) })
          })
        }
        .width('88%').backgroundColor(WHITE_GLASS).borderRadius(14).padding(10).margin({ top: 8, bottom: 8 })
      }

      Row() {
        if (this.showNameEditor) {
          TextInput({ text: this.tempName })
            .fontSize(16).fontColor(TEXT).backgroundColor(WHITE_GLASS).borderRadius(8)
            .height(38).width(160).onChange((v: string) => { this.tempName = v }).layoutWeight(1)
          Button('保存').fontSize(12).fontColor('#fff').backgroundColor('#8c8cb0')
            .borderRadius(8).height(34).margin({ left: 10 }).onClick(() => { this.saveNickname() })
        } else {
          Text(this.profile.nickname).fontSize(18).fontWeight(600).fontColor(TEXT)
          Text(' ✏️').fontSize(14).onClick(() => { this.showNameEditor = true })
        }
      }.margin({ top: 10, bottom: 20 })

      Row() {
        Column() {
          Text(`${this.favCount}`).fontSize(26).fontWeight(700).fontColor(TEXT)
          Text('收藏').fontSize(12).fontColor('#999').margin({ top: 2 })
        }.width('45%')
        Divider().vertical(true).height(36).color('#e0ded8')
        Column() {
          Text(`${this.likeCount}`).fontSize(26).fontWeight(700).fontColor(TEXT)
          Text('获赞').fontSize(12).fontColor('#999').margin({ top: 2 })
        }.width('45%')
      }
      .width('82%').justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: 14, bottom: 14 }).backgroundColor(WHITE_GLASS).borderRadius(16).margin({ bottom: 14 })

      // ── 知识领域 ──
      if (this.categoryStats.length > 0) {
        Column() {
          Text('知识领域').fontSize(13).fontWeight(600).fontColor(TEXT).margin({ bottom: 10 })
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.categoryStats.slice(0, 6), (item: [string, number], idx: number) => {
              Column() {
                Text(item[1].toString()).fontSize(18).fontWeight(700).fontColor(TEXT)
                Row() {
                  Circle({ width: 6, height: 6 }).fill(this.dotColors[idx % this.dotColors.length])
                  Text(item[0]).fontSize(10).fontColor('#999').maxLines(1).margin({ left: 3 })
                }.margin({ top: 4 })
              }
              .margin({ right: idx < 5 ? 16 : 0 })
            })
          }
          .width('100%')
        }
        .width('88%').padding(14).backgroundColor(WHITE_GLASS).borderRadius(14).margin({ bottom: 16 })
      }

      // 条形图
      if (this.categoryStats.length > 0) {
        Column() {
          Text('分类详情').fontSize(13).fontWeight(600).fontColor(TEXT).margin({ bottom: 8 })
          ForEach(this.categoryStats.slice(0, 8), (item: [string, number]) => {
            Row() {
              Text(item[0]).fontSize(11).fontColor('#666').width(72).maxLines(1)
              Row() {
                Row()
                  .width(this.getBarPct(item[1]) + '%').height(12).borderRadius(6)
                  .linearGradient({ direction: GradientDirection.Right, colors: [['#c5e8d5', 0.0], ['#a0d4bc', 1.0]] })
              }
              .width('50%').height(12).backgroundColor('#f0f0f4').borderRadius(6)
              Text(item[1].toString()).fontSize(10).fontColor('#999').width(24).margin({ left: 6 })
            }
            .width('100%').margin({ bottom: 5 })
          })
        }
        .width('88%').padding(14).backgroundColor(WHITE_GLASS).borderRadius(14).margin({ bottom: 14 })
      }

      // 设置入口
      Row() {
        Text('⚙ 设置').fontSize(13).fontColor('#888')
        Blank()
        Text('›').fontSize(16).fontColor('#ccc')
      }
      .width('88%').padding(14).backgroundColor(WHITE_GLASS).borderRadius(14)
      .margin({ bottom: 10 }).onClick(() => { this.showSettings = true })

      Text('知域 · 冷知识科普卡片').fontSize(11).fontColor('#bbb')
      Text('Version 1.0.0').fontSize(10).fontColor('#ddd').margin({ top: 2 })
    }
    .width('100%').height('100%')
  }
}
