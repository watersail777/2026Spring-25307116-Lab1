@ComponentV2
export struct BottomNavBar {
  @Param currentTab: number = 0
  @Event onTabChange?: (idx: number) => void

  build() {
    Row() {
      Column() {
        Text('🔍').fontSize(20)
        Text('查询').fontSize(10)
          .fontWeight(this.currentTab === 0 ? 600 : 400)
          .fontColor(this.currentTab === 0 ? '#1A73E8' : '#999999')
          .margin({ top: 2 })
      }
      .width('50%').onClick(() => { this.onTabChange?.(0) })

      Column() {
        Text('📋').fontSize(20)
        Text('结果').fontSize(10)
          .fontWeight(this.currentTab === 1 ? 600 : 400)
          .fontColor(this.currentTab === 1 ? '#1A73E8' : '#999999')
          .margin({ top: 2 })
      }
      .width('50%').onClick(() => { this.onTabChange?.(1) })
    }
    .width('100%').height(64)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E8E8E8' })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: -2 })
  }
}