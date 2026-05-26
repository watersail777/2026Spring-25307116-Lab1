import { KnowledgeItem } from '../model/KnowledgeItem'
import { LocalStore } from '../data/LocalStore'

@Entry
@Component
struct FavoritesPage {
  @State favorites: KnowledgeItem[] = []

  async aboutToAppear(): Promise<void> {
    const favIds = await LocalStore.getFavoriteIds()
    this.favorites = []
    for (const id of favIds) {
      const card = await LocalStore.getCard(id)
      if (card) { card.isFavorited = true; this.favorites.push(card) }
    }
  }

  async removeFavorite(cardId: string): Promise<void> {
    await LocalStore.toggleFavorite(cardId)
    this.favorites = this.favorites.filter(c => c.id !== cardId)
  }

  build() {
    Column() {
      Text('我的收藏').fontSize(22).fontWeight(700).fontColor('#FFFFFF')
        .width('100%').padding({ left: 24, top: 16, bottom: 12 })

      if (this.favorites.length === 0) {
        Column() {
          Text('❤️').fontSize(48).margin({ bottom: 12 })
          Text('还没有收藏').fontSize(16).fontColor('#999')
          Text('浏览卡片时点击 ❤️ 即可收藏').fontSize(13).fontColor('#666').margin({ top: 6 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.favorites, (item: KnowledgeItem) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title).fontSize(16).fontWeight(600).fontColor('#FFFFFF')
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.content).fontSize(13).fontColor('#AAAAAA')
                    .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 6 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Button('取消').fontSize(12).fontColor('#FF6B6B').backgroundColor('#FF6B6B20')
                  .borderRadius(12).height(32)
                  .onClick(() => { this.removeFavorite(item.id) })
              }
              .width('100%').padding(16).borderRadius(12)
              .backgroundColor('#FFFFFF08').margin({ bottom: 10 })
            }
          })
        }
        .width('100%').layoutWeight(1).padding({ left: 16, right: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor('#1A1A2E')
  }
}
