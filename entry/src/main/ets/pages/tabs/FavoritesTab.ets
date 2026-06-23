import { AppViewModel } from '../../model/AppViewModel'
import { RouteResult, ItinerarySegment } from '../../model/DataModels'

@ComponentV2
export struct FavoritesTab {
  @Require @Param vm: AppViewModel
  @Param isTablet: boolean = false

  private fmtDur(minutes: number): string {
    if (minutes <= 0) return '0分钟'
    if (minutes < 60) return `${minutes}分钟`
    if (minutes < 1440) {
      const h = Math.floor(minutes / 60)
      const m = minutes % 60
      return m > 0 ? `${h}h${m}m` : `${h}h`
    }
    const d = Math.floor(minutes / 1440)
    const remain = minutes % 1440
    const h = Math.floor(remain / 60)
    const m = remain % 60
    if (h === 0 && m === 0) return `${d}d`
    if (m === 0) return `${d}d${h}h`
    return `${d}d${h}h${m}m`
  }

  build() {
    Column() {
      Text('收藏路线')
        .fontSize(20).fontWeight(700).fontColor('#1A1A2E')
        .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.vm.favorites.length === 0) {
        Column() {
          Text('暂无收藏路线')
            .fontSize(15).fontColor('#999999')
          Text('在搜索结果中点击收藏按钮添加')
            .fontSize(12).fontColor('#BBBBBB').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.vm.favorites, (route: RouteResult, idx: number) => {
            ListItem() {
              Column() {
                // 路线摘要
                Row() {
                  Column() {
                    Text(`${route.segments[0]?.fromStation ?? ''} → ${route.segments[route.segments.length - 1]?.toStation ?? ''}`)
                      .fontSize(16).fontWeight(600).fontColor('#1A1A2E')
                    Row() {
                      Text(this.fmtDur(route.totalTimeMinutes))
                        .fontSize(12).fontColor('#888888')
                      if (route.transferCount > 0) {
                        Text(` · 换乘${route.transferCount}次`)
                          .fontSize(12).fontColor('#FF9800')
                      } else {
                        Text(' · 直达')
                          .fontSize(12).fontColor('#4CAF50')
                      }
                    }.margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                  // 删除按钮
                  Button() {
                    Text('✕').fontSize(14).fontColor('#EF4444')
                  }
                  .width(32).height(32).borderRadius(16).backgroundColor('#FEF2F2')
                  .onClick(() => { this.vm.removeFavorite(idx) })

                  // 查询按钮
                  Button() {
                    Text('查询').fontSize(12).fontColor('#1A73E8')
                  }
                  .height(32).padding({ left: 12, right: 12 }).borderRadius(8)
                  .backgroundColor('#E8F0FE').margin({ left: 8 })
                  .onClick(() => { this.vm.reSearchFromFavorite(route) })
                }.width('100%')

                // 车次预览
                Row() {
                  ForEach(route.segments.slice(0, 3), (seg: ItinerarySegment, si: number) => {
                    Text(si > 0 ? ` → ${seg.trainId}` : seg.trainId)
                      .fontSize(11).fontColor('#999999')
                  })
                  if (route.segments.length > 3) {
                    Text(' ...').fontSize(11).fontColor('#BBBBBB')
                  }
                }.width('100%').margin({ top: 8 })
              }
              .width('100%').padding(16).borderRadius(12)
              .backgroundColor('#FFFFFF')
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
              .margin({ left: 12, right: 12, top: 4, bottom: 4 })
              .onClick(() => { this.vm.reSearchFromFavorite(route) })
            }
          }, (_route: RouteResult, idx: number) => `fav_${idx}`)
        }
        .width('100%').layoutWeight(1).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
