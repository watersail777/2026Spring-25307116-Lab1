import { AppViewModel } from '../model/AppViewModel'
import { StarMapTab } from './tabs/StarMapTab'
import { FavoritesTab } from './tabs/FavoritesTab'
import { ProfileTab } from './tabs/ProfileTab'
import { BottomNavBar } from '../components/BottomNavBar'
import { GlobalThis } from '../utils/GlobalThis'

const BG = '#f5f4f0'

@Entry
@Component
struct Index {
  private vm: AppViewModel = new AppViewModel()

  aboutToAppear(): void {
    this.vm.init()
    this.handleWidgetJump()
  }

  onPageShow(): void {
    this.handleWidgetJump()
  }

  handleWidgetJump(): void {
    if (GlobalThis.widgetCardId.length > 0) {
      const targetId = GlobalThis.widgetCardId
      GlobalThis.widgetCardId = ''
      this.vm.jumpToCard(targetId)
    }
  }

  build() {
    Column() {
      // ── 内容区 ──
      Column() {
        if (this.vm.currentTab === 0) {
          StarMapTab({ vm: this.vm })          // 星图首页
        } else if (this.vm.currentTab === 1) {
          FavoritesTab({ vm: this.vm })       // 书签
        } else {
          ProfileTab({
            vm: this.vm,
            onNavigateToTab: (idx: number) => { this.vm.switchTab(idx) },
            onNavigateToCard: (cardId: string) => {
              for (let i = 0; i < this.vm.cards.length; i++) {
                if (this.vm.cards[i].id === cardId) {
                  this.vm.cardIndex = i; this.vm.currentTab = 0; break
                }
              }
            }
          })         // 我的
        }
      }
      .width('100%').layoutWeight(1)

      // ── 底部导航栏 ──
      BottomNavBar({
        currentTab: this.vm.currentTab,
        onTabChange: (idx: number) => { this.vm.switchTab(idx) }
      })
    }
    .width('100%').height('100%').backgroundColor(BG).padding({ top: 24 })
  }
}
