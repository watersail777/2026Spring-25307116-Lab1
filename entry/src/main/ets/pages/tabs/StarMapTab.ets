import { AppViewModel, CardGradient } from '../../model/AppViewModel'
import { KnowledgeItem } from '../../model/KnowledgeItem'
import { KnowledgeCard } from '../../components/KnowledgeCard'
import { StarNode } from '../../components/StarNode'

// ── 分类到画布区域的布局映射 ──
const CATEGORY_CENTERS: Record<string, [number, number]> = {
  '医学·冷知识': [600, 280],
  '基因·冷知识': [850, 350],
  '化学·冷知识': [350, 340],
  '食品·冷知识': [760, 580],
  '历史·冷知识': [420, 600],
  '文化·冷知识': [580, 140],
  '文学·冷知识': [480, 200],
  '人体·冷知识': [720, 160],
  '生物·冷知识': [880, 520],
  '天文·冷知识': [200, 250],
  '饮食·冷知识': [300, 500],
  '法医·冷知识': [500, 450],
  '科学假说': [150, 450],
  '自然·冷知识': [600, 720],
  '材料·冷知识': [400, 780],
  '电影·冷知识': [800, 700],
  '植物·冷知识': [250, 700],
  '体育·冷知识': [680, 800],
}

function scatterPositions(vm: AppViewModel): [number, number][] {
  const positions: [number, number][] = []
  const grouped: Map<string, number[]> = new Map()

  for (let i = 0; i < vm.cards.length; i++) {
    const cat = vm.cards[i].category || '冷知识'
    if (!grouped.has(cat)) grouped.set(cat, [])
    grouped.get(cat)!.push(i)
  }

  // 为每张卡生成坐标
  const result: [number, number][] = new Array(vm.cards.length)

  grouped.forEach((indices: number[], cat: string) => {
    const center = CATEGORY_CENTERS[cat] ?? [600 + Math.random() * 400 - 200, 600 + Math.random() * 400 - 200]
    const count = indices.length
    const radius = count <= 1 ? 0 : 40 + count * 8

    for (let j = 0; j < indices.length; j++) {
      const angle = (j / indices.length) * Math.PI * 2 + (Math.random() - 0.5) * 0.6
      const dist = radius * (0.3 + Math.random() * 0.7)
      const x = center[0] + Math.cos(angle) * dist
      const y = center[1] + Math.sin(angle) * dist
      result[indices[j]] = [x, y]
    }
  })

  return result
}

@ComponentV2
export struct StarMapTab {
  @Require @Param vm: AppViewModel
  @Local zoomScale: number = 0.55
  @Local offsetX: number = -80
  @Local offsetY: number = -120
  @Local currentIdx: number = 0
  @Local exploredIndices: Set<number> = new Set([0])
  @Local showDetail: boolean = false
  @Local starPositions: [number, number][] = []

  private startZoomScale: number = 0.55
  private lastPanX: number = 0
  private lastPanY: number = 0

  aboutToAppear(): void {
    this.starPositions = scatterPositions(this.vm)
    this.vm.markAsRead(this.vm.cards[0].id)
  }

  private getGradient(idx: number): CardGradient {
    return this.vm.getCardGradient(idx)
  }

  private selectStar(idx: number): void {
    this.currentIdx = idx
    this.exploredIndices.add(idx)
    this.vm.markAsRead(this.vm.cards[idx].id)
    this.showDetail = true
  }

  private handlePrev(): void {
    if (this.currentIdx > 0) {
      this.currentIdx--
      this.exploredIndices.add(this.currentIdx)
      this.vm.markAsRead(this.vm.cards[this.currentIdx].id)
    }
  }

  private handleNext(): void {
    if (this.currentIdx < this.vm.cards.length - 1) {
      this.currentIdx++
      this.exploredIndices.add(this.currentIdx)
      this.vm.markAsRead(this.vm.cards[this.currentIdx].id)
    }
  }

  build() {
    Column() {
      // ── 星图画布 ──
      Stack() {
        // 深空背景
        Column()
          .width('100%').height('100%')
          .linearGradient({
            angle: 180,
            colors: [['#0a0a1a', 0.0], ['#12122a', 0.5], ['#1a1a3a', 1.0]]
          })

        // 星云色块（装饰）
        Column()
          .width(300).height(300).borderRadius(150)
          .backgroundColor('#1a3a5a20')
          .position({ x: '15%', y: '20%' })
        Column()
          .width(250).height(250).borderRadius(125)
          .backgroundColor('#3a1a4a20')
          .position({ x: '55%', y: '50%' })
        Column()
          .width(200).height(200).borderRadius(100)
          .backgroundColor('#1a3a3a20')
          .position({ x: '30%', y: '65%' })

        // 星星层（缩放+平移变换）
        Stack() {
          ForEach(this.vm.cards, (card: KnowledgeItem, idx: number) => {
            Stack() {
              StarNode({
                accentColor: this.getGradient(idx).accentColor,
                explored: this.exploredIndices.has(idx),
                isCurrent: idx === this.currentIdx,
                label: card.title.length > 12 ? card.title.substring(0, 12) : card.title,
                onTap: () => { this.selectStar(idx) }
              })
            }
            .position({ x: this.starPositions[idx]?.[0] ?? 600, y: this.starPositions[idx]?.[1] ?? 600 })
            .width(0).height(0)
          }, (card: KnowledgeItem, idx: number) => idx.toString())
        }
        .width(1200).height(1200)
        .scale({ x: this.zoomScale, y: this.zoomScale })
        .translate({ x: this.offsetX, y: this.offsetY })

        // 详情覆盖层
        if (this.showDetail) {
          Column() {
            // 关闭按钮
            Row() {
              Blank()
              Button() {
                Text('✕').fontSize(20).fontColor('#FFFFFF')
              }
              .width(40).height(40).borderRadius(20)
              .backgroundColor('rgba(255,255,255,0.12)')
              .onClick(() => { this.showDetail = false })
            }
            .width('100%').padding({ right: 8, top: 8 })

            KnowledgeCard({
              card: this.vm.cards[this.currentIdx],
              gradient: this.getGradient(this.currentIdx),
              showActions: true,
              onFavorite: () => { this.vm.handleFavorite() },
              onLike: () => { this.vm.handleLike() },
              onShare: () => { this.vm.shareToSystem() }
            })
              .width('88%')

            Row().height(16).width('100%')
          }
          .width('100%').height('100%')
          .backgroundColor('rgba(0,0,0,0.85)')
          .backdropBlur(20)
        }
      }
      .width('100%').layoutWeight(1)
      .clip(true)
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PanGesture({ fingers: 1, distance: 8 })
            .onActionStart(() => {
              this.lastPanX = 0; this.lastPanY = 0
            })
            .onActionUpdate((event: GestureEvent) => {
              this.offsetX += event.offsetX - this.lastPanX
              this.offsetY += event.offsetY - this.lastPanY
              this.lastPanX = event.offsetX
              this.lastPanY = event.offsetY
            }),
          PinchGesture({ fingers: 2 })
            .onActionStart(() => {
              this.startZoomScale = this.zoomScale
            })
            .onActionUpdate((event: GestureEvent) => {
              const s = this.startZoomScale * event.scale
              this.zoomScale = Math.max(0.25, Math.min(2.5, s))
            })
        )
      )

      // ── 底部导航 ──
      Row() {
        Button() {
          Text('←').fontSize(18).fontColor('#FFFFFF')
        }
        .width(44).height(44).borderRadius(22)
        .backgroundColor('rgba(255,255,255,0.1)')
        .enabled(this.currentIdx > 0)
        .opacity(this.currentIdx > 0 ? 1 : 0.2)
        .onClick(() => { this.handlePrev() })

        Text(`${this.currentIdx + 1} / ${this.vm.cards.length}`)
          .fontSize(15).fontWeight(500).fontColor('#AAAAAA')
          .margin({ left: 20, right: 20 })

        Button() {
          Text('→').fontSize(18).fontColor('#FFFFFF')
        }
        .width(44).height(44).borderRadius(22)
        .backgroundColor('rgba(255,255,255,0.1)')
        .enabled(this.currentIdx < this.vm.cards.length - 1)
        .opacity(this.currentIdx < this.vm.cards.length - 1 ? 1 : 0.2)
        .onClick(() => { this.handleNext() })
      }
      .width('100%').justifyContent(FlexAlign.Center)
      .padding({ top: 10, bottom: 14 })
      .backgroundColor('#0a0a1a')
    }
    .width('100%').height('100%')
  }
}
