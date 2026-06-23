// OnTrack Widget — 4×4 收藏路线详情卡片
@Entry
@Component
struct OnTrackWidget4x4 {
  @LocalStorageProp('route1') route1: string = '暂无收藏'
  @LocalStorageProp('route1Time') route1Time: string = ''
  @LocalStorageProp('route1Trains') route1Trains: string = ''
  @LocalStorageProp('route2') route2: string = ''
  @LocalStorageProp('route2Time') route2Time: string = ''
  @LocalStorageProp('route2Trains') route2Trains: string = ''
  @LocalStorageProp('route3') route3: string = ''
  @LocalStorageProp('route3Time') route3Time: string = ''
  @LocalStorageProp('route3Trains') route3Trains: string = ''
  @LocalStorageProp('favCount') favCount: string = '0'
  @LocalStorageProp('isEmpty') isEmpty: string = 'true'

  build() {
    Stack() {
      Column() {
        Row() {
          Text('⭐ 收藏路线')
            .fontSize(16).fontWeight(700).fontColor('#FFFFFF')
          Text(`  (${this.favCount})`)
            .fontSize(12).fontColor('#FFFFFF').opacity(0.5)
        }.margin({ bottom: 14 })

        if (this.isEmpty === 'true') {
          Column() {
            Text('还没有收藏路线').fontSize(14).fontColor('#FFFFFF').opacity(0.5)
            Text('搜索并收藏路线后显示').fontSize(11).fontColor('#FFFFFF').opacity(0.3).margin({ top: 4 })
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          // 路线 1
          if (this.route1.length > 0) { this.buildRouteCard(this.route1, this.route1Time, this.route1Trains, 0) }
          if (this.route2.length > 0) { this.buildRouteCard(this.route2, this.route2Time, this.route2Trains, 1) }
          if (this.route3.length > 0) { this.buildRouteCard(this.route3, this.route3Time, this.route3Trains, 2) }
        }

        Blank()

        Text('点击打开 OnTrack').fontSize(10).fontColor('#FFFFFF').opacity(0.3)
          .width('100%').textAlign(TextAlign.Center)
      }
      .width('100%').height('100%').padding(16)
    }
    .width('100%').height('100%').borderRadius(20)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#E8781A', 0.0], ['#FF9800', 1.0]]
    })
    .onClick(() => {
      postCardAction(this, { action: 'router', abilityName: 'EntryAbility', params: { tab: '2' } })
    })
  }

  @Builder buildRouteCard(fromTo: string, time: string, trains: string, idx: number) {
    Column() {
      Row() {
        Text(fromTo)
          .fontSize(14).fontWeight(600).fontColor('#FFFFFF')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        if (time.length > 0) {
          Text(time)
            .fontSize(12).fontColor('#FFFFFF').opacity(0.8)
            .margin({ left: 8 })
        }
      }.width('100%')

      if (trains.length > 0) {
        Text(trains)
          .fontSize(11).fontColor('#FFFFFF').opacity(0.5)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }

      if (idx < 2) {
        Divider().height(0.5).color('rgba(255,255,255,0.15)').margin({ top: 10, bottom: 10 })
      }
    }.width('100%')
  }
}
