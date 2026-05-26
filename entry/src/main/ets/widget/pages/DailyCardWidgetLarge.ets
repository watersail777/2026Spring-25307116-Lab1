@Entry
@Component
struct DailyCardWidgetLarge {
  @LocalStorageProp('title') title: string = '冷知识'
  @LocalStorageProp('content') content: string = '点击查看详情...'
  @LocalStorageProp('category') category: string = ''
  @LocalStorageProp('cardId') cardId: string = ''

  build() {
    Stack() {
      Column() {
        Text('知域 · 每日冷知识')
          .fontSize(11).fontColor('#FFFFFF').opacity(0.5).margin({ bottom: 14 })

        Text(this.title)
          .fontSize(17).fontWeight(700).fontColor('#FFFFFF')
          .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(24)
          .margin({ bottom: 12 })

        Text(this.content)
          .fontSize(12).fontColor('#FFFFFF').opacity(0.9)
          .maxLines(8).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(19)

        Blank()

        Row() {
          if (this.category) {
            Text(`# ${this.category}`)
              .fontSize(10).fontColor('#FFFFFF').opacity(0.6)
              .padding({ left: 10, right: 10, top: 3, bottom: 3 })
              .backgroundColor('rgba(255,255,255,0.15)').borderRadius(8)
          }
          Blank()
          Text('📖 查看详情').fontSize(10).fontColor('#FFFFFF').opacity(0.5)
        }.width('100%')
      }
      .width('100%').height('100%').padding(18)
    }
    .width('100%').height('100%').borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#667eea', 0.0], ['#8b6fc0', 1.0]]
    })
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        uri: 'zhiyu://com.zhiyu.coldknowledge/card?id=' + this.cardId
      })
    })
  }
}
