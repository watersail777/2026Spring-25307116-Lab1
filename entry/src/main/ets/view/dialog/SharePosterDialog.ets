/**
 * 成就分享海报弹窗
 * 每日全部任务完成后弹出，展示打卡成就海报
 */

import { CommonConstants as Const } from '../../common/constants/CommonConstants';
import { HomeStore } from '../../viewmodel/HomeViewModel';
import TaskInfo from '../../viewmodel/TaskInfo';
import { dateToStr, weekDateFormat } from '../../common/utils/Utils';
import GlobalInfoApi from '../../common/database/tables/GlobalInfoApi';
import GlobalInfo from '../../viewmodel/GlobalInfo';
import Logger from '../../common/utils/Logger';

@Component
export struct SharePosterContent {
  @Link homeStore: HomeStore;
  @State checkInDays: number = 0;
  @State achievedList: number[] = [];
  private readonly posterBg: string = '#FFFFFF';
  private readonly accentColor: string = '#FF6B6B';
  private readonly goldColor: string = '#FFD93D';

  aboutToAppear() {
    this.loadAchievementData();
  }

  loadAchievementData() {
    GlobalInfoApi.query((res: GlobalInfo) => {
      this.checkInDays = res.checkInDays || 0;
      if (res.achievements && res.achievements.length > 0) {
        const parts: string[] = res.achievements.split(',');
        const nums: number[] = [];
        for (let i: number = 0; i < parts.length; i++) {
          const n: number = parseInt(parts[i]);
          if (n > 0 && !isNaN(n)) {
            nums.push(n);
          }
        }
        nums.sort((a: number, b: number) => a - b);
        this.achievedList = nums;
      }
    });
  }

  build() {
    Column() {
      // === 海报主体 ===
      Column() {
        // 顶部装饰区域
        Row() {
          Text('✨')
            .fontSize(28)
            .margin({ right: 8 });
          Text('今日成就')
            .fontSize(22)
            .fontWeight(Const.FONT_WEIGHT_700)
            .fontColor('#FFFFFF')
            .fontFamily(Const.DEFAULT_2 === 2 ? '' : '');
        }
        .width(Const.THOUSANDTH_1000)
        .height(60)
        .justifyContent(FlexAlign.Center)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#FF6B6B', 0], ['#FF8E53', 1]]
        });

        // 日期
        Text(weekDateFormat(new Date().getTime()))
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 16, bottom: 4 });

        // 完成百分比（大字）
        Row() {
          Text('100')
            .fontSize(56)
            .fontWeight(Const.FONT_WEIGHT_900)
            .fontColor(this.accentColor)
            .fontFamily(Const.DEFAULT_2 === 2 ? '' : '');
          Text('%')
            .fontSize(24)
            .fontWeight(Const.FONT_WEIGHT_700)
            .fontColor(this.accentColor)
            .margin({ top: 20 });
        }.margin({ top: 4, bottom: 4 });

        // 完成状态文字
        Text('全部任务已完成 🎉')
          .fontSize(16)
          .fontWeight(Const.FONT_WEIGHT_500)
          .fontColor('#333333')
          .margin({ bottom: 16 });

        // 分隔线
        Divider()
          .color('#F0F0F0')
          .width('85%')
          .margin({ top: 4, bottom: 12 });

        // 已完成任务列表
        Column() {
          Text('今日打卡')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ bottom: 8 });

          if (this.homeStore && this.homeStore.getTaskListOfDay().length > 0) {
            ForEach(this.homeStore.getTaskListOfDay(), (task: TaskInfo) => {
              Row() {
                Text(task.isDone ? '✅' : '⬜')
                  .fontSize(16)
                  .margin({ right: 10 });
                Text(task.taskID ? this.getTaskName(task.taskID) : '')
                  .fontSize(14)
                  .fontColor(task.isDone ? '#333333' : '#CCCCCC')
                  .fontWeight(task.isDone ? Const.FONT_WEIGHT_500 : Const.FONT_WEIGHT_400);
              }
              .width('80%')
              .height(32)
              .justifyContent(FlexAlign.Start);
            }, (task: TaskInfo) => JSON.stringify(task));
          }
        }.width(Const.THOUSANDTH_1000)
        .alignItems(HorizontalAlign.Center);

        // 连续打卡天数徽章
        if (this.checkInDays > 0) {
          Row() {
            Text('🔥')
              .fontSize(20)
              .margin({ right: 8 });
            Text('连续打卡 ')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(Const.FONT_WEIGHT_500);
            Text(`${this.checkInDays}`)
              .fontSize(24)
              .fontWeight(Const.FONT_WEIGHT_900)
              .fontColor(this.goldColor);
            Text(' 天')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(Const.FONT_WEIGHT_500);
          }
          .height(48)
          .padding({ left: 20, right: 20 })
          .borderRadius(24)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#4A90D9', 0], ['#357ABD', 1]]
          })
          .margin({ top: 16, bottom: 8 });
        }

        // 成就勋章行
        if (this.achievedList.length > 0) {
          Row({ space: 8 }) {
            Text('🏅')
              .fontSize(16);
            Text('已获成就：')
              .fontSize(13)
              .fontColor('#999999');
            ForEach(this.achievedList, (level: number) => {
              Text(`${level}天`)
                .fontSize(11)
                .fontColor('#FF6B6B')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('#FFF0F0')
                .borderRadius(8);
            }, (level: number) => level.toString());
          }
          .margin({ top: 8, bottom: 16 });
        }

        // 底部品牌
        Text('—— 健康生活 · Healthy Life ——')
          .fontSize(11)
          .fontColor('#CCCCCC')
          .margin({ top: 8, bottom: 16 });

      }
      .width('92%')
      .backgroundColor(this.posterBg)
      .borderRadius(16)
      .shadow({ radius: 12, color: '#00000015', offsetX: 0, offsetY: 4 });
    }
    .width(Const.THOUSANDTH_1000)
    .padding({ top: 12, bottom: 12 })
    .alignItems(HorizontalAlign.Center);
  }

  private getTaskName(taskID: number): string {
    const names: string[] = ['', '早起', '喝水', '吃苹果', '每日微笑', '每日刷牙', '早睡', '跑步'];
    return taskID >= 1 && taskID <= 7 ? names[taskID] : '未知任务';
  }
}

@CustomDialog
export struct SharePosterDialog {
  controller: CustomDialogController;
  @Link homeStore: HomeStore;

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('打卡成就')
          .fontSize(18)
          .fontWeight(Const.FONT_WEIGHT_700)
          .fontColor('#333333');

        Blank();

        // 关闭按钮
        Text('✕')
          .fontSize(18)
          .fontColor('#999999')
          .padding(8)
          .onClick(() => {
            this.controller.close();
          });
      }
      .width('92%')
      .padding({ top: 16, bottom: 8 });

      // 海报内容
      SharePosterContent({ homeStore: $homeStore });

      // 底部按钮
      Row({ space: 12 }) {
        Button('关闭')
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .width('40%')
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.controller.close();
          });

        Button('分享成就 ✨')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B6B')
          .width('50%')
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.controller.close();
          });
      }
      .width('92%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 12, bottom: 16 });
    }
    .width(Const.THOUSANDTH_1000)
    .backgroundColor('#F8F8F8')
    .borderRadius({ topLeft: 20, topRight: 20 });
  }
}
