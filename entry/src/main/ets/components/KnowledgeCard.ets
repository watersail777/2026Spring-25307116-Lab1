import { KnowledgeItem } from '../model/KnowledgeItem'

@Component
export struct KnowledgeCard {
  @Prop card: KnowledgeItem
  @Prop gradientStart: string = '#dcd0f0'
  @Prop gradientEnd: string = '#c8b8e4'

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 底层：满铺柔和渐变
      Column()
        .width('100%').height('100%').borderRadius(22)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [[this.gradientStart + '99', 0.0], [this.gradientEnd, 0.55], [this.gradientStart + '44', 1.0]]
        })

      // 图片区 — 顶部 38%
      if (this.card.imageUrl.length > 0) {
        Column() {
          Image(this.card.imageUrl)
            .width('100%').height('38%')
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 22, topRight: 22 })
          // 渐变过渡带
          Column()
            .width('100%').height(44)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['rgba(255,255,255,0)', 0.0], ['rgba(255,255,255,0.42)', 1.0]]
            })
        }
        .width('100%').height('100%')
      }

      // 毛玻璃文字层
      Column() {
        if (this.card.imageUrl.length > 0) {
          Blank().height('36%')
        }

        Text(this.card.title)
          .fontSize(20).fontWeight(700)
          .fontColor('#2a2a38').lineHeight(28)
          .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 12 })

        Text(this.card.content)
          .fontSize(14).fontWeight(400)
          .fontColor('#585868').lineHeight(23)
          .maxLines(this.card.imageUrl.length > 0 ? 8 : 10)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank()

        if (this.card.category) {
          Row() {
            Text(`# ${this.card.category}`)
              .fontSize(11).fontColor('#909098')
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor('rgba(0,0,0,0.03)').borderRadius(10)
          }
        }
      }
      .width('100%').height('100%')
      .padding({ left: 22, right: 22, top: 22, bottom: 22 })
      .borderRadius(22)
      .backgroundColor('rgba(255,255,255,0.45)')
      .backdropBlur(22)
    }
    .width('100%').height('100%')
    .borderRadius(22)
    .shadow({ radius: 28, color: this.gradientStart + '28', offsetY: 8 })
  }
}
