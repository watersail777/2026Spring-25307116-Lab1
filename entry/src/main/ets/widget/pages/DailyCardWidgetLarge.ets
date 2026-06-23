@Entry
@Component
struct DailyCardWidgetLarge {
  @LocalStorageProp('title') title: string = '冷知识'
  @LocalStorageProp('content') content: string = '点击查看详情...'
  @LocalStorageProp('category') category: string = ''
  @LocalStorageProp('cardId') cardId: string = ''
  @LocalStorageProp('date') date: string = ''

  private readonly GRADIENTS: [string, string][] = [
    ['#c9a8d8', '#8870c8'],
    ['#7dbe7d', '#4a9e90'],
    ['#c084fc', '#6b4d92'],
    ['#4ade80', '#2dd4bf'],
    ['#94a89a', '#6b7d8e'],
    ['#b8a090', '#8a7e6a'],
    ['#5c8a67', '#3a5a40'],
    ['#b89850', '#7a5a30'],
  ]

  private getGradient(): [string, string] {
    let hash = 0
    for (let i = 0; i < this.category.length; i++) {
      hash = ((hash << 5) - hash) + this.category.charCodeAt(i)
      hash |= 0
    }
    return this.GRADIENTS[Math.abs(hash) % this.GRADIENTS.length]
  }

  build() {
    Stack() {
      Column() {
        // ── 顶部：日期 + Logo ──
        Row() {
          Text(this.date.length > 0 ? this.date : new Date().toLocaleDateString())
            .fontSize(9).fontColor('#FFFFFF').opacity(0.4)
          Blank()
          Text('知域')
            .fontSize(9).fontWeight(600).fontColor('#FFFFFF').opacity(0.45)
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .borderRadius(4).backgroundColor('rgba(255,255,255,0.12)')
        }
        .width('100%').margin({ bottom: 10 })

        // ── 分类标签 ──
        if (this.category.length > 0) {
          Text(this.category)
            .fontSize(10).fontWeight(600).fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(6).backgroundColor('rgba(255,255,255,0.2)')
            .margin({ bottom: 8 })
        }

        // ── 标题 ──
        Text(this.title)
          .fontSize(17).fontWeight(700).fontColor('#FFFFFF')
          .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(24)
          .margin({ bottom: 10 })

        // ── 正文 ──
        Text(this.content)
          .fontSize(12).fontColor('#FFFFFF').opacity(0.85)
          .maxLines(7).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(19)

        Blank()

        // ── 底部 ──
        Row() {
          Text('每日随机轮换 · 点击查看完整内容')
            .fontSize(9).fontColor('#FFFFFF').opacity(0.35)
          Blank()
        }.width('100%')
      }
      .width('100%').height('100%').padding(16)
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