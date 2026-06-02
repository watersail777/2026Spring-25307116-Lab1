// ═══════════════════════════════════════
// 星图节点 — 分类色发光星点
// ═══════════════════════════════════════

@ComponentV2
export struct StarNode {
  @Require @Param accentColor: string
  @Param explored: boolean = false
  @Param isCurrent: boolean = false
  @Param label: string = ''
  @Event onTap?: () => void

  build() {
    Column() {
      Stack() {
        // 辉光外层
        if (this.isCurrent || this.explored) {
          Circle({ width: 22, height: 22 })
            .fill(this.accentColor + '25')
            .opacity(this.isCurrent ? 0.8 : 0.4)
        }

        // 主体星点
        Circle({
          width: this.isCurrent ? 14 : (this.explored ? 10 : 7),
          height: this.isCurrent ? 14 : (this.explored ? 10 : 7)
        })
          .fill(this.accentColor)
          .opacity(this.explored || this.isCurrent ? 0.95 : 0.3)
          .shadow({
            radius: this.isCurrent ? 12 : (this.explored ? 6 : 0),
            color: this.isCurrent ? this.accentColor + '80' : 'transparent'
          })

        // 当前星金色光环
        if (this.isCurrent) {
          Circle({ width: 20, height: 20 })
            .fill('none')
            .stroke('#FBBF24')
            .strokeWidth(1.5)
            .opacity(0.7)
        }
      }
      .width(24).height(24)

      // 标签（仅当前或已探索显示）
      if (this.label.length > 0 && (this.isCurrent || this.explored)) {
        Text(this.label)
          .fontSize(9).fontWeight(this.isCurrent ? 600 : 400)
          .fontColor(this.isCurrent ? '#FFFFFF' : '#999999')
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
          .width(80)
          .textAlign(TextAlign.Center)
      }
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => { this.onTap?.() })
  }
}
