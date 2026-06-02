// ═══════════════════════════════════════
// 心形图标 — SVG Path + 粒子爆发动效
// ═══════════════════════════════════════

interface ParticleData {
  x: number
  y: number
  targetX: number
  targetY: number
  opacity: number
  color: string
  particleSize: number
}

@ComponentV2
export struct AnimatedHeart {
  @Require @Param isLiked: boolean
  @Require @Param accentColor: string
  @Param iconSize: number = 20
  @Event onToggle?: () => void
  @Local heartScale: number = 1.0
  @Local particles: ParticleData[] = []
  @Local bursting: boolean = false

  private readonly PARTICLE_COLORS: string[] = [
    '#EF4444', '#F87171', '#FB923C', '#FBBF24',
    '#F472B6', '#EC4899', '#FF6B6B', '#FF8C8C'
  ]

  private generateParticles(): void {
    const arr: ParticleData[] = []
    for (let i = 0; i < 8; i++) {
      const angle = (Math.random() - 0.5) * Math.PI * 0.55
      const dist = 16 + Math.random() * 20
      arr.push({
        x: 0, y: 0,
        targetX: Math.sin(angle) * dist,
        targetY: Math.cos(angle) * dist - 10,
        opacity: 1.0,
        color: this.PARTICLE_COLORS[i],
        particleSize: 2.5 + Math.random() * 3
      })
    }
    this.particles = arr
    this.bursting = true
  }

  private playBurst(): void {
    this.generateParticles()

    this.getUIContext().animateTo({ duration: 380, curve: Curve.EaseOut }, () => {
      for (let i = 0; i < this.particles.length; i++) {
        this.particles[i].x = this.particles[i].targetX
        this.particles[i].y = this.particles[i].targetY
        this.particles[i].opacity = 0
      }
    })

    setTimeout(() => {
      this.bursting = false
      this.particles = []
    }, 400)
  }

  private playScaleBounce(): void {
    this.heartScale = 1.35
    this.getUIContext().animateTo({ duration: 350, curve: Curve.EaseOut }, () => {
      this.heartScale = 1.0
    })
  }

  private handleClick(): void {
    this.playScaleBounce()
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
        .strokeWidth(1.8)
        .strokeLineCap(LineCapStyle.Round)
        .strokeLineJoin(LineJoinStyle.Round)
        .scale({ x: this.heartScale, y: this.heartScale })

      if (this.bursting) {
        ForEach(this.particles, (p: ParticleData, idx: number) => {
          Circle({ width: p.particleSize, height: p.particleSize })
            .fill(p.color)
            .opacity(p.opacity)
            .translate({ x: p.x, y: p.y })
            .position({ x: this.iconSize / 2, y: this.iconSize / 2 })
        }, (p: ParticleData, idx: number) => idx.toString())
      }
    }
    .width(this.iconSize + 8).height(this.iconSize + 8)
    .alignContent(Alignment.Center)
    .onClick(() => { this.handleClick() })
  }
}
