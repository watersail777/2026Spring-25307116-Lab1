import { AppViewModel } from '../../model/AppViewModel'
import { ItinerarySegment, RouteResult } from '../../model/DataModels'
import { RouteCard } from '../../components/RouteCard'

@ComponentV2
export struct ResultsTab {
  @Require @Param vm: AppViewModel
  @Local currentRoute: number = 0
  @Param isTablet: boolean = false
  private scroller: Scroller = new Scroller()
  // 每条路线 header 在 List 中的索引
  private headerIndices: number[] = []

  aboutToAppear(): void {
    this.currentRoute = this.vm.selectedResultIndex
    this.buildHeaderIndices()
  }

  private buildHeaderIndices(): void {
    this.headerIndices = []
    let idx = 0
    for (let r = 0; r < this.vm.searchResults.length; r++) {
      this.headerIndices.push(idx)
      idx += 1  // header
      idx += this.vm.searchResults[r].segments.length  // segment cards
      idx += 1  // divider
    }
  }

  private scrollToRoute(routeIdx: number): void {
    if (routeIdx < 0 || routeIdx >= this.headerIndices.length) return
    this.currentRoute = routeIdx
    this.scroller.scrollToIndex(this.headerIndices[routeIdx], true, ScrollAlign.START)
  }

  private goPrev(): void {
    if (this.currentRoute > 0) this.scrollToRoute(this.currentRoute - 1)
  }

  private goNext(): void {
    if (this.currentRoute < this.vm.searchResults.length - 1) this.scrollToRoute(this.currentRoute + 1)
  }

  private fmtDur(minutes: number): string {
    if (minutes < 60) return `${minutes}分钟`
    const h = Math.floor(minutes / 60)
    const m = minutes % 60
    return m > 0 ? `${h}h${m}m` : `${h}h`
  }

  build() {
    Column() {
      // 顶栏（平板模式隐藏返回按钮）
      Row() {
        if (!this.isTablet) {
          Button() {
            Text('← 返回').fontSize(14).fontColor('#1A73E8')
          }
          .height(36).padding({ left: 8, right: 8 })
          .backgroundColor('#E8F0FE').borderRadius(8)
          .onClick(() => { this.vm.switchTab(0) })
        }

        Blank()

        // 翻页按钮
        Row() {
          Button('◀ 上一个').fontSize(13).fontColor('#FFFFFF')
            .height(36).padding({ left: 12, right: 12 })
            .borderRadius(10).backgroundColor('#1A73E8')
            .enabled(this.currentRoute > 0)
            .opacity(this.currentRoute > 0 ? 1 : 0.35)
            .onClick(() => { this.goPrev() })

          Text(`${this.currentRoute + 1}/${this.vm.searchResults.length}`)
            .fontSize(15).fontWeight(700).fontColor('#1A1A2E')
            .margin({ left: 10, right: 10 })

          Button('下一个 ▶').fontSize(13).fontColor('#FFFFFF')
            .height(36).padding({ left: 12, right: 12 })
            .borderRadius(10).backgroundColor('#1A73E8')
            .enabled(this.currentRoute < this.vm.searchResults.length - 1)
            .opacity(this.currentRoute < this.vm.searchResults.length - 1 ? 1 : 0.35)
            .onClick(() => { this.goNext() })
        }
      }
      .width('100%').padding({ left: 12, right: 12, top: 8, bottom: 8 })

      // 全路线列表
      if (this.vm.searchResults.length > 0) {
        List({ scroller: this.scroller }) {
          ForEach(this.vm.searchResults, (route: RouteResult, routeIdx: number) => {
            // 路线 header
            ListItem() {
              Row() {
                Text(`方案 ${routeIdx + 1}`)
                  .fontSize(14).fontWeight(700).fontColor('#1A73E8')
                  .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                  .borderRadius(6).backgroundColor('#E8F0FE')

                // 直达/换乘标签
                Text(route.transferCount === 0 ? ' 直达' : ` 换乘${route.transferCount}次`)
                  .fontSize(11).fontWeight(600)
                  .fontColor(route.transferCount === 0 ? '#FFFFFF' : '#FF9800')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .backgroundColor(route.transferCount === 0 ? '#4CAF50' : '#FFF3E0')
                  .margin({ left: 6 })

                Blank()
                Text(this.fmtDur(route.totalTimeMinutes))
                  .fontSize(12).fontColor('#999999')
              }
              .width('100%').padding({ left: 4, right: 4, top: 4, bottom: 6 })
            }

            // 段卡片
            ForEach(route.segments, (seg: ItinerarySegment, segIdx: number) => {
              ListItem() {
                Column() {
                  RouteCard({
                    segment: seg,
                    onTap: () => { this.vm.openDetail(segIdx) }
                  })
                  if (segIdx < route.segments.length - 1) {
                    Row() {
                      Text('换乘')
                        .fontSize(10).fontWeight(600).fontColor('#FFFFFF')
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(8).backgroundColor('#FF9800')
                    }
                    .width('100%').justifyContent(FlexAlign.Center)
                    .padding({ top: 4, bottom: 4 })
                  }
                }
              }
            }, (_seg: ItinerarySegment, idx: number) => `${routeIdx}_seg_${idx}`)

            // 方案间分隔
            ListItem() {
              Divider().height(1).color('#E8E8E8').margin({ top: 8, bottom: 8 })
            }
          }, (_route: RouteResult, idx: number) => `route_${idx}`)
        }
        .width('100%').layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .onScrollIndex((first: number) => {
          // 根据第一个可见项判断当前在哪个方案
          for (let i = this.headerIndices.length - 1; i >= 0; i--) {
            if (first >= this.headerIndices[i]) {
              this.currentRoute = i
              break
            }
          }
        })
      } else {
        Column() {
          Text('未找到路线').fontSize(16).fontColor('#999999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      }
    }
    .width('100%').height('100%')
    .padding({ left: 12, right: 12, bottom: 12 })
  }
}