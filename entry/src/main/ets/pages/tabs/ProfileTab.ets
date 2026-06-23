import { AppViewModel, CardGradient } from '../../model/AppViewModel'
import { LocalStore, ReadHistoryEntry } from '../../data/LocalStore'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

@ComponentV2
struct RingChart {
  @Param progress: number = 0.7
  @Param color: string = '#5b8cbf'
  @Param bgColor: string = '#e8e4dc'
  @Param panelBg: string = '#fffdf9'
  @Param labelColor: string = '#a09888'
  @Param centerText: string = '70%'
  @Param label: string = ''
  private circumference: number = 176

  build() {
    Column() {
      Stack() {
        Circle({ width: 56, height: 56 }).fill('none').stroke(this.bgColor).strokeWidth(5)
        Circle({ width: 56, height: 56 }).fill('none').stroke(this.color).strokeWidth(5)
          .strokeLineCap(LineCapStyle.Round)
          .strokeDashArray([this.circumference]).strokeDashOffset(this.circumference * (1 - this.progress))
        Text(this.centerText).fontSize(16).fontWeight(700).fontColor(this.color)
      }.width(56).height(56)
      Text(this.label).fontSize(10).fontColor(this.labelColor).margin({ top: 6 })
    }
    .padding({ top: 14, bottom: 12, left: 12, right: 12 }).borderRadius(18).backgroundColor(this.panelBg)
    .shadow({ radius: 8, color: 'rgba(120,100,70,0.06)', offsetY: 2 })
    .border({ width: 1, color: 'rgba(255,255,255,0.5)' }).layoutWeight(1)
  }
}

@ComponentV2
export struct ProfileTab {
  @Require @Param vm: AppViewModel
  @Param isTablet: boolean = false
  @Event onNavigateToTab?: (idx: number) => void
  @Event onNavigateToCard?: (cardId: string) => void
  @Local showHistory: boolean = false
  @Local deleteMode: boolean = false
  @Local selectedIds: string[] = []
  @Local showConfirm: boolean = false
  @Local dialogNick: boolean = false
  @Local dialogBio: boolean = false
  @Local dialogTheme: boolean = false
  @Local dialogAbout: boolean = false
  @Local dialogData: boolean = false
  @Local nickInput: string = ''
  @Local bioInput: string = ''

  aboutToAppear(): void {
    this.vm.loadProfile()
    this.vm.loadReadHistory()
    this.vm.refreshStats()
  }

  isSelected(cardId: string): boolean { return this.selectedIds.indexOf(cardId) >= 0 }
  toggleSelect(cardId: string): void {
    const idx = this.selectedIds.indexOf(cardId)
    if (idx >= 0) { this.selectedIds.splice(idx, 1) } else { this.selectedIds.push(cardId) }
  }
  confirmDelete(): void {
    for (const id of this.selectedIds) { this.vm.deleteFromHistory(id) }
    this.selectedIds = []; this.deleteMode = false; this.showConfirm = false
  }

  async pickAvatar(): Promise<void> {
    try {
      const p = new photoAccessHelper.PhotoViewPicker()
      const o = new photoAccessHelper.PhotoSelectOptions()
      o.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; o.maxSelectNumber = 1
      const r = await p.select(o)
      if (r.photoUris.length > 0) {
        this.vm.avatarUri = r.photoUris[0]; this.vm.profile.avatarUri = r.photoUris[0]
        LocalStore.saveProfile(this.vm.profile)
      }
    } catch (_e) { /* 用户取消 */ }
  }

  async pickBackground(): Promise<void> {
    try {
      const p = new photoAccessHelper.PhotoViewPicker()
      const o = new photoAccessHelper.PhotoSelectOptions()
      o.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; o.maxSelectNumber = 1
      const r = await p.select(o)
      if (r.photoUris.length > 0) {
        this.vm.bgUri = r.photoUris[0]; this.vm.profile.bgUri = r.photoUris[0]
        LocalStore.saveProfile(this.vm.profile)
      }
    } catch (_e) { /* 用户取消 */ }
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          this.buildHeader()
          this.buildStats()
          this.buildRings()
          this.buildSettings()
        }.width('100%')
      }.width('100%')

      if (this.showHistory) { this.buildHistoryOverlay() }

      if (this.dialogNick) { this.nickDialog() }
      if (this.dialogBio) { this.bioDialog() }
      if (this.dialogTheme) { this.themeDialog() }
      if (this.dialogAbout) { this.aboutDialog() }
      if (this.dialogData) { this.dataDialog() }
    }
    .width('100%').height('100%')
  }

  @Builder buildHeader() {
    Stack() {
      if (this.vm.bgUri.length > 0) {
        Image(this.vm.bgUri).width('100%').height('100%').objectFit(ImageFit.Cover)
        Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.4)').hitTestBehavior(HitTestMode.None)
      }
      Column() {
        Stack() {
          Circle({ width: 72, height: 72 }).fill('none').stroke('rgba(255,255,255,0.2)').strokeWidth(3)
          Circle({ width: 72, height: 72 }).fill('none').stroke('rgba(255,255,255,0.5)').strokeWidth(3)
            .strokeLineCap(LineCapStyle.Round).strokeDashArray([226]).strokeDashOffset(56)
          if (this.vm.avatarUri.length > 0) {
            Image(this.vm.avatarUri).width(64).height(64).borderRadius(32).objectFit(ImageFit.Cover)
          } else { Text(this.vm.profile.emoji || '🐼').fontSize(32) }
        }.width(72).height(72).margin({ bottom: 12 }).onClick(() => { this.pickAvatar() })
        Row() {
          Text(this.vm.profile.nickname || '知小域').fontSize(22).fontWeight(700).fontColor('#FFFFFF').letterSpacing(1.2)
          Image($r('app.media.pencil')).width(14).height(14).fillColor('rgba(255,255,255,0.6)').margin({ left: 8 })
        }.onClick(() => { this.nickInput = this.vm.profile.nickname; this.dialogNick = true })
        Row() {
          Text(this.vm.profile.bio || '好奇心是最好的老师').fontSize(13).fontWeight(300).fontColor('rgba(255,255,255,0.75)')
          Image($r('app.media.pencil')).width(12).height(12).fillColor('rgba(255,255,255,0.4)').margin({ left: 6 })
        }.margin({ top: 4 }).onClick(() => { this.bioInput = this.vm.profile.bio; this.dialogBio = true })
        Row() {
          Text('📷 更换背景').fontSize(12).fontColor('rgba(255,255,255,0.7)')
        }.margin({ top: 8 })
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .borderRadius(12).backgroundColor('rgba(255,255,255,0.15)')
        .onClick(() => { this.pickBackground() })
      }
      .width('100%').padding({ top: 28, bottom: 36, left: 24, right: 24 })
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    }
    .width('100%').height(240).clip(true)
    .linearGradient({ angle: 155, colors: this.vm.getProfileHeaderGradient() })
  }

  @Builder buildStats() {
    Row() {
      Column() {
        Text(`${this.vm.readCount}`).fontSize(24).fontWeight(700).fontColor(this.vm.getProfileTitleColor())
        Text('已阅读').fontSize(11).fontColor(this.vm.getProfileBodyColor()).margin({ top: 2 })
      }.layoutWeight(1).onClick(() => { this.vm.loadReadHistory(); this.showHistory = true })
      Row().width(1).height(32).backgroundColor(this.vm.getProfileDividerColor())
      Column() {
        Text(`${this.vm.favCount}`).fontSize(24).fontWeight(700).fontColor(this.vm.getProfileTitleColor())
        Text('已收藏').fontSize(11).fontColor(this.vm.getProfileBodyColor()).margin({ top: 2 })
      }.layoutWeight(1).onClick(() => { this.onNavigateToTab?.(1) })
      Row().width(1).height(32).backgroundColor(this.vm.getProfileDividerColor())
      Column() {
        Text(`${this.vm.streak}`).fontSize(24).fontWeight(700).fontColor(this.vm.getProfileTitleColor())
        Text('连续天数').fontSize(11).fontColor(this.vm.getProfileBodyColor()).margin({ top: 2 })
      }.layoutWeight(1)
    }
    .width('calc(100% - 32px)').padding({ top: 10, bottom: 10, left: 8, right: 8 })
    .borderRadius(20).backgroundColor(this.vm.getProfilePanelBg())
    .shadow({ radius: 20, color: 'rgba(120,100,70,0.08)', offsetY: 4 })
    .border({ width: 1, color: 'rgba(255,255,255,0.6)' }).offset({ x: 0, y: -18 })
  }

  @Builder buildRings() {
    Column() {
      Row() { Text('阅读统计').fontSize(13).fontWeight(600).fontColor(this.vm.getProfileTitleColor()) }
        .width('100%').padding({ left: 16, top: 4, bottom: 12 })
      Row() {
        RingChart({
          progress: this.vm.readPercent, color: this.vm.getRingColors()[0],
          bgColor: this.vm.getRingBgColor(), panelBg: this.vm.getProfilePanelBg(),
          labelColor: this.vm.getProfileBodyColor(),
          centerText: Math.round(this.vm.readPercent*100)+'%', label: '已阅读' })
        RingChart({
          progress: this.vm.favPercent, color: this.vm.getRingColors()[1],
          bgColor: this.vm.getRingBgColor(), panelBg: this.vm.getProfilePanelBg(),
          labelColor: this.vm.getProfileBodyColor(),
          centerText: Math.round(this.vm.favPercent*100)+'%', label: '收藏率' }).margin({ left: 10, right: 10 })
        RingChart({
          progress: this.vm.weeklyDays/7, color: this.vm.getRingColors()[2],
          bgColor: this.vm.getRingBgColor(), panelBg: this.vm.getProfilePanelBg(),
          labelColor: this.vm.getProfileBodyColor(),
          centerText: this.vm.weeklyDays+'/7', label: '本周活跃' })
      }.width('100%').padding({ left: 16, right: 16 })
    }.width('100%')
  }

  @Builder buildSettings() {
    Column() {
      Text('偏好设置').fontSize(12).fontWeight(600).fontColor(this.vm.getProfileBodyColor()).width('100%').padding({ left: 16, top: 20, bottom: 8 })
      // 卡片配色主题
      Row() {
        Row() {
          Image($rawfile('icon_palette.svg')).width(18).height(18).fillColor(this.vm.getRingColors()[0])
        }.width(28).height(28).borderRadius(10).backgroundColor(this.vm.getRingColors()[0] + '20').justifyContent(FlexAlign.Center)
        Text('卡片配色主题').fontSize(15).fontWeight(500).fontColor(this.vm.getProfileTitleColor()).margin({ left: 12 })
        Blank()
        Text(this.vm.selectedTheme).fontSize(12).fontColor(this.vm.getProfileBodyColor())
        Text('›').fontSize(16).fontColor(this.vm.getProfileBodyColor()).margin({ left: 4 })
      }
      .width('calc(100% - 32px)').padding(14).borderRadius(16).backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 8, color: 'rgba(120,100,70,0.04)', offsetY: 2 }).margin({ bottom: 8 })
      .onClick(() => { this.dialogTheme = true })
      // 震动反馈
      Row() {
        Row() {
          Image($rawfile('icon_activity.svg')).width(18).height(18).fillColor(this.vm.vibrateEnabled ? this.vm.getRingColors()[1] : this.vm.getProfileBodyColor())
        }.width(28).height(28).borderRadius(10).backgroundColor(this.vm.getRingColors()[1] + '20').justifyContent(FlexAlign.Center)
        Text('震动反馈').fontSize(15).fontWeight(500).fontColor(this.vm.getProfileTitleColor()).margin({ left: 12 })
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.vm.vibrateEnabled })
          .onChange((val: boolean) => {
            this.vm.vibrateEnabled = val
            LocalStore.saveVibrateEnabled(val)
          })
          .selectedColor(this.vm.getRingColors()[1])
          .switchPointColor('#FFFFFF')
      }
      .width('calc(100% - 32px)').padding(14).borderRadius(16).backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 8, color: 'rgba(120,100,70,0.04)', offsetY: 2 }).margin({ bottom: 8 })
      // 数据管理
      this.settingRow($rawfile('icon_database.svg'), this.vm.getRingColors()[2] + '20', '数据管理', true, () => { this.dialogData = true })
      Text('关于').fontSize(12).fontWeight(600).fontColor(this.vm.getProfileBodyColor()).width('100%').padding({ left: 16, top: 16, bottom: 8 })
      // 关于知域
      this.settingRow($rawfile('icon_info.svg'), this.vm.getRingColors()[0] + '20', '关于知域', true, () => { this.dialogAbout = true })
    }.width('100%').margin({ bottom: 16 })
  }

  @Builder settingRow(icon: ResourceStr, iconBg: string, label: string, showChevron: boolean, onTap?: () => void) {
    Row() {
      Row() {
        Image(icon).width(18).height(18).fillColor(this.vm.getRingColors()[0])
      }.width(28).height(28).borderRadius(10).backgroundColor(iconBg).justifyContent(FlexAlign.Center)
      Text(label).fontSize(15).fontWeight(500).fontColor(this.vm.getProfileTitleColor()).margin({ left: 12 })
      Blank()
      if (showChevron) { Text('›').fontSize(16).fontColor(this.vm.getProfileBodyColor()) }
      if (!showChevron) {
        Row().width(44).height(24).borderRadius(12).backgroundColor(this.vm.getRingColors()[1]).justifyContent(FlexAlign.End).padding({ left: 2, right: 2 })
      }
    }
    .width('calc(100% - 32px)').padding(14).borderRadius(16).backgroundColor(this.vm.getProfilePanelBg())
    .shadow({ radius: 8, color: 'rgba(120,100,70,0.04)', offsetY: 2 }).margin({ bottom: 8 })
    .onClick(() => { onTap?.() })
  }

  @Builder buildHistoryOverlay() {
    Column() {
      Row() {
        Button() { Image($r('app.media.chevronleft')).width(18).height(18) }.width(32).height(32).backgroundColor(Color.Transparent)
          .onClick(() => { this.showHistory = false; this.deleteMode = false; this.selectedIds = [] })
        Text('阅读历史').fontSize(20).fontWeight(700).fontColor(this.vm.getProfileTitleColor()).margin({ left: 8 })
        Blank()
        Row() {
          Image($r('app.media.pencil')).width(14).height(14)
          Text(this.deleteMode ? '完成' : '管理').fontSize(13).fontWeight(500).fontColor('#6b6358').margin({ left: 4 })
        }
        .padding({ left: 14, right: 14, top: 6, bottom: 6 }).borderRadius(16)
        .backgroundColor(this.deleteMode ? 'rgba(239,68,68,0.08)' : '#e8e4dc')
        .onClick(() => { this.deleteMode = !this.deleteMode; this.selectedIds = [] })
      }.width('100%').padding({ left: 12, right: 12, top: 12, bottom: 8 })
      if (this.deleteMode) {
        Text('点击条目右侧圆圈选择').fontSize(11).fontColor('#F87171').width('100%').padding({ left: 16, bottom: 4 })
      }
      Scroll() {
        Column() {
          if (this.vm.readHistory.length === 0) {
            Text('暂无阅读记录').fontSize(14).fontColor('#9CA3AF').width('100%').textAlign(TextAlign.Center).margin({ top: 40 })
          }
          ForEach(this.vm.readHistory.slice().reverse(), (entry: ReadHistoryEntry, idx: number) => { this.HistoryRow(entry, idx) })
        }.width('100%').padding({ left: 12, right: 12 })
      }.width('100%').layoutWeight(1)
      if (this.deleteMode && this.selectedIds.length > 0) {
        Row() {
          Text(`已选 ${this.selectedIds.length} 项`).fontSize(14).fontColor('#6b6358')
          Blank()
          Button(`删除 (${this.selectedIds.length})`).fontSize(14).fontColor('#FFFFFF').fontWeight(600)
            .padding({ left: 20, right: 20 }).height(40).borderRadius(20).backgroundColor('#F87171')
            .onClick(() => { this.showConfirm = true })
        }.width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor(this.vm.getProfilePanelBg()).backdropBlur(12).shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: -2 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F0').position({ x: 0, y: 0 })
    if (this.showConfirm) {
      Column() {
        Column() {
          Text('确认删除').fontSize(18).fontWeight(700).fontColor(this.vm.getProfileTitleColor()).margin({ bottom: 8 })
          Text(`确定要删除选中的 ${this.selectedIds.length} 条阅读记录吗？`).fontSize(14).fontColor(this.vm.getProfileBodyColor()).textAlign(TextAlign.Center).margin({ bottom: 20 })
          Row() {
            Button('取消').fontSize(14).fontColor(this.vm.getProfileBodyColor()).layoutWeight(1).height(40).backgroundColor(this.vm.getProfileDividerColor()).borderRadius(20)
              .onClick(() => { this.showConfirm = false })
            Button('确定删除').fontSize(14).fontColor('#FFFFFF').layoutWeight(1).height(40).backgroundColor('#F87171').borderRadius(20).margin({ left: 12 })
              .onClick(() => { this.confirmDelete() })
          }.width('100%')
        }.width('80%').padding(24).borderRadius(20).backgroundColor(this.vm.getProfilePanelBg())
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
      .onClick(() => { this.showConfirm = false })
    }
  }

  @Builder nickDialog() {
    Column() {
      Column() {
        Text('修改昵称').fontSize(18).fontWeight(700).fontColor(this.vm.getProfileTitleColor()).margin({ bottom: 16 })
        TextInput({ text: this.nickInput }).width('100%').height(44).borderRadius(12)
          .backgroundColor(this.vm.getProfileDividerColor()).padding({ left: 12, right: 12 })
          .onChange((v: string) => { this.nickInput = v })
        Row() {
          Button('取消').fontSize(14).fontColor(this.vm.getProfileBodyColor()).layoutWeight(1).height(40).backgroundColor(this.vm.getProfileDividerColor()).borderRadius(20)
            .onClick(() => { this.dialogNick = false })
          Button('保存').fontSize(14).fontColor('#FFFFFF').layoutWeight(1).height(40).backgroundColor(this.vm.getRingColors()[0]).borderRadius(20).margin({ left: 12 })
            .onClick(() => {
              if (this.nickInput.trim().length > 0) { this.vm.profile.nickname = this.nickInput.trim(); LocalStore.saveProfile(this.vm.profile) }
              this.dialogNick = false
            })
        }.width('100%').margin({ top: 16 })
      }.width('80%').padding(24).borderRadius(20).backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
  }

  @Builder bioDialog() {
    Column() {
      Column() {
        Text('修改签名').fontSize(18).fontWeight(700).fontColor(this.vm.getProfileTitleColor()).margin({ bottom: 16 })
        TextInput({ text: this.bioInput }).width('100%').height(44).borderRadius(12)
          .backgroundColor(this.vm.getProfileDividerColor()).padding({ left: 12, right: 12 })
          .onChange((v: string) => { this.bioInput = v })
        Row() {
          Button('取消').fontSize(14).fontColor(this.vm.getProfileBodyColor()).layoutWeight(1).height(40).backgroundColor(this.vm.getProfileDividerColor()).borderRadius(20)
            .onClick(() => { this.dialogBio = false })
          Button('保存').fontSize(14).fontColor('#FFFFFF').layoutWeight(1).height(40).backgroundColor(this.vm.getRingColors()[0]).borderRadius(20).margin({ left: 12 })
            .onClick(() => {
              if (this.bioInput.trim().length > 0) { this.vm.profile.bio = this.bioInput.trim(); LocalStore.saveProfile(this.vm.profile) }
              this.dialogBio = false
            })
        }.width('100%').margin({ top: 16 })
      }.width('80%').padding(24).borderRadius(20).backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
  }

  @Builder themeDialog() {
    Column() {
      Column() {
        Text('选择配色主题').fontSize(18).fontWeight(700).fontColor(this.vm.getProfileTitleColor()).margin({ bottom: 16 })
        Column() {
          ForEach(Object.keys(AppViewModel.THEMES), (name: string) => {
            Row() {
              ForEach(AppViewModel.THEMES[name], (g: CardGradient) => {
                Row().width(24).height(24).borderRadius(6).backgroundColor(g.accentColor).margin({ right: 4 })
              })
              Text(name).fontSize(15).fontWeight(name === this.vm.selectedTheme ? 700 : 400)
                .fontColor(name === this.vm.selectedTheme ? this.vm.getRingColors()[0] : this.vm.getProfileTitleColor()).margin({ left: 12 })
              Blank()
              if (name === this.vm.selectedTheme) { Text('✓').fontSize(16).fontColor(this.vm.getRingColors()[0]) }
            }
            .width('100%').padding(12).borderRadius(12)
            .backgroundColor(name === this.vm.selectedTheme ? this.vm.getRingColors()[0] + '18' : Color.Transparent)
            .margin({ bottom: 4 })
            .onClick(() => { this.vm.selectedTheme = name; LocalStore.saveTheme(name) })
          })
        }
        Button('关闭').fontSize(14).fontColor(this.vm.getProfileBodyColor()).width('100%').height(40)
          .backgroundColor(this.vm.getProfileDividerColor()).borderRadius(20).margin({ top: 12 })
          .onClick(() => { this.dialogTheme = false })
      }.width('85%').padding(24).borderRadius(20).backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
  }

  @Builder aboutDialog() {
    Column() {
      Column() {
        // 关闭按钮
        Row() {
          Blank()
          Button() { Text('✕').fontSize(16).fontColor(this.vm.getProfileBodyColor()) }
            .width(32).height(32).backgroundColor(Color.Transparent)
            .onClick(() => { this.dialogAbout = false })
        }.width('100%').margin({ bottom: 8 })

        // App 标识
        Text('知域').fontSize(28).fontWeight(700)
          .fontColor(this.vm.getProfileTitleColor())
        Text('ZhiYu · 冷知识科普').fontSize(13)
          .fontColor(this.vm.getProfileBodyColor()).margin({ top: 4, bottom: 20 })

        // 分隔线
        Row().width('60%').height(1).backgroundColor(this.vm.getProfileDividerColor()).margin({ bottom: 20 })

        // 版本信息
        this.aboutLine('版本', '1.2.0')
        this.aboutLine('构建', 'HarmonyOS NEXT · API 22')
        this.aboutLine('AI 引擎', 'DeepSeek + Vercel')
        this.aboutLine('设计', 'Soft Editorial')

        Row().height(16).width('100%')

        Text('好奇心是最好的老师')
          .fontSize(12).fontColor(this.vm.getProfileBodyColor()).opacity(0.6)

        Row().height(20).width('100%')

        Button('关闭').fontSize(14).fontColor('#FFFFFF')
          .width('60%').height(40).borderRadius(20)
          .backgroundColor(this.vm.getRingColors()[0])
          .onClick(() => { this.dialogAbout = false })
      }
      .width('82%').padding(28).borderRadius(24)
      .backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetY: 12 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
    .onClick(() => { this.dialogAbout = false })
  }

  @Builder aboutLine(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(this.vm.getProfileBodyColor()).opacity(0.7)
      Blank()
      Text(value).fontSize(14).fontWeight(500).fontColor(this.vm.getProfileTitleColor())
    }
    .width('100%').padding({ top: 6, bottom: 6 })
  }

  @Builder dataDialog() {
    Column() {
      Column() {
        Row() {
          Blank()
          Button() { Text('✕').fontSize(16).fontColor(this.vm.getProfileBodyColor()) }
            .width(32).height(32).backgroundColor(Color.Transparent)
            .onClick(() => { this.dialogData = false })
        }.width('100%').margin({ bottom: 4 })

        Text('数据管理').fontSize(20).fontWeight(700)
          .fontColor(this.vm.getProfileTitleColor()).margin({ bottom: 4 })
        Text('清除数据后不可恢复').fontSize(12)
          .fontColor('#F87171').margin({ bottom: 20 })

        // 清除阅读历史
        Row() {
          Column() {
            Text('清除阅读历史').fontSize(15).fontWeight(500).fontColor(this.vm.getProfileTitleColor())
            Text(`当前 ${this.vm.readCount} 条记录`).fontSize(12).fontColor(this.vm.getProfileBodyColor()).margin({ top: 2 })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          Button('清除').fontSize(13).fontColor('#F87171').height(34).padding({ left: 14, right: 14 })
            .backgroundColor('rgba(248,113,113,0.1)').borderRadius(12)
            .onClick(() => {
              LocalStore.clearReadHistory()
              this.vm.loadReadHistory()
              this.vm.refreshStats()
              this.dialogData = false
              this.vm.showToast('阅读历史已清除')
            })
        }.width('100%').padding(14).borderRadius(14)
        .backgroundColor(this.vm.getProfileDividerColor()).margin({ bottom: 10 })

        // 重置统计数据
        Row() {
          Column() {
            Text('重置统计数据').fontSize(15).fontWeight(500).fontColor(this.vm.getProfileTitleColor())
            Text('点赞、收藏、连续天数归零').fontSize(12).fontColor(this.vm.getProfileBodyColor()).margin({ top: 2 })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          Button('重置').fontSize(13).fontColor('#F87171').height(34).padding({ left: 14, right: 14 })
            .backgroundColor('rgba(248,113,113,0.1)').borderRadius(12)
            .onClick(() => {
              LocalStore.resetStats()
              this.vm.loadProfile()
              this.vm.loadFavorites()
              this.vm.refreshStats()
              this.dialogData = false
              this.vm.showToast('统计数据已重置')
            })
        }.width('100%').padding(14).borderRadius(14)
        .backgroundColor(this.vm.getProfileDividerColor())

        Row().height(20).width('100%')
        Button('关闭').fontSize(14).fontColor('#FFFFFF')
          .width('60%').height(40).borderRadius(20)
          .backgroundColor(this.vm.getRingColors()[0])
          .onClick(() => { this.dialogData = false })
      }
      .width('82%').padding(28).borderRadius(24)
      .backgroundColor(this.vm.getProfilePanelBg())
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetY: 12 })
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)').position({ x: 0, y: 0 })
    .onClick(() => { this.dialogData = false })
  }

  @Builder HistoryRow(entry: ReadHistoryEntry, idx: number) {
    Row() {
      Column() {
        Text(LocalStore.getCard(entry.cardId)?.title || '(已删除)')
          .fontSize(15).fontWeight(700).fontColor(this.vm.getCardGradient(idx % 6).titleColor)
          .lineHeight(21).maxLines(2).width('100%').textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(new Date(entry.readAt).toLocaleString())
          .fontSize(11).fontWeight(400).fontColor(this.vm.getCardGradient(idx % 6).accentColor).margin({ top: 4 })
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      if (this.deleteMode) {
        Button() {
          Circle({ width: 20, height: 20 })
            .fill(this.isSelected(entry.cardId) ? '#F87171' : 'none')
            .stroke(this.isSelected(entry.cardId) ? '#F87171' : '#D1D5DB').strokeWidth(2)
        }.width(28).height(28).backgroundColor(Color.Transparent).onClick(() => { this.toggleSelect(entry.cardId) })
      }
    }
    .width('100%').padding(16).borderRadius(20)
    .linearGradient({ angle: 112, colors: [[this.vm.getCardGradient(idx % 6).gradientStart, 0.0], [this.vm.getCardGradient(idx % 6).gradientEnd + 'CC', 1.0]] })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
    .border({ width: 1, color: this.vm.getCardGradient(idx % 6).borderColor }).margin({ bottom: 10 })
    .gesture(LongPressGesture({ repeat: false, duration: 500 })
      .onAction(() => { this.deleteMode = true; this.toggleSelect(entry.cardId) }))
    .onClick(() => { if (!this.deleteMode) { this.onNavigateToCard?.(entry.cardId) } })
  }
}
