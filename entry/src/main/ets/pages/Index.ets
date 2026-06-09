import { AppViewModel } from '../model/AppViewModel'
import { SearchTab } from './tabs/SearchTab'
import { ResultsTab } from './tabs/ResultsTab'
import { DataLoader } from '../data/DataLoader'
import { GlobalThis } from '../utils/GlobalThis'

@Entry
@ComponentV2
struct Index {
  @Local vm: AppViewModel = new AppViewModel()
  @Local splashVisible: boolean = true
  @Local splashText: string = '正在加载列车数据...'
  @Local isTablet: boolean = false
  private timer: number = 0

  aboutToAppear(): void {
    this.vm.init()

    if (DataLoader.isLoaded) {
      this.splashVisible = false
      return
    }

    this.timer = setInterval(() => {
      if (GlobalThis.rawDataReady) {
        clearInterval(this.timer)
        this.splashText = '正在解析数据...'
        DataLoader.loadAllAsync().then(() => {
          this.vm.isDataReady = true
          this.splashVisible = false
        })
        const parseTimer = setInterval(() => {
          this.vm.refreshProgress()
          if (DataLoader.isLoaded) {
            this.splashVisible = false
            clearInterval(parseTimer)
          }
        }, 200)
      }
    }, 200)
  }

  aboutToDisappear(): void {
    if (this.timer > 0) clearInterval(this.timer)
  }

  build() {
    Column() {
      if (this.splashVisible) {
        Column() {
          Text('OnTrack').fontSize(26).fontWeight(700)
            .fontColor('#1A1A2E').margin({ top: 12, bottom: 6 })

          Text(this.vm.loadingText.length > 0 ? this.vm.loadingText : '正在加载列车数据...')
            .fontSize(13).fontColor('#888888')
            .margin({ bottom: 20 })

          Progress({
            value: this.vm.loadingProgress,
            total: 100,
            type: ProgressType.Linear
          })
          .width('60%').height(4)
          .color('#1A73E8')
          .backgroundColor('#E8E8E8')

          Text(`${this.vm.loadingProgress}%`)
            .fontSize(12).fontColor('#AAAAAA').margin({ top: 8 })
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.isTablet) {
        SideBarContainer(SideBarContainerType.Embed) {
          Scroll() {
            SearchTab({ vm: this.vm, isTablet: true })
          }
          .width('100%').height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .backgroundColor('#F5F5F5')

          Scroll() {
            ResultsTab({ vm: this.vm, isTablet: true })
          }
          .width('100%').height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .backgroundColor('#FFFFFF')
        }
        .showSideBar(true)
        .sideBarWidth('35%')
        .minSideBarWidth(300)
        .autoHide(false)
        .width('100%').height('100%')
      } else {
        Column() {
          if (this.vm.currentTab === 0) {
            SearchTab({ vm: this.vm, isTablet: false })
          } else {
            ResultsTab({ vm: this.vm, isTablet: false })
          }
        }
        .width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F5F5F5')
    .padding({ top: 24 })
    .onAreaChange((_: Area, newArea: Area) => {
      // 宽度 >= 600vp 视为平板
      const w = newArea.width as number
      const tablet = w >= 600
      if (tablet !== this.isTablet) {
        this.isTablet = tablet
        this.vm.isTablet = tablet
      }
    })
  }
}