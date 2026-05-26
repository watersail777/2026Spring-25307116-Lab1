const TEXT = '#3c3c50'
const TEXT_DIM = '#a0a0b0'

// ── 图标组件（纯矢量） ──

@Component
export struct IconDiscover {
  @Prop active: boolean = false
  build() {
    Stack() {
      Circle({ width: 14, height: 14 })
        .fill('none').stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.6)
      Line().width(6).height(0)
        .stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.6).strokeLineCap(LineCapStyle.Round)
        .position({ x: 12, y: 12 }).rotate({ angle: 45, centerX: 3, centerY: 0 })
    }.width(20).height(20)
  }
}

@Component
export struct IconFavorites {
  @Prop active: boolean = false
  build() {
    Path()
      .width(21).height(19)
      .commands('M10.5 18 C10.5 18 1 11.5 1 5.5 C1 2.5 3.5 0 6.5 0 C9 0 10.5 1.5 10.5 3 C10.5 1.5 12 0 14.5 0 C17.5 0 20 2.5 20 5.5 C20 11.5 10.5 18 10.5 18 Z')
      .fill(this.active ? '#e06060' : 'none')
      .stroke(this.active ? '#e06060' : '#bfbfcc').strokeWidth(1.5)
  }
}

@Component
export struct IconNearby {
  @Prop active: boolean = false
  build() {
    Stack() {
      Circle({ width: 17, height: 17 })
        .fill('none').stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(1.4)
      Line().width(14).height(0).position({ x: 1.5, y: 8.5 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.8).opacity(0.4)
      Line().width(10).height(0).position({ x: 3.5, y: 5 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.7).opacity(0.35)
      Line().width(10).height(0).position({ x: 3.5, y: 12 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.7).opacity(0.35)
      Line().width(0).height(12).position({ x: 8.5, y: 2.5 })
        .stroke(this.active ? '#5c8c80' : '#bfbfcc').strokeWidth(0.8).opacity(0.3)
    }.width(20).height(20)
  }
}

@Component
export struct IconProfile {
  @Prop active: boolean = false
  build() {
    Stack() {
      Circle({ width: 9, height: 9 })
        .fill('none').stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.5)
        .position({ x: 5.5, y: 0 })
      Path()
        .width(20).height(12)
        .commands('M0 22 Q2 10 10 11 Q18 10 20 22')
        .fill('none').stroke(this.active ? '#5c5c80' : '#bfbfcc').strokeWidth(1.5).strokeLineCap(LineCapStyle.Round)
        .position({ x: 0, y: 7 })
    }.width(20).height(20)
  }
}

// ── 底部导航栏 ──

@Component
export struct BottomNavBar {
  @Prop currentTab: number = 0
  onTabChange?: (idx: number) => void

  build() {
    Row() {
      Column() {
        if (this.currentTab === 0) {
          Circle({ width: 4, height: 4 }).fill('#8c8cb0').margin({ bottom: 4 })
        } else {
          Row().height(4).margin({ bottom: 4 })
        }
        IconDiscover({ active: this.currentTab === 0 })
        Text('发现').fontSize(10).fontWeight(this.currentTab === 0 ? 600 : 400)
          .fontColor(this.currentTab === 0 ? TEXT : TEXT_DIM).margin({ top: 2 })
      }
      .width('25%')
      .onClick(() => { this.onTabChange?.(0) })

      Column() {
        if (this.currentTab === 1) {
          Circle({ width: 4, height: 4 }).fill('#e06060').margin({ bottom: 4 })
        } else {
          Row().height(4).margin({ bottom: 4 })
        }
        IconFavorites({ active: this.currentTab === 1 })
        Text('收藏').fontSize(10).fontWeight(this.currentTab === 1 ? 600 : 400)
          .fontColor(this.currentTab === 1 ? TEXT : TEXT_DIM).margin({ top: 2 })
      }
      .width('25%')
      .onClick(() => { this.onTabChange?.(1) })

      Column() {
        if (this.currentTab === 2) {
          Circle({ width: 4, height: 4 }).fill('#5c8c80').margin({ bottom: 4 })
        } else {
          Row().height(4).margin({ bottom: 4 })
        }
        IconNearby({ active: this.currentTab === 2 })
        Text('附近圈').fontSize(10).fontWeight(this.currentTab === 2 ? 600 : 400)
          .fontColor(this.currentTab === 2 ? TEXT : TEXT_DIM).margin({ top: 2 })
      }
      .width('25%')
      .onClick(() => { this.onTabChange?.(2) })

      Column() {
        if (this.currentTab === 3) {
          Circle({ width: 4, height: 4 }).fill('#8c8cb0').margin({ bottom: 4 })
        } else {
          Row().height(4).margin({ bottom: 4 })
        }
        IconProfile({ active: this.currentTab === 3 })
        Text('我的').fontSize(10).fontWeight(this.currentTab === 3 ? 600 : 400)
          .fontColor(this.currentTab === 3 ? TEXT : TEXT_DIM).margin({ top: 2 })
      }
      .width('25%')
      .onClick(() => { this.onTabChange?.(3) })
    }
    .width('100%').height(60).padding({ bottom: 4, top: 4 })
    .backgroundColor('rgba(248,247,244,0.85)').backdropBlur(20)
    .border({ width: { top: 1 }, color: '#e8e6e0' })
    .shadow({ radius: 8, color: '#00000006', offsetY: -2 })
  }
}
