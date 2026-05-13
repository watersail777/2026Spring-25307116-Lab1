import { router } from '@kit.ArkUI';
import { ITaskItem } from '../model/TaskInitList';
import TaskList from '../view/task/TaskListComponent';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { getAllTask, taskIndexDataInit, taskOriginData } from '../viewmodel/TaskViewModel';
import TaskInfo from '../viewmodel/TaskInfo';
import { getMaxCustomCount, getCustomTasks, CustomTaskDef } from '../model/CustomTaskStore';

@Entry
@Component
@Preview
struct TaskIndex {
  @Provide taskList: ITaskItem[] = taskOriginData;

  async onPageShow() {
    // 加载自定义任务并合并到列表
    const customTasks: CustomTaskDef[] = await getCustomTasks();
    let mergedList: ITaskItem[] = JSON.parse(JSON.stringify(taskOriginData));
    for (let i: number = 0; i < customTasks.length; i++) {
      const ct: CustomTaskDef = customTasks[i];
      const customItem: ITaskItem = {
        taskID: ct.taskID,
        taskName: $r('app.string.empty'),
        isOpen: false,
        unit: ct.unit,
        icon: $r('app.media.ic_task_morning'),
        dialogBg: $r('app.media.ic_dialog_getup'),
        targetValue: ct.targetValue,
        isAlarm: false,
        startTime: '08:00',
        endTime: '00:00',
        frequency: '1,2,3,4,5,6,7',
        isInit: true,
        step: ct.step,
        finValue: '0',
        customName: ct.taskName,
        customIcon: ct.icon,
        customUnit: ct.unit
      };
      mergedList.push(customItem);
    }

    this.taskList = mergedList;

    getAllTask().then((res: TaskInfo[]) => {
      let deepCopyDataStr = JSON.stringify(this.taskList);
      let deepCopyData: ITaskItem[] = JSON.parse(deepCopyDataStr);
      this.taskList = taskIndexDataInit(deepCopyData, res);
    })
  }

  build() {
    Stack() {
      Row() {
        Navigation() {
          Column() {
            TaskList()
          }
          .width(Const.THOUSANDTH_1000)
          .justifyContent(FlexAlign.Center)
        }
        .size({ width: Const.THOUSANDTH_1000, height: Const.THOUSANDTH_1000 })
        .title(Const.ADD_TASK_TITLE)
        .titleMode(NavigationTitleMode.Mini)
      }
      .backgroundColor($r('app.color.primaryBgColor'))
      .height(Const.THOUSANDTH_1000)

      // 自定义任务入口 - 悬浮在底部
      Row() {
        Text('🎨')
          .fontSize(20)
          .margin({ right: 10 });
        Column() {
          Text('创建自定义任务')
            .fontSize(15)
            .fontWeight(Const.FONT_WEIGHT_500)
            .fontColor($r('app.color.titleColor'));
          Text(`突破7项预设，创建专属任务（最多${getMaxCustomCount()}个）`)
            .fontSize(11)
            .fontColor($r('app.color.tabTitleColor'))
            .margin({ top: 2 });
        }
        .alignItems(HorizontalAlign.Start);
        Blank();
        Image($r('app.media.ic_right_grey'))
          .width(16)
          .height(16);
      }
      .width('92%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor($r('app.color.white'))
      .borderRadius(12)
      .shadow({ radius: 8, color: '#00000015', offsetX: 0, offsetY: -2 })
      .position({ x: '4%', y: '85%' })
      .onClick(() => {
        router.pushUrl({ url: 'pages/CustomTaskCreatePage' });
      });
    }
    .height(Const.THOUSANDTH_1000)
  }
}
