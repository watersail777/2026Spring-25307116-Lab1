import { UserProfile } from '../model/KnowledgeItem'
import { LocalStore } from '../data/LocalStore'

const EMOJIS = ['🐼', '🐱', '🐶', '🦊', '🐸', '🐙', '🦉', '🐳', '🦋', '🌵']

@Entry
@Component
struct ProfilePage {
  @State profile: UserProfile = new UserProfile()
  @State showEmojiPicker: boolean = false
  @State showNameEditor: boolean = false
  @State tempName: string = ''
  @State favCount: number = 0
  @State likeCount: number = 0

  async aboutToAppear(): Promise<void> {
    this.profile = await LocalStore.getProfile()
    this.tempName = this.profile.nickname
    const favIds = await LocalStore.getFavoriteIds()
    this.favCount = favIds.length
    const cards = await LocalStore.getAllCards()
    this.likeCount = cards.reduce((s, c) => s + c.likeCount, 0)
  }

  async selectEmoji(emoji: string): Promise<void> {
    this.profile.emoji = emoji
    this.showEmojiPicker = false
    await LocalStore.saveProfile(this.profile)
  }

  async saveNickname(): Promise<void> {
    this.profile.nickname = this.tempName || '知域用户'
    this.showNameEditor = false
    await LocalStore.saveProfile(this.profile)
  }

  build() {
    Column() {
      Text('我的').fontSize(22).fontWeight(700).fontColor('#FFFFFF')
        .width('100%').padding({ left: 24, top: 16, bottom: 16 })

      Text(this.profile.emoji).fontSize(56)
        .onClick(() => { this.showEmojiPicker = !this.showEmojiPicker })

      if (this.showEmojiPicker) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(EMOJIS, (emoji: string) => {
            Text(emoji).fontSize(32).padding(8)
              .onClick(() => { this.selectEmoji(emoji) })
          })
        }
        .width('90%')
        .backgroundColor('#FFFFFF10').borderRadius(16).padding(12).margin({ top: 8, bottom: 8 })
      }

      Row() {
        if (this.showNameEditor) {
          TextInput({ text: this.tempName })
            .fontSize(18).fontColor('#FFFFFF').backgroundColor('#FFFFFF15')
            .borderRadius(8).height(40).width(180)
            .onChange((v: string) => { this.tempName = v }).layoutWeight(1)
          Button('保存').fontSize(13).fontColor('#FFFFFF').backgroundColor('#667eea')
            .borderRadius(8).height(36).margin({ left: 12 })
            .onClick(() => { this.saveNickname() })
        } else {
          Text(this.profile.nickname).fontSize(20).fontWeight(600).fontColor('#FFFFFF')
          Text(' ✏️').fontSize(16).onClick(() => { this.showNameEditor = true })
        }
      }.margin({ top: 12, bottom: 24 })

      Row() {
        Column() {
          Text(`${this.favCount}`).fontSize(28).fontWeight(700).fontColor('#FFFFFF')
          Text('收藏').fontSize(13).fontColor('#AAAAAA').margin({ top: 4 })
        }.width('40%')
        Divider().vertical(true).height(40).color('#FFFFFF20')
        Column() {
          Text(`${this.likeCount}`).fontSize(28).fontWeight(700).fontColor('#FFFFFF')
          Text('获赞').fontSize(13).fontColor('#AAAAAA').margin({ top: 4 })
        }.width('40%')
      }
      .width('80%').justifyContent(FlexAlign.SpaceEvenly)
      .padding({ top: 16, bottom: 16 }).backgroundColor('#FFFFFF08')
      .borderRadius(16).margin({ bottom: 24 })

      Text('关于知域').fontSize(14).fontColor('#AAAAAA').margin({ bottom: 8 })
      Text('冷知识科普卡片 · 碰一碰交换 · 附近圈分享').fontSize(12).fontColor('#777')
      Text('Version 1.0.0').fontSize(12).fontColor('#555').margin({ top: 4 })
    }
    .width('100%').height('100%').backgroundColor('#1A1A2E')
  }
}
