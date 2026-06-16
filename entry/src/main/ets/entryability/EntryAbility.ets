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
      hilog.error(DOMAIN, 'Zhiyu', 'Failed to set colorMode: %{public}s', JSON.stringify(err))
    }
    hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onCreate')
    this.extractCardId(want)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onNewWant')
    this.extractCardId(want)
  }

  private extractCardId(want: Want): void {
    // 尝试从 URI 解析: zhiyu://.../card?id=xxx
    if (want.uri && want.uri.length > 0) {
      const idx = want.uri.indexOf('id=')
      if (idx >= 0) {
        GlobalThis.widgetCardId = want.uri.substring(idx + 3)
        hilog.info(DOMAIN, 'Zhiyu', 'widget cardId from URI: %{public}s', GlobalThis.widgetCardId)
        return
      }
    }
    // 降级：检查 params
    const params = want.parameters
    if (params) {
      const cid = params['cardId'] as string
      if (cid && cid.length > 0) {
        GlobalThis.widgetCardId = cid
        return
      }
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LocalStore.init(this.context)

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'Zhiyu', 'Failed to load content: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, 'Zhiyu', 'Succeeded in loading content')
    })
  }

  onContinue(wantParams: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onContinue')
    wantParams['continueTab'] = AppStorage.get<number>('currentTab') ?? 0
    wantParams['continueCardIndex'] = AppStorage.get<number>('currentCardIndex') ?? 0
    return AbilityConstant.OnContinueResult.AGREE
  }

  onDestroy(): void { hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onDestroy') }
  onWindowStageDestroy(): void { hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onWindowStageDestroy') }
  onForeground(): void { hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onForeground') }
  onBackground(): void { hilog.info(DOMAIN, 'Zhiyu', '%{public}s', 'Ability onBackground') }
}
