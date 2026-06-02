// ═══════════════════════════════════════
// 心形图标 — SVG Path + 粒子爆发动效
// ═══════════════════════════════════════

@ComponentV2
export struct AnimatedHeart {
  @Require @Param isLiked: boolean
  @Require @Param accentColor: string
  @Param iconSize: number = 24
  @Event onToggle?: () => void
  @Local heartScale: number = 1.0
  // 6 个固定粒子的偏移和透明度
  @Local p0x: number = 0; @Local p0y: number = 0; @Local p0o: number = 0
  @Local p1x: number = 0; @Local p1y: number = 0; @Local p1o: number = 0
  @Local p2x: number = 0; @Local p2y: number = 0; @Local p2o: number = 0
  @Local p3x: number = 0; @Local p3y: number = 0; @Local p3o: number = 0
  @Local p4x: number = 0; @Local p4y: number = 0; @Local p4o: number = 0
  @Local p5x: number = 0; @Local p5y: number = 0; @Local p5o: number = 0
  @Local p6x: number = 0; @Local p6y: number = 0; @Local p6o: number = 0
  @Local p7x: number = 0; @Local p7y: number = 0; @Local p7o: number = 0

  private playBurst(): void {
    const angles: number[] = [-0.9, -0.55, -0.2, 0.15, 0.5, 0.85, -1.2, 1.1]
    const dists: number[] = [24, 20, 26, 18, 28, 22, 19, 25]
    const offsets: number = this.iconSize / 2

    // 镜头 1：粒子置中，可见
    this.p0x = offsets; this.p0y = offsets; this.p0o = 1
    this.p1x = offsets; this.p1y = offsets; this.p1o = 1
    this.p2x = offsets; this.p2y = offsets; this.p2o = 1
    this.p3x = offsets; this.p3y = offsets; this.p3o = 1
    this.p4x = offsets; this.p4y = offsets; this.p4o = 1
    this.p5x = offsets; this.p5y = offsets; this.p5o = 1
    this.p6x = offsets; this.p6y = offsets; this.p6o = 1
    this.p7x = offsets; this.p7y = offsets; this.p7o = 1

    // 镜头 2：飞出
    this.getUIContext().animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
      this.p0x = offsets + Math.sin(angles[0]) * dists[0]; this.p0y = offsets + Math.cos(angles[0]) * dists[0] - 10; this.p0o = 0
      this.p1x = offsets + Math.sin(angles[1]) * dists[1]; this.p1y = offsets + Math.cos(angles[1]) * dists[1] - 10; this.p1o = 0
      this.p2x = offsets + Math.sin(angles[2]) * dists[2]; this.p2y = offsets + Math.cos(angles[2]) * dists[2] - 10; this.p2o = 0
      this.p3x = offsets + Math.sin(angles[3]) * dists[3]; this.p3y = offsets + Math.cos(angles[3]) * dists[3] - 10; this.p3o = 0
      this.p4x = offsets + Math.sin(angles[4]) * dists[4]; this.p4y = offsets + Math.cos(angles[4]) * dists[4] - 10; this.p4o = 0
      this.p5x = offsets + Math.sin(angles[5]) * dists[5]; this.p5y = offsets + Math.cos(angles[5]) * dists[5] - 10; this.p5o = 0
      this.p6x = offsets + Math.sin(angles[6]) * dists[6]; this.p6y = offsets + Math.cos(angles[6]) * dists[6] - 10; this.p6o = 0
      this.p7x = offsets + Math.sin(angles[7]) * dists[7]; this.p7y = offsets + Math.cos(angles[7]) * dists[7] - 10; this.p7o = 0
    })
  }

  private handleClick(): void {
    // 两段弹跳
    this.getUIContext().animateTo({ duration: 140, curve: Curve.EaseOut }, () => {
      this.heartScale = 1.35
    })
    setTimeout(() => {
      this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
        this.heartScale = 1.0
      })
    }, 145)

    if (!this.isLiked) {
      this.playBurst()
    }
    this.onToggle?.()
  }

  build() {
    Stack() {
      Path()
        .width(this.iconSize).height(this.iconSize)
        .commands('M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z')
        .fill(this.isLiked ? '#EF4444' : 'none')
        .stroke(this.isLiked ? 'none' : this.accentColor)
        .strokeWidth(2.0)
        .strokeLineCap(LineCapStyle.Round)
        .strokeLineJoin(LineJoinStyle.Round)
        .scale({ x: this.heartScale, y: this.heartScale })

      // 粒子层
      Circle({ width: 3, height: 3 }).fill('#EF4444').opacity(this.p0o).position({ x: this.p0x, y: this.p0y })
      Circle({ width: 2.5, height: 2.5 }).fill('#F87171').opacity(this.p1o).position({ x: this.p1x, y: this.p1y })
      Circle({ width: 3.5, height: 3.5 }).fill('#FB923C').opacity(this.p2o).position({ x: this.p2x, y: this.p2y })
      Circle({ width: 2, height: 2 }).fill('#FBBF24').opacity(this.p3o).position({ x: this.p3x, y: this.p3y })
      Circle({ width: 3, height: 3 }).fill('#F472B6').opacity(this.p4o).position({ x: this.p4x, y: this.p4y })
      Circle({ width: 2.5, height: 2.5 }).fill('#EC4899').opacity(this.p5o).position({ x: this.p5x, y: this.p5y })
      Circle({ width: 3.5, height: 3.5 }).fill('#FF6B6B').opacity(this.p6o).position({ x: this.p6x, y: this.p6y })
      Circle({ width: 2, height: 2 }).fill('#FF8C8C').opacity(this.p7o).position({ x: this.p7x, y: this.p7y })
    }
    .width(this.iconSize).height(this.iconSize)
    .alignContent(Alignment.Center)
    .onClick(() => { this.handleClick() })
  }
}
