/**
 * 打卡统计柱状图组件
 * 使用 Canvas 绘制近7天打卡完成率柱状图
 */

import { DayStats } from '../viewmodel/StatsViewModel';

/** 参考线数据结构 */
interface RefLine {
  y: number;
  label: string;
}

@Component
export default struct ChartComponent {
  @Prop dayStatsList: DayStats[] = [];
  // Canvas 尺寸
  private readonly chartWidth: number = 340;
  private readonly chartHeight: number = 220;
  private readonly barWidth: number = 32;
  private readonly baseY: number = 180;
  private readonly maxBarHeight: number = 140;
  private readonly leftPadding: number = 30;
  // Canvas 渲染上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Column() {
      Text('近7天打卡完成率')
        .fontSize(16)
        .fontWeight(500)
        .fontColor('#333333')
        .padding({ left: 16, top: 12, bottom: 4 })
        .width('100%')

      Canvas(this.context)
        .width('100%')
        .height(this.chartHeight)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .margin({ left: 16, right: 16, bottom: 8 })
        .onReady(() => {
          this.drawChart();
        })
    }
    .width('100%')
  }

  private drawChart(): void {
    const ctx: CanvasRenderingContext2D = this.context;
    const count: number = this.dayStatsList.length;
    if (count === 0) {
      return;
    }

    // 柱间距计算
    const totalBarsWidth: number = count * this.barWidth;
    const totalGaps: number = this.chartWidth - this.leftPadding * 2 - totalBarsWidth;
    const gap: number = count > 1 ? totalGaps / (count - 1) : 0;

    // 水平参考线
    const refLine0: RefLine = { y: this.baseY, label: '0%' };
    const refLine50: RefLine = { y: this.baseY - this.maxBarHeight / 2, label: '50%' };
    const refLine100: RefLine = { y: this.baseY - this.maxBarHeight, label: '100%' };
    const refLines: RefLine[] = [refLine0, refLine50, refLine100];

    for (let ri: number = 0; ri < refLines.length; ri++) {
      const line: RefLine = refLines[ri];
      ctx.beginPath();
      ctx.strokeStyle = '#E8E8E8';
      ctx.lineWidth = 1;
      ctx.moveTo(this.leftPadding, line.y);
      ctx.lineTo(this.chartWidth - this.leftPadding, line.y);
      ctx.stroke();

      // 参考线文字
      ctx.fillStyle = '#999999';
      ctx.font = '10px sans-serif';
      ctx.textAlign = 'left';
      ctx.fillText(line.label, 4, line.y + 4);
    }

    // 画柱子
    for (let i: number = 0; i < count; i++) {
      const day: DayStats = this.dayStatsList[i];
      const x: number = this.leftPadding + i * (this.barWidth + gap);

      // 柱身颜色
      const barColor: string = day.isToday ? '#2196F3' : '#90CAF9';

      // 柱高
      const barHeight: number = (day.percent / 100) * this.maxBarHeight;
      const barY: number = this.baseY - barHeight;

      // 画柱身
      ctx.fillStyle = barColor;
      ctx.fillRect(x, barY, this.barWidth, barHeight);

      // 柱身顶部圆角
      const radius: number = 4;
      ctx.beginPath();
      ctx.moveTo(x, barY + radius);
      ctx.arcTo(x, barY, x + radius, barY, radius);
      ctx.arcTo(x + this.barWidth, barY, x + this.barWidth, barY + radius, radius);
      ctx.lineTo(x + this.barWidth, barY + 6);
      ctx.lineTo(x, barY + 6);
      ctx.closePath();
      ctx.fill();

      // 柱顶百分比文字
      if (day.percent > 0) {
        ctx.fillStyle = day.isToday ? '#1565C0' : '#666666';
        const fontSize: string = day.isToday ? 'bold 11px sans-serif' : '10px sans-serif';
        ctx.font = fontSize;
        ctx.textAlign = 'center';
        const percentText: string = day.percent.toString() + '%';
        ctx.fillText(percentText, x + this.barWidth / 2, barY - 8);
      }

      // 柱底星期标签
      ctx.fillStyle = day.isToday ? '#1565C0' : '#888888';
      const bottomFont: string = day.isToday ? 'bold 11px sans-serif' : '10px sans-serif';
      ctx.font = bottomFont;
      ctx.textAlign = 'center';
      ctx.fillText(day.dayLabel, x + this.barWidth / 2, this.baseY + 16);

      // 今天标记圆点
      if (day.isToday) {
        ctx.fillStyle = '#2196F3';
        ctx.beginPath();
        ctx.arc(x + this.barWidth / 2, this.baseY + 28, 3, 0, 2 * Math.PI);
        ctx.fill();
      }
    }
  }
}
