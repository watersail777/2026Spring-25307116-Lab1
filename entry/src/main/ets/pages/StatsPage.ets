/**
 * 统计页面
 * 展示打卡数据统计：柱状图 + 汇总卡片
 */

import { CommonConstants as Const } from '../common/constants/CommonConstants';
import ChartComponent from '../view/ChartComponent';
import { StatsData, DayStats, queryWeekStats } from '../viewmodel/StatsViewModel';
import Logger from '../common/utils/Logger';

@Component
export struct StatsIndex {
  @State statsData: StatsData = new StatsData([], {
    totalCheckInDays: 0, currentStreak: 0, bestStreak: 0, achievedCount: 0
  });
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadData();
  }

  onPageShow() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      const data = await queryWeekStats();
      this.statsData = data;
    } catch (err) {
      Logger.error('StatsPage', 'Failed to load stats data');
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color($r('app.color.blueColor'));
          Text('加载统计数据...')
            .fontSize(14)
            .fontColor($r('app.color.tabTitleColor'))
            .margin({ top: 12 });
        }
        .width(Const.FULL_WIDTH)
        .height(Const.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column() {
            // 页面标题
            Text('打卡统计')
              .fontSize(24)
              .fontWeight(Const.FONT_WEIGHT_700)
              .fontColor($r('app.color.titleColor'))
              .fontFamily($r('app.string.HarmonyHeiTi_Medium'))
              .padding({
                left: $r('app.float.default_16'),
                top: $r('app.float.default_16'),
                bottom: $r('app.float.default_4')
              })
              .width(Const.THOUSANDTH_1000);

            // 汇总统计卡片
            this.summaryCards();

            // 柱状图
            Column() {
              ChartComponent({ dayStatsList: this.statsData.dayStatsList });
            }
            .width(Const.THOUSANDTH_1000)
            .backgroundColor($r('app.color.white'))
            .borderRadius($r('app.float.default_12'))
            .margin({
              left: $r('app.float.default_16'),
              right: $r('app.float.default_16'),
              top: $r('app.float.default_16'),
              bottom: $r('app.float.default_12')
            })
            .padding({ top: 4, bottom: 12 });

            // 每日详情列表
            Text('每日详情')
              .fontSize(16)
              .fontWeight(Const.FONT_WEIGHT_500)
              .fontColor($r('app.color.titleColor'))
              .padding({ left: $r('app.float.default_24'), top: 8, bottom: 8 })
              .width(Const.THOUSANDTH_1000);

            ForEach(this.statsData.dayStatsList, (item: DayStats, index: number) => {
              this.dayDetailRow(item, index);
            }, (item: DayStats) => item.date);
          }
          .width(Const.THOUSANDTH_1000);
        }
        .scrollBar(BarState.Off)
        .width(Const.THOUSANDTH_1000)
        .height(Const.THOUSANDTH_1000);
      }
    }
    .width(Const.FULL_WIDTH)
    .height(Const.FULL_HEIGHT)
    .backgroundColor($r('app.color.primaryBgColor'));
  }

  @Builder
  summaryCards() {
    Row() {
      // 累计打卡天数
      this.summaryCard(
        `${this.statsData.summary.totalCheckInDays}`,
        '累计打卡(天)',
        '#42A5F5'
      );
      // 当前连续天数
      this.summaryCard(
        `${this.statsData.summary.currentStreak}`,
        '当前连续(天)',
        '#66BB6A'
      );
      // 历史最佳
      this.summaryCard(
        `${this.statsData.summary.bestStreak}`,
        '历史最佳(天)',
        '#FFA726'
      );
      // 已获成就
      this.summaryCard(
        `${this.statsData.summary.achievedCount}`,
        '已获成就',
        '#AB47BC'
      );
    }
    .width(Const.THOUSANDTH_1000)
    .padding({ left: $r('app.float.default_8'), right: $r('app.float.default_8') })
    .justifyContent(FlexAlign.SpaceEvenly);
  }

  @Builder
  summaryCard(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(28)
        .fontWeight(Const.FONT_WEIGHT_700)
        .fontColor(color)
        .fontFamily($r('app.string.HarmonyHeiTi_Bold'));
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.tabTitleColor'))
        .margin({ top: 4 });
    }
    .width('22%')
    .height(70)
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.float.default_12'))
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });
  }

  @Builder
  dayDetailRow(item: DayStats, index: number) {
    Row() {
      // 星期 + 日期
      Column() {
        Text(item.dayLabel)
          .fontSize(14)
          .fontWeight(item.isToday ? Const.FONT_WEIGHT_700 : Const.FONT_WEIGHT_400)
          .fontColor(item.isToday ? $r('app.color.blueColor') : $r('app.color.titleColor'));
        Text(item.date)
          .fontSize(10)
          .fontColor($r('app.color.tabTitleColor'))
          .margin({ top: 2 });
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: $r('app.float.default_24') });

      Blank();

      // 完成进度条
      Row() {
        // 进度条背景
        Stack() {
          // 底部灰条
          Row()
            .width(120)
            .height(8)
            .backgroundColor('#F0F0F0')
            .borderRadius(4);

          // 实际进度
          Row()
            .width(`${item.percent}%`)
            .height(8)
            .backgroundColor(item.percent >= 100 ? '#66BB6A' : (item.isToday ? '#42A5F5' : '#90CAF9'))
            .borderRadius(4);
        };

        Text(`${item.percent}%`)
          .fontSize(13)
          .fontWeight(Const.FONT_WEIGHT_500)
          .fontColor(item.percent >= 100 ? '#66BB6A' : '#666666')
          .width(36)
          .textAlign(TextAlign.End)
          .margin({ left: 8 });
      };

      // 打卡状态图标
      Text(item.percent >= 100 ? '✅' : (item.finishNum > 0 ? '🔄' : '⬜'))
        .fontSize(16)
        .margin({ left: 12, right: $r('app.float.default_24') });
    }
    .width(Const.THOUSANDTH_1000)
    .height(56)
    .backgroundColor(item.isToday ? `${$r('app.color.blueColor')}08` : $r('app.color.white'))
    .borderRadius(0)
    .margin({ bottom: 1 });
  }
}
