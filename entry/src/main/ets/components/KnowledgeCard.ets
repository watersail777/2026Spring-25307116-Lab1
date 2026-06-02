import { KnowledgeItem } from '../model/KnowledgeItem'
import { CardGradient } from '../model/AppViewModel'
import { AnimatedHeart } from './AnimatedHeart'
import { AnimatedBookmark } from './AnimatedBookmark'

// ═══════════════════════════════════════
// 知识卡片 — 1:1 复刻 arkui-2 Frame_2_1116
// ═══════════════════════════════════════

@ComponentV2
export struct KnowledgeCard {
  @Require @Param card: KnowledgeItem
  @Require @Param gradient: CardGradient
  @Param showActions: boolean = true
  @Event onFavorite?: () => void
  @Event onLike?: () => void
  @Event onShare?: () => void

  private formatCount(n: number): string {
    if (n >= 1000) {
      const k = n / 1000
      return k >= 10 ? Math.floor(k).toString() + 'k' : k.toFixed(1) + 'k'
    }
    return n.toString()
  }

  build() {
    Stack() {
      // ── 卡片主体 ──
      Column() {
        // ① 顶行：分类药丸 + 收藏按钮
        Row() {
          // 分类药丸：白色文字 + 彩色背景
          Text(this.card.category || '冷知识')
            .fontSize(11).fontWeight(600).fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .borderRadius(20)
            .backgroundColor(this.gradient.accentColor)

          Blank()

          // 收藏图标
          AnimatedBookmark({
            isFavorited: this.card.isFavorited,
            accentColor: this.gradient.accentColor,
            iconSize: 22,
            onToggle: () => { this.onFavorite?.() }
          })
        }
        .width('100%')

        Row().height(16).width('100%')

        // ② 标题 — 22px Bold
        Text(this.card.title)
          .fontSize(22).fontWeight(700).fontColor(this.gradient.titleColor)
          .lineHeight(31).maxLines(2).width('100%')
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row().height(12).width('100%')

        // ③ 分割线 — 1px
        Row().width('100%').height(1).borderRadius(1)
          .backgroundColor(`rgba(${this.gradient.borderRgb},0.5)`)

        Row().height(16).width('100%')

        // ④ 正文 — 15px
        Text(this.card.content)
          .fontSize(15).fontWeight(400).fontColor(this.gradient.bodyColor)
          .lineHeight(25.5).maxLines(8).width('100%').layoutWeight(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // ⑤ 操作行：点赞 + 分享（内联图文，无圆钮）
        if (this.showActions) {
          Row() {
            // 点赞
            Row() {
              AnimatedHeart({
                isLiked: this.card.isLiked,
                accentColor: this.gradient.accentColor,
                iconSize: 22,
                onToggle: () => { this.onLike?.() }
              })
              Text(this.card.likeCount > 0 ? this.formatCount(this.card.likeCount) : '点赞')
                .fontSize(13).fontWeight(500).fontColor(this.gradient.accentColor)
                .margin({ left: 6 })
            }

            Blank()

            // 分享
            Row() {
              Image($r('app.media.share2'))
                .width(18).height(18)
              Text('分享')
                .fontSize(13).fontWeight(500).fontColor(this.gradient.accentColor)
                .margin({ left: 6 })
            }.onClick(() => { this.onShare?.() })
          }
          .width('100%')
        }
      }
      .width('100%').height('100%')
      .padding({ left: 24, right: 24, top: 28, bottom: 24 })
      .borderRadius(28)
      .linearGradient({
        angle: 165,
        colors: [[this.gradient.gradientStart, 0.0], [this.gradient.gradientEnd, 0.5], [this.gradient.gradientStart + '88', 1.0]]
      })
      .border({ width: 1, color: this.gradient.borderColor })
      .shadow({ radius: 32, color: 'rgba(0,0,0,0.13)', offsetY: 14 })
    }
    .width('100%').height('100%')
  }
}
