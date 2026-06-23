// OnTrack Widget — 2×2 收藏路线卡片
@Entry
@Component
struct OnTrackWidget {
  @LocalStorageProp('route1') route1: string = '暂无收藏'
  @LocalStorageProp('route1Time') route1Time: string = ''
  @LocalStorageProp('route2') route2: string = ''
  @LocalStorageProp('route3') route3: string = ''
  @LocalStorageProp('favCount') favCount: string = '0'
  @LocalStorageProp('isEmpty') isEmpty: string = 'true'

  build() {
    Stack() {
      Column() {
        Row() {
          Text('⭐').fontSize(12)
          Text(` 收藏 (${this.favCount})`)
            .fontSize(10).fontColor('#FFFFFF').opacity(0.6)
        }.margin({ bottom: 8 })

        Text(this.route1)
          .fontSize(14).fontWeight(600).fontColor('#FFFFFF')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 2 })

        if (this.route1Time.length > 0) {
          Text(this.route1Time)
            .fontSize(11).fontColor('#FFFFFF').opacity(0.7)
            .margin({ bottom: 4 })
        }

        if (this.route2.length > 0) {
          Text(this.route2)
            .fontSize(12).fontColor('#FFFFFF').opacity(0.7)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 2 })
        }

        if (this.route3.length > 0) {
          Text(this.route3)
            .fontSize(12).fontColor('#FFFFFF').opacity(0.7)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        Blank()

        Row() {
          Text(this.isEmpty === 'true' ? '去查询路线' : '点击打开')
            .fontSize(10).fontColor('#FFFFFF').opacity(0.4)
          Blank()
        }.width('100%')
      }
      .width('100%').height('100%').padding(14)
    }
    .width('100%').height('100%').borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#E8781A', 0.0], ['#FF9800', 1.0]]
    })
    .onClick(() => {
      postCardAction(this, { action: 'router', abilityName: 'EntryAbility', params: { tab: '2' } })
    })
  }
}
