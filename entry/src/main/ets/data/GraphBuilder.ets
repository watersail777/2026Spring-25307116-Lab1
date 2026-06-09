import { DepartureEntry } from '../model/DataModels'
import { RouteNode } from '../model/DataModels'
import { DataLoader } from './DataLoader'

// ═══════════════════════════════════════
// 图构建器 — 从 stationDepartures 索引即时生成邻接边
// ═══════════════════════════════════════

const MINUTES_PER_DAY = 1440
const MAX_WAIT_MINUTES = 1440  // 午夜起始查询时覆盖全天发车

export class GraphBuilder {

  // 获取从 origin 站出发的初始边（长途+中短途混合）
  static getInitialDepartures(origin: string, startMin: number): RouteNode[] {
    const deps = DataLoader.stationDepartures.get(origin)
    if (!deps || deps.length === 0) return []

    const startDayMin = startMin % MINUTES_PER_DAY
    const depList: DepartureEntry[] = []
    const durations: number[] = []

    let idx = GraphBuilder.lowerBound(deps, startDayMin)
    // 扫描 600 条
    const scanEnd = Math.min(idx + 600, deps.length)
    for (let i = idx; i < scanEnd; i++) {
      const dep = deps[i]
      if (dep.departureMin - startDayMin > MAX_WAIT_MINUTES) break
      depList.push(dep)
      const dur = dep.arrivalMin - dep.departureMin
      durations.push(dur >= 0 ? dur : dur + MINUTES_PER_DAY)
    }

    // 冒泡排序：行程时间降序（长途优先）
    for (let i = 0; i < depList.length; i++) {
      for (let j = i + 1; j < depList.length; j++) {
        if (durations[j] > durations[i]) {
          const tmpDep = depList[i]; depList[i] = depList[j]; depList[j] = tmpDep
          const tmpDur = durations[i]; durations[i] = durations[j]; durations[j] = tmpDur
        }
      }
    }

    const nodes: RouteNode[] = []
    // 取前 30 条最长途作为种子
    const limit = Math.min(30, depList.length)
    for (let i = 0; i < limit; i++) {
      const dep = depList[i]
      const node = new RouteNode()
      node.stationName = dep.arrivalStation
      node.timeMinutes = startMin + (dep.departureMin - startDayMin) + (dep.arrivalMin - dep.departureMin)
      if (node.timeMinutes < startMin) node.timeMinutes += MINUTES_PER_DAY
      node.dayIndex = 0
      node.trainId = dep.trainId
      node.prevNode = null
      node.costFromStart = node.timeMinutes - startMin
      nodes.push(node)
    }
    return nodes
  }

  // 从当前节点展开所有可能的下一跳
  static expandNode(
    node: RouteNode,
    minTransferMinutes: number,
    maxTransfers: number,
    destStation: string
  ): RouteNode[] {
    const results: RouteNode[] = []

    const currentTotalMin = node.timeMinutes
    const currentDayMin = currentTotalMin % MINUTES_PER_DAY

    const deps = DataLoader.stationDepartures.get(node.stationName)
    if (!deps || deps.length === 0) return results

    // 二分查找 >= currentDayMin + minTransferMinutes 的发车
    const earliestDep = currentDayMin + minTransferMinutes
    let idx = GraphBuilder.lowerBound(deps, earliestDep)

    // 先扫一遍：找直达目标站的车次（优先级最高）
    const end = Math.min(idx + 50, deps.length)
    for (let i = idx; i < end; i++) {
      const dep = deps[i]
      if (dep.arrivalStation === destStation) {
        let newMin = currentTotalMin
        if (dep.departureMin < currentDayMin) {
          newMin = (Math.floor(currentTotalMin / MINUTES_PER_DAY) + 1) * MINUTES_PER_DAY + dep.departureMin + (dep.arrivalMin - dep.departureMin)
        } else {
          newMin = Math.floor(currentTotalMin / MINUTES_PER_DAY) * MINUTES_PER_DAY + dep.departureMin + (dep.arrivalMin - dep.departureMin)
        }
        const newNode = new RouteNode()
        newNode.stationName = dep.arrivalStation
        newNode.timeMinutes = newMin
        newNode.dayIndex = Math.floor(newMin / MINUTES_PER_DAY)
        newNode.trainId = dep.trainId
        newNode.prevNode = node
        newNode.costFromStart = newMin - node.timeMinutes + node.costFromStart
        results.push(newNode)
      }
    }

    // 再扫普通展开（最多取 15 条）
    for (let i = idx; i < end; i++) {
      const dep = deps[i]

      if (dep.arrivalStation === destStation) continue // 上面已加

      let newMin = currentTotalMin
      if (dep.departureMin < currentDayMin) {
        newMin = (Math.floor(currentTotalMin / MINUTES_PER_DAY) + 1) * MINUTES_PER_DAY + dep.departureMin + (dep.arrivalMin - dep.departureMin)
      } else {
        newMin = Math.floor(currentTotalMin / MINUTES_PER_DAY) * MINUTES_PER_DAY + dep.departureMin + (dep.arrivalMin - dep.departureMin)
      }

      const newNode = new RouteNode()
      newNode.stationName = dep.arrivalStation
      newNode.timeMinutes = newMin
      newNode.dayIndex = Math.floor(newMin / MINUTES_PER_DAY)
      newNode.trainId = dep.trainId
      newNode.prevNode = node
      newNode.costFromStart = newMin - node.timeMinutes + node.costFromStart

      if (dep.arrivalStation !== node.stationName) {
        results.push(newNode)
      }

      if (results.length >= 6) break
    }

    // 同城换乘
    GraphBuilder.addSameCityTransfers(node, minTransferMinutes, results)

    return results
  }

  private static addSameCityTransfers(
    node: RouteNode,
    minTransferMinutes: number,
    results: RouteNode[]
  ): void {
    for (let i = 0; i < DataLoader.sameCityPairs.length; i++) {
      const pair = DataLoader.sameCityPairs[i]
      const s1 = pair[0]
      const s2 = pair[1]
      const transitMin = pair[2]
      let otherStation = ''
      if (s1 === node.stationName) {
        otherStation = s2
      } else if (s2 === node.stationName) {
        otherStation = s1
      } else {
        continue
      }

      // 检查是否是假同城
      const key1 = `${node.stationName}|${otherStation}`
      if (DataLoader.falseSameCityKeys.has(key1)) continue

      const deps = DataLoader.stationDepartures.get(otherStation)
      if (!deps || deps.length === 0) continue

      const readyMin = (node.timeMinutes % MINUTES_PER_DAY) + transitMin + minTransferMinutes
      let idx = GraphBuilder.lowerBound(deps, readyMin % MINUTES_PER_DAY)
      const end = Math.min(idx + 5, deps.length)
      for (let j = idx; j < end; j++) {
        const dep = deps[j]
        if (dep.departureMin - readyMin > 120) break // 不想等太久

        const newNode = new RouteNode()
        newNode.stationName = dep.arrivalStation
        newNode.timeMinutes = node.timeMinutes + transitMin + (dep.departureMin - (node.timeMinutes % MINUTES_PER_DAY)) + (dep.arrivalMin - dep.departureMin)
        newNode.dayIndex = Math.floor(newNode.timeMinutes / MINUTES_PER_DAY)
        newNode.trainId = dep.trainId
        newNode.prevNode = node
        newNode.costFromStart = node.costFromStart + (newNode.timeMinutes - node.timeMinutes)
        results.push(newNode)
      }
    }
  }

  // 二分查找第一个 departureMin >= target 的位置
  static lowerBound(deps: DepartureEntry[], target: number): number {
    let lo = 0
    let hi = deps.length
    while (lo < hi) {
      const mid = Math.floor((lo + hi) / 2)
      if (deps[mid].departureMin < target) {
        lo = mid + 1
      } else {
        hi = mid
      }
    }
    return lo
  }
}