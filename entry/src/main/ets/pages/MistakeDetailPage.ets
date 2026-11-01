/**
 * 错题详情页（M2 空壳）。
 * M3 实现：首屏三方对照（原图裁片/识别答案/正确答案，UX-U07）、
 * 渐进披露（错因+提示默认可见，完整解析主动展开并埋点，UX-U12）、
 * 「下一道错题」连续浏览（UX-U06）、「识别有误？修正」入口占位（V0.2 开放）、
 * 「模拟数据」徽标常驻。
 */
@Component
export struct MistakeDetailPage {
  private pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text($r('app.string.page_placeholder'))
          .fontSize($r('app.float.font_size_body'))
          .fontColor($r('app.color.text_secondary'))
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.page_title_mistake_detail'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Builder
export function mistakeDetailPageBuilder(name: string) {
  MistakeDetailPage()
}
