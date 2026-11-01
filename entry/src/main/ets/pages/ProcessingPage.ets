/**
 * 检查中页（M2 空壳）。
 * M3 实现：分阶段进度（上传→识别→判题，mock 约 1.5s，可取消），
 * 阶段文案用任务语言，不出现"OCR"等实现层词汇（UX-U03）。
 */
@Component
export struct ProcessingPage {
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
    .title($r('app.string.page_title_processing'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}

@Builder
export function processingPageBuilder(name: string) {
  ProcessingPage()
}
