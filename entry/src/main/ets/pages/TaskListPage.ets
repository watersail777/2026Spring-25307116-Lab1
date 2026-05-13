import { router } from '@kit.ArkUI';
import { ITaskItem } from '../model/TaskInitList';
import TaskList from '../view/task/TaskListComponent';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { getAllTask, taskIndexDataInit, taskOriginData } from '../viewmodel/TaskViewModel';
import TaskInfo from '../viewmodel/TaskInfo';
import { getMaxCustomCount } from '../model/CustomTaskStore';

@Entry
@Component
@Preview
struct TaskIndex {
  @Provide taskList: ITaskItem[] = taskOriginData;

  onPageShow() {
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

          // 自定义任务入口
          Row() {
            Text('🎨')
              .fontSize(20)
              .margin({ right: 10 });
            Column() {
              Text('创建自定义任务')
                .fontSize(15)
                .fontWeight(Const.FONT_WEIGHT_500)
                .fontColor($r('app.color.titleColor'));
              Text(`突破7项预设，创建你的专属健康任务（最多${getMaxCustomCount()}个）`)
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
          .width(Const.THOUSANDTH_1000)
          .padding({ left: $r('app.float.default_24'), right: $r('app.float.default_24'), top: 12, bottom: 12 })
          .backgroundColor($r('app.color.white'))
          .borderRadius($r('app.float.default_12'))
          .margin({ left: $r('app.float.default_12'), right: $r('app.float.default_12'), top: 16 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/CustomTaskCreatePage' });
          });
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
