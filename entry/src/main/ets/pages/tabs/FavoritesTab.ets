import { KnowledgeItem } from '../../model/KnowledgeItem'
import { AppViewModel, CardGradient } from '../../model/AppViewModel'

// ── 书签页 — Frame_2_1317 + 管理删除 ──

@ComponentV2
export struct FavoritesTab {
  @Require @Param vm: AppViewModel
  @Local deleteMode: boolean = false
  @Local selectedIds: string[] = []
  @Local showConfirm: boolean = false

  aboutToAppear(): void {
    this.vm.loadFavorites()
  }

  isSelected(id: string): boolean { return this.selectedIds.indexOf(id) >= 0 }
  toggleSelect(id: string): void {
    const i = this.selectedIds.indexOf(id)
    if (i >= 0) { this.selectedIds.splice(i, 1) }
    else { this.selectedIds.push(id) }
  }
  confirmDelete(): void {
    for (const id of this.selectedIds) { this.vm.removeFavorite(id) }
    this.selectedIds = []; this.deleteMode = false; this.showConfirm = false
  }

  build() {
    Stack() {
      Column() {
        // ── 标题行 ──
        Row() {
          Text('我的书签').fontSize(24).fontWeight(700).fontColor('#1F2937')
          Blank()
          Row() {
            Image($r('app.media.pencil')).width(14).height(14)
            Text(this.deleteMode ? '完成' : '管理').fontSize(13).fontWeight(500)
              .fontColor('#6B7280').margin({ left: 4 })
          }
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .borderRadius(16).backgroundColor(this.deleteMode ? 'rgba(239,68,68,0.08)' : '#F3F4F6')
          .onClick(() => { this.deleteMode = !this.deleteMode; this.selectedIds = [] })
        }
        .width('100%').padding({ left: 24, right: 24, top: 12, bottom: 16 })

        // ── 统计 ──
        Row() {
          Image($r('app.media.bookmark0')).width(14).height(14)
          Text(`已收藏 ${this.vm.favorites.length} 条`)
            .fontSize(13).fontWeight(500).fontColor('#7A52A0').margin({ left: 6 })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .borderRadius(16).border({ width: 1, color: '#E9D8F5' })
        .backgroundColor('#F9F5FF').margin({ left: 16, right: 16, bottom: 12 })

        if (this.deleteMode) {
          Text('点击条目右侧圆圈选择').fontSize(11).fontColor('#F87171')
            .width('100%').padding({ left: 20, bottom: 4 })
        }

        // ── 书签列表 ──
        if (this.vm.favorites.length === 0) {
          Column() {
            Text('还没有收藏').fontSize(15).fontColor('#9CA3AF')
          }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              ForEach(this.vm.favorites, (card: KnowledgeItem, idx: number) => {
                this.BookmarkCard(card, this.vm.getCardGradient(idx % 6), idx)
              })
            }
            .width('100%').padding({ left: 16, right: 16, top: 4, bottom: 4 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%').layoutWeight(1).align(Alignment.Top)
        }

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
      .width('100%').height('100%')

      // 确认弹窗
      if (this.showConfirm) {
        Column() {
          Column() {
            Text('确认删除').fontSize(18).fontWeight(700).fontColor('#1F2937').margin({ bottom: 8 })
            Text(`确定要移除选中的 ${this.selectedIds.length} 条收藏吗？`)
              .fontSize(14).fontColor('#6B7280').textAlign(TextAlign.Center).margin({ bottom: 20 })
            Row() {
              Button('取消').fontSize(14).fontColor('#6B7280').layoutWeight(1).height(40)
                .backgroundColor('#F3F4F6').borderRadius(20)
                .onClick(() => { this.showConfirm = false })
              Button('确定').fontSize(14).fontColor('#FFFFFF').layoutWeight(1).height(40)
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
    .width('100%').height('100%')
  }

  @Builder BookmarkCard(card: KnowledgeItem, grad: CardGradient, idx: number) {
    Row() {
      Column() {
        Text(card.category || '冷知识')
          .fontSize(10).fontWeight(600).fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10).backgroundColor(grad.accentColor)
        Row().height(6).width('100%')
        Text(card.title)
          .fontSize(15).fontWeight(700).fontColor(grad.titleColor)
          .lineHeight(21).maxLines(2).width('100%')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row().height(4).width('100%')
        Text('3天前收藏').fontSize(11).fontWeight(400).fontColor(grad.accentColor)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

      if (this.deleteMode) {
        Button() {
          Circle({ width: 20, height: 20 })
            .fill(this.isSelected(card.id) ? '#F87171' : 'none')
            .stroke(this.isSelected(card.id) ? '#F87171' : '#D1D5DB').strokeWidth(2)
        }
        .width(28).height(28).backgroundColor(Color.Transparent)
        .onClick(() => { this.toggleSelect(card.id) })
      } else {
        Image($r('app.media.bookmark4')).width(20).height(20)
      }
    }
    .width('100%').padding(16).borderRadius(20)
    .linearGradient({ angle: 112, colors: [[grad.gradientStart, 0.0], [grad.gradientEnd + 'CC', 1.0]] })
    .border({ width: 1, color: grad.borderColor })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
    .margin({ bottom: 12 })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => { this.deleteMode = true; this.toggleSelect(card.id) })
    )
  }
}
