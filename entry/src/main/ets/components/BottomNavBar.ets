// ═══════════════════════════════════════
// 底部导航 — arkui-2 PNG 图标
// ═══════════════════════════════════════

@ComponentV2
export struct BottomNavBar {
  @Param currentTab: number = 0
  @Event onTabChange?: (idx: number) => void

  build() {
    Row() {
      // 今日
      Column() {
        Image($r('app.media.compass2'))
          .width(24).height(24)
          .opacity(this.currentTab === 0 ? 1 : 0.45)
        Text('今日').fontSize(10)
          .fontWeight(this.currentTab === 0 ? 600 : 400)
          .fontColor(this.currentTab === 0 ? '#1F2937' : '#9CA3AF')
          .margin({ top: 4 })
      }.width('25%').onClick(() => { this.onTabChange?.(0) })

      // 发现
      Column() {
        Stack() {
          Image($r('app.media.Vector_2_1193'))
            .width(2).height(20).position({ x: 12, y: 3 })
          Image($r('app.media.Vector_2_1194'))
            .width(20).height(2).position({ x: 3, y: 12 })
          Row()
            .width(18).height(18).borderRadius(2)
            .border({ width: 2, color: this.currentTab === 1 ? '#1F2937' : '#9CA3AF' })
            .position({ x: 3, y: 3 })
        }
        .width(24).height(24)
        .opacity(this.currentTab === 1 ? 1 : 0.45)
        Text('发现').fontSize(10)
          .fontWeight(this.currentTab === 1 ? 600 : 400)
          .fontColor(this.currentTab === 1 ? '#1F2937' : '#9CA3AF')
          .margin({ top: 4 })
      }.width('25%').onClick(() => { this.onTabChange?.(1) })

      // 书签
      Column() {
        Image($r('app.media.bookmark8'))
          .width(24).height(24)
          .opacity(this.currentTab === 2 ? 1 : 0.45)
        Text('书签').fontSize(10)
          .fontWeight(this.currentTab === 2 ? 600 : 400)
          .fontColor(this.currentTab === 2 ? '#1F2937' : '#9CA3AF')
          .margin({ top: 4 })
      }.width('25%').onClick(() => { this.onTabChange?.(2) })

      // 我的
      Column() {
        Image($r('app.media.user2'))
          .width(24).height(24)
          .opacity(this.currentTab === 3 ? 1 : 0.45)
        Text('我的').fontSize(10)
          .fontWeight(this.currentTab === 3 ? 600 : 400)
          .fontColor(this.currentTab === 3 ? '#1F2937' : '#9CA3AF')
          .margin({ top: 4 })
      }.width('25%').onClick(() => { this.onTabChange?.(3) })
    }
    .width('100%').height(70).padding({ top: 8, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.9)').backdropBlur(20)
    .border({ width: { top: 1 }, color: '#F3F4F6' })
  }
}
