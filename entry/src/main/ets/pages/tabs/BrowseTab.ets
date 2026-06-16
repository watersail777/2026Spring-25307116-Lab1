import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel, CardGradient } from '../../model/AppViewModel'
import { KnowledgeCard } from '../../components/KnowledgeCard'
import { DotIndicator } from '../../components/DotIndicator'

@ComponentV2
export struct BrowseTab {
  @Require @Param vm: AppViewModel
  @Param isTablet: boolean = false

  @Local mode: string = 'immersive'    // immersive | discover
  @Local inDetail: boolean = false
  @Local detailIdx: number = 0
  @Local currentGradient: CardGradient = this.vm.getCardGradient(0)

  enterDetail(idx: number): void {
    this.detailIdx = idx
    this.inDetail = true
    this.vm.markAsRead(this.vm.cards[idx].id)
  }

  exitDetail(): void { this.inDetail = false }

  build() {
    Stack() {
      Column() {
        // ── 沉浸 / 发现 切换 ──
        Row() {
          Column() {
            Text('沉浸').fontSize(15).fontWeight(700)
              .fontColor(this.mode === 'immersive' ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
            if (this.mode === 'immersive') {
              Row().width(20).height(3).borderRadius(2).backgroundColor($r('app.color.text_primary')).margin({ top: 4 })
            }
          }.onClick(() => { this.mode = 'immersive' })
          Blank().width(32)
          Column() {
            Text('发现').fontSize(15).fontWeight(500)
              .fontColor(this.mode === 'discover' ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
            if (this.mode === 'discover') {
              Row().width(20).height(3).borderRadius(2).backgroundColor($r('app.color.text_primary')).margin({ top: 4 })
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
    Scroll() {
      Column() {
        // 顶部留白
        Row().height(12).width('100%')

        if (this.vm.cards.length > 0 && this.vm.cardIndex < this.vm.cards.length) {
          KnowledgeCard({
            card: this.vm.cards[this.vm.cardIndex],
            gradient: this.currentGradient,
            showActions: true,
            onFavorite: () => { this.vm.handleFavorite() },
            onLike: () => { this.vm.handleLike() },
            onShare: () => { this.vm.shareToSystem() }
          })
            .width('88%')
        } else {
          Column() {
            Text('暂无卡片').fontSize(15).fontColor($r('app.color.text_tertiary'))
            Text('左右滑动发现更多').fontSize(12).fontColor($r('app.color.text_tertiary')).margin({ top: 4 })
          }
          .width('88%').height(200).justifyContent(FlexAlign.Center).borderRadius(28)
          .backgroundColor('rgba(255,255,255,0.4)')
        }

        // 轮播导航点
        DotIndicator({
          totalCount: this.vm.cards.length,
          currentIndex: this.vm.cardIndex,
          activeColor: this.currentGradient.accentColor,
          inactiveColor: this.currentGradient.borderColor,
          onDotClick: (idx: number) => {
            this.vm.cardIndex = idx
            this.currentGradient = this.vm.getCardGradient(idx)
            this.vm.markAsRead(this.vm.cards[idx].id)
            this.vm.tryGenerate()
          }
        })

        // 底部留出导航空间
        Row().height(48).width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%').layoutWeight(1).scrollBar(BarState.Off)
    .align(Alignment.Top)

    this.buildFloatNav()
  }

  // ── 发现模式（手机层叠 / 平板多列网格）──
  @Builder buildDiscover() {
    if (this.isTablet) {
      // 平板：2-3 列网格
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.vm.cards, (card: KnowledgeItem, idx: number) => {
            Column() {
              this.GridCard(card, this.vm.getCardGradient(idx))
            }
            .width('31%')
            .margin({ left: '1.1%', right: '1.1%', bottom: 14 })
            .onClick(() => { this.enterDetail(idx) })
          })
        }
        .width('100%').padding({ left: 12, right: 12, top: 8 })
      }
      .width('100%').layoutWeight(1).align(Alignment.Top)
    } else {
      // 手机：单列层叠
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
  }

  // ── 详情页覆盖层 ──
  @Builder buildDetail() {
    Column() {
      Row() {
        Button() {
          Row() {
            Path().width(18).height(18).commands('M15 18l-6-6 6-6')
              .fill('none').stroke($r('app.color.text_primary')).strokeWidth(2)
              .strokeLineCap(LineCapStyle.Round).strokeLineJoin(LineJoinStyle.Round)
            Text('返回').fontSize(15).fontWeight(500).fontColor($r('app.color.text_primary')).margin({ left: 4 })
          }
        }
        .backgroundColor(Color.Transparent).onClick(() => { this.exitDetail() })
        Blank()
        Text(`${this.detailIdx + 1} / ${this.vm.cards.length}`)
          .fontSize(12).fontColor($r('app.color.text_tertiary'))
      }
      .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 4 })

      Scroll() {
        Column() {
          Row().height(12).width('100%')
          KnowledgeCard({
            card: this.vm.cards[this.detailIdx],
            gradient: this.currentGradient,
            showActions: true,
            onFavorite: () => { this.vm.handleFavorite() },
            onLike: () => { this.vm.handleLike() },
            onShare: () => { this.vm.shareToSystem() }
          })
            .width('88%')

          DotIndicator({
            totalCount: this.vm.cards.length,
            currentIndex: this.detailIdx,
            activeColor: this.currentGradient.accentColor,
            inactiveColor: this.currentGradient.borderColor,
            onDotClick: (idx: number) => {
              this.detailIdx = idx
              this.currentGradient = this.vm.getCardGradient(idx)
              this.vm.markAsRead(this.vm.cards[idx].id)
            }
          })
          Row().height(80).width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%').layoutWeight(1).scrollBar(BarState.Off)
      .align(Alignment.Top)

      this.buildFloatNavForDetail()
    }
    .width('100%').height('100%').backgroundColor($r('app.color.page_bg'))
  }

  // ── 浮动导航（沉浸模式）──
  @Builder buildFloatNav() {
    Row() {
      Button() { Image($r('app.media.chevronleft')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.vm.cardIndex > 0).opacity(this.vm.cardIndex > 0 ? 1 : 0.25)
        .onClick(() => { if (this.vm.cardIndex > 0) { this.vm.cardIndex--; this.currentGradient = this.vm.getCardGradient(this.vm.cardIndex); this.vm.markAsRead(this.vm.cards[this.vm.cardIndex].id); this.vm.tryGenerate() } })

      // 中间计数
      Text(`${this.vm.cardIndex + 1} / ${this.vm.cards.length}`)
        .fontSize(14).fontWeight(500).fontColor($r('app.color.text_tertiary'))
        .margin({ left: 24, right: 24 })

      Button() { Image($r('app.media.chevronright2')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.vm.cardIndex < this.vm.cards.length - 1)
        .opacity(this.vm.cardIndex < this.vm.cards.length - 1 ? 1 : 0.25)
        .onClick(() => { if (this.vm.cardIndex < this.vm.cards.length - 1) { this.vm.cardIndex++; this.currentGradient = this.vm.getCardGradient(this.vm.cardIndex); this.vm.markAsRead(this.vm.cards[this.vm.cardIndex].id); this.vm.tryGenerate() } })
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
        .onClick(() => { if (this.detailIdx > 0) { this.detailIdx--; this.currentGradient = this.vm.getCardGradient(this.detailIdx); this.vm.markAsRead(this.vm.cards[this.detailIdx].id) } })

      Text(`${this.detailIdx + 1} / ${this.vm.cards.length}`)
        .fontSize(14).fontWeight(500).fontColor($r('app.color.text_tertiary'))
        .margin({ left: 24, right: 24 })

      Button() { Image($r('app.media.chevronright2')).width(20).height(20) }
        .width(48).height(48).borderRadius(24).backgroundColor('rgba(255,255,255,0.8)').backdropBlur(12)
        .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
        .enabled(this.detailIdx < this.vm.cards.length - 1)
        .opacity(this.detailIdx < this.vm.cards.length - 1 ? 1 : 0.25)
        .onClick(() => { if (this.detailIdx < this.vm.cards.length - 1) { this.detailIdx++; this.currentGradient = this.vm.getCardGradient(this.detailIdx); this.vm.markAsRead(this.vm.cards[this.detailIdx].id) } })
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
