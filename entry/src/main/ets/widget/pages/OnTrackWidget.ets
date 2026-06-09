// OnTrack Widget — 2×2 最近查询卡片
@Entry
@Component
struct OnTrackWidget {
  @LocalStorageProp('query1') query1: string = '暂无查询'
  @LocalStorageProp('query2') query2: string = ''
  @LocalStorageProp('query3') query3: string = ''

  build() {
    Stack() {
      Column() {
        Text('OnTrack')
          .fontSize(10).fontColor('#FFFFFF').opacity(0.6).margin({ bottom: 8 })

        Text(this.query1)
          .fontSize(14).fontWeight(600).fontColor('#FFFFFF')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })

        if (this.query2.length > 0) {
          Text(this.query2)
            .fontSize(12).fontColor('#FFFFFF').opacity(0.7)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 2 })
        }

        if (this.query3.length > 0) {
          Text(this.query3)
            .fontSize(12).fontColor('#FFFFFF').opacity(0.7)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        Blank()

        Row() {
          Text('点击查询').fontSize(10).fontColor('#FFFFFF').opacity(0.4)
          Blank()
        }.width('100%')
      }
      .width('100%').height('100%').padding(14)
    }
    .width('100%').height('100%').borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#1A5CC8', 0.0], ['#1A73E8', 1.0]]
    })
    .onClick(() => {
      postCardAction(this, { action: 'router', abilityName: 'EntryAbility' })
    })
  }
}