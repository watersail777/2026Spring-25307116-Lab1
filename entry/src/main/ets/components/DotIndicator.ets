/**
 * 轮播导航点 — 10个固定点，卡片按 currentIndex % 10 循环映射
 */
@ComponentV2
export struct DotIndicator {
  @Require @Param totalCount: number
  @Require @Param currentIndex: number
  @Param activeColor: string = '#333333'
  @Param inactiveColor: string = '#CCCCCC'
  @Event onDotClick?: (index: number) => void

  build() {
    Row() {
      // 点0 — card 0,10,20,30
      Column() { Row().width(this.currentIndex % 10 === 0 ? 8 : 6).height(this.currentIndex % 10 === 0 ? 8 : 6).borderRadius(this.currentIndex % 10 === 0 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 0 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 0 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(0) })
      // 1
      Column() { Row().width(this.currentIndex % 10 === 1 ? 8 : 6).height(this.currentIndex % 10 === 1 ? 8 : 6).borderRadius(this.currentIndex % 10 === 1 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 1 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 1 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(1) })
      // 2
      Column() { Row().width(this.currentIndex % 10 === 2 ? 8 : 6).height(this.currentIndex % 10 === 2 ? 8 : 6).borderRadius(this.currentIndex % 10 === 2 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 2 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 2 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(2) })
      // 3
      Column() { Row().width(this.currentIndex % 10 === 3 ? 8 : 6).height(this.currentIndex % 10 === 3 ? 8 : 6).borderRadius(this.currentIndex % 10 === 3 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 3 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 3 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(3) })
      // 4
      Column() { Row().width(this.currentIndex % 10 === 4 ? 8 : 6).height(this.currentIndex % 10 === 4 ? 8 : 6).borderRadius(this.currentIndex % 10 === 4 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 4 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 4 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(4) })
      // 5
      Column() { Row().width(this.currentIndex % 10 === 5 ? 8 : 6).height(this.currentIndex % 10 === 5 ? 8 : 6).borderRadius(this.currentIndex % 10 === 5 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 5 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 5 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(5) })
      // 6
      Column() { Row().width(this.currentIndex % 10 === 6 ? 8 : 6).height(this.currentIndex % 10 === 6 ? 8 : 6).borderRadius(this.currentIndex % 10 === 6 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 6 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 6 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(6) })
      // 7
      Column() { Row().width(this.currentIndex % 10 === 7 ? 8 : 6).height(this.currentIndex % 10 === 7 ? 8 : 6).borderRadius(this.currentIndex % 10 === 7 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 7 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 7 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(7) })
      // 8
      Column() { Row().width(this.currentIndex % 10 === 8 ? 8 : 6).height(this.currentIndex % 10 === 8 ? 8 : 6).borderRadius(this.currentIndex % 10 === 8 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 8 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 8 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(8) })
      // 9
      Column() { Row().width(this.currentIndex % 10 === 9 ? 8 : 6).height(this.currentIndex % 10 === 9 ? 8 : 6).borderRadius(this.currentIndex % 10 === 9 ? 4 : 3).backgroundColor(this.currentIndex % 10 === 9 ? this.activeColor : this.inactiveColor).opacity(this.currentIndex % 10 === 9 ? 1.0 : 0.45).animation({ duration: 200, curve: Curve.EaseOut }) }.width(20).height(20).justifyContent(FlexAlign.Center).onClick(() => { this.goToCard(9) })
    }
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 4 })
  }

  /** 点击第 k 个点 → 跳到与当前卡片最近的以 k 为模的卡片 */
  goToCard(dotIdx: number): void {
    const base = this.currentIndex - (this.currentIndex % 10) + dotIdx
    let target = base
    if (base >= this.totalCount) target = base - 10
    else if (base < 0) target = base + 10
    if (target >= 0 && target < this.totalCount) {
      this.onDotClick?.(target)
    }
  }
}
