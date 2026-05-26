import { AppViewModel } from '../../model/AppViewModel'

const EMOJIS = ['🐼', '🐱', '🐶', '🦊', '🐸', '🐙', '🦉', '🐳', '🦋', '🌵']
const TEXT = '#3c3c50'
const WHITE_GLASS = 'rgba(255,255,255,0.7)'

@ComponentV2
export struct ProfileTab {
  @Require @Param vm: AppViewModel
  @Local showEmojiPicker: boolean = false
  @Local showNameEditor: boolean = false
  @Local tempName: string = ''
  private dotColors: string[] = ['#c5e8d5', '#dcd0f0', '#f8d8d4', '#d0e4f4', '#f8f0d0', '#f0d8e4']

  aboutToAppear(): void {
    this.vm.loadProfile()
    this.tempName = this.vm.profile.nickname
  }

  build() {
    Column() {
      Text('我的').fontSize(22).fontWeight(700).fontColor(TEXT)
        .width('100%').padding({ left: 20, top: 14, bottom: 14 })

      Text(this.vm.profile.emoji).fontSize(48)
        .onClick(() => { this.showEmojiPicker = !this.showEmojiPicker })

      if (this.showEmojiPicker) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(EMOJIS, (emoji: string) => {
            Text(emoji).fontSize(28).padding(6)
              .onClick(() => {
                this.vm.selectEmoji(emoji)
                this.showEmojiPicker = false
              })
          })
        }
        .width('88%').backgroundColor(WHITE_GLASS).borderRadius(14).padding(10).margin({ top: 8, bottom: 8 })
      }

      Row() {
        if (this.showNameEditor) {
          TextInput({ text: this.tempName })
            .fontSize(16).fontColor(TEXT).backgroundColor(WHITE_GLASS).borderRadius(8)
            .height(38).width(160).onChange((v: string) => { this.tempName = v }).layoutWeight(1)
          Button('保存').fontSize(12).fontColor('#fff').backgroundColor('#8c8cb0')
            .borderRadius(8).height(34).margin({ left: 10 })
            .onClick(() => {
              this.vm.saveProfileNickname(this.tempName)
              this.showNameEditor = false
            })
        } else {
          Text(this.vm.profile.nickname).fontSize(18).fontWeight(600).fontColor(TEXT)
          Text(' ✏️').fontSize(14).onClick(() => { this.showNameEditor = true })
        }
      }.margin({ top: 10, bottom: 20 })

      // ── 统计卡片 ──
      Row() {
        Column() {
          Text(`${this.vm.favCount}`).fontSize(26).fontWeight(700).fontColor(TEXT)
          Text('收藏').fontSize(12).fontColor('#999').margin({ top: 2 })
        }.width('45%')
        Divider().vertical(true).height(36).color('#e0ded8')
        Column() {
          Text(`${this.vm.likeCount}`).fontSize(26).fontWeight(700).fontColor(TEXT)
          Text('获赞').fontSize(12).fontColor('#999').margin({ top: 2 })
        }.width('45%')
      }
      .width('82%').justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: 14, bottom: 14 }).backgroundColor(WHITE_GLASS).borderRadius(16).margin({ bottom: 14 })

      // ── 知识领域 ──
      if (this.vm.categoryStats.length > 0) {
        Column() {
          Text('知识领域').fontSize(13).fontWeight(600).fontColor(TEXT).margin({ bottom: 10 })
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.vm.categoryStats.slice(0, 6), (item: [string, number], idx: number) => {
              Column() {
                Text(item[1].toString()).fontSize(18).fontWeight(700).fontColor(TEXT)
                Row() {
                  Circle({ width: 6, height: 6 }).fill(this.dotColors[idx % this.dotColors.length])
                  Text(item[0]).fontSize(10).fontColor('#999').maxLines(1).margin({ left: 3 })
                }.margin({ top: 4 })
              }
              .margin({ right: idx < 5 ? 16 : 0 })
            })
          }
          .width('100%')
        }
        .width('88%').padding(14).backgroundColor(WHITE_GLASS).borderRadius(14).margin({ bottom: 16 })
      }

      // ── 分类条形图 ──
      if (this.vm.categoryStats.length > 0) {
        Column() {
          Text('分类详情').fontSize(13).fontWeight(600).fontColor(TEXT).margin({ bottom: 8 })
          ForEach(this.vm.categoryStats.slice(0, 8), (item: [string, number]) => {
            Row() {
              Text(item[0]).fontSize(11).fontColor('#666').width(72).maxLines(1)
              Row() {
                Row()
                  .width(this.vm.getBarWidth(item[1])).height(12).borderRadius(6)
                  .linearGradient({ direction: GradientDirection.Right, colors: [['#c5e8d5', 0.0], ['#a0d4bc', 1.0]] })
              }
              .width('50%').height(12).backgroundColor('#f0f0f4').borderRadius(6)
              Text(item[1].toString()).fontSize(10).fontColor('#999').width(24).margin({ left: 6 })
            }
            .width('100%').margin({ bottom: 5 })
          })
        }
        .width('88%').padding(14).backgroundColor(WHITE_GLASS).borderRadius(14).margin({ bottom: 14 })
      }

      // ── 设置入口 ──
      Row() {
        Text('⚙ 设置').fontSize(13).fontColor('#888')
        Blank()
        Text('›').fontSize(16).fontColor('#ccc')
      }
      .width('88%').padding(14).backgroundColor(WHITE_GLASS).borderRadius(14).margin({ bottom: 10 })
      .onClick(() => {
        // 设置浮层（后续可扩展）
      })

      Text('知域 · 冷知识科普卡片').fontSize(11).fontColor('#bbb')
      Text('Version 1.0.0').fontSize(10).fontColor('#ddd').margin({ top: 2 })
    }
    .width('100%').height('100%')
  }
}
