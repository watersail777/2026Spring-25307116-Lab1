import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel, CardGradient } from '../../model/AppViewModel'

// ── 发现页 — 1:1 复刻 arkui-2 Frame_2_1206 ──

@ComponentV2
export struct DiscoverTab {
  @Require @Param vm: AppViewModel

  build() {
    Column() {
      // ── 标题行：发现 + 搜索 ──
      Row() {
        Text('发现').fontSize(24).fontWeight(700).fontColor('#1F2937')
        Blank()
        Image($r('app.media.search')).width(22).height(22)
      }
      .width('100%').padding({ left: 16, right: 16, bottom: 12, top: 8 })

      // ── 分类胶囊横向滚动 ──
      Row() {
        Text('全部').fontSize(13).fontWeight(600).fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .borderRadius(20).backgroundColor('#2D1B3D')

        Text('天文').fontSize(13).fontWeight(500).fontColor('#6B7280')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .borderRadius(20).border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('rgba(255,255,255,0.63)')
          .margin({ left: 8 })

        Text('生物').fontSize(13).fontWeight(500).fontColor('#6B7280')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .borderRadius(20).border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('rgba(255,255,255,0.63)')
          .margin({ left: 8 })

        Text('历史').fontSize(13).fontWeight(500).fontColor('#6B7280')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .borderRadius(20).border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('rgba(255,255,255,0.63)')
          .margin({ left: 8 })

        Text('化学').fontSize(13).fontWeight(500).fontColor('#6B7280')
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .borderRadius(20).border({ width: 1, color: '#E5E7EB' })
          .backgroundColor('rgba(255,255,255,0.63)')
          .margin({ left: 8 })
      }
      .width('100%').padding({ left: 16, right: 16, bottom: 12 })

      // ── 双列瀑布流 ──
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.vm.cards, (card: KnowledgeItem, idx: number) => {
            Column() {
              this.GridCard(card, this.vm.getCardGradient(idx))
            }
            .width('48%')
            .margin({ left: idx % 2 === 0 ? 0 : '2%', right: idx % 2 === 0 ? '2%' : 0, bottom: 10 })
          })
        }
        .width('100%').padding({ left: 12, right: 12, top: 4, bottom: 4 })
      }
      .width('100%').layoutWeight(1)
    }
    .width('100%').height('100%')
  }

  @Builder
  GridCard(card: KnowledgeItem, grad: CardGradient) {
    Column() {
      // 分类药丸
      Text(card.category || '冷知识')
        .fontSize(10).fontWeight(600).fontColor('#FFFFFF')
        .padding({ left: 10, right: 10, top: 3, bottom: 3 })
        .borderRadius(12).backgroundColor(grad.accentColor)

      Row().height(8).width('100%')

      // 标题
      Text(card.title)
        .fontSize(14).fontWeight(700).fontColor(grad.titleColor)
        .lineHeight(21).maxLines(3).width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .flexShrink(1)

      Row().height(8).width('100%')

      // 底部：点赞数 + heart 图标
      Row() {
        Text('2.4k').fontSize(11).fontWeight(500).fontColor(grad.accentColor)
        Image($r('app.media.heart5')).width(14).height(14).margin({ left: 4 })
      }
      .width('100%').justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 16, bottom: 14 })
    .borderRadius(20)
    .linearGradient({
      angle: 150,
      colors: [[grad.gradientStart, 0.0], [grad.gradientEnd, 1.0]]
    })
    .border({ width: 1, color: grad.borderColor })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.06)', offsetY: 4 })
  }
}
