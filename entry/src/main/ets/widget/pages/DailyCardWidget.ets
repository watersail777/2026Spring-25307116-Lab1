@Entry
@Component
struct DailyCardWidget {
  @LocalStorageProp('title') title: string = '冷知识'
  @LocalStorageProp('content') content: string = ''
  @LocalStorageProp('category') category: string = ''
  @LocalStorageProp('cardId') cardId: string = ''
  @LocalStorageProp('date') date: string = ''

  // 渐变色方案（8组，覆盖4套主题色系）
  private readonly GRADIENTS: [string, string][] = [
    ['#c9a8d8', '#8870c8'], // 马卡龙·紫
    ['#7dbe7d', '#4a9e90'], // 马卡龙·绿
    ['#c084fc', '#6b4d92'], // 夜间·紫
    ['#4ade80', '#2dd4bf'], // 夜间·绿
    ['#94a89a', '#6b7d8e'], // 素白·灰绿
    ['#b8a090', '#8a7e6a'], // 素白·暖灰
    ['#5c8a67', '#3a5a40'], // 森林·深绿
    ['#b89850', '#7a5a30'], // 森林·暖金
  ]

  private getGradient(): [string, string] {
    let hash = 0
    for (let i = 0; i < this.category.length; i++) {
      hash = ((hash << 5) - hash) + this.category.charCodeAt(i)
      hash |= 0
    }
    const idx = Math.abs(hash) % this.GRADIENTS.length
    return this.GRADIENTS[idx]
  }

  private truncate(text: string, maxLen: number): string {
    if (text.length <= maxLen) return text
    return text.substring(0, maxLen) + '…'
  }

  build() {
    Stack() {
      Column() {
        // ── 顶部：日期 + 分类标签 ──
        Row() {
          Text(this.date.length > 0 ? this.date : new Date().toLocaleDateString())
            .fontSize(9).fontColor('#FFFFFF').opacity(0.5)

          Blank()

          if (this.category.length > 0) {
            Text(this.category.split('·')[0])
              .fontSize(9).fontWeight(600).fontColor('#FFFFFF')
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
              .borderRadius(4).backgroundColor('rgba(255,255,255,0.2)')
          }
        }
        .width('100%').margin({ bottom: 8 })

        // ── 标题 ──
        Text(this.title)
          .fontSize(14).fontWeight(700).fontColor('#FFFFFF')
          .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(20)

        // ── 正文摘要 ──
        if (this.content.length > 0) {
          Text(this.truncate(this.content, 55))
            .fontSize(9).fontColor('#FFFFFF').opacity(0.6)
            .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(14)
            .margin({ top: 4 })
        }

        Blank()

        // ── 底部提示 ──
        Row() {
          Text('每日轮换 · 点击查看')
            .fontSize(8).fontColor('#FFFFFF').opacity(0.35)
          Blank()
        }.width('100%')
      }
      .width('100%').height('100%').padding(14)
    }
    .width('100%').height('100%').borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[this.getGradient()[0], 0.0], [this.getGradient()[1], 1.0]]
    })
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        uri: 'zhiyu://com.zhiyu.coldknowledge/card?id=' + this.cardId
      })
    })
  }
}