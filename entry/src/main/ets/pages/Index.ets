import { promptAction } from '@kit.ArkUI';
import { AnalyticsEvent, EventLogger } from '../service/analytics/EventLogger';

/**
 * 首页（@Entry，Navigation 宿主）。
 * 信息架构（UX-U02）：单一主 CTA「检查作业」，错题本/历史为置灰占位入口，
 * 首页可预见产品长期结构。
 */
@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      Column({ space: 40 }) {
        Column({ space: 8 }) {
          Text($r('app.string.EntryAbility_label'))
            .fontSize($r('app.float.font_size_title'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('拍照检查 · 逐步辅导')
            .fontSize($r('app.float.font_size_caption'))
            .fontColor($r('app.color.text_secondary'))
        }

        Button($r('app.string.home_cta_check'))
          .width('72%')
          .height(56)
          .fontSize($r('app.float.font_size_body'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.cta_primary'))
          .onClick(() => {
            EventLogger.log(AnalyticsEvent.CAPTURE_START, new Map<string, string>());
            this.pathStack.pushPathByName('CapturePage', null);
          })

        Row({ space: 12 }) {
          Button($r('app.string.home_entry_mistake_book'))
            .placeholderEntryStyle()
            .onClick(() => this.showComingSoon())
          Button($r('app.string.home_entry_history'))
            .placeholderEntryStyle()
            .onClick(() => this.showComingSoon())
        }
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }

  private showComingSoon(): void {
    promptAction.showToast({ message: $r('app.string.home_coming_soon'), duration: 1500 });
  }
}

/** 置灰占位入口样式（后续版本开放）。 */
@Extend(Button)
function placeholderEntryStyle() {
  .backgroundColor($r('app.color.page_background'))
  .fontColor($r('app.color.text_secondary'))
  .fontSize($r('app.float.font_size_caption'))
  .height(40)
  .padding({ left: 20, right: 20 })
}
