import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { LocalStore } from '../../data/LocalStore'

interface FavRouteInfo {
  fromTo: string
  time: string
  trains: string
}

interface RouteSegJson {
  fromStation: string
  toStation: string
  trainId: string
}

interface RouteJson {
  segments: Array<RouteSegJson>
  totalTimeMinutes: number
}

function parseFavRoute(json: string): FavRouteInfo {
  try {
    const r: RouteJson = JSON.parse(json) as RouteJson
    const segs = r.segments
    if (!segs || segs.length === 0) {
      const empty: FavRouteInfo = { fromTo: '暂无', time: '', trains: '' }
      return empty
    }
    const from = segs[0].fromStation ?? ''
    const to = segs[segs.length - 1].toStation ?? ''
    const totalMin = r.totalTimeMinutes ?? 0
    let time = ''
    if (totalMin >= 1440) {
      const d = Math.floor(totalMin / 1440)
      const remain = totalMin % 1440
      const h = Math.floor(remain / 60)
      time = `${d}d${h}h`
    } else if (totalMin >= 60) {
      time = `${Math.floor(totalMin / 60)}h`
    } else {
      time = `${totalMin}m`
    }
    const trainIds: string[] = []
    for (let i = 0; i < segs.length; i++) {
      const tid = segs[i].trainId
      if (tid && tid.length > 0) trainIds.push(tid)
    }
    const result: FavRouteInfo = { fromTo: `${from} → ${to}`, time: time, trains: trainIds.join(' → ') }
    return result
  } catch (_) {
    const fallback: FavRouteInfo = { fromTo: '数据损坏', time: '', trains: '' }
    return fallback
  }
}

export default class EntryFormAbility extends FormExtensionAbility {
  private buildData(): formBindingData.FormBindingData {
    const favs = LocalStore.getFavorites()
    const r1: FavRouteInfo = favs.length > 0 ? parseFavRoute(favs[0]) : { fromTo: '暂无收藏', time: '', trains: '' }
    const r2: FavRouteInfo = favs.length > 1 ? parseFavRoute(favs[1]) : { fromTo: '', time: '', trains: '' }
    const r3: FavRouteInfo = favs.length > 2 ? parseFavRoute(favs[2]) : { fromTo: '', time: '', trains: '' }

    const data: Record<string, string> = {
      'route1': r1.fromTo,
      'route1Time': r1.time,
      'route1Trains': r1.trains,
      'route2': r2.fromTo,
      'route2Time': r2.time,
      'route2Trains': r2.trains,
      'route3': r3.fromTo,
      'route3Time': r3.time,
      'route3Trains': r3.trains,
      'favCount': favs.length.toString(),
      'isEmpty': (favs.length === 0).toString()
    }
    return formBindingData.createFormBindingData(data)
  }

  onAddForm(want: Want): formBindingData.FormBindingData {
    return this.buildData()
  }

  onUpdateForm(formId: string): void {
    formProvider.updateForm(formId, this.buildData())
  }
}
