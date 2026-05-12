/**
 * 打卡统计柱状图组件
 * 使用 Canvas 绘制近7天打卡完成率柱状图
 */

import { DayStats } from '../viewmodel/StatsViewModel';

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

  build() {
    Column() {
      Text('近7天打卡完成率')
        .fontSize(16)
        .fontWeight(500)
        .fontColor('#333333')
        .padding({ left: 16, top: 12, bottom: 4 })
        .width('100%')

      Canvas(this.renderChart)
        .width('100%')
        .height(this.chartHeight)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .margin({ left: 16, right: 16, bottom: 8 })
    }
    .width('100%')
  }

  // Canvas 渲染函数
  private renderChart = (context: CanvasRenderingContext2D) => {
    const ctx = context;
    const count = this.dayStatsList.length;
    if (count === 0) return;

    // 柱间距计算
    const totalBarsWidth = count * this.barWidth;
    const totalGaps = this.chartWidth - this.leftPadding * 2 - totalBarsWidth;
    const gap = count > 1 ? totalGaps / (count - 1) : 0;

    // 画水平参考线 + 标签（0%, 50%, 100%）
    const refLines = [
      { y: this.baseY, label: '0%' },
      { y: this.baseY - this.maxBarHeight / 2, label: '50%' },
      { y: this.baseY - this.maxBarHeight, label: '100%' }
    ];

    for (const line of refLines) {
      ctx.beginPath();
      ctx.strokeStyle = '#E8E8E8';
      ctx.lineWidth = 1;
      ctx.moveTo(this.leftPadding, line.y);
      ctx.lineTo(this.chartWidth - this.leftPadding, line.y);
      ctx.stroke();

      // 参考线标签
      ctx.fillStyle = '#999999';
      ctx.font = '10px sans-serif';
      ctx.textAlign = 'left';
      ctx.fillText(line.label, 4, line.y + 4);
    }

    // 画每个柱子
    for (let i = 0; i < count; i++) {
      const day = this.dayStatsList[i];
      const x = this.leftPadding + i * (this.barWidth + gap);

      // 柱身颜色：今天用蓝色，其他用浅蓝
      const barColor = day.isToday ? '#2196F3' : '#90CAF9';

      // 柱高 = 完成率 * maxBarHeight
      const barHeight = (day.percent / 100) * this.maxBarHeight;
      const barY = this.baseY - barHeight;

      // 画柱身
      ctx.fillStyle = barColor;
      ctx.fillRect(x, barY, this.barWidth, barHeight);

      // 柱身顶部圆角
      ctx.fillStyle = barColor;
      const radius = 4;
      ctx.beginPath();
      ctx.moveTo(x, barY + radius);
      ctx.arcTo(x, barY, x + radius, barY, radius);
      ctx.arcTo(x + this.barWidth, barY, x + this.barWidth, barY + radius, radius);
      ctx.lineTo(x + this.barWidth, barY + 6);
      ctx.lineTo(x, barY + 6);
      ctx.fill();

      // 柱顶显示百分比
      if (day.percent > 0) {
        ctx.fillStyle = day.isToday ? '#1565C0' : '#666666';
        ctx.font = day.isToday ? 'bold 11px sans-serif' : '10px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(`${day.percent}%`, x + this.barWidth / 2, barY - 8);
      }

      // 柱底显示星期标签
      ctx.fillStyle = day.isToday ? '#1565C0' : '#888888';
      ctx.font = day.isToday ? 'bold 11px sans-serif' : '10px sans-serif';
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
  };
}
