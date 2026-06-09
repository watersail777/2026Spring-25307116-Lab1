import { AppViewModel } from '../model/AppViewModel'
import { ItinerarySegment } from '../model/DataModels'
import { RouteCard } from './RouteCard'

@ComponentV2
export struct RouteCardList {
  @Require @Param vm: AppViewModel
  @Param routeIndex: number = 0
  @Local segments: ItinerarySegment[] = []
  @Local totalRoutes: number = 0
  @Local transferCount: number = 0

  @Monitor('routeIndex')
  onRouteChange(): void {
    this.segments = this.vm.searchResults[this.routeIndex].segments
    this.totalRoutes = this.vm.searchResults.length
    this.transferCount = this.vm.searchResults[this.routeIndex].transferCount
  }

  aboutToAppear(): void {
    this.onRouteChange()
  }

  build() {
    List() {
      ListItem() {
        Row() {
          Text(`${this.totalRoutes} 条路线`)
            .fontSize(14).fontWeight(600).fontColor('#555555')
          Blank()
          Text(`换乘 ${this.transferCount} 次`)
            .fontSize(12).fontColor('#999999')
        }
        .width('100%').padding({ left: 4, right: 4, top: 8, bottom: 8 })
      }

      ForEach(this.segments,
        (seg: ItinerarySegment, idx: number) => {
          ListItem() {
            Column() {
              RouteCard({
                segment: seg,
                onTap: () => { this.vm.openDetail(idx) }
              })
              if (idx < this.segments.length - 1) {
                Row() {
                  Text('换乘')
                    .fontSize(10).fontWeight(600).fontColor('#FFFFFF')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(8)
                    .backgroundColor('#FF9800')
                }
                .width('100%').justifyContent(FlexAlign.Center)
                .padding({ top: 4, bottom: 4 })
              }
            }
          }
        },
        (_seg: ItinerarySegment, idx: number) => idx.toString()
      )
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }
}