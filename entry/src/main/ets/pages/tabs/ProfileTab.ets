import { AppViewModel } from '../../model/AppViewModel'
import { LocalStore, ReadHistoryEntry } from '../../data/LocalStore'

// ── 环形进度图 ──

@ComponentV2
struct RingChart {
  @Param progress: number = 0.7
  @Param color: string = '#5b8cbf'
  @Param centerText: string = '70%'
  @Param label: string = ''
  private circumference: number = 176

  build() {
    Column() {
      Stack() {
        Circle({ width: 56, height: 56 })
          .fill('none').stroke('#e8e4dc').strokeWidth(5)
        Circle({ width: 56, height: 56 })
          .fill('none').stroke(this.color).strokeWidth(5)
          .strokeLineCap(LineCapStyle.Round)
          .strokeDashArray([this.circumference])
          .strokeDashOffset(this.circumference * (1 - this.progress))
        Text(this.centerText).fontSize(16).fontWeight(700).fontColor(this.color)
      }
      .width(56).height(56)
      Text(this.label).fontSize(10).fontColor('#a09888').margin({ top: 6 })
    }
    .padding({ top: 14, bottom: 12, left: 12, right: 12 })
    .borderRadius(18).backgroundColor('#fffdf9')
    .shadow({ radius: 8, color: 'rgba(120,100,70,0.06)', offsetY: 2 })
    .border({ width: 1, color: 'rgba(255,255,255,0.5)' })
    .layoutWeight(1)
  }
}

// ═══════════════════════════════════════
// 我的页
// ═══════════════════════════════════════

@ComponentV2
export struct ProfileTab {
  @Require @Param vm: AppViewModel
  @Event onNavigateToTab?: (idx: number) => void
  @Event onNavigateToCard?: (cardId: string) => void
  @Local showHistory: boolean = false
  @Local deleteMode: boolean = false
  @Local selectedIds: string[] = []
  @Local showConfirm: boolean = false

  aboutToAppear(): void {
    this.vm.loadProfile()
    this.vm.loadReadHistory()
  }

  isSelected(cardId: string): boolean {
    return this.selectedIds.indexOf(cardId) >= 0
  }
  toggleSelect(cardId: string): void {
    const idx = this.selectedIds.indexOf(cardId)
    if (idx >= 0) { this.selectedIds.splice(idx, 1) }
    else { this.selectedIds.push(cardId) }
  }
  confirmDelete(): void {
    for (const id of this.selectedIds) { this.vm.deleteFromHistory(id) }
    this.selectedIds = []; this.deleteMode = false; this.showConfirm = false
  }

  @Builder HistoryRow(entry: ReadHistoryEntry, idx: number) {
    Row() {
      Column() {
        Text(LocalStore.getCard(entry.cardId)?.title || '(已删除)')
          .fontSize(15).fontWeight(700).fontColor(this.vm.getCardGradient(idx % 6).titleColor)
          .lineHeight(21).maxLines(2).width('100%')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(new Date(entry.readAt).toLocaleString())
          .fontSize(11).fontWeight(400).fontColor(this.vm.getCardGradient(idx % 6).accentColor).margin({ top: 4 })
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

      if (this.deleteMode) {
        Button() {
          Circle({ width: 20, height: 20 })
            .fill(this.isSelected(entry.cardId) ? '#F87171' : 'none')
            .stroke(this.isSelected(entry.cardId) ? '#F87171' : '#D1D5DB').strokeWidth(2)
        }
        .width(28).height(28).backgroundColor(Color.Transparent)
        .onClick(() => { this.toggleSelect(entry.cardId) })
      }
    }
    .width('100%').padding(16).borderRadius(20)
    .linearGradient({ angle: 112, colors: [[this.vm.getCardGradient(idx % 6).gradientStart, 0.0], [this.vm.getCardGradient(idx % 6).gradientEnd + 'CC', 1.0]] })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
    .border({ width: 1, color: this.vm.getCardGradient(idx % 6).borderColor })
    .margin({ bottom: 10 })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => { this.deleteMode = true; this.toggleSelect(entry.cardId) })
    )
    .onClick(() => {
      if (!this.deleteMode) { this.onNavigateToCard?.(entry.cardId) }
    })
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          // ── 渐变头部 ──
          this.buildHeader()
          // ── 统计卡片 ──
          this.buildStats()
          // ── 环形图 ──
          this.buildRings()
          // ── 设置 ──
          this.buildSettings()
        }.width('100%')
      }.width('100%')

      // ── 历史覆盖层 ──
      if (this.showHistory) {
        this.buildHistoryOverlay()
      }
    }
    .width('100%').height('100%')
  }

  @Builder buildHeader() {
    Stack() {
      Column() {
        Stack() {
          Circle({ width: 72, height: 72 }).fill('none').stroke('rgba(255,255,255,0.2)').strokeWidth(3)
          Circle({ width: 72, height: 72 }).fill('none').stroke('rgba(255,255,255,0.5)').strokeWidth(3)
            .strokeLineCap(LineCapStyle.Round).strokeDashArray([226]).strokeDashOffset(56)
          Text(this.vm.profile.emoji || '🐼').fontSize(32)
        }.width(72).height(72).margin({ bottom: 12 })
        Text(this.vm.profile.nickname || '知小域').fontSize(22).fontWeight(700).fontColor('#FFFFFF').letterSpacing(1.2)
        Text('好奇心是最好的老师').fontSize(13).fontWeight(300).fontColor('rgba(255,255,255,0.75)').margin({ top: 4 })
      }
      .width('100%').padding({ top: 28, bottom: 36, left: 24, right: 24 })
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .linearGradient({ angle: 155, colors: [['#d4855e',0],['#c97a6a',0.15],['#b8686e',0.3],['#9b5e78',0.5],['#7d5588',0.7],['#6b4d92',1]] })
  }

  @Builder buildStats() {
    Row() {
      Column() {
        Text(`${this.vm.readCount}`).fontSize(24).fontWeight(700).fontColor('#3a3028')
        Text('已阅读').fontSize(11).fontColor('#a09888').margin({ top: 2 })
      }.layoutWeight(1).onClick(() => { this.vm.loadReadHistory(); this.showHistory = true })
      Row().width(1).height(32).backgroundColor('#e8e4dc')
      Column() {
        Text(`${this.vm.favCount}`).fontSize(24).fontWeight(700).fontColor('#3a3028')
        Text('已收藏').fontSize(11).fontColor('#a09888').margin({ top: 2 })
      }.layoutWeight(1).onClick(() => { this.onNavigateToTab?.(1) })
      Row().width(1).height(32).backgroundColor('#e8e4dc')
      Column() {
        Text('7').fontSize(24).fontWeight(700).fontColor('#3a3028')
        Text('连续天数').fontSize(11).fontColor('#a09888').margin({ top: 2 })
      }.layoutWeight(1)
    }
    .width('calc(100% - 32px)').padding({ top: 10, bottom: 10, left: 8, right: 8 })
    .borderRadius(20).backgroundColor('#fffdf9')
    .shadow({ radius: 20, color: 'rgba(120,100,70,0.08)', offsetY: 4 })
    .border({ width: 1, color: 'rgba(255,255,255,0.6)' })
    .offset({ x: 0, y: -18 })
  }

  @Builder buildRings() {
    Column() {
      Row() { Text('阅读统计').fontSize(13).fontWeight(600).fontColor('#6b6358') }
        .width('100%').padding({ left: 16, top: 4, bottom: 12 })
      Row() {
        RingChart({ progress: 0.7, color: '#5b8cbf', centerText: '70%', label: '已阅读' })
        RingChart({ progress: 0.46, color: '#c4945a', centerText: '46%', label: '收藏率' }).margin({ left: 10, right: 10 })
        RingChart({ progress: 0.86, color: '#6b9e78', centerText: '6/7', label: '本周活跃' })
      }.width('100%').padding({ left: 16, right: 16 })
    }.width('100%')
  }

  @Builder buildSettings() {
    Column() {
      Text('偏好设置').fontSize(12).fontWeight(600).fontColor('#9CA3AF').width('100%').padding({ left: 16, top: 20, bottom: 8 })
      this.settingRow('🎨', '#f0e6f4', '卡片配色主题', true)
      this.settingRow('🔔', '#e6f0e6', '每日推送提醒', false)
      this.settingRow('🎚', '#f6f0e0', '知识难度偏好', true)
      Text('关于').fontSize(12).fontWeight(600).fontColor('#9CA3AF').width('100%').padding({ left: 16, top: 16, bottom: 8 })
      this.settingRow('ℹ', '#f4e6e4', '关于知域', true)
    }.width('100%').margin({ bottom: 16 })
  }

  @Builder settingRow(icon: string, iconBg: string, label: string, showChevron: boolean) {
    Row() {
      Row() { Text(icon).fontSize(14) }
        .width(28).height(28).borderRadius(10).backgroundColor(iconBg).justifyContent(FlexAlign.Center)
      Text(label).fontSize(15).fontWeight(500).fontColor('#2a2520').margin({ left: 12 })
      Blank()
      if (showChevron) { Text('›').fontSize(16).fontColor('#a09888') }
      if (!showChevron) {
        Row().width(44).height(24).borderRadius(12).backgroundColor('#7dbe7d').justifyContent(FlexAlign.End).padding({ left: 2, right: 2 })
      }
    }
    .width('calc(100% - 32px)').padding(14).borderRadius(16)
    .backgroundColor('#fffdf9').shadow({ radius: 8, color: 'rgba(120,100,70,0.04)', offsetY: 2 })
    .margin({ bottom: 8 })
  }

  @Builder buildHistoryOverlay() {
    Column() {
      // 标题栏：← 返回 | 阅读历史 | 管理
      Row() {
        Button() {
          Image($r('app.media.chevronleft')).width(18).height(18)
        }
        .width(32).height(32).backgroundColor(Color.Transparent)
        .onClick(() => { this.showHistory = false; this.deleteMode = false; this.selectedIds = [] })

        Text('阅读历史').fontSize(20).fontWeight(700).fontColor('#1F2937').margin({ left: 8 })
        Blank()
        Row() {
          Image($r('app.media.pencil')).width(14).height(14)
          Text(this.deleteMode ? '完成' : '管理').fontSize(13).fontWeight(500)
            .fontColor('#6B7280').margin({ left: 4 })
        }
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .borderRadius(16).backgroundColor(this.deleteMode ? 'rgba(239,68,68,0.08)' : '#F3F4F6')
        .onClick(() => { this.deleteMode = !this.deleteMode; this.selectedIds = [] })
      }.width('100%').padding({ left: 12, right: 12, top: 12, bottom: 8 })

      if (this.deleteMode) {
        Text('点击条目右侧圆圈选择').fontSize(11).fontColor('#F87171')
          .width('100%').padding({ left: 16, bottom: 4 })
      }

      Scroll() {
        Column() {
          if (this.vm.readHistory.length === 0) {
            Text('暂无阅读记录').fontSize(14).fontColor('#9CA3AF').width('100%').textAlign(TextAlign.Center).margin({ top: 40 })
          }
          ForEach(this.vm.readHistory.slice().reverse(), (entry: ReadHistoryEntry, idx: number) => {
            this.HistoryRow(entry, idx)
          })
        }.width('100%').padding({ left: 12, right: 12 })
      }.width('100%').layoutWeight(1)

      // 底部删除栏
      if (this.deleteMode && this.selectedIds.length > 0) {
        Row() {
          Text(`已选 ${this.selectedIds.length} 项`).fontSize(14).fontColor('#6B7280')
          Blank()
          Button(`删除 (${this.selectedIds.length})`)
            .fontSize(14).fontColor('#FFFFFF').fontWeight(600)
            .padding({ left: 20, right: 20 }).height(40).borderRadius(20)
            .backgroundColor('#F87171')
            .onClick(() => { this.showConfirm = true })
        }
        .width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor('rgba(255,255,255,0.95)').backdropBlur(12)
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: -2 })
      }
    }
    .width('100%').height('100%').backgroundColor('#f5f4f0').position({ x: 0, y: 0 })

    // 确认删除弹窗
    if (this.showConfirm) {
      Column() {
        Column() {
          Text('确认删除').fontSize(18).fontWeight(700).fontColor('#1F2937').margin({ bottom: 8 })
          Text(`确定要删除选中的 ${this.selectedIds.length} 条阅读记录吗？`)
            .fontSize(14).fontColor('#6B7280').textAlign(TextAlign.Center).margin({ bottom: 20 })
          Row() {
            Button('取消')
              .fontSize(14).fontColor('#6B7280').layoutWeight(1).height(40)
              .backgroundColor('#F3F4F6').borderRadius(20)
              .onClick(() => { this.showConfirm = false })
            Button('确定删除')
              .fontSize(14).fontColor('#FFFFFF').layoutWeight(1).height(40)
              .backgroundColor('#F87171').borderRadius(20).margin({ left: 12 })
              .onClick(() => { this.confirmDelete() })
          }.width('100%')
        }
        .width('80%').padding(24).borderRadius(20).backgroundColor('#FFFFFF')
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
      .onClick(() => { this.showConfirm = false })
    }
  }
}
