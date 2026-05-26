import { KnowledgeItem } from '../model/KnowledgeItem'
import { KnowledgeCard } from './KnowledgeCard'
import { ColorPool } from '../utils/ColorPool'

@Component
export struct CardStack {
  @Link cards: KnowledgeItem[]
  @State currentIndex: number = 0
  @State translateX: number = 0
  @State cardOpacity: number = 1
  private colorPool: ColorPool = new ColorPool()
  private startX: number = 0

  build() {
    Stack() {
      if (this.cards.length > 0 && this.currentIndex < this.cards.length) {
        KnowledgeCard({
          card: this.cards[this.currentIndex],
          gradientStart: this.colorPool.next()[0],
          gradientEnd: this.colorPool.next()[1]
        })
          .width('88%')
          .height('75%')
          .offset({ x: this.translateX, y: 0 })
          .opacity(this.cardOpacity)
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal, distance: 60 })
              .onActionStart(() => { this.startX = this.translateX })
              .onActionUpdate((event: GestureEvent) => {
                this.translateX = this.startX + event.offsetX
              })
              .onActionEnd((event: GestureEvent) => {
                if (Math.abs(event.offsetX) > 120) {
                  const dir = event.offsetX > 0 ? 1 : -1
                  this.translateX = dir * 400
                  this.cardOpacity = 0
                  setTimeout(() => {
                    if (dir < 0 && this.currentIndex < this.cards.length - 1) {
                      this.currentIndex++
                    } else if (dir > 0 && this.currentIndex > 0) {
                      this.currentIndex--
                    }
                    this.translateX = 0
                    this.cardOpacity = 1
                  }, 300)
                } else {
                  animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
                    this.translateX = 0
                  })
                }
              })
          )
      } else {
        Column() {
          Text('📚').fontSize(48).margin({ bottom: 12 })
          Text('暂无卡片').fontSize(16).fontColor('#999')
          Text('点击 ✨ AI生成 获取冷知识').fontSize(13).fontColor('#bbb').margin({ top: 6 })
        }
        .width('88%')
        .height('75%')
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .backgroundColor('#FFFFFF08')
        .border({ width: 1, color: '#FFFFFF15' })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}
