import { RouteResult, ItinerarySegment } from './DataModels'
import { LocalStore } from '../data/LocalStore'
import { DataLoader } from '../data/DataLoader'
import { RouteFinder } from '../data/RouteFinder'

// ═══════════════════════════════════════
// 全局 ViewModel — @ObservedV2 状态中心
// ═══════════════════════════════════════

@ObservedV2
export class AppViewModel {
  // ── Tab ──
  @Trace currentTab: number = 0            // 0=Search, 1=Results

  // ── 查询表单 ──
  @Trace departureStation: string = ''
  @Trace arrivalStation: string = ''
  @Trace queryDate: string = ''            // "YYYY-MM-DD"

  // ── 搜索结果 ──
  @Trace searchResults: RouteResult[] = []
  @Trace selectedResultIndex: number = 0
  @Trace isLoading: boolean = false
  @Trace isDataReady: boolean = false

  // ── UI 状态 ──
  @Trace showDetail: boolean = false
  @Trace selectedSegmentIndex: number = 0
  @Trace toastMsg: string = ''
  @Trace recentQueries: string[] = []
  @Trace favorites: RouteResult[] = []

  // ── 收藏 ──

  loadFavorites(): void {
    const raw = LocalStore.getFavorites()
    this.favorites = []
    for (let i = 0; i < raw.length; i++) {
      try {
        const parsed = JSON.parse(raw[i]) as RouteResult
        this.favorites.push(parsed)
      } catch (_) {
        // 跳过损坏条目
      }
    }
  }

  removeFavorite(index: number): void {
    if (index < 0 || index >= this.favorites.length) return
    const json = JSON.stringify(this.favorites[index])
    LocalStore.toggleFavorite(json)
    this.loadFavorites()
    this.showToast('已删除收藏')
  }

  isRouteFavorited(route: RouteResult): boolean {
    const json = JSON.stringify(route)
    const raw = LocalStore.getFavorites()
    return raw.indexOf(json) >= 0
  }

  reSearchFromFavorite(route: RouteResult): void {
    if (route.segments.length === 0) return
    this.departureStation = route.segments[0].fromStation
    this.arrivalStation = route.segments[route.segments.length - 1].toStation
    this.currentTab = 0
    this.search()
  }

  toggleFavorite(route: RouteResult): boolean {
    const json = JSON.stringify(route)
    const added = LocalStore.toggleFavorite(json)
    this.loadFavorites()
    return added
  }

  @Trace loadingProgress: number = 0
  @Trace loadingText: string = ''

  // ── 筛选 ──
  @Trace maxTransfers: number = 7
  @Trace minTransferGap: number = 15
  @Trace filterG: boolean = true
  @Trace filterD: boolean = true
  @Trace filterC: boolean = true
  @Trace filterZ: boolean = true
  @Trace filterT: boolean = true
  @Trace filterK: boolean = true
  @Trace directOnly: boolean = false
  @Trace isTablet: boolean = false
  @Trace showFilter: boolean = false

  init(): void {
    this.recentQueries = LocalStore.getRecentQueries()
    this.loadFavorites()
    // DataLoader.loadAllAsync is called from Index.ets directly
    if (DataLoader.isLoaded) {
      this.isDataReady = true
    }
  }

  refreshProgress(): void {
    this.loadingProgress = DataLoader.progress
    this.loadingText = DataLoader.progressText
  }

  // ── 查询 ──

  search(): void {
    const dep = this.departureStation.trim()
    const arr = this.arrivalStation.trim()
    if (dep.length === 0 || arr.length === 0) {
      this.showToast('请输入出发站和到达站')
      return
    }
    if (dep === arr) {
      this.showToast('出发站和到达站不能相同')
      return
    }

    // 站到站精确匹配：不展开同城候选
    const depCandidates: string[] = DataLoader.stations.has(dep) ? [dep] : DataLoader.searchStations(dep, 1)
    const arrCandidates: string[] = DataLoader.stations.has(arr) ? [arr] : DataLoader.searchStations(arr, 1)

    if (depCandidates.length === 0) { this.showToast(`未找到车站: ${dep}`); return }
    if (arrCandidates.length === 0) { this.showToast(`未找到车站: ${arr}`); return }

    // 记住用户原始输入，用于无结果时的建议
    const originalDep = dep
    const originalArr = arr

    // 显示匹配到的确切站名
    this.departureStation = depCandidates[0]
    this.arrivalStation = arrCandidates[0]

    this.isLoading = true
    this.searchResults = []

    setTimeout(async () => {
      try {
        const types: string[] = []
        if (this.filterG) types.push('G')
        if (this.filterD) types.push('D')
        if (this.filterC) types.push('C')
        if (this.filterZ) types.push('Z')
        if (this.filterT) types.push('T')
        if (this.filterK) types.push('K')
        const typeFilter = types.length < 6 ? types : undefined

        let allResults: RouteResult[] = []

        // ═══ 阶段 1：直达扫描（O(n)，零 Dijkstra） ═══
        console.info('[AppViewModel] Stage 1: direct scan')
        for (let di = 0; di < depCandidates.length; di++) {
          for (let ai = 0; ai < arrCandidates.length; ai++) {
            if (depCandidates[di] === arrCandidates[ai]) continue
            const direct = RouteFinder.findDirectRoutes(depCandidates[di], arrCandidates[ai], 0)
            console.info(`[AppViewModel] direct ${depCandidates[di]} → ${arrCandidates[ai]}: ${direct.length} results`)
            for (let bi = 0; bi < direct.length; bi++) allResults.push(direct[bi])
          }
        }

        // 过滤车型（含双编号）
        if (typeFilter) {
          allResults = allResults.filter((r: RouteResult) => {
            return r.segments.every((s: ItinerarySegment) => {
              const typeChar = s.trainId.charAt(0)
              const train = DataLoader.trains.get(s.trainId)
              const dualChar = train?.trainIdDual?.charAt(0) ?? ''
              return typeFilter!.indexOf(typeChar) >= 0 ||
                (dualChar.length > 0 && typeFilter!.indexOf(dualChar) >= 0)
            })
          })
        }

        // ═══ 阶段 2：Dijkstra 换乘搜索（直达不足或未开"仅直达"时触发） ═══
        if (!this.directOnly) {
          console.info('[AppViewModel] Stage 2: Dijkstra fallback')
          for (let di = 0; di < depCandidates.length; di++) {
            for (let ai = 0; ai < arrCandidates.length; ai++) {
              if (depCandidates[di] === arrCandidates[ai]) continue
              console.info(`[AppViewModel] Dijkstra: ${depCandidates[di]} → ${arrCandidates[ai]}`)
              const batch = await RouteFinder.findRoutes(
                depCandidates[di], arrCandidates[ai], 0, this.maxTransfers, this.minTransferGap, 5, typeFilter
              )
              for (let bi = 0; bi < batch.length; bi++) allResults.push(batch[bi])
            }
          }
        }

        // 去重（同车次同出发到达的只保留耗时最短）
        const seen: Set<string> = new Set()
        const deduped: RouteResult[] = []
        for (let ri = 0; ri < allResults.length; ri++) {
          const r = allResults[ri]
          const key = r.segments.map((s: ItinerarySegment) => `${s.trainId}|${s.fromStation}|${s.toStation}`).join('>>')
          if (!seen.has(key)) {
            seen.add(key)
            deduped.push(r)
          }
        }

        deduped.sort((a, b) => a.transferCount - b.transferCount || a.totalTimeMinutes - b.totalTimeMinutes)
        this.searchResults = deduped

        this.selectedResultIndex = 0
        LocalStore.addRecentQuery(this.departureStation, this.arrivalStation)
        this.recentQueries = LocalStore.getRecentQueries()
      } catch (e) {
        console.error(`[AppViewModel] search error: ${e}`)
        this.showToast('查询出错，请重试')
      } finally {
        this.isLoading = false
        if (this.searchResults.length > 0) {
          // 平板模式不切 tab（双栏同时可见）
          if (!this.isTablet) this.currentTab = 1
        } else {
          this.showNoResultFeedback(originalDep, originalArr, depCandidates, arrCandidates)
        }
      }
    }, 50)
  }

  // ── 无结果时的智能建议 ──
  private showNoResultFeedback(
    dep: string, arr: string,
    depCandidates: string[], arrCandidates: string[]
  ): void {
    // 收集同城站信息
    const depSameCity: string[] = []
    const arrSameCity: string[] = []
    for (let i = 0; i < DataLoader.sameCityPairs.length; i++) {
      const pair = DataLoader.sameCityPairs[i]
      for (let ci = 0; ci < depCandidates.length; ci++) {
        if (pair[0] === depCandidates[ci] && depSameCity.indexOf(pair[1]) < 0) depSameCity.push(pair[1])
        if (pair[1] === depCandidates[ci] && depSameCity.indexOf(pair[0]) < 0) depSameCity.push(pair[0])
      }
      for (let ci = 0; ci < arrCandidates.length; ci++) {
        if (pair[0] === arrCandidates[ci] && arrSameCity.indexOf(pair[1]) < 0) arrSameCity.push(pair[1])
        if (pair[1] === arrCandidates[ci] && arrSameCity.indexOf(pair[0]) < 0) arrSameCity.push(pair[0])
      }
    }

    let tips = `未找到 ${dep} → ${arr} 的路线。`

    if (depCandidates.length > 1) {
      tips += `\n出发站"${dep}"可试: ${depCandidates.slice(0, 4).join('、')}`
    }
    if (arrCandidates.length > 1) {
      tips += `\n到达站"${arr}"可试: ${arrCandidates.slice(0, 4).join('、')}`
    }
    if (depSameCity.length > 0) {
      tips += `\n同城出发站: ${depSameCity.slice(0, 3).join('、')}`
    }
    if (arrSameCity.length > 0) {
      tips += `\n同城到达站: ${arrSameCity.slice(0, 3).join('、')}`
    }
    tips += `\n试试更宽泛的城市名（如"广州"而非"广州南"）`

    this.showToast(tips, 6000)
  }

  // ── 导航 ──

  switchTab(idx: number): void {
    this.currentTab = idx
  }

  selectResult(idx: number): void {
    if (idx >= 0 && idx < this.searchResults.length) {
      this.selectedResultIndex = idx
    }
  }

  openDetail(segIdx: number): void {
    this.selectedSegmentIndex = segIdx
    this.showDetail = true
  }

  closeDetail(): void {
    this.showDetail = false
  }

  // ── Toast ──

  showToast(msg: string, durationMs: number = 2000): void {
    this.toastMsg = msg
    setTimeout(() => { this.toastMsg = '' }, durationMs)
  }

  // ── 收藏（向后兼容）

  toggleFavoriteCurrent(): void {
    if (this.searchResults.length === 0) return
    const result = this.searchResults[this.selectedResultIndex]
    const added = this.toggleFavorite(result)
    this.showToast(added ? '已收藏' : '已取消')
  }
}