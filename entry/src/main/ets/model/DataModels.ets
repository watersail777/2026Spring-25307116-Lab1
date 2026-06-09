// ═══════════════════════════════════════
// 数据模型：车站 · 列车 · 路线 · 行程段
// ═══════════════════════════════════════

export class Station {
  name: string = ''
  lon: number = 0
  lat: number = 0
}

export class TrainStop {
  stationName: string = ''
  arrivalTime: string = ''    // "HH:MM"
  departureTime: string = ''  // "HH:MM"
  dayOffset: number = 0
}

export class Train {
  trainId: string = ''
  trainIdDual: string = ''
  stops: TrainStop[] = []
}

// 时间扩展图中的节点
@ObservedV2
export class RouteNode {
  @Trace stationName: string = ''
  @Trace timeMinutes: number = 0
  @Trace dayIndex: number = 0
  @Trace trainId: string = ''
  @Trace prevNode: RouteNode | null = null
  @Trace costFromStart: number = 0
}

// 单段行程
export class ItinerarySegment {
  trainId: string = ''
  fromStation: string = ''
  toStation: string = ''
  departureTime: string = ''   // "HH:MM"
  arrivalTime: string = ''     // "HH:MM"
  durationMinutes: number = 0
  isTransfer: boolean = false
  transferType: string = ''    // '' | 'same_station' | 'same_city'
  transferMinutes: number = 0
}

// 完整路线结果
export class RouteResult {
  segments: ItinerarySegment[] = []
  totalTimeMinutes: number = 0
  transferCount: number = 0
  departureTime: string = ''
  arrivalTime: string = ''
}

// 发车条目（用于 stationDepartures 索引）
export class DepartureEntry {
  trainId: string = ''
  departureMin: number = 0      // 发车时间（距午夜分钟数）
  arrivalStation: string = ''
  arrivalMin: number = 0        // 到达时间（距午夜分钟数）
}