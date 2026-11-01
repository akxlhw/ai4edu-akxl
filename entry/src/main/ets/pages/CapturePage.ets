/**
 * 拍摄页（M2 空壳）。
 * M3 实现：Camera Kit 预览 + 拍照存沙箱、相册 PhotoViewPicker、
 * 权限被拒引导视图（UX-U08）、取景引导线（UX-U10）。
 */
@Component
export struct CapturePage {
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
    .title($r('app.string.page_title_capture'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Builder
export function capturePageBuilder(name: string) {
  CapturePage()
}
