import { geoLocationManager } from '@kit.LocationKit'

export class LocationHelper {
  static async getLocationLabel(): Promise<string> {
    try {
      const location = await geoLocationManager.getCurrentLocation()
      return `附近 · ${location.latitude.toFixed(2)}, ${location.longitude.toFixed(2)}`
    } catch (_) {
      return '未知位置'
    }
  }

  static async getDistrictCode(): Promise<string> {
    try {
      const loc = await geoLocationManager.getCurrentLocation()
      return `DIST_${loc.latitude.toFixed(3)}_${loc.longitude.toFixed(3)}`
    } catch (_) {
      return ''
    }
  }
}
