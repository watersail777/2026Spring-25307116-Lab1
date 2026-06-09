// ═══════════════════════════════════════
// 全局跨 Ability 状态桥
// ═══════════════════════════════════════

export class GlobalThis {
  static widgetCardId: string = ''

  // 原始字节缓存（EntryAbility 异步读取，不解码）
  static rawScheduleBytes: Uint8Array | null = null
  static rawStationCoordsBytes: Uint8Array | null = null
  static rawSameCityBytes: Uint8Array | null = null
  static rawFalseSameCityBytes: Uint8Array | null = null
  static rawDualNumbersBytes: Uint8Array | null = null

  // 解码后的文本（DataLoader 分批解码+解析时填充）
  static rawSchedule: string = ''
  static rawStationCoords: string = ''
  static rawSameCity: string = ''
  static rawFalseSameCity: string = ''
  static rawDualNumbers: string = ''

  static rawDataReady: boolean = false
}