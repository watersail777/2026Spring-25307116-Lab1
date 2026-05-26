import { KnowledgeItem } from '../model/KnowledgeItem'
import { LocalStore } from '../data/LocalStore'
import { LocationHelper } from '../utils/LocationHelper'

@Entry
@Component
struct NearbyPage {
  @State nearbyCards: KnowledgeItem[] = []
  @State locationLabel: string = '定位中...'
  @State isLoading: boolean = true

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    this.locationLabel = await LocationHelper.getLocationLabel()
    this.nearbyCards = await LocalStore.getNearbyCards()
    this.isLoading = false
  }

  build() {
    Column() {
      Row() {
        Text('附近圈').fontSize(22).fontWeight(700).fontColor('#FFFFFF')
        Blank()
        Text(`📍 ${this.locationLabel}`).fontSize(11).fontColor('#AAAAAA')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#FFFFFF10').borderRadius(10)
      }
      .width('100%').padding({ left: 24, right: 24, top: 16, bottom: 8 })

      Text('同区/县内其他用户公开分享的冷知识')
        .fontSize(13).fontColor('#777').width('100%').padding({ left: 24, bottom: 12 })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#666')
          Text('正在查找附近...').fontSize(13).fontColor('#666').margin({ top: 12 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.nearbyCards.length === 0) {
        Column() {
          Text('🌍').fontSize(48).margin({ bottom: 12 })
          Text('附近还没有人分享冷知识').fontSize(16).fontColor('#999')
          Text('去首页把喜欢的卡片分享到附近圈吧').fontSize(13).fontColor('#666').margin({ top: 6 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.nearbyCards, (item: KnowledgeItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.authorName || '匿名用户').fontSize(12).fontColor('#AAAAAA')
                  Blank()
                }.width('100%').margin({ bottom: 8 })
                Text(item.title).fontSize(16).fontWeight(600).fontColor('#FFFFFF').margin({ bottom: 6 })
                Text(item.content).fontSize(13).fontColor('#BBBBBB')
                  .maxLines(4).textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%').padding(16).borderRadius(12)
              .backgroundColor('#FFFFFF08').margin({ bottom: 10 })
            }
          })
        }.width('100%').layoutWeight(1).padding({ left: 16, right: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor('#1A1A2E')
  }
}
