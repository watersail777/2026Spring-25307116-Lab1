import { RouteResult, ItinerarySegment } from '../model/DataModels'
import { DataLoader } from '../data/DataLoader'

// ═══════════════════════════════════════
// Canvas 路线图 — 地铁线路图风格
// ═══════════════════════════════════════

const LINE_COLORS: string[] = ['#4A90D9', '#E57373', '#81C784', '#FFB74D', '#BA68C8', '#4DD0E1']
const BAND_HEIGHT = 110
const NODE_RADIUS = 6
const LINE_WIDTH = 4

@ComponentV2
export struct RouteMapCanvas {
  @Require @Param routeResult: RouteResult

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @Local canvasWidth: number = 800
  @Local canvasHeight: number = 300
  @Local ready: boolean = false

  aboutToAppear(): void {
    this.computeSize()
  }

  private computeSize(): void {
    const segs = this.routeResult.segments
    if (segs.length === 0) return
    let totalW = 40 // padding
    for (let i = 0; i < segs.length; i++) {
      totalW += 220 // 每段固定宽度
    }
    this.canvasWidth = Math.max(totalW, 400)
    this.canvasHeight = segs.length * BAND_HEIGHT + 40
  }

  private draw(): void {
    const ctx = this.ctx
    const segs = this.routeResult.segments
    if (segs.length === 0) return

    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight)

    // 背景
    ctx.fillStyle = '#FAFBFC'
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight)

    let xStart = 30
    const paddingX = 30

    for (let i = 0; i < segs.length; i++) {
      const seg = segs[i]
      const color = LINE_COLORS[i % LINE_COLORS.length]
      const yCenter = i * BAND_HEIGHT + 55
      const xEnd = xStart + 200

      // 线路条带
      ctx.beginPath()
      ctx.moveTo(xStart, yCenter)
      ctx.lineTo(xEnd, yCenter)
      ctx.strokeStyle = color
      ctx.lineWidth = LINE_WIDTH
      ctx.lineCap = 'round'
      ctx.stroke()

      // 起点圆圈
      ctx.beginPath()
      ctx.arc(xStart, yCenter, NODE_RADIUS, 0, Math.PI * 2)
      ctx.fillStyle = '#FFFFFF'
      ctx.fill()
      ctx.strokeStyle = color
      ctx.lineWidth = 2.5
      ctx.stroke()

      // 终点圆圈
      ctx.beginPath()
      ctx.arc(xEnd, yCenter, NODE_RADIUS, 0, Math.PI * 2)
      ctx.fillStyle = '#FFFFFF'
      ctx.fill()
      ctx.strokeStyle = color
      ctx.lineWidth = 2.5
      ctx.stroke()

      // 起点站名
      ctx.fillStyle = '#333333'
      ctx.font = '11px sans-serif'
      ctx.textAlign = 'center'
      ctx.fillText(seg.fromStation.length > 5 ? seg.fromStation.substring(0, 5) + '..' : seg.fromStation, xStart, yCenter - 14)

      // 终点站名
      ctx.fillText(seg.toStation.length > 5 ? seg.toStation.substring(0, 5) + '..' : seg.toStation, xEnd, yCenter - 14)

      // 车次标签（条带上方中央）
      ctx.fillStyle = color
      ctx.font = 'bold 12px sans-serif'
      ctx.fillText(seg.trainId, (xStart + xEnd) / 2, yCenter - 2)

      // 时间标注在起点下方
      ctx.fillStyle = '#888888'
      ctx.font = '9px sans-serif'
      ctx.fillText(seg.departureTime, xStart, yCenter + 20)
      ctx.fillText(seg.arrivalTime, xEnd, yCenter + 20)

      // 换乘连接线（垂直虚线）
      if (i > 0) {
        const prevSeg = segs[i - 1]
        const prevY = (i - 1) * BAND_HEIGHT + 55
        const prevXEnd = xStart // 上一段的终点x（大致）
        ctx.beginPath()
        ctx.setLineDash([4, 4])
        ctx.moveTo(xStart, prevY)
        ctx.lineTo(xStart, yCenter)
        ctx.strokeStyle = '#999999'
        ctx.lineWidth = 1.5
        ctx.stroke()
        ctx.setLineDash([])

        // 换乘标记
        ctx.beginPath()
        ctx.arc(xStart, (prevY + yCenter) / 2, 3, 0, Math.PI * 2)
        ctx.fillStyle = '#FF9800'
        ctx.fill()
      }

      xStart = xEnd
    }
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(this.canvasHeight < 300 ? this.canvasHeight : 300)
      .onReady(() => {
        this.ready = true
        setTimeout(() => { this.draw() }, 100)
      })
  }
}