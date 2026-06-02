// ═══════════════════════════════════════
// 书签图标 — SVG Path + 填充变色 + 弹性回弹
// ═══════════════════════════════════════

@ComponentV2
export struct AnimatedBookmark {
  @Require @Param isFavorited: boolean
  @Require @Param accentColor: string
  @Param iconSize: number = 24
  @Event onToggle?: () => void
  @Local iconScale: number = 1.0

  private handleClick(): void {
    this.getUIContext().animateTo({ duration: 140, curve: Curve.EaseOut }, () => {
      this.iconScale = 1.25
    })
    setTimeout(() => {
      this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
        this.iconScale = 1.0
      })
    }, 145)
    this.onToggle?.()
  }

  build() {
    Path()
      .width(this.iconSize).height(this.iconSize)
      .commands('M3 2h18a1 1 0 011 1v18l-9-5-9 5V3a1 1 0 011-1z')
      .fill(this.isFavorited ? this.accentColor : 'none')
      .stroke(this.isFavorited ? 'none' : this.accentColor)
      .strokeWidth(2.0)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
      .scale({ x: this.iconScale, y: this.iconScale })
      .onClick(() => { this.handleClick() })
  }
}
