import { AppViewModel } from '../../model/AppViewModel'
import { StationPicker } from '../../components/StationPicker'

// ═══════════════════════════════════════
// 搜索页 — 出发/到达站 + 查询按钮
// ═══════════════════════════════════════

@ComponentV2
export struct SearchTab {
  @Require @Param vm: AppViewModel
  @Param isTablet: boolean = false
  @Local showTrainTypeHelp: boolean = false

  build() {
    Stack() {
    Column() {
      // Header
      Column() {
        // 火车图标 SVG
        Text('OnTrack')
          .fontSize(30).fontWeight(700)
          .fontColor('#1A1A2E')
          .fontFamily('serif')
        Text('火车路线查询')
          .fontSize(14).fontColor('#999999')
          .margin({ top: 4 })
      }
      .width('100%').alignItems(HorizontalAlign.Center)
      .margin({ top: 32, bottom: 32 })

      // 查询表单卡片
      Column() {
        StationPicker({
          label: '出发站',
          value: this.vm.departureStation,
          onChange: (name: string) => { this.vm.departureStation = name }
        })
          .margin({ bottom: 16 })

        // 交换按钮
        Row() {
          Button() {
            Text('↑↓').fontSize(16).fontColor('#1A73E8').fontWeight(700)
          }
          .width(40).height(40).borderRadius(20)
          .backgroundColor('#E8F0FE')
          .onClick(() => {
            const tmp = this.vm.departureStation
            this.vm.departureStation = this.vm.arrivalStation
            this.vm.arrivalStation = tmp
          })
        }
        .width('100%').justifyContent(FlexAlign.Center)
        .margin({ top: -8, bottom: 8 })

        StationPicker({
          label: '到达站',
          value: this.vm.arrivalStation,
          onChange: (name: string) => { this.vm.arrivalStation = name }
        })
          .margin({ bottom: 20 })

        // 查询按钮
        Button() {
          Text(this.vm.isLoading ? '查询中...' : '查询')
            .fontSize(18).fontWeight(600).fontColor('#FFFFFF')
        }
        .width('100%').height(50)
        .borderRadius(12)
        .backgroundColor(this.vm.isLoading ? '#A0C4FF' : '#1A73E8')
        .enabled(!this.vm.isLoading)
        .onClick(() => { this.vm.search() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
      .borderRadius(16)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 12, color: 'rgba(0,0,0,0.06)', offsetY: 4 })

      // 筛选面板
      Column() {
        Row() {
          Text('[=] 筛选条件')
            .fontSize(13).fontWeight(600).fontColor('#555555')
          Blank()
          Image($r('app.media.icon_chevron_right'))
            .width(14).height(14).fillColor('#999999')
            .rotate({ angle: this.vm.showFilter ? 270 : 90 })
        }
        .width('100%').padding({ top: 8, bottom: 8 })
        .onClick(() => { this.vm.showFilter = !this.vm.showFilter })

        if (this.vm.showFilter) {
          // 换乘次数
          Row() {
            Text('换乘次数').fontSize(12).fontColor('#666666').width(80)
            Scroll() {
              Row() {
                ForEach([0, 1, 2, 3, 4, 5, 6, 7], (n: number) => {
                  Text(n === 7 ? '不限' : `${n}次`)
                    .fontSize(11).fontWeight(this.vm.maxTransfers === n ? 700 : 400)
                    .fontColor(this.vm.maxTransfers === n ? '#FFFFFF' : '#666666')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(12)
                    .backgroundColor(this.vm.maxTransfers === n ? '#1A73E8' : '#F0F0F0')
                    .margin({ right: 6 })
                    .onClick(() => { this.vm.maxTransfers = n })
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%').margin({ bottom: 8 })

          // 车型筛选
          Row() {
            Row() {
              Text('车型').fontSize(12).fontColor('#666666')
              // 帮助按钮
              Text('?')
                .fontSize(10).fontWeight(700).fontColor('#999999')
                .width(16).height(16).borderRadius(8)
                .border({ width: 1, color: '#BBBBBB' })
                .textAlign(TextAlign.Center)
                .margin({ left: 4 })
                .onClick(() => { this.showTrainTypeHelp = true })
            }
            .width(80)

            Row() {
              Text('G').fontSize(11).fontWeight(this.vm.filterG ? 700 : 400)
                .fontColor(this.vm.filterG ? '#FFFFFF' : '#666666')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12)
                .backgroundColor(this.vm.filterG ? '#1A73E8' : '#F0F0F0').margin({ right: 6 })
                .onClick(() => { this.vm.filterG = !this.vm.filterG })
              Text('D').fontSize(11).fontWeight(this.vm.filterD ? 700 : 400)
                .fontColor(this.vm.filterD ? '#FFFFFF' : '#666666')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12)
                .backgroundColor(this.vm.filterD ? '#1A73E8' : '#F0F0F0').margin({ right: 6 })
                .onClick(() => { this.vm.filterD = !this.vm.filterD })
              Text('C').fontSize(11).fontWeight(this.vm.filterC ? 700 : 400)
                .fontColor(this.vm.filterC ? '#FFFFFF' : '#666666')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12)
                .backgroundColor(this.vm.filterC ? '#1A73E8' : '#F0F0F0').margin({ right: 6 })
                .onClick(() => { this.vm.filterC = !this.vm.filterC })
              Text('Z').fontSize(11).fontWeight(this.vm.filterZ ? 700 : 400)
                .fontColor(this.vm.filterZ ? '#FFFFFF' : '#666666')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12)
                .backgroundColor(this.vm.filterZ ? '#1A73E8' : '#F0F0F0').margin({ right: 6 })
                .onClick(() => { this.vm.filterZ = !this.vm.filterZ })
              Text('T').fontSize(11).fontWeight(this.vm.filterT ? 700 : 400)
                .fontColor(this.vm.filterT ? '#FFFFFF' : '#666666')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12)
                .backgroundColor(this.vm.filterT ? '#1A73E8' : '#F0F0F0').margin({ right: 6 })
                .onClick(() => { this.vm.filterT = !this.vm.filterT })
              Text('K').fontSize(11).fontWeight(this.vm.filterK ? 700 : 400)
                .fontColor(this.vm.filterK ? '#FFFFFF' : '#666666')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(12)
                .backgroundColor(this.vm.filterK ? '#1A73E8' : '#F0F0F0').margin({ right: 6 })
                .onClick(() => { this.vm.filterK = !this.vm.filterK })
            }
          }
          .width('100%').margin({ bottom: 8 })

          // 仅直达
          Row() {
            Text('仅直达').fontSize(12).fontColor('#666666').width(80)
            Toggle({ type: ToggleType.Switch, isOn: this.vm.directOnly })
              .onChange((checked: boolean) => { this.vm.directOnly = checked })
          }
          .width('100%').margin({ bottom: 8 })

          // 最小换乘间隔
          Row() {
            Text('最小换乘间隔').fontSize(12).fontColor('#666666').width(80)
            Row() {
              ForEach([10, 15, 20, 30, 60], (n: number) => {
                Text(`${n}分`)
                  .fontSize(11).fontWeight(this.vm.minTransferGap === n ? 700 : 400)
                  .fontColor(this.vm.minTransferGap === n ? '#FFFFFF' : '#666666')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .backgroundColor(this.vm.minTransferGap === n ? '#1A73E8' : '#F0F0F0')
                  .margin({ right: 6 })
                  .onClick(() => { this.vm.minTransferGap = n })
              })
            }
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 4, right: 4, top: 4, bottom: 8 })
      .border({ width: { top: 0.5 }, color: '#F0F0F0' })
      .margin({ top: 8 })

      // Toast
      if (this.vm.toastMsg.length > 0) {
        Text(this.vm.toastMsg)
          .fontSize(13).fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .borderRadius(20)
          .backgroundColor('#333333')
          .margin({ top: 20 })
      }

      Blank()

      // 最近查询（平板模式隐藏）
      if (this.vm.recentQueries.length > 0 && !this.vm.isLoading && !this.isTablet) {
        Column() {
          Text('最近查询')
            .fontSize(13).fontWeight(600).fontColor('#999999')
            .margin({ bottom: 8 })
            .width('100%')

          ForEach(this.vm.recentQueries.slice(0, 6), (query: string) => {
            Row() {
              Text(query)
                .fontSize(13).fontColor('#555555')
                .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%').padding({ top: 8, bottom: 8 })
            .border({ width: { bottom: 0.5 }, color: '#F0F0F0' })
            .onClick(() => {
              const parts = query.split(' → ')
              if (parts.length === 2) {
                this.vm.departureStation = parts[0]
                this.vm.arrivalStation = parts[1]
                this.vm.search()
              }
            })
          })
        }
        .width('100%').padding({ left: 8, right: 8 })
        .margin({ top: 24 })
      }
    }
    .width('100%').height('100%')
    .padding({ left: 20, right: 20, bottom: 20 })

    // ── 车型帮助弹窗 ──
    if (this.showTrainTypeHelp) {
      Stack() {
        Column()
          .width('100%').height('100%')
          .backgroundColor('rgba(0,0,0,0.45)')
          .onClick(() => { this.showTrainTypeHelp = false })

        Column() {
          Row() {
            Text('列车类型说明')
              .fontSize(16).fontWeight(700).fontColor('#1A1A2E')
            Blank()
            Text('✕')
              .fontSize(14).fontColor('#999999')
              .onClick(() => { this.showTrainTypeHelp = false })
          }
          .width('100%').margin({ bottom: 14 })

          Column() {
            this.TrainTypeRow('G', '高速动车组', '300–350 km/h', 'G1234', '中国最快，和谐号/复兴号')
            this.TrainTypeRow('D', '动车组', '200–250 km/h', 'D5678', '性价比高，覆盖广')
            this.TrainTypeRow('C', '城际动车', '160–350 km/h', 'C2010', '短途城市群通勤')
            this.TrainTypeRow('Z', '直达特快', '160 km/h', 'Z1', '一站直达或只停大站')
            this.TrainTypeRow('T', '特快', '140 km/h', 'T110', '停靠地级市')
            this.TrainTypeRow('K', '快速', '120 km/h', 'K1234', '停靠较多县级站，票价低')
          }
          .width('100%')
        }
        .width('85%')
        .padding(20)
        .borderRadius(14)
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)' })
      }
      .position({ x: 0, y: 0 })
      .width('100%').height('100%')
      .zIndex(200)
    }
    } // end outer Stack
  }

  @Builder
  TrainTypeRow(letter: string, name: string, speed: string, example: string, desc: string) {
    Row() {
      Text(letter)
        .fontSize(14).fontWeight(700).fontColor('#FFFFFF')
        .width(28).height(28).borderRadius(14)
        .backgroundColor('#1A73E8')
        .textAlign(TextAlign.Center)
      Column() {
        Row() {
          Text(name).fontSize(14).fontWeight(600).fontColor('#333333')
          Text(` ${speed}`).fontSize(11).fontColor('#999999')
        }
        Text(`${desc}（如 ${example}）`)
          .fontSize(11).fontColor('#888888')
          .margin({ top: 2 })
      }
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding({ top: 6, bottom: 6 })
  }
}