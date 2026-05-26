import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel } from '../../model/AppViewModel'

const TEXT = '#3c3c50'
const WHITE_GLASS = 'rgba(255,255,255,0.7)'

@ComponentV2
export struct FavoritesTab {
  @Require @Param vm: AppViewModel

  build() {
    Column() {
      Text('我的收藏').fontSize(22).fontWeight(700).fontColor(TEXT)
        .width('100%').padding({ left: 20, top: 14, bottom: 10 })

      if (this.vm.favorites.length === 0) {
        Column() {
          Stack() {
            Path().width(40).height(36)
              .commands('M20 0 C8 0 0 10 0 17 C0 24 8 34 20 36 C32 34 40 24 40 17 C40 10 32 0 20 0 Z')
              .fill('none').stroke('#ddd').strokeWidth(1.8)
          }.width(40).height(36).margin({ bottom: 14 })
          Text('还没有收藏').fontSize(15).fontColor('#999')
          Text('在发现页点击底部爱心即可收藏').fontSize(12).fontColor('#bbb').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.vm.favorites, (item: KnowledgeItem) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title).fontSize(15).fontWeight(600).fontColor(TEXT)
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.content).fontSize(12).fontColor('#888')
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 4 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Button('取消').fontSize(11).fontColor('#e06060').backgroundColor('#fef0f0')
                  .borderRadius(10).height(30).onClick(() => { this.vm.removeFavorite(item.id) })
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
