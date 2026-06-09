import { DataLoader } from '../data/DataLoader'

// ═══════════════════════════════════════
// 车站选择器 — 输入 + 下拉自动补全
// ═══════════════════════════════════════

@ComponentV2
export struct StationPicker {
  @Param label: string = '车站'
  @Param value: string = ''
  @Event onChange?: (name: string) => void
  @Local inputText: string = ''
  @Local showDropdown: boolean = false
  @Local candidates: string[] = []
  private suppressNextChange: boolean = false
  private blurSync: boolean = false

  aboutToAppear(): void {
    this.inputText = this.value
  }

  @Monitor('value')
  onValueChange(): void {
    this.suppressNextChange = true
    this.inputText = this.value
    if (!this.blurSync) {
      this.showDropdown = false
    }
    this.blurSync = false
    this.candidates = []
  }

  private onInputChange(text: string): void {
    if (this.suppressNextChange) {
      this.suppressNextChange = false
      return
    }
    this.inputText = text
    if (text.trim().length > 0) {
      this.candidates = DataLoader.searchStations(text.trim(), 8)
      this.showDropdown = this.candidates.length > 0
    } else {
      this.candidates = []
      this.showDropdown = false
    }
  }

  private selectStation(name: string): void {
    this.inputText = name
    this.showDropdown = false
    this.candidates = []
    this.onChange?.(name)
  }

  build() {
    Column() {
      Text(this.label)
        .fontSize(12).fontWeight(500)
        .fontColor('#666666')
        .margin({ bottom: 6 })

      TextInput({ text: this.inputText, placeholder: `输入${this.label}名称` })
        .width('100%').height(48)
        .fontSize(16)
        .borderRadius(10)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#E0E0E0' })
        .onChange((value: string) => { this.onInputChange(value) })
        .onFocus(() => {
          if (this.inputText.trim().length > 0) {
            this.candidates = DataLoader.searchStations(this.inputText.trim(), 8)
            this.showDropdown = this.candidates.length > 0
          }
        })
        .onBlur(() => {
          // 键盘收起时把当前文本同步给 ViewModel
          // blurSync 标志阻止 Monitor 关闭下拉列表
          setTimeout(() => {
            const text = this.inputText.trim()
            if (text.length > 0 && this.onChange) {
              this.blurSync = true
              this.onChange(text)
            }
          }, 150)
        })

      // 下拉列表
      if (this.showDropdown && this.candidates.length > 0) {
        Column() {
          ForEach(this.candidates, (name: string) => {
            Row() {
              Text(name)
                .fontSize(14).fontColor('#333333')
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
            }
            .width('100%')
            .onClick(() => { this.selectStation(name) })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#E8E8E8' })
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 4 })
        .margin({ top: 4 })
        .zIndex(100)
      }
    }
    .width('100%')
  }
}