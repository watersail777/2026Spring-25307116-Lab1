import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel, CardGradient } from '../../model/AppViewModel'
import { KnowledgeCard } from '../../components/KnowledgeCard'

@ComponentV2
export struct BrowseTab {
  @Require @Param vm: AppViewModel

  @Local mode: string = 'immersive'    // immersive | discover
  @Local inDetail: boolean = false     // 是否在详情页
  @Local detailIdx: number = 0
  @Local translateX: number = 0
  @Local cardOpacity: number = 1
  @Local currentGradient: CardGradient = this.vm.getCardGradient(0)
  private startX: number = 0

  updateGradient(idx: number): void { this.currentGradient = this.vm.getCardGradient(idx) }
  handleSwipe(idx: number, dir: number): number {
    let newIdx = idx
    if (dir < 0) { newIdx = (idx + 1) % this.vm.cards.length }
    else if (dir > 0) { newIdx = (idx - 1 + this.vm.cards.length) % this.vm.cards.length }
    this.updateGradient(newIdx)
    this.vm.markAsRead(this.vm.cards[newIdx].id)
    return newIdx
  }

  // 从瀑布流进入详情
  enterDetail(idx: number): void {
    this.detailIdx = idx
    this.inDetail = true
    this.updateGradient(idx)
    this.vm.markAsRead(this.vm.cards[idx].id)
    this.translateX = 0; this.cardOpacity = 1
  }

  exitDetail(): void { this.inDetail = false }

  // 拖动比例 0..1
  ratio(): number {
    return Math.min(Math.abs(this.translateX) / 120, 1)
  }
  ghostOpacity(): number { return 0.2 + this.ratio() * 0.55 }
  ghostScale(): number { return 0.75 + this.ratio() * 0.23 }
  ghostOffsetY(): number { return 24 - this.ratio() * 18 }

  build() {
    Stack() {
      Column() {
        // ── 沉浸 / 发现 切换 ──
        Row() {
          Column() {
            Text('沉浸').fontSize(15).fontWeight(700)
              .fontColor(this.mode === 'immersive' ? '#1F2937' : '#9CA3AF')
            if (this.mode === 'immersive') {
              Row().width(20).height(3).borderRadius(2).backgroundColor('#1F2937').margin({ top: 4 })
            }
          }.onClick(() => { this.mode = 'immersive' })
          Blank().width(32)
          Column() {
            Text('发现').fontSize(15).fontWeight(500)
              .fontColor(this.mode === 'discover' ? '#1F2937' : '#9CA3AF')
            if (this.mode === 'discover') {
              Row().width(20).height(3).borderRadius(2).backgroundColor('#1F2937').margin({ top: 4 })
            }
          }.onClick(() => { this.mode = 'discover' })
        }
        .width('100%').justifyContent(FlexAlign.Center).padding({ top: 8, bottom: 8 })

        if (this.mode === 'immersive') { this.buildImmersive() }
        else { this.buildDiscover() }
      }
      .width('100%').height('100%')

      // ── 详情页覆盖层（从瀑布进入）──
      if (this.inDetail) { this.buildDetail() }

      // ── Toast 浮层 ──
      if (this.vm.toastMsg.length > 0) {
        Row() {
          Path().width(18).height(18).commands('M20 6L9 17 4 12')
            .fill('none').stroke('#A7F3D0').strokeWidth(4)
            .strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
            .margin({ right: 6 })
          Text(this.vm.toastMsg).fontSize(14).fontColor('#FFFFFF')
        }
        .padding({ left: 18, right: 18, top: 10, bottom: 10 })
        .backgroundColor('rgba(31,41,55,0.88)').borderRadius(20).backdropBlur(10)
        .position({ x: '50%', y: '88%' }).translate({ x: '-50%', y: 0 })
      }
    }
    .width('100%').height('100%')
  }

  // ── 沉浸模式 ──
  @Builder buildImmersive() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.vm.cards.length > 0 && this.vm.cardIndex < this.vm.cards.length) {
        this.cardSwipeArea(this.vm.cardIndex)
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
    this.buildPager()
    this.buildFloatNav()
  }

  // ── 发现模式（单列层叠）──
  @Builder buildDiscover() {
    Scroll() {
      Stack({ alignContent: Alignment.TopStart }) {
        ForEach(this.vm.cards, (card: KnowledgeItem, idx: number) => {
          Row() {
            this.GridCard(card, this.vm.getCardGradient(idx))
          }
          .width('90%')
          .position({ x: '5%', y: idx * 120 })
          .zIndex(idx + 1)
          .onClick(() => { this.enterDetail(idx) })
        })
      }
      .width('100%')
      .height(this.vm.cards.length * 120 + 80)
    }
    .width('100%').layoutWeight(1).align(Alignment.Top)
  }

  // ── 详情页覆盖层 ──
  @Builder buildDetail() {
    Column() {
      // ← 返回按钮
      Row() {
        Button() {
          Row() {
            Path().width(18).height(18).commands('M15 18l-6-6 6-6')
              .fill('none').stroke('#1F2937').strokeWidth(2)
              .strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
            Text('返回').fontSize(15).fontWeight(500).fontColor('#1F2937').margin({ left: 4 })
          }
        }
        .backgroundColor(Color.Transparent).onClick(() => { this.exitDetail() })
        Blank()
        Text(`${this.detailIdx + 1} / ${this.vm.cards.length}`)
          .fontSize(12).fontColor('#9CA3AF')
      }
      .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 4 })

      // 卡片可滑动
      Stack({ alignContent: Alignment.Center }) {
        this.cardSwipeArea(this.detailIdx)
      }
      .width('100%').layoutWeight(1)

      this.buildFloatNavForDetail()
    }
    .width('100%').height('100%').backgroundColor('#f5f4f0')
  }

  // ── 卡片滑动区域（复用）──
  @Builder cardSwipeArea(idx: number) {
    // 虚影：渐变背景+文字在同一容器内，统一缩放
    Column() {
      // 渐变底+文字内容
      Stack() {
        Column()
          .width('100%').height('100%').borderRadius(24)
          .linearGradient({ angle: 165, colors: [[this.vm.getCardGradient((idx + 1) % this.vm.cards.length).gradientStart, 0.0], [this.vm.getCardGradient((idx + 1) % this.vm.cards.length).gradientEnd, 0.5], [this.vm.getCardGradient((idx + 1) % this.vm.cards.length).gradientStart + '88', 1.0]] })

        Column() {
          Text(`# ${this.vm.cards[(idx + 1) % this.vm.cards.length].category || ''}`)
            .fontSize(10).fontWeight(500)
            .fontColor(this.vm.getCardGradient((idx + 1) % this.vm.cards.length).accentColor)
            .maxLines(1).opacity(this.ratio() * 0.9)
          Row().height(4).width('100%')
          Text(this.vm.cards[(idx + 1) % this.vm.cards.length].title)
            .fontSize(16).fontWeight(500).fontColor('#1F2937')
            .lineHeight(22).maxLines(2)
            .opacity(this.ratio() * 0.75)
          Row().height(6).width('100%')
          Text(this.vm.cards[(idx + 1) % this.vm.cards.length].content)
            .fontSize(11).fontWeight(300).fontColor('#6B7280')
            .lineHeight(17).maxLines(2)
            .opacity(this.ratio() * 0.55)
        }
        .width('100%').height('100%').padding({ left: 20, right: 20, top: 20, bottom: 20 })
      }
      .width('100%').height('100%')
    }
    .width('82%').height('76%').borderRadius(28)
    .opacity(this.ghostOpacity())
    .scale({ x: this.ghostScale(), y: this.ghostScale() })
    .offset({ x: 0, y: this.ghostOffsetY() })

    KnowledgeCard({
      card: this.vm.cards[this.mode === 'immersive' ? this.vm.cardIndex : this.detailIdx],
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
              setTimeout(() => {
                if (this.mode === 'immersive') {
                  this.vm.cardIndex = this.handleSwipe(this.vm.cardIndex, dir)
                } else {
                  this.detailIdx = this.handleSwipe(this.detailIdx, dir)
                }
                this.translateX = 0; this.cardOpacity = 1
              }, 300)
            } else {
              this.getUIContext().animateTo({ duration: 250, curve: Curve.EaseOut }, () => { this.translateX = 0 })
            }
          })
      )
  }

  // ── 页码器 ──
  @Builder buildPager() {
    if (this.vm.cards.length > 1) {
      Row() {
        ForEach(this.vm.getDotIndices(), (i: number) => {
          if (i === this.vm.cardIndex % 10) {
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
  }

  // ── 浮动导航（沉浸模式）──
  @Builder buildFloatNav() {
    Row() {
      Button() { Image($r('app.media.chevronleft')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.vm.cardIndex > 0).opacity(this.vm.cardIndex > 0 ? 1 : 0.25)
        .onClick(() => { if (this.vm.cardIndex > 0) { this.vm.cardIndex--; this.updateGradient(this.vm.cardIndex); this.vm.markAsRead(this.vm.cards[this.vm.cardIndex].id) } })

      Button() { Image($r('app.media.shuffle')).width(24).height(24) }
        .width(60).height(60).borderRadius(30)
        .shadow({ radius: 20, color: 'rgba(155,114,176,0.2)', offsetY: 8 })
        .linearGradient({ angle: 135, colors: [['rgba(201,168,216,1)', 0.0], ['rgba(155,114,176,1)', 1.0]] })
        .margin({ left: 20, right: 20 })

      Button() { Image($r('app.media.chevronright2')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.vm.cardIndex < this.vm.cards.length - 1)
        .opacity(this.vm.cardIndex < this.vm.cards.length - 1 ? 1 : 0.25)
        .onClick(() => { if (this.vm.cardIndex < this.vm.cards.length - 1) { this.vm.cardIndex++; this.updateGradient(this.vm.cardIndex); this.vm.markAsRead(this.vm.cards[this.vm.cardIndex].id) } })
    }
    .width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 8, top: 2 })
  }

  // ── 浮动导航（详情模式）──
  @Builder buildFloatNavForDetail() {
    Row() {
      Button() { Image($r('app.media.chevronleft')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.detailIdx > 0).opacity(this.detailIdx > 0 ? 1 : 0.25)
        .onClick(() => { if (this.detailIdx > 0) { this.detailIdx--; this.updateGradient(this.detailIdx); this.vm.markAsRead(this.vm.cards[this.detailIdx].id) } })

      Button() { Image($r('app.media.shuffle')).width(24).height(24) }
        .width(60).height(60).borderRadius(30)
        .shadow({ radius: 20, color: 'rgba(155,114,176,0.2)', offsetY: 8 })
        .linearGradient({ angle: 135, colors: [['rgba(201,168,216,1)', 0.0], ['rgba(155,114,176,1)', 1.0]] })
        .margin({ left: 20, right: 20 })

      Button() { Image($r('app.media.chevronright2')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.detailIdx < this.vm.cards.length - 1)
        .opacity(this.detailIdx < this.vm.cards.length - 1 ? 1 : 0.25)
        .onClick(() => { if (this.detailIdx < this.vm.cards.length - 1) { this.detailIdx++; this.updateGradient(this.detailIdx); this.vm.markAsRead(this.vm.cards[this.detailIdx].id) } })
    }
    .width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 8, top: 2 })
  }

  // ── 网格卡片 ──
  @Builder GridCard(card: KnowledgeItem, grad: CardGradient) {
    Column() {
      Text(card.category || '冷知识')
        .fontSize(11).fontWeight(600).fontColor('#FFFFFF')
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .borderRadius(12).backgroundColor(grad.accentColor)
      Row().height(10).width('100%')
      Text(card.title)
        .fontSize(16).fontWeight(700).fontColor(grad.titleColor)
        .lineHeight(23).maxLines(2).width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis }).flexShrink(1)
      Blank()
      Row() {
        Text('2.4k').fontSize(11).fontWeight(500).fontColor(grad.accentColor)
        Image($r('app.media.heart5')).width(14).height(14).margin({ left: 4 })
      }.width('100%').justifyContent(FlexAlign.End)
    }
    .width('100%').height(160)
    .padding({ left: 20, right: 20, top: 20, bottom: 16 })
    .borderRadius(20)
    .linearGradient({ angle: 112, colors: [[grad.gradientStart, 0.0], [grad.gradientEnd + 'CC', 1.0]] })
    .border({ width: 1, color: grad.borderColor })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.06)', offsetY: 4 })
  }
}
