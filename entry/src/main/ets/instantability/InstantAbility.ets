import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { LocalStore } from '../data/LocalStore'
import { GlobalThis } from '../utils/GlobalThis'

const DOMAIN = 0x0000

export default class InstantAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'OnTrack', 'InstantAbility onCreate')
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'OnTrack', 'InstantAbility onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LocalStore.init(this.context)

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'OnTrack', `Failed to load: ${JSON.stringify(err)}`)
      }
    })

    setTimeout(() => {
      try {
        const rm = this.context.resourceManager
        GlobalThis.rawStationCoordsBytes = rm.getRawFileContentSync('station_coords.txt')
        GlobalThis.rawSameCityBytes = rm.getRawFileContentSync('same_city.txt')
        GlobalThis.rawFalseSameCityBytes = rm.getRawFileContentSync('false_same_city.txt')
        GlobalThis.rawDualNumbersBytes = rm.getRawFileContentSync('train_dual_numbers.txt')
        setTimeout(() => {
          GlobalThis.rawScheduleBytes = rm.getRawFileContentSync('train_schedule.txt')
          GlobalThis.rawDataReady = true
        }, 0)
      } catch (err) {
        hilog.error(DOMAIN, 'OnTrack', `I/O failed: ${JSON.stringify(err)}`)
      }
    }, 100)
  }

  onWindowStageDestroy(): void {}
  onForeground(): void {}
  onBackground(): void {}
}
