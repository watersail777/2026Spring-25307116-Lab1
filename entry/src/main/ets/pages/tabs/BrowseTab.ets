import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel, CardGradient } from '../../model/AppViewModel'
import { KnowledgeCard } from '../../components/KnowledgeCard'

@ComponentV2
export struct BrowseTab {
  @Require @Param vm: AppViewModel

  @Local tabMode: string = 'today'
  @Local translateX: number = 0
  @Local cardOpacity: number = 1
  @Local currentGradient: CardGradient = this.vm.getCardGradient(0)
  private startX: number = 0

  updateGradient(): void { this.currentGradient = this.vm.getCardGradient(this.vm.cardIndex) }
  handleSwipe(dir: number): void {
    if (dir < 0 && this.vm.cardIndex < this.vm.cards.length - 1) { this.vm.cardIndex++ }
    else if (dir > 0 && this.vm.cardIndex > 0) { this.vm.cardIndex-- }
    this.updateGradient()
  }
  prevCard(): void { if (this.vm.cardIndex > 0) { this.vm.cardIndex--; this.updateGradient() } }
  nextCard(): void { if (this.vm.cardIndex < this.vm.cards.length - 1) { this.vm.cardIndex++; this.updateGradient() } }

  build() {
    Column() {
      // ── Tab 标签：今日 / 精选 ──
      Row() {
        Column() {
          Text('今日').fontSize(15).fontWeight(700)
            .fontColor(this.tabMode === 'today' ? '#1F2937' : '#9CA3AF')
          if (this.tabMode === 'today') {
            Row().width(20).height(3).borderRadius(2).backgroundColor('#1F2937').margin({ top: 4 })
          }
        }.onClick(() => { this.tabMode = 'today' })

        Blank().width(32)

        Column() {
          Text('精选').fontSize(15).fontWeight(500)
            .fontColor(this.tabMode === 'featured' ? '#1F2937' : '#9CA3AF')
          if (this.tabMode === 'featured') {
            Row().width(20).height(3).borderRadius(2).backgroundColor('#1F2937').margin({ top: 4 })
          }
        }.onClick(() => { this.tabMode = 'featured' })
      }
      .width('100%').justifyContent(FlexAlign.Center).padding({ top: 8, bottom: 8 })

      // ── 卡片区 ──
      Stack({ alignContent: Alignment.Center }) {
        if (this.vm.cards.length > 0 && this.vm.cardIndex < this.vm.cards.length) {
          // 后方虚影
          Column()
            .width('82%').height('76%').borderRadius(28)
            .linearGradient({
              angle: 165,
              colors: [[this.currentGradient.gradientStart, 0.0], [this.currentGradient.gradientEnd, 0.5], [this.currentGradient.gradientStart + '88', 1.0]]
            })
            .opacity(0.4).scale({ x: 0.93, y: 0.93 }).offset({ x: 0, y: 16 })

          // 主卡片 (w:318 = 390-40padding-32margin)
          KnowledgeCard({
            card: this.vm.cards[this.vm.cardIndex],
            gradient: this.currentGradient,
            showActions: true,
            onFavorite: () => { this.vm.handleFavorite() },
            onLike: () => { this.vm.handleLike() },
            onShare: () => { this.vm.shareToSystem() }
          })
            .width('82%').height('76%')
            .offset({ x: this.translateX, y: 0 }).opacity(this.cardOpacity)
            .gesture(
              PanGesture({ direction: PanDirection.Horizontal, distance: 60 })
                .onActionStart(() => { this.startX = this.translateX })
                .onActionUpdate((event: GestureEvent) => { this.translateX = this.startX + event.offsetX })
                .onActionEnd((event: GestureEvent) => {
                  if (Math.abs(event.offsetX) > 120) {
                    const dir = event.offsetX > 0 ? 1 : -1
                    this.translateX = dir * 400; this.cardOpacity = 0
                    setTimeout(() => { this.handleSwipe(dir); this.translateX = 0; this.cardOpacity = 1 }, 300)
                  } else {
                    this.getUIContext().animateTo({ duration: 250, curve: Curve.EaseOut }, () => { this.translateX = 0 })
                  }
                })
            )
        } else {
          Column() {
            Text('暂无卡片').fontSize(15).fontColor('#9CA3AF')
            Text('左右滑动发现更多').fontSize(12).fontColor('#D1D5DB').margin({ top: 4 })
          }
          .width('82%').height('76%').justifyContent(FlexAlign.Center).borderRadius(28)
          .backgroundColor('rgba(255,255,255,0.4)')
        }
      }
      .width('100%').layoutWeight(1)

      // ── 页码指示器（主题色高亮）──
      if (this.vm.cards.length > 1) {
        Row() {
          ForEach(this.vm.getDotIndices(), (i: number) => {
            if (i === this.vm.cardIndex) {
              Row().width(24).height(6).borderRadius(3)
                .backgroundColor(this.currentGradient.accentColor)
                .margin({ left: 4, right: 4 })
            } else {
              Circle({ width: 6, height: 6 }).fill('#D1D5DB')
                .margin({ left: 4, right: 4 })
            }
          })
        }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 14, bottom: 10 })
      }

      // ── 浮动导航：白底 chevron + 渐变 shuffle ──
      Row() {
        // 左箭头（白底）
        Button() { Image($r('app.media.chevronleft')).width(20).height(20) }
          .width(48).height(48).borderRadius(24)
          .backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
          .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
          .enabled(this.vm.cardIndex > 0).opacity(this.vm.cardIndex > 0 ? 1 : 0.25)
          .onClick(() => { this.prevCard() })

        // 中心 shuffle（渐变紫）
        Button() { Image($r('app.media.shuffle')).width(24).height(24) }
          .width(60).height(60).borderRadius(30)
          .shadow({ radius: 20, color: 'rgba(155,114,176,0.2)', offsetY: 8 })
          .linearGradient({
            angle: 135,
            colors: [['rgba(201,168,216,1)', 0.0], ['rgba(155,114,176,1)', 1.0]]
          })
          .margin({ left: 20, right: 20 })

        // 右箭头（白底）
        Button() { Image($r('app.media.chevronright2')).width(20).height(20) }
          .width(48).height(48).borderRadius(24)
          .backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
          .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
          .enabled(this.vm.cardIndex < this.vm.cards.length - 1)
          .opacity(this.vm.cardIndex < this.vm.cards.length - 1 ? 1 : 0.25)
          .onClick(() => { this.nextCard() })
      }
      .width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 8, top: 2 })

      // ── Toast ──
      if (this.vm.toastMsg.length > 0) {
        Row() {
          Path().width(16).height(16).commands('M20 6L9 17 4 12')
            .fill('none').stroke('#A7F3D0').strokeWidth(3)
            .strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
            .margin({ right: 8 })
          Text(this.vm.toastMsg).fontSize(14).fontColor('#FFFFFF')
        }
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
        .backgroundColor('rgba(31,41,55,0.88)').borderRadius(20).backdropBlur(10)
      }
    }
    .width('100%').height('100%')
  }
}
