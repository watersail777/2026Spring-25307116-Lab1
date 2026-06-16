// ═══════════════════════════════════════
// 底部导航 — 3 Tab：首页 / 书签 / 我的
// ═══════════════════════════════════════

@ComponentV2
export struct BottomNavBar {
  @Param currentTab: number = 0
  @Event onTabChange?: (idx: number) => void

  build() {
    Row() {
      // 首页
      Column() {
        Image($r('app.media.compass2'))
          .width(24).height(24)
          .opacity(this.currentTab === 0 ? 1 : 0.45)
          .fillColor(this.currentTab === 0 ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
        Text('首页').fontSize(10)
          .fontWeight(this.currentTab === 0 ? 600 : 400)
          .fontColor(this.currentTab === 0 ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
          .margin({ top: 4 })
      }.width('33%').onClick(() => { this.onTabChange?.(0) })

      // 书签
      Column() {
        Image($r('app.media.bookmark8'))
          .width(24).height(24)
          .opacity(this.currentTab === 1 ? 1 : 0.45)
          .fillColor(this.currentTab === 1 ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
        Text('书签').fontSize(10)
          .fontWeight(this.currentTab === 1 ? 600 : 400)
          .fontColor(this.currentTab === 1 ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
          .margin({ top: 4 })
      }.width('33%').onClick(() => { this.onTabChange?.(1) })

      // 我的
      Column() {
        Image($r('app.media.user2'))
          .width(24).height(24)
          .opacity(this.currentTab === 2 ? 1 : 0.45)
          .fillColor(this.currentTab === 2 ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
        Text('我的').fontSize(10)
          .fontWeight(this.currentTab === 2 ? 600 : 400)
          .fontColor(this.currentTab === 2 ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
          .margin({ top: 4 })
      }.width('33%').onClick(() => { this.onTabChange?.(2) })
    }
    .width('100%').height(72).padding({ top: 8, bottom: 16 })
    .backgroundColor($r('app.color.page_bg')).opacity(0.85).backdropBlur(28)
    .border({ width: { top: 1 }, color: 'rgba(128,128,128,0.15)' })
    .borderRadius({ topLeft: 20, topRight: 20 })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.06)', offsetY: -2 })
  }
}
