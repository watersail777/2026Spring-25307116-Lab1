import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { LocalStore } from '../data/LocalStore'

const DOMAIN = 0x0000

export default class InstantAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    } catch (err) {
      hilog.error(DOMAIN, 'Zhiyu', 'Failed to set colorMode: %{public}s', JSON.stringify(err))
    }
    hilog.info(DOMAIN, 'Zhiyu', 'InstantAbility onCreate')
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'Zhiyu', 'InstantAbility onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LocalStore.init(this.context)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'Zhiyu', `Failed to load: ${JSON.stringify(err)}`)
      }
    })
  }

  onWindowStageDestroy(): void {}
  onForeground(): void {}
  onBackground(): void {}
}
