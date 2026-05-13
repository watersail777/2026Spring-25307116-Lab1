/**
 * 自定义任务创建页面
 * 用户可创建最多5个个性化健康任务，突破7项预设限制
 */

import { router } from '@kit.ArkUI';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { CustomTaskDef, addCustomTask, getCustomTasks, deleteCustomTask, getMaxCustomCount } from '../model/CustomTaskStore';
import { promptAction } from '@kit.ArkUI';
import Logger from '../common/utils/Logger';

@Entry
@Component
struct CustomTaskCreatePage {
  @State taskName: string = '';
  @State targetValue: string = '';
  @State unit: string = '';
  @State step: string = '1';
  @State selectedEmoji: string = '🏃';
  @State customTaskList: CustomTaskDef[] = [];

  private readonly emojiOptions: string[] = ['🏃', '🧘', '📚', '💪', '🧠', '🎯', '🚴', '⚽', '🏊', '🍎',
    '💧', '☀️', '🌙', '❤️', '⭐', '🔥'];

  aboutToAppear() {
    this.loadTasks();
  }

  async loadTasks() {
    this.customTaskList = await getCustomTasks();
  }

  async doCreateTask() {
    if (!this.taskName || this.taskName.trim().length === 0) {
      promptAction.showToast({ message: '请输入任务名称', duration: 2000 });
      return;
    }
    if (!this.targetValue || this.targetValue.trim().length === 0) {
      promptAction.showToast({ message: '请输入目标值', duration: 2000 });
      return;
    }
    if (!this.unit || this.unit.trim().length === 0) {
      promptAction.showToast({ message: '请输入单位', duration: 2000 });
      return;
    }

    if (this.customTaskList.length >= getMaxCustomCount()) {
      promptAction.showToast({ message: `最多创建${getMaxCustomCount()}个自定义任务`, duration: 2000 });
      return;
    }

    const stepNum: number = parseFloat(this.step) || 1;
    const newTask: CustomTaskDef = {
      taskID: 0, // 由addCustomTask自动分配
      taskName: this.taskName.trim(),
      targetValue: this.targetValue.trim(),
      unit: this.unit.trim(),
      step: stepNum,
      icon: this.selectedEmoji
    };

    const ok: boolean = await addCustomTask(newTask);
    if (ok) {
      promptAction.showToast({ message: '创建成功！请到任务列表开启该任务', duration: 2000 });
      // 清空表单
      this.taskName = '';
      this.targetValue = '';
      this.unit = '';
      this.step = '1';
      await this.loadTasks();
    } else {
      promptAction.showToast({ message: '创建失败，已达上限', duration: 2000 });
    }
  }

  async doDeleteTask(taskID: number) {
    await deleteCustomTask(taskID);
    promptAction.showToast({ message: '已删除', duration: 1500 });
    await this.loadTasks();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor($r('app.color.blueColor'))
          .padding(12)
          .onClick(() => {
            router.back();
          });

        Blank();

        Text('自定义任务')
          .fontSize(18)
          .fontWeight(Const.FONT_WEIGHT_700)
          .fontColor($r('app.color.titleColor'));
        Blank();
        // 占位保持居中
        Row().width(60).height(1);
      }
      .width(Const.THOUSANDTH_1000)
      .padding({ top: 8, bottom: 8 });

      Scroll() {
        Column() {
          // === 创建表单 ===
          Column() {
            Text('创建新任务')
              .fontSize(16)
              .fontWeight(Const.FONT_WEIGHT_500)
              .fontColor($r('app.color.titleColor'))
              .width(Const.THOUSANDTH_1000)
              .padding({ left: 20, top: 16, bottom: 12 });

            // emoji选择
            Text('选择图标')
              .fontSize(13)
              .fontColor($r('app.color.tabTitleColor'))
              .width(Const.THOUSANDTH_1000)
              .padding({ left: 20, bottom: 8 });

            Row({ space: 6 }) {
              ForEach(this.emojiOptions, (emoji: string) => {
                Text(emoji)
                  .fontSize(22)
                  .padding(6)
                  .borderRadius(8)
                  .backgroundColor(this.selectedEmoji === emoji ? '#E3F2FD' : '#F5F5F5')
                  .border({ width: this.selectedEmoji === emoji ? 2 : 0, color: '#2196F3' })
                  .onClick(() => { this.selectedEmoji = emoji; });
              }, (emoji: string) => emoji);
            }
            .width(Const.THOUSANDTH_1000)
            .padding({ left: 20, right: 20, bottom: 12 });

            // 名称输入
            Row() {
              Text('任务名')
                .fontSize(14)
                .fontColor($r('app.color.titleColor'))
                .width(60);
              TextInput({ placeholder: '例如：瑜伽、冥想、阅读...', text: this.taskName })
                .fontSize(14)
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => { this.taskName = value; });
            }
            .width(Const.THOUSANDTH_1000)
            .padding({ left: 20, right: 20, bottom: 8 });

            // 目标值 + 单位
            Row() {
              Text('目标')
                .fontSize(14)
                .fontColor($r('app.color.titleColor'))
                .width(60);
              TextInput({ placeholder: '30', text: this.targetValue })
                .fontSize(14)
                .width(80)
                .height(40)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => { this.targetValue = value; });
              Text('单位')
                .fontSize(14)
                .fontColor($r('app.color.tabTitleColor'))
                .margin({ left: 12, right: 8 });
              TextInput({ placeholder: '分钟/页/组', text: this.unit })
                .fontSize(14)
                .width(80)
                .height(40)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => { this.unit = value; });
            }
            .width(Const.THOUSANDTH_1000)
            .padding({ left: 20, right: 20, bottom: 8 });

            // 每次步进
            Row() {
              Text('每次 +')
                .fontSize(14)
                .fontColor($r('app.color.titleColor'))
                .width(60);
              TextInput({ placeholder: '1', text: this.step })
                .fontSize(14)
                .width(80)
                .height(40)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => { this.step = value; });
            }
            .width(Const.THOUSANDTH_1000)
            .padding({ left: 20, right: 20, bottom: 16 });

            // 创建按钮
            Button('创建任务')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#2196F3')
              .width('90%')
              .height(44)
              .borderRadius(22)
              .onClick(() => { this.doCreateTask(); });
          }
          .width(Const.THOUSANDTH_1000)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 8, bottom: 12 });

          // === 已创建的自定义任务列表 ===
          if (this.customTaskList.length > 0) {
            Column() {
              Text(`已创建的个性任务 (${this.customTaskList.length}/${getMaxCustomCount()})`)
                .fontSize(14)
                .fontWeight(Const.FONT_WEIGHT_500)
                .fontColor($r('app.color.tabTitleColor'))
                .width(Const.THOUSANDTH_1000)
                .padding({ left: 20, top: 12, bottom: 8 });

              ForEach(this.customTaskList, (item: CustomTaskDef) => {
                Row() {
                  Text(item.icon)
                    .fontSize(22)
                    .margin({ right: 10 });
                  Column() {
                    Text(item.taskName)
                      .fontSize(15)
                      .fontWeight(Const.FONT_WEIGHT_500)
                      .fontColor($r('app.color.titleColor'));
                    Text(`目标: ${item.targetValue} ${item.unit}  |  每次+${item.step}`)
                      .fontSize(11)
                      .fontColor($r('app.color.tabTitleColor'))
                      .margin({ top: 2 });
                  }
                  .alignItems(HorizontalAlign.Start);
                  Blank();
                  Text('删除')
                    .fontSize(12)
                    .fontColor('#FF5252')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .border({ width: 1, color: '#FF5252' })
                    .borderRadius(12)
                    .onClick(() => { this.doDeleteTask(item.taskID); });
                }
                .width(Const.THOUSANDTH_1000)
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .alignItems(VerticalAlign.Center);
              }, (item: CustomTaskDef) => item.taskID.toString());

              Text('创建后请前往「任务列表」页面开启任务才能打卡')
                .fontSize(11)
                .fontColor($r('app.color.tabTitleColor'))
                .opacity(0.6)
                .width(Const.THOUSANDTH_1000)
                .padding({ left: 20, top: 4, bottom: 12 });
            }
            .width(Const.THOUSANDTH_1000)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 12, right: 12, bottom: 16 });
          }
        }
        .width(Const.THOUSANDTH_1000);
      }
      .width(Const.THOUSANDTH_1000)
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'));
  }
}
