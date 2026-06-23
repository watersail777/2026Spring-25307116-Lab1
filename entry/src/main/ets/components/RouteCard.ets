import { ItinerarySegment, TrainStop } from '../model/DataModels'
import { DataLoader } from '../data/DataLoader'

@ComponentV2
export struct RouteCard {
  @Require @Param segment: ItinerarySegment
  @Event onTap?: () => void
  @Local expanded: boolean = false
  @Local stopList: TrainStop[] = []
  @Local dualId: string = ''

  aboutToAppear(): void {
    this.loadStops()
    const train = DataLoader.trains.get(this.segment.trainId)
    this.dualId = train?.trainIdDual ?? ''
  }

  private loadStops(): void {
    const train = DataLoader.trains.get(this.segment.trainId)
    if (!train) {
      this.stopList = []
      return
    }
    const stops: TrainStop[] = []
    let inRange = false
    for (let i = 0; i < train.stops.length; i++) {
      const s = train.stops[i]
      if (s.stationName === this.segment.fromStation) inRange = true
      if (inRange) stops.push(s)
      if (s.stationName === this.segment.toStation && stops.length > 1) break
    }
    this.stopList = stops
  }

  private toggleExpand(): void {
    this.expanded = !this.expanded
    this.onTap?.()
  }

  private formatDuration(minutes: number): string {
    if (minutes < 60) return `${minutes}分钟`
    const h = Math.floor(minutes / 60)
    const m = minutes % 60
    return m > 0 ? `${h}h ${m}m` : `${h}h`
  }

  private formatTime(t: string, dayOffset: number): string {
    if (dayOffset === 0) return t
    return `${t} +${dayOffset}`
  }

  build() {
    Column() {
      // 头部：车次 + 时长
      Row() {
        Row() {
          Text(this.segment.trainId)
            .fontSize(18).fontWeight(700).fontColor('#1A73E8')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(6).backgroundColor('#E8F0FE')
          if (this.dualId.length > 0) {
            Text(` / ${this.dualId}`)
              .fontSize(13).fontWeight(500).fontColor('#999999')
              .margin({ left: 4 })
          }
        }

        Blank()

        Text(this.formatDuration(this.segment.durationMinutes))
          .fontSize(12).fontColor('#888888')

        Image(this.expanded ? $r('app.media.icon_chevron_right') : $r('app.media.icon_chevron_right'))
          .width(14).height(14).fillColor('#AAAAAA').margin({ left: 6 })
          .rotate({ angle: this.expanded ? 270 : 90 })
      }
      .width('100%')

      Row().height(12).width('100%')

      // 时间 + 车站行
      Row() {
        Column() {
          Text(this.segment.departureTime)
            .fontSize(22).fontWeight(700).fontColor('#1A1A2E')
          Text(this.segment.fromStation)
            .fontSize(12).fontColor('#666666').margin({ top: 2 })
        }
        Column() {
          Row() {
            Circle({ width: 6, height: 6 }).fill('#1A73E8')
            Divider().width(40).height(1).color('#1A73E8')
            Circle({ width: 6, height: 6 }).fill('#1A73E8')
          }
          Text('→').fontSize(10).fontColor('#1A73E8')
        }
        .alignItems(HorizontalAlign.Center).margin({ left: 12, right: 12 })
        Column() {
          Text(this.segment.arrivalTime)
            .fontSize(22).fontWeight(700).fontColor('#1A1A2E')
          Text(this.segment.toStation)
            .fontSize(12).fontColor('#666666').margin({ top: 2 })
        }
      }
      .width('100%')

      // 经停站列表（点击展开）
      if (this.expanded) {
        Divider().height(1).color('#F0F0F0').margin({ top: 12, bottom: 8 })

        Text('途经站点').fontSize(12).fontWeight(600).fontColor('#999999').width('100%').margin({ bottom: 6 })

        Column() {
          ForEach(this.stopList, (stop: TrainStop, idx: number) => {
            Row() {
              Column() {
                Circle({ width: 7, height: 7 })
                  .fill(idx === 0 || idx === this.stopList.length - 1 ? '#1A73E8' : '#CCCCCC')
                if (idx < this.stopList.length - 1) {
                  Divider().width(1).height(18).color('#E8E8E8')
                }
              }.alignItems(HorizontalAlign.Center).margin({ right: 10 })

              Text(stop.stationName)
                .fontSize(13).fontColor(idx === 0 || idx === this.stopList.length - 1 ? '#1A1A2E' : '#666666')
                .fontWeight(idx === 0 || idx === this.stopList.length - 1 ? 600 : 400)
                .width(80)

              Blank()

              Column() {
                if (idx > 0) {
                  Text(`到 ${this.formatTime(stop.arrivalTime, stop.dayOffset)}`)
                    .fontSize(11).fontColor('#888888')
                }
                if (idx < this.stopList.length - 1) {
                  Text(`发 ${this.formatTime(stop.departureTime, stop.dayOffset)}`)
                    .fontSize(11).fontColor('#1A73E8')
                }
              }.alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .padding({ top: 3, bottom: 3 })
          }, (_stop: TrainStop, idx: number) => `stop_${idx}`)
        }
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
    .onClick(() => { this.toggleExpand() })
  }
}