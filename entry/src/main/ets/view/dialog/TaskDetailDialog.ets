import { CustomDialogCallback } from './CustomDialogView';
import TaskInfo from '../../viewmodel/TaskInfo';
import { TaskMapById } from '../../model/TaskInitList';
import { getCustomTaskSync } from '../../model/CustomTaskStore';
import { CommonConstants as Const } from '../../common/constants/CommonConstants';
import { GlobalContext } from '../../common/utils/GlobalContext';
import { CJCalendar, CJDateItem, OptMode, SelectedStyle } from 'cjcalendar'
import { HomeStore } from '../../viewmodel/HomeViewModel';

@Extend(Text)
function textStyle() {
  .fontColor($r('app.color.white'))
  .fontFamily($r('app.string.HarmonyHeiTi'))
}

@Extend(Text)
function taskTextStyle() {
  .fontColor($r('app.color.white'))
  .width('100%')
}

@CustomDialog
export struct TaskDetailDialog {
  @Link homeStore: HomeStore;
  controller: CustomDialogController = new CustomDialogController({ builder: '' });
  @Consume currentTask: TaskInfo;
  @State showButton: boolean = true;
  @Consume dialogCallBack: CustomDialogCallback;

  getDialogTaskName(): string | Resource {
    const tid: number = this.currentTask?.taskID || 0;
    if (tid >= 1 && tid <= 7 && TaskMapById[tid - 1]) {
      return TaskMapById[tid - 1].taskName;
    }
    // 自定义任务：从缓存获取名称
    const def = getCustomTaskSync(tid);
    return def ? def.taskName : '';
  }

  getDialogBg(): Resource {
    const tid: number = this.currentTask?.taskID || 0;
    if (tid >= 1 && tid <= 7 && TaskMapById[tid - 1]) {
      return TaskMapById[tid - 1].dialogBg;
    }
    return $r('app.media.ic_dialog_getup');
  }

  build() {
    Column() {
      TaskBaseInfo({
        taskName: this.getDialogTaskName()
      });

      TaskClock({
        curTaskID:this.currentTask?.taskID,
        myMonthHomeStore:this.homeStore,
        confirm: () => {
          this.dialogCallBack.confirmCallback(this.currentTask);
          this.controller.close();
        },
        cancel: () => {
          this.controller.close();
        },
        showButton: this.showButton
      })
    }
    .height($r('app.float.default_451'))
    .width($r('app.float.default_316'))
    .backgroundImage(this.getDialogBg(), ImageRepeat.NoRepeat)
    .backgroundImageSize({
      width: '100%',
      height: '100%'
    })
    .justifyContent(FlexAlign.End)
    .padding({
      bottom: $r('app.float.default_12'),
      left: $r('app.float.default_20')
    })
  }
}

@Component
struct TaskBaseInfo {
  taskName: string | Resource = '';

  build() {
    Column({ space: Const.DEFAULT_8 }) {
      Text(this.taskName)
        .fontSize($r('app.float.default_22'))
        .fontWeight(FontWeight.Bold)
        .fontFamily($r('app.string.HarmonyHeiTi_Bold'))
        .taskTextStyle()
        .margin({ left: $r('app.float.default_12') })
    }
    .position({ y: $r('app.float.default_267') })
  }
}

@Component
struct TaskClock {
  curTaskID:number=0;
  myMonthHomeStore:HomeStore=  new HomeStore(new Date());
  confirm: Function = () => {};
  cancel: Function = () => {};
  showButton: boolean = false;

  getAchieveDate() {
    let selectedItems: Array<string | Date> = [];
    for (let dayTaskInfoList of this.myMonthHomeStore.MonthTaskListArr) {
      if(dayTaskInfoList.length!=0){
        let filteredDayTaskInfoList = dayTaskInfoList.filter((taskItem) =>
        (taskItem.taskID === this.curTaskID) && taskItem.isDone
        );
        filteredDayTaskInfoList.forEach(element => {
          selectedItems.push(element.date)
        });
      }
    }
    return selectedItems;
  }

  build() {
    Column({ space: Const.DEFAULT_12 }) {
      CJCalendar({
        defSelectedItems: this.getAchieveDate()
      })
      Button() {
        Text($r('app.string.clock_in'))
          .height($r('app.float.default_42'))
          .fontSize($r('app.float.default_20'))
          .fontWeight(FontWeight.Normal)
          .textStyle()
      }
      .width($r('app.float.default_220'))
      .borderRadius($r('app.float.default_24'))
      .backgroundColor('rgba(255,255,255,0.40)')
      .onClick(() => {
        GlobalContext.getContext().setObject('taskListChange', true);
        this.confirm();
      })
      .visibility(!this.showButton ? Visibility.None : Visibility.Visible)
      Text($r('app.string.got_it'))
        .fontSize($r('app.float.default_14'))
        .fontWeight(FontWeight.Regular)
        .textStyle()
        .onClick(() => {
          this.cancel();
        })
    }.alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }
}
