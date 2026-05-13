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

    // 追加创建入口（taskID=0 作为标记）
    const addEntry: ITaskItem = {
      taskID: 0,
      taskName: $r('app.string.empty'),
      isOpen: false,
      unit: '',
      icon: $r('app.media.ic_task_morning'),
      dialogBg: $r('app.media.ic_dialog_getup'),
      targetValue: '',
      isAlarm: false,
      startTime: '',
      endTime: '',
      frequency: '',
      isInit: true,
      step: 0,
      finValue: '',
      customName: `🎨 创建自定义任务（最多${getMaxCustomCount()}个）`,
      customIcon: '🎨',
      customUnit: ''
    };
    mergedList.push(addEntry);

    this.taskList = mergedList;

    getAllTask().then((res: TaskInfo[]) => {
      let deepCopyDataStr = JSON.stringify(this.taskList);
      let deepCopyData: ITaskItem[] = JSON.parse(deepCopyDataStr);
      this.taskList = taskIndexDataInit(deepCopyData, res);
    })
  }

  build() {
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
  }
}
