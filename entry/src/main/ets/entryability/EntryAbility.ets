import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { LocalStore } from '../data/LocalStore'
import { GlobalThis } from '../utils/GlobalThis'

const DOMAIN = 0x0000

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    } catch (err) {
      hilog.error(DOMAIN, 'OnTrack', 'Failed to set colorMode: %{public}s', JSON.stringify(err))
    }
    hilog.info(DOMAIN, 'OnTrack', 'Ability onCreate')
    this.handleWidgetDeepLink(want)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'OnTrack', 'Ability onNewWant')
    this.handleWidgetDeepLink(want)
  }

  private handleWidgetDeepLink(want: Want): void {
    if (want.parameters) {
      const tabParam = want.parameters['tab'] as string
      if (tabParam && tabParam.length > 0) {
        AppStorage.setOrCreate('launchTab', parseInt(tabParam))
      }
    }
  }

  onContinue(wantParams: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, 'OnTrack', 'Ability onContinue')
    wantParams['continueTab'] = AppStorage.get<number>('currentTab') ?? 0
    return AbilityConstant.OnContinueResult.AGREE
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'OnTrack', 'Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'OnTrack', 'onWindowStageCreate start')

    LocalStore.init(this.context)

    // 1. 立即渲染 splash
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'OnTrack', `Failed to load content: ${JSON.stringify(err)}`)
      }
    })

    // 2. 分步读文件：大文件单独读(yield)，小文件合批
    setTimeout(() => {
      try {
        const rm = this.context.resourceManager
        // Step A: 先读 4 个小文件（~250KB，<200ms）
        GlobalThis.rawStationCoordsBytes = rm.getRawFileContentSync('station_coords.txt')
        GlobalThis.rawSameCityBytes = rm.getRawFileContentSync('same_city.txt')
        GlobalThis.rawFalseSameCityBytes = rm.getRawFileContentSync('false_same_city.txt')
        GlobalThis.rawDualNumbersBytes = rm.getRawFileContentSync('train_dual_numbers.txt')
        hilog.info(DOMAIN, 'OnTrack', 'Small files loaded')

        // Step B: yield → 读大文件（2.8MB，单独阻塞）
        setTimeout(() => {
          GlobalThis.rawScheduleBytes = rm.getRawFileContentSync('train_schedule.txt')
          GlobalThis.rawDataReady = true
          hilog.info(DOMAIN, 'OnTrack', `All files loaded: ${GlobalThis.rawScheduleBytes.length} bytes`)
        }, 0)
      } catch (err) {
        hilog.error(DOMAIN, 'OnTrack', `I/O failed: ${JSON.stringify(err)}`)
      }
    }, 100)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}