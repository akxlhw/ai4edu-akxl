/**
 * 预检页（M2 空壳）。
 * M3 实现：自动检测建议框（默认直接确认）+ 完整裁切交互
 * （四角手柄/三等分网格/比例约束）、重置/重拍、<60% 裁切过小警示（UX-U01/U09）。
 */
@Component
export struct CropPage {
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
    .title($r('app.string.page_title_crop'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Builder
export function cropPageBuilder(name: string) {
  CropPage()
}
