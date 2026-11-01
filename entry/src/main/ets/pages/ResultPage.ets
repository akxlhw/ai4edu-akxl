/**
 * 结果页（M2 空壳）。
 * M3 实现：小结条（对X·错Y·待确认Z）、原图四态标注（颜色+图标+文案三重编码，
 * UX-U04）、图↔列表双向联动（UX-U11）、UNREADABLE 重新拍这题（UX-U05）、
 * 完成态横幅（UX-U06）、「模拟数据」徽标（UX-U14）。
 * 返回行为：本页起为结果阶段，返回直接回首页（设计 3.1）。
 */
@Component
export struct ResultPage {
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
    .title($r('app.string.page_title_result'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Builder
export function resultPageBuilder(name: string) {
  ResultPage()
}
