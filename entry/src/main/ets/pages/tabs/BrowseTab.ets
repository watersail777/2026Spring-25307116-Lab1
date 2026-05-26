import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel } from '../../model/AppViewModel'
import { KnowledgeCard } from '../../components/KnowledgeCard'
import { ColorPool } from '../../utils/ColorPool'
import { NFCExchange } from '../../utils/NFCExchange'
import { IconFavorites } from '../../components/BottomNavBar'

const TEXT = '#3c3c50'
const WHITE_GLASS = 'rgba(255,255,255,0.7)'

@ComponentV2
export struct BrowseTab {
  @Require @Param vm: AppViewModel
  @Local translateX: number = 0
  @Local cardOpacity: number = 1
  private colorPool: ColorPool = new ColorPool()
  private gradientPair: [string, string] = ['#dcd0f0', '#c8b8e4']
  private startX: number = 0

  handleSwipe(dir: number): void {
    if (dir < 0 && this.vm.cardIndex < this.vm.cards.length - 1) {
      this.vm.cardIndex++
    } else if (dir > 0 && this.vm.cardIndex > 0) {
      this.vm.cardIndex--
    }
    this.gradientPair = this.colorPool.next()
  }

  build() {
    Column() {
      // ── 顶栏 ──
      Row() {
        Text('知域').fontSize(24).fontWeight(700).fontColor(TEXT)
        Blank()
        Text(`${this.vm.cards.length} 条`).fontSize(12).fontColor('#c0c0c8')
      }
      .width('100%').padding({ left: 20, right: 20, top: 10, bottom: 6 })

      Row().width('86%').height(1).backgroundColor('#e8e6e0').margin({ bottom: 2 })

      // ── 卡片区 ──
      Stack({ alignContent: Alignment.Center }) {
        if (this.vm.cards.length > 0 && this.vm.cardIndex < this.vm.cards.length) {
          KnowledgeCard({
            card: this.vm.cards[this.vm.cardIndex],
            gradientStart: this.gradientPair[0],
            gradientEnd: this.gradientPair[1]
          })
            .width('92%').height('86%')
            .offset({ x: this.translateX, y: 0 }).opacity(this.cardOpacity)
            .gesture(
              PanGesture({ direction: PanDirection.Horizontal, distance: 60 })
                .onActionStart(() => {
                  this.startX = this.translateX
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.translateX = this.startX + event.offsetX
                })
                .onActionEnd((event: GestureEvent) => {
                  if (Math.abs(event.offsetX) > 120) {
                    const dir = event.offsetX > 0 ? 1 : -1
                    this.translateX = dir * 400
                    this.cardOpacity = 0
                    setTimeout(() => {
                      this.handleSwipe(dir)
                      this.translateX = 0
                      this.cardOpacity = 1
                    }, 300)
                  } else {
                    this.getUIContext().animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
                      this.translateX = 0
                    })
                  }
                })
            )
        } else {
          Column() {
            Stack() {
              Line().width(60).height(0).stroke('#ddd').strokeWidth(2).strokeLineCap(LineCapStyle.Round).position({ x: 0, y: 30 })
              Line().width(50).height(0).stroke('#ddd').strokeWidth(2).strokeLineCap(LineCapStyle.Round).position({ x: 5, y: 18 })
              Line().width(40).height(0).stroke('#ddd').strokeWidth(2).strokeLineCap(LineCapStyle.Round).position({ x: 10, y: 6 })
              Line().width(30).height(0).stroke('#ccc').strokeWidth(2.5).strokeLineCap(LineCapStyle.Round).position({ x: 8, y: 0 }).rotate({ angle: 12, centerX: 0, centerY: 4 })
            }.width(60).height(34).margin({ bottom: 16 })
            Text('暂无卡片').fontSize(15).fontColor('#999')
            Text('左右滑动发现更多').fontSize(12).fontColor('#bbb').margin({ top: 4 })
          }
          .width('92%').height('86%').justifyContent(FlexAlign.Center).borderRadius(22)
          .backgroundColor('rgba(255,255,255,0.45)')
        }
      }
      .width('100%').layoutWeight(1).alignContent(Alignment.Center)

      // ── 页码指示器 ──
      if (this.vm.cards.length > 1) {
        Row() {
          ForEach(this.vm.getDotIndices(), (i: number) => {
            Circle({ width: i === this.vm.cardIndex ? 6 : 4, height: i === this.vm.cardIndex ? 6 : 4 })
              .fill(i === this.vm.cardIndex ? '#8c8cb0' : '#d8d8e0')
              .margin({ left: 3, right: 3 })
          })
        }.width('100%').justifyContent(FlexAlign.Center).margin({ bottom: 8 })
      }

      // ── 操作栏 ──
      Row() {
        Button() {
          IconFavorites({ active: (this.vm.cards.length > 0 && (this.vm.cards[this.vm.cardIndex]?.isFavorited ?? false)) })
        }
        .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
        .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
        .onClick(() => { this.vm.handleFavorite() })

        Button() { Text('👍').fontSize(17) }
          .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
          .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
          .margin({ left: 14, right: 14 }).onClick(() => { this.vm.handleLike() })

        Button() {
          Path().width(16).height(15)
            .commands('M1 7 L10 1 L10 5 L9 5 L9 2.5 L3 7 L9 11.5 L9 9 L10 9 L10 13 L1 7 Z M10 13 L10 15 L15 15 L15 8 L13 8 L13 13 L10 13 Z')
            .fill('none').stroke('#808090').strokeWidth(1.4).strokeLineJoin(LineJoinStyle.Round)
        }
        .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
        .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
        .margin({ right: 14 }).onClick(() => { this.vm.shareToSystem() })

        Button() {
          Stack() {
            Circle({ width: 13, height: 13 }).fill('none').stroke('#808090').strokeWidth(1.4)
            Circle({ width: 3.5, height: 3.5 }).fill('#808090')
          }.width(18).height(18)
        }
        .width(42).height(42).backgroundColor(WHITE_GLASS).borderRadius(21)
        .border({ width: 1, color: '#e8e6e0', style: BorderStyle.Solid })
        .onClick(() => {
          if (this.vm.cards.length > 0) {
            NFCExchange.prepareExchangeData(this.vm.cards[this.vm.cardIndex])
            this.vm.showToast('准备交换... 📱')
          }
        })
      }
      .width('100%').justifyContent(FlexAlign.Center).padding({ bottom: 6, top: 4 })

      // ── Toast ──
      if (this.vm.toastMsg) {
        Text(this.vm.toastMsg).fontSize(13).fontColor('#fff')
          .padding({ left: 18, right: 18, top: 9, bottom: 9 })
          .backgroundColor('rgba(60,60,70,0.85)').borderRadius(16).backdropBlur(10)
      }
    }
    .width('100%').height('100%')
  }
}
