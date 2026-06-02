// ═══════════════════════════════════════
// 书签图标 — SVG Path + 填充动效
// ═══════════════════════════════════════

@ComponentV2
export struct AnimatedBookmark {
  @Require @Param isFavorited: boolean
  @Require @Param accentColor: string
  @Param iconSize: number = 16
  @Event onToggle?: () => void
  @Local iconScale: number = 1.0

  private handleClick(): void {
    this.iconScale = 1.25
    this.getUIContext().animateTo({ duration: 280, curve: Curve.EaseOut }, () => {
      this.iconScale = 1.0
    })
    this.onToggle?.()
  }

  build() {
    Path()
      .width(this.iconSize).height(this.iconSize)
      .commands('M5 2h14a1 1 0 011 1v18l-7-5-7 5V3a1 1 0 011-1z')
      .fill(this.isFavorited ? this.accentColor : 'none')
      .stroke(this.isFavorited ? 'none' : this.accentColor)
      .strokeWidth(1.8)
      .strokeLineCap(LineCapStyle.Round)
      .strokeLineJoin(LineJoinStyle.Round)
      .scale({ x: this.iconScale, y: this.iconScale })
      .onClick(() => { this.handleClick() })
  }
}
