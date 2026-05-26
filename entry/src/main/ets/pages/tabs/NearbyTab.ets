import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel } from '../../model/AppViewModel'

const TEXT = '#3c3c50'
const WHITE_GLASS = 'rgba(255,255,255,0.7)'

@ComponentV2
export struct NearbyTab {
  @Require @Param vm: AppViewModel

  aboutToAppear(): void {
    this.vm.loadNearby()
  }

  build() {
    Column() {
      Row() {
        Text('附近圈').fontSize(22).fontWeight(700).fontColor(TEXT)
        Blank()
        Text(`📍 ${this.vm.locationLabel}`).fontSize(10).fontColor('#999')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(WHITE_GLASS).borderRadius(10)
      }
      .width('100%').padding({ left: 20, right: 20, top: 14, bottom: 6 })

      Text('附近街坊分享的本地小知识：哪家餐馆好吃、哪里修路、附近趣事…')
        .fontSize(12).fontColor('#aaa').width('100%').padding({ left: 20, bottom: 8 })

      if (this.vm.nearbyLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#ccc')
          Text('查找附近...').fontSize(12).fontColor('#aaa').margin({ top: 10 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.vm.nearbyCards.length === 0) {
        Column() {
          Stack() {
            Circle({ width: 36, height: 36 }).fill('none').stroke('#ddd').strokeWidth(1.8)
            Circle({ width: 8, height: 8 }).fill('none').stroke('#ddd').strokeWidth(1.8).position({ x: 14, y: 10 })
            Line().width(0).height(8).stroke('#ddd').strokeWidth(1.4).position({ x: 18, y: 18 })
          }.width(36).height(36).margin({ bottom: 14 })
          Text('附近还没有人分享').fontSize(15).fontColor('#999')
          Text('去发现页转发到附近圈吧').fontSize(12).fontColor('#bbb').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.vm.nearbyCards, (item: KnowledgeItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.authorName || '匿名用户').fontSize(11).fontColor('#aaa')
                  Blank()
                }.width('100%').margin({ bottom: 6 })
                Text(item.title).fontSize(15).fontWeight(600).fontColor(TEXT).margin({ bottom: 4 })
                Text(item.content).fontSize(12).fontColor('#888')
                  .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%').padding(14).borderRadius(14)
              .backgroundColor(WHITE_GLASS).margin({ bottom: 8, left: 16, right: 16 })
            }
          })
        }.width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%')
  }
}
