/**
 * 每日健康知识卡片组件
 * 在首页展示随机健康冷知识，支持展开/收起
 *
 * 集成方式：在 HomeComponent 的 Scroll 中 HomeTopView 之后插入
 */

import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { KnowledgeItem } from '../model/KnowledgeData';

@Component
export default struct KnowledgeCard {
  @Prop knowledge: KnowledgeItem = { title: '', content: '', category: '' };
  @State isExpanded: boolean = false;

  build() {
    Column() {
      // 卡片头部：图标 + 标题行
      Row() {
        // 灯泡图标占位
        Text('💡')
          .fontSize(20)
          .margin({ right: 8 });

        // 标题
        Text(this.knowledge.title)
          .fontSize($r('app.float.default_16'))
          .fontWeight(Const.FONT_WEIGHT_700)
          .fontColor($r('app.color.titleColor'))
          .fontFamily($r('app.string.HarmonyHeiTi_Medium'))
          .layoutWeight(1)
          .maxLines(this.isExpanded ? 10 : 1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        // 展开/收起箭头
        Text(this.isExpanded ? '▲' : '▼')
          .fontSize(12)
          .fontColor($r('app.color.tabTitleColor'))
          .margin({ left: 8 });
      }
      .width(Const.THOUSANDTH_1000)
      .alignItems(VerticalAlign.Center)
      .padding({
        top: 12,
        bottom: this.isExpanded ? 0 : 12
      });

      // 展开后显示正文和分类
      if (this.isExpanded) {
        Column() {
          // 分隔线
          Divider()
            .color($r('app.color.primaryBgColor'))
            .width(Const.THOUSANDTH_1000)
            .margin({ top: 12, bottom: 12 });

          // 正文
          Text(this.knowledge.content)
            .fontSize($r('app.float.default_14'))
            .fontColor($r('app.color.titleColor'))
            .opacity(0.8)
            .lineHeight(22)
            .width(Const.THOUSANDTH_1000)
            .padding({ bottom: 12 });

          // 底部分类标签
          Row() {
            Text(this.knowledge.category)
              .fontSize($r('app.float.default_10'))
              .fontColor($r('app.color.blueColor'))
              .padding({
                left: 10,
                right: 10,
                top: 3,
                bottom: 3
              })
              .backgroundColor('#EBF5FF')
              .borderRadius(10);
          }
          .width(Const.THOUSANDTH_1000)
          .justifyContent(FlexAlign.Start)
          .padding({ bottom: 12 });
        }
        .width(Const.THOUSANDTH_1000);
      }
    }
    .width(Const.THOUSANDTH_1000)
    .padding({
      left: $r('app.float.default_16'),
      right: $r('app.float.default_16')
    })
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.float.default_12'))
    .margin({
      left: $r('app.float.default_16'),
      right: $r('app.float.default_16'),
      bottom: $r('app.float.default_12')
    })
    .onClick(() => {
      this.isExpanded = !this.isExpanded;
    });
  }
}
