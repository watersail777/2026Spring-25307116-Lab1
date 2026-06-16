import { AppViewModel } from '../model/AppViewModel'
import { BrowseTab } from './tabs/BrowseTab'
import { FavoritesTab } from './tabs/FavoritesTab'
import { ProfileTab } from './tabs/ProfileTab'
import { BottomNavBar } from '../components/BottomNavBar'
import { GlobalThis } from '../utils/GlobalThis'

@Entry
@ComponentV2
struct Index {
  @Local vm: AppViewModel = new AppViewModel()
  @Local isTablet: boolean = false

  aboutToAppear(): void {
    this.vm.init()
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
      Column() {
        if (this.vm.currentTab === 0) {
          BrowseTab({ vm: this.vm, isTablet: this.isTablet })
        } else if (this.vm.currentTab === 1) {
          FavoritesTab({ vm: this.vm, isTablet: this.isTablet })
        } else {
          ProfileTab({
            vm: this.vm,
            isTablet: this.isTablet,
            onNavigateToTab: (idx: number) => { this.vm.switchTab(idx) },
            onNavigateToCard: (cardId: string) => { this.vm.jumpToCard(cardId) }
          })
        }
      }
      .width('100%').layoutWeight(1)

      BottomNavBar({
        currentTab: this.vm.currentTab,
        onTabChange: (idx: number) => { this.vm.switchTab(idx) }
      })
    }
    .width('100%').height('100%').backgroundColor($r('app.color.page_bg')).padding({ top: 24 })
    .onAreaChange((_: Area, newArea: Area) => {
      const w = newArea.width as number
      const tablet = w >= 600
      if (tablet !== this.isTablet) {
        this.isTablet = tablet
        this.vm.isTablet = tablet
      }
    })
  }
}