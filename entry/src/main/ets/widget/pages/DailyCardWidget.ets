@Entry
@Component
struct DailyCardWidget {
  @LocalStorageProp('title') title: string = '冷知识'
  @LocalStorageProp('cardId') cardId: string = ''

  build() {
    Stack() {
      Column() {
        Text('知域 · 每日冷知识')
          .fontSize(10).fontColor('#FFFFFF').opacity(0.55).margin({ bottom: 10 })

        Text(this.title)
          .fontSize(15).fontWeight(700).fontColor('#FFFFFF')
          .maxLines(4).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(22)

        Blank()

        Row() {
          Text('📖 点击查看完整内容')
            .fontSize(10).fontColor('#FFFFFF').opacity(0.5)
          Blank()
        }.width('100%')
      }
      .width('100%').height('100%').padding(16)
    }
    .width('100%').height('100%').borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#667eea', 0.0], ['#b8a0d8', 1.0]]
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
