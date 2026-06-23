import { RouteNode, RouteResult, ItinerarySegment } from '../model/DataModels'
import { GraphBuilder } from './GraphBuilder'
import { DataLoader } from './DataLoader'

// ═══════════════════════════════════════
// 路径搜索 — MinHeap + Dijkstra
// ═══════════════════════════════════════

const MINUTES_PER_DAY = 1440

// ── 最小堆 ──
class MinHeap {
  private data: RouteNode[] = []

  push(n: RouteNode): void {
    this.data.push(n)
    this.siftUp(this.data.length - 1)
  }

  pop(): RouteNode | null {
    if (this.data.length === 0) return null
    const top = this.data[0]
    const last = this.data.pop()!
    if (this.data.length > 0) {
      this.data[0] = last
      this.siftDown(0)
    }
    return top
  }

  get size(): number { return this.data.length }

  private siftUp(idx: number): void {
    while (idx > 0) {
      const parent = Math.floor((idx - 1) / 2)
      if (this.data[idx].costFromStart < this.data[parent].costFromStart) {
        const tmp = this.data[idx]
        this.data[idx] = this.data[parent]
        this.data[parent] = tmp
        idx = parent
      } else {
        break
      }
    }
  }

  private siftDown(idx: number): void {
    const n = this.data.length
    while (true) {
      let smallest = idx
      const left = 2 * idx + 1
      const right = 2 * idx + 2
      if (left < n && this.data[left].costFromStart < this.data[smallest].costFromStart) smallest = left
      if (right < n && this.data[right].costFromStart < this.data[smallest].costFromStart) smallest = right
      if (smallest !== idx) {
        const tmp = this.data[idx]
        this.data[idx] = this.data[smallest]
        this.data[smallest] = tmp
        idx = smallest
      } else {
        break
      }
    }
  }
}

export class RouteFinder {

  static async findRoutes(
    origin: string,
    destination: string,
    startHour: number = 0,
    maxTransfers: number = 5,
    minTransferMinutes: number = 15,
    maxResults: number = 5,
    allowedTypes?: string[]
  ): Promise<RouteResult[]> {
    const startMin = startHour * 60
    const heap = new MinHeap()
    const visited: Set<string> = new Set()
    const results: RouteResult[] = []

    const initials = GraphBuilder.getInitialDepartures(origin, startMin)
    console.info(`[RouteFinder] Initial departures from ${origin}: ${initials.length}`)
    for (let i = 0; i < initials.length; i++) {
      const n = initials[i]
      if (n.trainId.length > 0 && i < 3) {
        console.info(`[RouteFinder] Init[${i}]: ${n.trainId} to ${n.stationName} time=${n.timeMinutes}`)
      }
      if (n.trainId.length > 0) {
        const originNode = new RouteNode()
        originNode.stationName = origin
        originNode.timeMinutes = startMin
        originNode.trainId = ''
        originNode.prevNode = null
        originNode.costFromStart = 0
        n.prevNode = originNode
        n.costFromStart = n.timeMinutes - originNode.timeMinutes
      }
      heap.push(n)
    }

    // 主循环，每 3000 次迭代 yield 一次
    let iter = 0
    while (heap.size > 0 && results.length < maxResults && iter < 6000) {
      iter++

      if (iter % 400 === 0) {
        await new Promise<void>((r: Function) => setTimeout(r, 0))
      }

      const current = heap.pop()!
      const visitKey = `${current.stationName}|${current.trainId}|${current.dayIndex}`

      if (visited.has(visitKey)) continue
      visited.add(visitKey)

      if (current.stationName === destination) {
        console.info(`[RouteFinder] Reached ${destination}! train=${current.trainId}`)
        const result = RouteFinder.reconstructRoute(current, origin, startMin)
        console.info(`[RouteFinder] Reconstructed: ${result.segments.length} segments`)
        if (result.segments.length > 0) {
          results.push(result)
        }
        continue
      }

      const neighbors = GraphBuilder.expandNode(current, minTransferMinutes, maxTransfers, destination)
      for (let ni = 0; ni < neighbors.length; ni++) {
        const neighbor = neighbors[ni]
        const nk = `${neighbor.stationName}|${neighbor.trainId}|${neighbor.dayIndex}`
        if (visited.has(nk)) continue
        const newTransfers = RouteFinder.countTransfers(neighbor)
        if (newTransfers > maxTransfers) continue
        // 车型筛选（含双编号）
        if (allowedTypes && allowedTypes.length > 0) {
          const typeChar = neighbor.trainId.charAt(0)
          const train = DataLoader.trains.get(neighbor.trainId)
          const dualChar = train?.trainIdDual?.charAt(0) ?? ''
          if (allowedTypes.indexOf(typeChar) < 0 && (dualChar.length === 0 || allowedTypes.indexOf(dualChar) < 0)) continue
        }
        heap.push(neighbor)
      }
    }

    console.info(`[RouteFinder] Done: ${results.length} routes, ${iter} iterations`)
    return results
  }

  // 计算路径中的换乘次数
  private static countTransfers(node: RouteNode): number {
    let count = 0
    let current: RouteNode | null = node
    while (current !== null && current.prevNode !== null) {
      if (current.trainId !== current.prevNode.trainId && current.prevNode.trainId.length > 0) {
        count++
      }
      current = current.prevNode
    }
    return count
  }

  // 重建路线 — 从时刻表取真实发车/到达时间
  private static reconstructRoute(endNode: RouteNode, origin: string, startMin: number): RouteResult {
    const path: RouteNode[] = []
    let cur: RouteNode | null = endNode
    while (cur !== null) {
      path.unshift(cur)
      cur = cur.prevNode
    }

    const segments: ItinerarySegment[] = []
    let lastSegmentEndStation: string = origin

    for (let i = 0; i < path.length; i++) {
      const node = path[i]
      if (node.trainId.length === 0) continue

      // 这条边从 lastSegmentEndStation → node.stationName，坐 node.trainId
      const train = DataLoader.trains.get(node.trainId)
      if (!train) continue

      // 找 lastSegmentEndStation 在 train 停站列表中的发车时间
      let depTime = ''
      let depDay = 0
      let arrTime = ''
      let arrDay = 0
      let foundDep = false

      for (let s = 0; s < train.stops.length; s++) {
        const stop = train.stops[s]
        if (stop.stationName === lastSegmentEndStation && !foundDep) {
          depTime = stop.departureTime
          depDay = stop.dayOffset
          foundDep = true
        }
        if (foundDep && stop.stationName === node.stationName) {
          arrTime = stop.arrivalTime
          arrDay = stop.dayOffset
          break
        }
      }

      if (depTime.length > 0 && arrTime.length > 0) {
        const seg = new ItinerarySegment()
        seg.trainId = node.trainId
        seg.fromStation = lastSegmentEndStation
        seg.toStation = node.stationName
        seg.departureDay = depDay
        seg.arrivalDay = arrDay
        seg.departureTime = depTime + (depDay > 0 ? ` +${depDay}` : '')
        seg.arrivalTime = arrTime + (arrDay > 0 ? ` +${arrDay}` : '')
        seg.durationMinutes = node.timeMinutes - (node.prevNode ? node.prevNode.timeMinutes : startMin)
        if (seg.durationMinutes < 0) seg.durationMinutes += MINUTES_PER_DAY
        seg.isTransfer = false
        segments.push(seg)
      }

      lastSegmentEndStation = node.stationName
    }

    // 计算换乘间隙
    for (let si = 1; si < segments.length; si++) {
      const prevSeg = segments[si - 1]
      const currSeg = segments[si]
      const prevArrAbs = prevSeg.arrivalDay * MINUTES_PER_DAY + RouteFinder.parseTimeToMin(prevSeg.arrivalTime.replace(/ \+\d+/, ''))
      const currDepAbs = currSeg.departureDay * MINUTES_PER_DAY + RouteFinder.parseTimeToMin(currSeg.departureTime.replace(/ \+\d+/, ''))
      let gap = currDepAbs - prevArrAbs
      if (gap < 0) gap += MINUTES_PER_DAY
      currSeg.transferMinutes = gap
      currSeg.isTransfer = true
      if (prevSeg.arrivalDay !== currSeg.departureDay) {
        currSeg.transferType = 'overnight'
      } else if (gap > 120) {
        currSeg.transferType = 'long_wait'
      } else {
        currSeg.transferType = 'same_station'
      }
    }

    const result = new RouteResult()
    result.segments = segments
    if (segments.length > 0) {
      result.departureTime = segments[0].departureTime
      result.arrivalTime = segments[segments.length - 1].arrivalTime
      // 计算总耗时
      let total = 0
      for (let si = 0; si < segments.length; si++) total += segments[si].durationMinutes
      result.totalTimeMinutes = total
      result.transferCount = Math.max(0, segments.length - 1)
    }
    return result
  }

  // ── 阶段 1：直达扫描（零 Dijkstra，O(n) 扫描出发索引）──
  static findDirectRoutes(origin: string, destination: string, startHour: number = 0): RouteResult[] {
    const deps = DataLoader.stationDepartures.get(origin)
    if (!deps || deps.length === 0) return []

    const startMin = startHour * 60
    const startDayMin = startMin % MINUTES_PER_DAY
    const visitedTrains: Set<string> = new Set()
    const results: RouteResult[] = []

    // 从出发时间开始扫描，找直达目的地的车次
    let idx = GraphBuilder.lowerBound(deps, startDayMin)
    const scanEnd = Math.min(idx + 3000, deps.length)

    for (let i = idx; i < scanEnd; i++) {
      const dep = deps[i]
      if (dep.departureMin - startDayMin > MINUTES_PER_DAY) break

      if (dep.arrivalStation === destination && !visitedTrains.has(dep.trainId)) {
        visitedTrains.add(dep.trainId)

        const train = DataLoader.trains.get(dep.trainId)
        if (!train) continue

        let departureTime = ''
        let arrivalTime = ''
        let depDay = 0
        let arrDay = 0

        for (let s = 0; s < train.stops.length; s++) {
          const stop = train.stops[s]
          if (stop.stationName === origin && departureTime.length === 0) {
            departureTime = stop.departureTime
            depDay = stop.dayOffset
          }
          if (stop.stationName === destination) {
            arrivalTime = stop.arrivalTime
            arrDay = stop.dayOffset
            break
          }
        }

        if (departureTime.length > 0 && arrivalTime.length > 0) {
          const seg = new ItinerarySegment()
          seg.trainId = dep.trainId
          seg.fromStation = origin
          seg.toStation = destination
          seg.departureDay = depDay
          seg.arrivalDay = arrDay
          seg.departureTime = departureTime + (depDay > 0 ? ` +${depDay}` : '')
          seg.arrivalTime = arrivalTime + (arrDay > 0 ? ` +${arrDay}` : '')
          const dur = (arrDay - depDay) * MINUTES_PER_DAY +
            (RouteFinder.parseTimeToMin(arrivalTime) - RouteFinder.parseTimeToMin(departureTime))
          seg.durationMinutes = dur >= 0 ? dur : dur + MINUTES_PER_DAY
          seg.isTransfer = false

          const result = new RouteResult()
          result.segments = [seg]
          result.departureTime = seg.departureTime
          result.arrivalTime = seg.arrivalTime
          result.totalTimeMinutes = seg.durationMinutes
          result.transferCount = 0
          results.push(result)
        }

        if (results.length >= 10) break
      }
    }

    // 按总耗时升序
    results.sort((a, b) => a.totalTimeMinutes - b.totalTimeMinutes)
    return results
  }

  private static parseTimeToMin(t: string): number {
    if (t.length < 5) return 0
    const h = parseInt(t.substring(0, 2))
    const m = parseInt(t.substring(3, 5))
    return isNaN(h) || isNaN(m) ? 0 : h * 60 + m
  }

  private static minToTime(min: number): string {
    let m = min % MINUTES_PER_DAY
    if (m < 0) m += MINUTES_PER_DAY
    const h = Math.floor(m / 60)
    const mi = m % 60
    return `${h.toString().padStart(2, '0')}:${mi.toString().padStart(2, '0')}`
  }
}