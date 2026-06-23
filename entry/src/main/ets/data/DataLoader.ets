import { util } from '@kit.ArkTS'
import { Station, Train, TrainStop, DepartureEntry } from '../model/DataModels'
import { GlobalThis } from '../utils/GlobalThis'

// ═══════════════════════════════════════
// 数据加载器 — 从 GlobalThis 缓存中解码+解析
// ═══════════════════════════════════════

const MINUTES_PER_DAY = 1440

function timeToMinutes(t: string): number {
  if (t.length < 5) return -1
  const h = parseInt(t.substring(0, 2))
  const m = parseInt(t.substring(3, 5))
  if (isNaN(h) || isNaN(m)) return -1
  return h * 60 + m
}

function isTrainHeader(s: string): boolean {
  if (s.length < 2) return false
  const first = s.charAt(0)
  return (first >= 'A' && first <= 'Z') && (s.charAt(1) >= '0' && s.charAt(1) <= '9') && s.indexOf('\t') < 0
}

// 解码 Uint8Array → string
function decodeBytes(bytes: Uint8Array | null): string {
  if (bytes === null) return ''
  const td = util.TextDecoder.create('utf-8', { ignoreBOM: true })
  return td.decodeToString(bytes, { stream: false })
}

export class DataLoader {
  static stations: Map<string, Station> = new Map()
  static trains: Map<string, Train> = new Map()
  static trainDualMap: Map<string, string> = new Map()
  static sameCityPairs: [string, string, number][] = []
  static falseSameCityKeys: Set<string> = new Set()

  // 核心索引：每个站 → 此站所有发车条目（按发车时间排序）
  static stationDepartures: Map<string, DepartureEntry[]> = new Map()

  static isLoaded: boolean = false
  static progress: number = 0       // 0~100
  static progressText: string = '准备加载数据...'

  // ── 异步分批加载 ──
  static async loadAllAsync(): Promise<void> {
    if (DataLoader.isLoaded) return

    DataLoader.progressText = '解码车站数据...'
    DataLoader.progress = 2
    await DataLoader.yieldToUI()

    // 解码 + 解析小文件（同步但不重）
    GlobalThis.rawStationCoords = decodeBytes(GlobalThis.rawStationCoordsBytes)
    GlobalThis.rawSameCity = decodeBytes(GlobalThis.rawSameCityBytes)
    GlobalThis.rawFalseSameCity = decodeBytes(GlobalThis.rawFalseSameCityBytes)
    GlobalThis.rawDualNumbers = decodeBytes(GlobalThis.rawDualNumbersBytes)

    DataLoader.progress = 10
    DataLoader.parseStationCoords()
    DataLoader.progress = 14
    await DataLoader.yieldToUI()
    DataLoader.parseSameCity()
    DataLoader.progress = 17
    await DataLoader.yieldToUI()
    DataLoader.parseFalseSameCity()
    DataLoader.progress = 19
    await DataLoader.yieldToUI()
    DataLoader.parseDualNumbers()
    DataLoader.progress = 22
    await DataLoader.yieldToUI()

    // 大文件延迟解码 + 分批解析
    DataLoader.progressText = '解码时刻表...'
    DataLoader.progress = 25
    await DataLoader.yieldToUI()
    GlobalThis.rawSchedule = decodeBytes(GlobalThis.rawScheduleBytes)
    await DataLoader.yieldToUI()

    await DataLoader.parseTrainScheduleAsync()

    DataLoader.progressText = '构建搜索索引...'
    DataLoader.progress = 92
    await DataLoader.yieldToUI()
    await DataLoader.buildDepartureIndexAsync()
    DataLoader.progress = 100
    DataLoader.progressText = '就绪'
    await DataLoader.yieldToUI()

    DataLoader.isLoaded = true
  }

  private static yieldToUI(): Promise<void> {
    return new Promise<void>((resolve: Function) => { setTimeout(() => { resolve() }, 0) })
  }

  // ── 解析器：从 GlobalThis 缓存读取 ──
  private static parseStationCoords(): void {
    const raw = GlobalThis.rawStationCoords
    if (raw.length === 0) return
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      let line = lines[i].trim()
      if (line.length === 0 || line.startsWith('火车站名')) continue
      if (line.endsWith('\r')) line = line.substring(0, line.length - 1)
      const parts = line.split('\t')
      if (parts.length < 2) continue
      const coords = parts[1].trim().split(',')
      if (coords.length < 2) continue
      const lon = parseFloat(coords[0])
      const lat = parseFloat(coords[1])
      if (isNaN(lon) || isNaN(lat)) continue
      const st = new Station()
      st.name = parts[0].trim()
      st.lon = lon
      st.lat = lat
      DataLoader.stations.set(st.name, st)
    }
  }

  private static parseSameCity(): void {
    const raw = GlobalThis.rawSameCity
    if (raw.length === 0) return
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      let line = lines[i].trim()
      if (line.length === 0 || line.startsWith('软件') || line.startsWith('如果') ||
          line.startsWith('1条') || line.startsWith('建议')) continue
      if (line.endsWith('\r')) line = line.substring(0, line.length - 1)
      const parts = line.split('\t')
      if (parts.length < 3) continue
      const mins = parseInt(parts[2].trim())
      if (isNaN(mins)) continue
      DataLoader.sameCityPairs.push([parts[0].trim(), parts[1].trim(), mins])
    }
  }

  private static parseFalseSameCity(): void {
    const raw = GlobalThis.rawFalseSameCity
    if (raw.length === 0) return
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      let line = lines[i].trim()
      if (line.length === 0 || line.startsWith('软件') || line.startsWith('同城有')) continue
      if (line.endsWith('\r')) line = line.substring(0, line.length - 1)
      const parts = line.split('\t')
      if (parts.length < 2) continue
      const a = parts[0].trim()
      const b = parts[1].trim()
      DataLoader.falseSameCityKeys.add(`${a}|${b}`)
      DataLoader.falseSameCityKeys.add(`${b}|${a}`)
    }
  }

  private static parseDualNumbers(): void {
    const raw = GlobalThis.rawDualNumbers
    if (raw.length === 0) return
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      let line = lines[i].trim()
      if (line.length === 0 || line.startsWith('20') || line.startsWith('列车朝') ||
          line.startsWith('因此') || line.startsWith('本文件')) continue
      if (line.endsWith('\r')) line = line.substring(0, line.length - 1)
      const parts = line.split('\t')
      if (parts.length < 2) continue
      const a = parts[0].trim()
      const b = parts[1].trim()
      DataLoader.trainDualMap.set(a, b)
      DataLoader.trainDualMap.set(b, a)
    }
  }

  // ── 分批异步解析 train_schedule.txt ──
  private static async parseTrainScheduleAsync(): Promise<void> {
    DataLoader.progressText = '读取时刻表...'
    DataLoader.progress = 22
    await DataLoader.yieldToUI()

    const raw = GlobalThis.rawSchedule
    const lines = raw.split('\n')
    const totalLines = lines.length
    const BATCH_SIZE = 1500

    DataLoader.progressText = `解析时刻表 (${totalLines}行)...`
    DataLoader.progress = 25
    await DataLoader.yieldToUI()

    let state: 'OUTSIDE' | 'READING' = 'OUTSIDE'
    let currentTrainId = ''
    let currentStops: TrainStop[] = []
    let dayOffset = 0
    let lastDepMin = -1

    for (let batchStart = 0; batchStart < totalLines; batchStart += BATCH_SIZE) {
      const batchEnd = Math.min(batchStart + BATCH_SIZE, totalLines)

      for (let i = batchStart; i < batchEnd; i++) {
        let line = lines[i]
        if (line.endsWith('\r')) line = line.substring(0, line.length - 1)

        if (state === 'OUTSIDE') {
          if (line.startsWith('\t') || line.length === 0) continue
          if (isTrainHeader(line)) {
            currentTrainId = line.trim()
            currentStops = []
            dayOffset = 0
            lastDepMin = -1
            state = 'READING'
          }
        } else {
          if (line.length === 0 || isTrainHeader(line)) {
            if (currentStops.length > 0) {
              const train = new Train()
              train.trainId = currentTrainId
              train.trainIdDual = DataLoader.trainDualMap.get(currentTrainId) ?? ''
              train.stops = currentStops
              DataLoader.trains.set(currentTrainId, train)
            }
            if (isTrainHeader(line)) {
              currentTrainId = line.trim()
              currentStops = []
              dayOffset = 0
              lastDepMin = -1
            } else {
              state = 'OUTSIDE'
            }
            continue
          }
          const parts = line.split('\t')
          if (parts.length >= 3) {
            const stop = new TrainStop()
            stop.stationName = parts[0].trim()
            stop.arrivalTime = parts[1].trim()
            stop.departureTime = parts[2].trim()
            const depMin = timeToMinutes(stop.departureTime)
            if (depMin >= 0 && lastDepMin >= 0 && depMin < lastDepMin) dayOffset++
            if (depMin >= 0) lastDepMin = depMin
            stop.dayOffset = dayOffset
            currentStops.push(stop)
          }
        }
      }

      const pct = 25 + Math.floor((batchEnd / totalLines) * 65)
      DataLoader.progress = pct
      DataLoader.progressText = `解析时刻表 ${batchEnd}/${totalLines}`
      await DataLoader.yieldToUI()
    }

    if (state === 'READING' && currentStops.length > 0) {
      const train = new Train()
      train.trainId = currentTrainId
      train.trainIdDual = DataLoader.trainDualMap.get(currentTrainId) ?? ''
      train.stops = currentStops
      DataLoader.trains.set(currentTrainId, train)
    }
  }

  // ── 分批构建出发索引 ──
  private static async buildDepartureIndexAsync(): Promise<void> {
    const trainIds: string[] = []
    DataLoader.trains.forEach((_: Train, id: string) => { trainIds.push(id) })
    const BATCH = 200

    const tmp: Map<string, DepartureEntry[]> = new Map()
    for (let b = 0; b < trainIds.length; b += BATCH) {
      const end = Math.min(b + BATCH, trainIds.length)
      for (let ti = b; ti < end; ti++) {
        const train = DataLoader.trains.get(trainIds[ti])
        if (!train) continue
        for (let i = 0; i < train.stops.length; i++) {
          const stop = train.stops[i]
          const depMin = timeToMinutes(stop.departureTime)
          if (depMin >= 0 && i < train.stops.length - 1) {
            for (let j = i + 1; j < train.stops.length; j++) {
              const nextStop = train.stops[j]
              const arrMin = timeToMinutes(nextStop.arrivalTime)
              if (arrMin >= 0) {
                const entry = new DepartureEntry()
                entry.trainId = train.trainId
                entry.departureMin = depMin + stop.dayOffset * MINUTES_PER_DAY
                entry.arrivalStation = nextStop.stationName
                entry.arrivalMin = arrMin + (stop.dayOffset + (nextStop.dayOffset - stop.dayOffset)) * MINUTES_PER_DAY
                if (!tmp.has(stop.stationName)) tmp.set(stop.stationName, [])
                tmp.get(stop.stationName)!.push(entry)
                // 不 break — 生成到所有下游站的边
              }
            }
          }
        }
      }
      const pct = 92 + Math.floor((end / trainIds.length) * 8)
      DataLoader.progress = pct
      await DataLoader.yieldToUI()
    }

    tmp.forEach((entries: DepartureEntry[], station: string) => {
      entries.sort((a: DepartureEntry, b: DepartureEntry) => a.departureMin - b.departureMin)
      DataLoader.stationDepartures.set(station, entries)
    })
  }

  // ── 搜索辅助：三级匹配（完全匹配 > 前缀匹配 > 包含匹配），每级内按发车边数降序 ──
  static searchStations(query: string, limit: number = 8): string[] {
    const q = query.trim()
    if (q.length === 0) return []

    const exact: string[] = []
    const prefix: string[] = []
    const contains: string[] = []

    DataLoader.stations.forEach((_: Station, name: string) => {
      const hasDepartures = (DataLoader.stationDepartures.get(name)?.length ?? 0) > 0
      if (!hasDepartures) return  // 过滤无列车服务的噪声站
      if (name === q) {
        exact.push(name)
      } else if (name.startsWith(q)) {
        prefix.push(name)
      } else if (name.includes(q)) {
        contains.push(name)
      }
    })

    const sortByDepartures = (a: string, b: string): number => {
      const countA = DataLoader.stationDepartures.get(a)?.length ?? 0
      const countB = DataLoader.stationDepartures.get(b)?.length ?? 0
      if (countB !== countA) return countB - countA
      return a.length - b.length
    }

    exact.sort(sortByDepartures)
    prefix.sort(sortByDepartures)
    contains.sort(sortByDepartures)

    const result: string[] = [...exact, ...prefix, ...contains]
    return result.slice(0, limit)
  }
}