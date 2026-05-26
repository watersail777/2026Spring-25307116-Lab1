// 马卡龙色系 — 低饱和高明度渐变对
const PALETTE: [string, string][] = [
  ['#c5e8d5', '#a0d4bc'], // 薄荷绿
  ['#dcd0f0', '#c8b8e4'], // 薰衣草紫
  ['#f8d8d4', '#f0c8c4'], // 蜜桃粉
  ['#f8f0d0', '#f0e4b8'], // 奶油黄
  ['#d0e4f4', '#c0d8e8'], // 天蓝
  ['#f0d8e4', '#e8c8d8'], // 淡玫瑰
  ['#d4e8cc', '#c4dcb8'], // 鼠尾草绿
  ['#e4d8ec', '#d4c8e0'], // 丁香紫
  ['#fce4c8', '#f8d8b0'], // 杏色
  ['#c8e0e8', '#b4d4e0']  // 雾蓝
]

export class ColorPool {
  private index: number = 0
  private pool: [string, string][] = []

  constructor() { this.shuffle() }

  private shuffle(): void {
    this.pool = [...PALETTE]
    for (let i = this.pool.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = this.pool[i]
      this.pool[i] = this.pool[j]
      this.pool[j] = temp
    }
    this.index = 0
  }

  next(): [string, string] {
    if (this.index >= this.pool.length) {
      const last = this.pool[this.pool.length - 1]
      this.shuffle()
      if (this.pool[0] === last) {
        const temp2 = this.pool[0]
        this.pool[0] = this.pool[1]
        this.pool[1] = temp2
      }
    }
    return this.pool[this.index++]
  }
}
