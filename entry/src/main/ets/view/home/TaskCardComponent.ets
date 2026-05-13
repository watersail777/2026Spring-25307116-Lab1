import { TaskMapById } from '../../model/TaskInitList';
import { CustomTaskDef, getCustomTaskById } from '../../model/CustomTaskStore';
import HealthText from '../../view/HealthTextComponent';
import { CommonConstants as Const } from '../../common/constants/CommonConstants';
import TaskInfo from '../../viewmodel/TaskInfo';

@Styles
function allSize() {
  .width(Const.THOUSANDTH_1000)
  .height(Const.THOUSANDTH_1000)
}

@Extend(Text)
function labelTextStyle() {
  .fontSize($r('app.float.default_16'))
  .fontWeight(Const.FONT_WEIGHT_500)
  .opacity(Const.OPACITY_6)
  .fontFamily($r('app.string.HarmonyHeiTi'))
}

@Component
export struct TaskCard {
  @Prop taskInfoStr: string = '';
  @Prop customTaskName: string = '';
  @Prop customTaskIcon: string = '';
  clickAction: Function = (isClick: boolean) => {};
  @State taskInfo: TaskInfo = new TaskInfo(-1, '', -1, '', false, '', '', '', false, '', false);
  @State isCustom: boolean = false;

  aboutToAppear() {
    this.taskInfo = JSON.parse(this.taskInfoStr);
    this.isCustom = this.taskInfo.taskID >= 8;
  }

  @Builder
  targetValueBuilder() {
    Row() {
      if(this.taskInfo.finValue != '') {
        HealthText({
          title: this.taskInfo.finValue,
          fontSize: $r('app.float.default_24')
        })
        Text(` / `)
          .labelTextStyle()
          .fontWeight(Const.FONT_WEIGHT_400)
      }

      Text(`${this.taskInfo.targetValue} ${this.isCustom ? '' : TaskMapById[this.taskInfo.taskID - 1]?.unit || ''}`)
        .labelTextStyle()
        .fontWeight(Const.FONT_WEIGHT_400)

      if (this.taskInfo.isDone){
        Text($r('app.string.task_done'))
          .fontColor($r('app.color.proGressColor'))
          .fontSize($r('app.float.default_18'))
          .fontWeight(Const.FONT_WEIGHT_700)}else{
        Progress({ value: Number(this.taskInfo.finValue)*100, total: Number(this.taskInfo.targetValue)*100, type: ProgressType.ScaleRing })
          .width($r('app.float.default_36')).height($r('app.float.default_36'))
          .color($r('app.color.proGressColor'))
          .backgroundColor($r('app.color.proGressBgColor'))
          .style({ strokeWidth: 15, scaleCount: 20, scaleWidth: 9 })
      }
    }
  }

  build() {
    Row() {
      Row({ space: Const.DEFAULT_6 }) {
        if (this.isCustom && this.customTaskIcon) {
          Text(this.customTaskIcon)
            .fontSize(24)
            .margin({ right: 4 });
        } else if (!this.isCustom) {
          Image(TaskMapById[this.taskInfo.taskID - 1]?.icon)
            .width($r('app.float.default_36')).height($r('app.float.default_36'))
            .objectFit(ImageFit.Contain)
        }

        if (this.isCustom && this.customTaskName) {
          HealthText({
            title: this.customTaskName,
            fontFamily: $r('app.string.HarmonyHeiTi')
          })
        } else if (!this.isCustom) {
          HealthText({
            title: '',
            titleResource: TaskMapById[this.taskInfo.taskID - 1]?.taskName,
            fontFamily: $r('app.string.HarmonyHeiTi')
          })
        }
      }

      this.targetValueBuilder();
    }
    .allSize()
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius($r('app.float.default_24'))
    .padding({ left: Const.THOUSANDTH_50, right: Const.THOUSANDTH_33 })
    .backgroundColor($r('app.color.white'))
    .onClick(() => this.clickAction(true))
    .gesture(LongPressGesture().onAction(() => this.clickAction(false)))
  }
}
